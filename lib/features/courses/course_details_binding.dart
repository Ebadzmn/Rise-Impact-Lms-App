import 'package:get/get.dart';
import 'course_details_controller.dart';

class CourseDetailsBinding extends Bindings {
  final String identifier;

  CourseDetailsBinding({required this.identifier});

  @override
  void dependencies() {
    // We use Get.put or Get.lazyPut with the dynamic identifier
    Get.lazyPut(() => CourseDetailsController(identifier: identifier), tag: identifier);
  }
}
