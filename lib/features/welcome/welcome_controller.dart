import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';

class WelcomeController extends GetxController {
  void navigateToLogin() {
    AppRouter.router.push(AppRoutes.login);
  }

  void navigateToSignUp() {
    AppRouter.router.push(AppRoutes.signup);
  }
}
