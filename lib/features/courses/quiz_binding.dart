import 'package:get/get.dart';
import 'quiz_controller.dart';

class QuizBinding extends Bindings {
  final String quizId;
  final String? courseId;
  final String? lessonId;
  final String? courseSlug;
  final String? initialAttemptId;

  QuizBinding({
    required this.quizId,
    this.courseId,
    this.lessonId,
    this.courseSlug,
    this.initialAttemptId,
  });

  @override
  void dependencies() {
    Get.lazyPut(
      () => QuizController(
        quizId: quizId,
        courseId: courseId,
        lessonId: lessonId,
        courseSlug: courseSlug,
        initialAttemptId: initialAttemptId,
      ),
      tag: quizId,
    );
  }
}
