import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  
  final RxBool isLoading = false.obs;
  final RxBool isOtpComplete = false.obs;
  final RxBool isResending = false.obs;
  final RxInt resendTimer = 0.obs;
  Timer? _timer;

  void onOtpComplete(String otp) {
    isOtpComplete.value = otp.length == 6;
  }

  Future<void> verifyOtp(String email) async {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;

      await ApiClient.instance.post(
        ApiEndpoints.verifyOtp,
        body: {
          "email": email,
          "oneTimeCode": int.tryParse(otpController.text) ?? 0,
        },
      );

      Get.snackbar('Success', 'Email verified successfully');
      AppRouter.router.go(AppRoutes.login);
      
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      isLoading.value = false;
    }
  }

  void startResendTimer() {
    resendTimer.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp(String email) async {
    if (resendTimer.value > 0 || isResending.value) return;

    try {
      isResending.value = true;
      await ApiClient.instance.post(
        ApiEndpoints.resendVerifyEmail,
        body: {"email": email},
      );

      Get.snackbar('Success', 'Verification code has been resent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF576045), // Sage Green
          colorText: Colors.white);
      
      startResendTimer();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
