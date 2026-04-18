import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';
import '../../../routes/app_router.dart';
import '../models/course_option_model.dart';

class CreatePostController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCoursesLoading = true.obs;
  final RxList<CourseOptionModel> courseList = <CourseOptionModel>[].obs;
  final Rx<CourseOptionModel?> selectedCourse = Rx<CourseOptionModel?>(null);
  
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchCourseOptions();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> fetchCourseOptions() async {
    try {
      isCoursesLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.courseOptions);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        courseList.assignAll(data.map((e) => CourseOptionModel.fromJson(e)).toList());
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
      }
    } catch (e) {
      debugPrint('Pick Image Error: $e');
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<void> submitPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('Validation', 'Title and Content are required', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      final Map<String, dynamic> fields = {
        'title': title,
        'content': content,
      };

      if (selectedCourse.value != null) {
        fields['courseId'] = selectedCourse.value!.id;
      }

      final Map<String, File> files = {};
      if (selectedImage.value != null) {
        files['image'] = selectedImage.value!;
      }

      final response = await ApiClient.instance.postMultipart(
        ApiEndpoints.communityPosts,
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppRouter.router.go('/community');
        Get.snackbar('Success', 'Post created successfully',
          backgroundColor: const Color(0xFF576045), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Create Post Error: $e');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to create post',
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
