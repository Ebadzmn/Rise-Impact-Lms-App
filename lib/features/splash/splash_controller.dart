import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';
import '../../core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final storage = Get.find<StorageService>();
    final token = storage.getToken();

    if (token != null && token.isNotEmpty) {
      AppRouter.router.go(AppRoutes.topics);
    } else {
      AppRouter.router.go(AppRoutes.welcome);
    }
  }
}
