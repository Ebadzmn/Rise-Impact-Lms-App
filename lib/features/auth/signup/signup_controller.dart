import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_riseandimpact/routes/app_router.dart';
import '../../../routes/app_routes.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final RxString gender = 'male'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;


  // Validation States
  final RxBool isNameValid = false.obs;
  final RxBool isEmailValid = false.obs;
  final RxBool isDobValid = false.obs;
  final RxBool isPasswordValid = false.obs;


  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }



  void onNameChanged(String val) {
    isNameValid.value = val.isNotEmpty;
  }

  void onEmailChanged(String val) {
    isEmailValid.value = GetUtils.isEmail(val);
  }

  void onGenderChanged(String? val) {
    if (val != null) {
      gender.value = val;
    }
  }

  void onDobChanged(String val) {
    isDobValid.value = val.isNotEmpty;
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      dobController.text = formattedDate;
      onDobChanged(formattedDate);
    }
  }

  void onPasswordChanged(String val) {
    isPasswordValid.value = val.length >= 6;
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

  String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
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



  Future<void> signup() async {
    if (formKey.currentState?.validate() ?? false) {

      try {
        isLoading.value = true;

        await ApiClient.instance.post(
          ApiEndpoints.signup,
          body: {
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "password": passwordController.text,
            "gender": gender.value,
            "dateOfBirth": dobController.text,
          },
        );

        Get.snackbar('Success', 'Registration successful');
        AppRouter.router.push('${AppRoutes.otp}?email=${emailController.text}');
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
    dobController.dispose();
    super.onClose();
  }
}
