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

  void resendOtp() {
    Get.snackbar('Success', 'OTP sent again.');
  }

  @override
  void onClose() {
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
