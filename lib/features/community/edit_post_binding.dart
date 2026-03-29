import 'package:get/get.dart';
import 'controllers/edit_post_controller.dart';
import 'models/post_model.dart';

class EditPostBinding extends Bindings {
  final PostModel post;
  
  EditPostBinding({required this.post});

  @override
  void dependencies() {
    Get.lazyPut(() => EditPostController(initialPost: post));
  }
}
