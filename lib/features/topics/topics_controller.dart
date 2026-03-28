import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

class CourseModel {
  final String id;
  final String title;
  final String thumbnail;

  CourseModel({
    required this.id,
    required this.title,
    required this.thumbnail,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title']?.toString() ?? 'Unknown',
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }
}

class TopicsController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString userName = 'Loading...'.obs;

  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxList<String> selectedCourseIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchCourses();
  }

  Future<void> fetchProfile() async {
    final storage = Get.find<StorageService>();
    final cachedUser = storage.getUser();
    
    // Optimistic cache load
    if (cachedUser != null) {
      userName.value = cachedUser['name']?.toString() ?? cachedUser['email']?.toString() ?? 'User';
    }

    try {
      final response = await ApiClient.instance.get(ApiEndpoints.profile);
      
      Map<String, dynamic> responseMap = {};
      if (response.data is String) {
        try { responseMap = jsonDecode(response.data) as Map<String, dynamic>; } catch (_) {}
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      }

      Map<String, dynamic> payload = responseMap;
      if (responseMap.containsKey('data') && responseMap['data'] is Map) {
         payload = Map<String, dynamic>.from(responseMap['data']);
      }
      
      storage.saveUser(payload); // Extracted caching structure
      
      final rawName = payload['name']?.toString() ?? payload['email']?.toString();
      if (rawName != null && rawName.isNotEmpty) {
        userName.value = rawName;
      } else {
        userName.value = 'User';
      }
      
    } catch (e, stack) {
      debugPrint('Profile Fetch Error: $e\n$stack');
      if (cachedUser == null) {
        userName.value = 'User'; // Fallback
      }
    }
  }

  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(
        ApiEndpoints.getCourses,
        query: {'page': 1, 'limit': 50},
      );

      final dynamic rawData = response.data['data'];
      if (rawData is List) {
        courses.value = rawData
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e, stack) {
      debugPrint('Fetch Courses Error: $e\n$stack');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to load courses');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCourse(String courseId) {
    if (selectedCourseIds.contains(courseId)) {
      selectedCourseIds.remove(courseId);
    } else {
      selectedCourseIds.add(courseId);
    }
  }

  Future<void> submitEnrollment() async {
    if (selectedCourseIds.isEmpty) {
      Get.snackbar('Validation', 'Please select at least one course');
      return;
    }

    try {
      isSubmitting.value = true;
      await ApiClient.instance.post(
        ApiEndpoints.bulkEnrollment,
        body: {
          'courseIds': selectedCourseIds.toList(),
        },
      );

      Get.snackbar('Success', 'Enrolled successfully');
      selectedCourseIds.clear();
      AppRouter.router.go(AppRoutes.home);

    } catch (e, stack) {
      debugPrint('Submit Enrollment Error: $e\n$stack');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to enroll');
    } finally {
      isSubmitting.value = false;
    }
  }
}
