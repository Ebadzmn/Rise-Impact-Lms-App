import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/lesson_detail_model.dart';

class LessonController extends GetxController {
  final ApiClient _api = ApiClient.instance;
  final String courseId;
  final String lessonId;

  LessonController({required this.courseId, required this.lessonId});

  // State Variables
  final RxBool isLoading = true.obs;
  final Rxn<LessonDetailModel> lessonData = Rxn<LessonDetailModel>();
  final RxBool isCompleting = false.obs;
  final RxInt completionPercentage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLessonContent();
  }

  Future<void> fetchLessonContent() async {
    isLoading.value = true;
    try {
      final endpoint = ApiEndpoints.getLesson
          .replaceFirst(':courseId', courseId)
          .replaceFirst(':lessonId', lessonId);
      
      final response = await _api.get(endpoint);
      lessonData.value = LessonDetailModel.fromJson(response.data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load lesson: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsComplete() async {
    if (isCompleting.value) return;

    isCompleting.value = true;
    try {
      final endpoint = ApiEndpoints.markLessonComplete
          .replaceFirst(':courseId', courseId)
          .replaceFirst(':lessonId', lessonId);

      final response = await _api.post(endpoint);
      
      // Assume Response has completionPercentage
      final data = response.data['data'] ?? response.data;
      if (data['completionPercentage'] != null) {
        completionPercentage.value = data['completionPercentage'] is int 
            ? data['completionPercentage'] 
            : int.tryParse(data['completionPercentage'].toString()) ?? 0;
      }

      Get.snackbar('Success', 'Lesson marked as completed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      if (completionPercentage.value == 100) {
        _showCompletionDialog();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark complete: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isCompleting.value = false;
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: const Text('You have successfully completed the course!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }
}
