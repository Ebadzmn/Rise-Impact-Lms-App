import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/app_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  String? resetToken;

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> sendOtp(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await ApiClient.instance.post(
          ApiEndpoints.forgetPassword,
          body: {
            "email": emailController.text.trim(),
          },
        );

        Get.snackbar('Success', 'Please check your email. We have sent you a one-time passcode (OTP).',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
            
        // Navigate to OTP page
        AppRouter.router.push(AppRoutes.forgotPasswordOtp);
      } catch (e) {
        Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to send OTP',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length == 6) {
      isLoading.value = true;
      try {
        final response = await ApiClient.instance.post(
          ApiEndpoints.verifyOtp,
          body: {
            "email": emailController.text.trim(),
            "oneTimeCode": otpController.text.trim(),
          },
        );

        // Save reset token
        final result = response.data;
        if (result != null && result['data'] != null && result['data']['resetToken'] != null) {
          resetToken = result['data']['resetToken'];
        } else if (result != null && result['resetToken'] != null) {
          resetToken = result['resetToken'];
        }

        if (resetToken == null) {
           throw Exception("Reset token not found in response.");
        }

        Get.snackbar('Success', 'Verification successful',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
            
        // Navigate to Reset Password page
        AppRouter.router.pushReplacement(AppRoutes.resetPassword);
      } catch (e) {
        Get.snackbar('Error', e is NetworkException ? e.message : 'Invalid OTP',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  Future<void> resetPassword(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      if (resetToken == null) {
         Get.snackbar('Error', 'Reset token missing. Please verify OTP again.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
         return;
      }

      isLoading.value = true;
      try {
        await ApiClient.instance.post(
          ApiEndpoints.resetPassword,
          body: {
            "token": resetToken,
            "newPassword": newPasswordController.text,
            "confirmPassword": confirmPasswordController.text,
          },
        );

        Get.snackbar('Success', 'Password reset successful',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
            
        // Go back to login
        AppRouter.router.go(AppRoutes.login);
      } catch (e) {
        Get.snackbar('Error', e is NetworkException ? e.message : 'Reset failed',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }
}
