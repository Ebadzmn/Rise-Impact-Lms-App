import 'package:get/get.dart';
import 'controllers/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CommunityController>()) {
      Get.put<CommunityController>(CommunityController());
    }
  }
}
