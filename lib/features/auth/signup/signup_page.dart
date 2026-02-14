import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_app_bar.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Create Account'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.spa, // Placeholder for Rise & Impact logo
                        size: 40,
                        color: Color(0xFFD88B2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Join Rise & Impact',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Start your journey to mastering life skills',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  Obx(
                    () => CustomTextField(
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                      controller: controller.nameController,
                      validator: controller.validateName,
                      onChanged: controller.onNameChanged,
                      showSuccessState: controller.isNameValid.value,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  Obx(
                    () => CustomTextField(
                      label: 'Email Address *',
                      hint: 'you@example.com',
                      controller: controller.emailController,
                      validator: controller.validateEmail,
                      onChanged: controller.onEmailChanged,
                      showSuccessState: controller.isEmailValid.value,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Age
                  Obx(
                    () => CustomTextField(
                      label: 'Age (16-22) *',
                      hint: 'Enter your age',
                      controller: controller.ageController,
                      validator: controller.validateAge,
                      onChanged: controller.onAgeChanged,
                      showSuccessState: controller.isAgeValid.value,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  Obx(
                    () => CustomTextField(
                      label: 'Password *',
                      hint: 'Create a password',
                      controller: controller.passwordController,
                      validator: controller.validatePassword,
                      onChanged: controller.onPasswordChanged,
                      showSuccessState: controller.isPasswordValid.value,
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  Obx(
                    () => CustomTextField(
                      label: 'Confirm Password *',
                      hint: 'Confirm your password',
                      controller: controller.confirmPasswordController,
                      validator: controller.validateConfirmPassword,
                      onChanged: controller.onConfirmPasswordChanged,
                      showSuccessState: controller.isConfirmPasswordValid.value,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD88B2F), // Mustard
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFD88B2F).withOpacity(0.4),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color(0xFF576045), // Sage Green
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
