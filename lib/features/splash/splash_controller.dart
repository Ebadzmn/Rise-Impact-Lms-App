import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    // TODO: Check auth status and navigate accordingly
    // For now, go to welcome
    AppRouter.router.go(AppRoutes.welcome);
  }
}
