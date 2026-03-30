import 'package:get/get.dart';
import 'quiz_controller.dart';

class QuizBinding extends Bindings {
  final String quizId;

  QuizBinding({required this.quizId});

  @override
  void dependencies() {
    Get.lazyPut(() => QuizController(quizId: quizId), tag: quizId);
  }
}
