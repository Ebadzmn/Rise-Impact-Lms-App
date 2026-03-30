import 'package:get/get.dart';
import 'lesson_controller.dart';

class LessonBinding extends Bindings {
  final String courseId;
  final String lessonId;

  LessonBinding({required this.courseId, required this.lessonId});

  @override
  void dependencies() {
    Get.lazyPut(() => LessonController(courseId: courseId, lessonId: lessonId), 
    tag: '${courseId}_${lessonId}');
  }
}
