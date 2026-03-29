import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';
import '../models/post_model.dart';
import '../models/course_option_model.dart';
import 'my_posts_controller.dart';

class EditPostController extends GetxController {
  final PostModel initialPost;
  
  final RxBool isLoading = false.obs;
  final RxBool isCoursesLoading = true.obs;
  final RxList<CourseOptionModel> courseList = <CourseOptionModel>[].obs;
  final Rx<CourseOptionModel?> selectedCourse = Rx<CourseOptionModel?>(null);
  
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool removeImageFlag = false.obs;
  final ImagePicker _picker = ImagePicker();

  EditPostController({required this.initialPost});

  @override
  void onInit() {
    super.onInit();
    _prefillData();
    fetchCourseOptions();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  void _prefillData() {
    titleController.text = initialPost.title;
    contentController.text = initialPost.content;
    // Course selection will be pre-filled after course list is loaded
  }

  Future<void> fetchCourseOptions() async {
    try {
      isCoursesLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.courseOptions);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final parsedCourses = data.map((e) => CourseOptionModel.fromJson(e)).toList();
        courseList.assignAll(parsedCourses);
        
        // Match existing course if possible
        if (initialPost.courseName != null) {
          final matched = courseList.firstWhereOrNull((c) => c.title == initialPost.courseName);
          if (matched != null) {
            selectedCourse.value = matched;
          }
        }
      }
    } catch (e) {
      debugPrint('Fetch Courses Error: $e');
    } finally {
      isCoursesLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        removeImageFlag.value = false; // Picking a new image cancels removal
      }
    } catch (e) {
      debugPrint('Pick Image Error: $e');
    }
  }

  void removeImage() {
    selectedImage.value = null;
    removeImageFlag.value = true;
  }

  Future<void> submitUpdate() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('Validation', 'Title and Content are required', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      final Map<String, dynamic> fields = {};
      
      // Always send title and content if they changed (or just send them anyway as it's a PATCH)
      if (title != initialPost.title) fields['title'] = title;
      if (content != initialPost.content) fields['content'] = content;
      
      // Course ID handling
      if (selectedCourse.value?.id != null) {
        fields['courseId'] = selectedCourse.value!.id;
      } else if (initialPost.courseName != null) {
        // User cleared the course
        fields['courseId'] = "null";
      }

      // Image handling
      if (removeImageFlag.value) {
        fields['removeImage'] = "true";
      }

      final Map<String, File> files = {};
      if (selectedImage.value != null) {
        files['image'] = selectedImage.value!;
      }

      // If nothing changed, don't ping API
      if (fields.isEmpty && files.isEmpty) {
        Get.back();
        return;
      }

      final response = await ApiClient.instance.patchMultipart(
        ApiEndpoints.editPost(initialPost.id),
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      if (response.statusCode == 200) {
        // Refresh My Posts list if the controller is active
        if (Get.isRegistered<MyPostsController>()) {
          Get.find<MyPostsController>().fetchMyPosts(isRefresh: true);
        }
        
        Get.back();
        Get.snackbar('Success', 'Post updated successfully',
          backgroundColor: const Color(0xFF576045), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Update Post Error: $e');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to update post',
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
