import 'package:get/get.dart';

class ProgressController extends GetxController {
  var selectedTab = 0.obs;

  void switchTab(int index) {
    selectedTab.value = index;
  }
}
