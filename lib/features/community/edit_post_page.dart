import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'controllers/edit_post_controller.dart';
import 'models/course_option_model.dart';

class EditPostPage extends GetView<EditPostController> {
  const EditPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: 'Update Post', showBackButton: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Title *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.titleController,
                  hintText: "Update your question or topic?",
                ),
                const SizedBox(height: 24),
                
                _buildInputLabel('Course Name (Optional)'),
                const SizedBox(height: 8),
                Obx(() => _buildDropdownField()),
                const SizedBox(height: 24),
                
                _buildInputLabel('Description *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.contentController,
                  hintText: 'Update more details...',
                  maxLines: 6,
                ),
                const SizedBox(height: 24),

                _buildInputLabel('Post Image (Optional)'),
                const SizedBox(height: 12),
                Obx(() => _buildImageSection()),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.submitUpdate(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE39D41), // Amber
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Update Post',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    // If a new image is picked
    if (controller.selectedImage.value != null) {
      return Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(controller.selectedImage.value!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildRemoveButton(() => controller.removeImage()),
          ),
        ],
      );
    }

    // If an existing image exists and hasn't been removed
    if (controller.initialPost.image != null && !controller.removeImageFlag.value) {
      return Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(controller.initialPost.image!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildRemoveButton(() => controller.removeImage()),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Color(0xFF2C3E50)),
                    SizedBox(width: 4),
                    Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default upload placeholder
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            Text('Upload Photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF34495E)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    if (controller.isCoursesLoading.value) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CourseOptionModel>(
          value: controller.selectedCourse.value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(16),
          hint: Text('Select Course Name', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
          selectedItemBuilder: (BuildContext context) {
            final List<CourseOptionModel?> allOptions = [
              null,
              ...controller.courseList,
            ];
            return allOptions.map<Widget>((item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item?.title ?? 'None',
                  style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
                ),
              );
            }).toList();
          },
          items: [
            // Null option to clear course
            DropdownMenuItem<CourseOptionModel>(
              value: null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: const Text('None', style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
            ...controller.courseList.map((value) {
              bool isSelected = controller.selectedCourse.value?.id == value.id;
              return DropdownMenuItem<CourseOptionModel>(
                value: value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(color: isSelected ? const Color(0xFF869277) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                  child: Text(value.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ),
              );
            }).toList(),
          ],
          onChanged: (newValue) => controller.selectedCourse.value = newValue,
        ),
      ),
    );
  }
}
