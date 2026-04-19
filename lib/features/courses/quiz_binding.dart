import 'package:get/get.dart';
import 'quiz_controller.dart';

class QuizBinding extends Bindings {
  final String quizId;
  final String? courseId;
  final String? lessonId;
  final String? courseSlug;

  QuizBinding({
    required this.quizId,
    this.courseId,
    this.lessonId,
    this.courseSlug,
  });

  @override
  void dependencies() {
    Get.lazyPut(
      () => QuizController(
        quizId: quizId,
        courseId: courseId,
        lessonId: lessonId,
        courseSlug: courseSlug,
      ),
      tag: quizId,
    );
  }
}
