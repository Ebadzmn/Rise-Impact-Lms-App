import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../features/profile/profile_model.dart';
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
      try {
        final response = await ApiClient.instance.get(ApiEndpoints.profile);

        Map<String, dynamic> responseMap = {};
        if (response.data is String) {
          responseMap = jsonDecode(response.data) as Map<String, dynamic>;
        } else if (response.data is Map) {
          responseMap = Map<String, dynamic>.from(response.data);
        }

        final profile = ProfileModel.fromJson(responseMap);
        if (profile.onboardingCompleted) {
          AppRouter.router.go(AppRoutes.home);
        } else {
          AppRouter.router.go(AppRoutes.topics);
        }
      } catch (e, stack) {
        debugPrint('Splash profile check failed: $e\n$stack');
        AppRouter.router.go(AppRoutes.topics);
      }
    } else {
      AppRouter.router.go(AppRoutes.welcome);
    }
  }
}
