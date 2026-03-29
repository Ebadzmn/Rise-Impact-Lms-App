import 'package:get/get.dart';
import 'controllers/post_details_controller.dart';

class PostDetailsBinding extends Bindings {
  final String postId;

  PostDetailsBinding({required this.postId});

  @override
  void dependencies() {
    Get.delete<PostDetailsController>();
    Get.lazyPut<PostDetailsController>(() => PostDetailsController(postId: postId));
  }
}
