import 'dart:async';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/quiz_model.dart';
import 'course_details_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/app_router.dart';

class QuizController extends GetxController {
  final ApiClient _api = ApiClient.instance;
  final String quizId;
  final String? courseId;
  final String? lessonId;
  final String? courseSlug;

  QuizController({
    required this.quizId,
    this.courseId,
    this.lessonId,
    this.courseSlug,
  });

  // State Variables
  final RxBool isLoading = true.obs;
  final RxString attemptId = ''.obs;
  final RxList<QuizQuestionModel> questions = <QuizQuestionModel>[].obs;
  final RxMap<String, String> selectedAnswers = <String, String>{}.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt timeLeft = 0.obs; // In seconds
  final RxBool isSubmitting = false.obs;
  final Rxn<QuizResultModel> quizResult = Rxn<QuizResultModel>();
  
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startQuizFlow();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> startQuizFlow() async {
    isLoading.value = true;
    try {
      // 1. Start Attempt
      final attemptRes = await _api.post(
        ApiEndpoints.startQuizAttempt.replaceFirst(':quizId', quizId),
        body: {'quizId': quizId},
      );
      
      final attemptData = attemptRes.data['data'] ?? attemptRes.data;
      attemptId.value = attemptData['_id']?.toString() ?? attemptData['id']?.toString() ?? '';
      
      // 2. Load Questions
      final questionsRes = await _api.get(
        ApiEndpoints.getQuizQuestions.replaceFirst(':quizId', quizId),
      );
      
      final data = questionsRes.data['data'] ?? questionsRes.data;
      
      // DEBUG LOGGING
      if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
        final firstQ = data['questions'][0];
        print('QUIZ DEBUG: First Q: ${firstQ['title'] ?? firstQ['text'] ?? firstQ['question']}');
        if (firstQ['options'] != null && (firstQ['options'] as List).isNotEmpty) {
          print('QUIZ DEBUG: First Option keys: ${firstQ['options'][0].keys}');
        }
      }

      final qList = (data['questions'] as List?)?.map((e) => QuizQuestionModel.fromJson(e)).toList() ?? [];
      questions.assignAll(qList);

      // 3. Setup Timer if available
      final timeLimitMinutes = data['settings']?['timeLimit'] as int?;
      if (timeLimitMinutes != null && timeLimitMinutes > 0) {
        startTimer(timeLimitMinutes);
      }

    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      // Handle Already Attempted logic if needed
      if (e.toString().contains('already attempted')) {
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void startTimer(int minutes) {
    timeLeft.value = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timer?.cancel();
        submitQuiz(); // Auto submit
      }
    });
  }

  void selectOption(String questionId, String optionId) {
    selectedAnswers[questionId] = optionId;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  Future<void> submitQuiz() async {
    if (isSubmitting.value) return;
    if (attemptId.value.isEmpty) {
      Get.snackbar('Submission Failed', 'Invalid quiz attempt. Please restart the quiz.');
      return;
    }

    isSubmitting.value = true;
    try {
      // Unanswered questions are omitted intentionally.
      final answersList = selectedAnswers.entries
          .where((e) => e.key.isNotEmpty && e.value.isNotEmpty)
          .map((e) => {
                'questionId': e.key,
                'selectedOptionId': e.value,
              })
          .toList();

      final res = await _api.patch(
        ApiEndpoints.submitQuizAttempt.replaceFirst(':attemptId', attemptId.value),
        body: {'answers': answersList},
      );

      final result = QuizResultModel.fromJson(res.data);
      quizResult.value = result;

      if (result.passed) {
        await _markLessonCompleteAfterPass();
      }
      
      // Navigate to Result Page
      AppRouter.router.pushNamed(AppRoutes.quizResult, extra: result);

    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('time limit')) {
        Get.snackbar('Time Limit', 'Time limit exceeded');
      } else {
        Get.snackbar('Submission Failed', 'Failed to submit quiz');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _markLessonCompleteAfterPass() async {
    final cId = courseId;
    final lId = lessonId;
    if (cId == null || cId.isEmpty || lId == null || lId.isEmpty) return;

    try {
      final endpoint = ApiEndpoints.markLessonComplete
          .replaceFirst(':courseId', cId)
          .replaceFirst(':lessonId', lId);

      final response = await _api.post(endpoint);
      final data = response.data['data'] ?? response.data;
      final completionPercentage = data['completionPercentage'] is int
          ? data['completionPercentage'] as int
          : int.tryParse(data['completionPercentage']?.toString() ?? '');

      final slug = courseSlug;
      if (slug != null && slug.isNotEmpty && Get.isRegistered<CourseDetailsController>(tag: slug)) {
        final detailsController = Get.find<CourseDetailsController>(tag: slug);
        detailsController.applyLessonCompletionLocally(
          lessonId: lId,
          completionPercentage: completionPercentage,
        );
      }
    } catch (_) {
      // Keep result flow working even if completion update fails.
    }
  }
}
