import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../profile_controller.dart';

class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF576045),
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final imageFile = controller.selectedImage.value;
                      final profileUrl = controller.profileData.value?.profilePicture ?? '';
                      
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageFile != null 
                            ? FileImage(imageFile) 
                            : (profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null) as ImageProvider?,
                        child: (imageFile == null && profileUrl.isEmpty) 
                            ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE39D41),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Full Name'),
              _buildTextField(controller.nameController, 'Enter full name'),
              
              const SizedBox(height: 16),
              _buildLabel('Gender'),
              _buildGenderDropdown(controller),

              const SizedBox(height: 16),
              _buildLabel('Date of Birth'),
              _buildDatePickerField(context, controller),

              const SizedBox(height: 16),
              _buildLabel('Location'),
              _buildTextField(controller.locationController, 'Enter location'),

              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              _buildTextField(controller.phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
              
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isUpdating.value
                          ? null
                          : () => controller.updateUserProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE39D41),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: const Color(0xFFE39D41).withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: controller.isUpdating.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF34495E)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
      decoration: InputDecoration(
        hintText: hint,
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

  Widget _buildGenderDropdown(ProfileController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: controller.genderController.text.isEmpty ? null : controller.genderController.text,
          items: ['male', 'female', 'other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.capitalizeFirst!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.genderController.text = value;
            }
          },
          decoration: const InputDecoration(border: InputBorder.none),
          hint: const Text('Select Gender'),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, ProfileController controller) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          controller.dobController.text = formattedDate;
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller.dobController,
          style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
          decoration: InputDecoration(
            hintText: 'Select Date of Birth',
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
        ),
      ),
    );
  }
}
