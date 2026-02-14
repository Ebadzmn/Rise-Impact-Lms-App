import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_riseandimpact/routes/app_router.dart';
import '../../../routes/app_routes.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Validation States
  final RxBool isNameValid = false.obs;
  final RxBool isEmailValid = false.obs;
  final RxBool isAgeValid = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isConfirmPasswordValid = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void onNameChanged(String val) {
    isNameValid.value = val.isNotEmpty;
  }

  void onEmailChanged(String val) {
    isEmailValid.value = GetUtils.isEmail(val);
  }

  void onAgeChanged(String val) {
    final age = int.tryParse(val);
    isAgeValid.value = age != null && age >= 16 && age <= 22;
  }

  void onPasswordChanged(String val) {
    isPasswordValid.value = val.length >= 6;
    // Also re-validate confirm password if it has value
    if (confirmPasswordController.text.isNotEmpty) {
      onConfirmPasswordChanged(confirmPasswordController.text);
    }
  }

  void onConfirmPasswordChanged(String val) {
    isConfirmPasswordValid.value =
        val.isNotEmpty && val == passwordController.text;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full Name is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Address is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 16 || age > 22) {
      return 'Age must be between 16 and 22';
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signup() async {
    if (formKey.currentState?.validate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      try {
        isLoading.value = true;

        // TODO: Implement actual signup API call
        await Future.delayed(const Duration(seconds: 2));

        AppRouter.router.go(AppRoutes.topics);
      } catch (e) {
        Get.snackbar('Error', 'Signup failed. Please try again.');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
