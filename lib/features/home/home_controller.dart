import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;

      // TODO: Load initial data
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    // TODO: Clear user session
    Get.offAllNamed(AppRoutes.login);
  }
}
