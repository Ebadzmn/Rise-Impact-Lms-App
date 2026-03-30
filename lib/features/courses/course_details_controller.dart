import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/course_details_model.dart';

class CourseDetailsController extends GetxController {
  final ApiClient _api = ApiClient.instance;
  final String identifier; // Dynamic identifier (slug or id)

  CourseDetailsController({required this.identifier});

  // State Variables
  final RxBool isLoading = true.obs;
  final Rxn<CourseDetailModel> courseDetail = Rxn<CourseDetailModel>();
  final RxBool isEnrolled = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    isLoading.value = true;
    try {
      final endpoint = ApiEndpoints.studentCourseDetail.replaceFirst(':identifier', identifier);
      final response = await _api.get(endpoint);
      
      final detail = CourseDetailModel.fromJson(response.data);
      courseDetail.value = detail;
      isEnrolled.value = detail.enrollment != null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load course details: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enrollInCourse(BuildContext context) async {
    final courseId = courseDetail.value?.id;
    if (courseId == null) return;

    try {
      final res = await _api.post(
        ApiEndpoints.enrollments,
        body: {'courseId': courseId},
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        // Success -> Re-fetch details to update UI with curriculum
        await fetchCourseDetails();
        Get.snackbar('Success', 'Successfully enrolled in course!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Enrollment Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
