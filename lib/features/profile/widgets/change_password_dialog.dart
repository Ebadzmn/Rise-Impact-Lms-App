import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile_controller.dart';

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF576045), // Sage Green from app theme
              ),
            ),
            const SizedBox(height: 24),
            
            _buildLabel('Current Password'),
            Obx(() => _buildTextField(
                  controller.oldPasswordController,
                  'Enter current password',
                  isObscure: !controller.isOldPasswordVisible.value,
                  suffix: IconButton(
                    icon: Icon(
                      controller.isOldPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.toggleOldPasswordVisibility,
                  ),
                )),
            const SizedBox(height: 16),

            _buildLabel('New Password'),
            Obx(() => _buildTextField(
                  controller.newPasswordController,
                  'Enter new password',
                  isObscure: !controller.isNewPasswordVisible.value,
                  suffix: IconButton(
                    icon: Icon(
                      controller.isNewPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.toggleNewPasswordVisibility,
                  ),
                )),
            const SizedBox(height: 16),

            _buildLabel('Confirm Password'),
            Obx(() => _buildTextField(
                  controller.confirmPasswordController,
                  'Confirm new password',
                  isObscure: !controller.isConfirmPasswordVisible.value,
                  suffix: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                )),
            const SizedBox(height: 32),

            // Button Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9ECEF),
                      foregroundColor: const Color(0xFF2C3E50),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isChangingPassword.value
                        ? null
                        : () {
                            final oldP = controller.oldPasswordController.text.trim();
                            final newP = controller.newPasswordController.text.trim();
                            final confirmP = controller.confirmPasswordController.text.trim();

                            if (oldP.isEmpty || newP.isEmpty) {
                              Get.snackbar('Error', 'Fields cannot be empty', backgroundColor: Colors.redAccent, colorText: Colors.white);
                              return;
                            }
                            if (newP != confirmP) {
                              Get.snackbar('Error', 'Passwords do not match', backgroundColor: Colors.redAccent, colorText: Colors.white);
                              return;
                            }
                            if (newP.length < 6) {
                              Get.snackbar('Error', 'Password must be at least 6 characters', backgroundColor: Colors.redAccent, colorText: Colors.white);
                              return;
                            }

                            controller.changePassword(oldP, newP, confirmP);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE39D41), // Amber/Orange
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFFE39D41).withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isChangingPassword.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF34495E),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isObscure = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
