import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_riseandimpact/routes/app_router.dart';
import '../../../routes/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../notifications/notifications_controller.dart';
import '../../profile/profile_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        final notificationService = Get.find<NotificationService>();
        final deviceToken = await notificationService.ensureToken();

        if (deviceToken == null || deviceToken.isEmpty) {
          Get.snackbar(
            'Notification setup incomplete',
            'FCM token is unavailable. Enable notifications and try again.',
          );
          return;
        }

        final response = await ApiClient.instance.post(
          ApiEndpoints.login,
          body: {
            "email": emailController.text.trim(),
            "password": passwordController.text,
            "deviceToken": deviceToken,
          },
        );

        Map<String, dynamic> responseMap = {};
        if (response.data is String) {
          try {
            responseMap = jsonDecode(response.data) as Map<String, dynamic>;
          } catch (_) {}
        } else if (response.data is Map) {
          responseMap = Map<String, dynamic>.from(response.data);
        }

        Map<String, dynamic> payload = responseMap;
        if (responseMap.containsKey('data') && responseMap['data'] is Map) {
          payload = Map<String, dynamic>.from(responseMap['data']);
        }

        final accessToken = payload['accessToken']?.toString();
        final refreshToken = payload['refreshToken']?.toString();

        if (accessToken != null &&
            refreshToken != null &&
            accessToken.isNotEmpty) {
          final storage = Get.find<StorageService>();
          storage.saveTokens(accessToken, refreshToken);

          if (Get.isRegistered<NotificationsController>()) {
            await Get.find<NotificationsController>().refreshNotifications();
          }

          // Fetch profile to check onboarding status
          try {
            final profileController = Get.put(ProfileController());
            await profileController.fetchData();

            final onboardingCompleted =
                profileController.profileData.value?.onboardingCompleted ??
                false;

            if (onboardingCompleted) {
              AppRouter.router.go(AppRoutes.home);
            } else {
              AppRouter.router.go(AppRoutes.topics);
            }
          } catch (e) {
            debugPrint('Post-Login Profile Fetch Error: $e');
            AppRouter.router.go(AppRoutes.topics);
          }
        } else {
          debugPrint(
            'Login Token Error: Expected tokens not found in payload: $payload',
          );
          Get.snackbar('Error', 'Invalid response from server');
        }
      } catch (e, stack) {
        debugPrint('Login Exception: $e\n$stack');
        Get.snackbar(
          'Error',
          e is NetworkException ? e.message : 'Login failed. Please try again.',
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
