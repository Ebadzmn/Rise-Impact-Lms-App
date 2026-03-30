import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/course_model.dart';
import '../../routes/app_routes.dart';

class CoursesController extends GetxController {
  final ApiClient _api = ApiClient.instance;

  // State Variables
  final RxList<CourseModel> courseList = <CourseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;

  // Search & Filter
  final RxString searchTerm = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  Timer? _searchDebounce;

  final Map<String, String> filterDisplayNames = {
    'all': 'All',
    'active': 'Active',
    'completed': 'Completed',
    'none': 'None',
  };

  final List<String> filters = ['all', 'active', 'completed', 'none'];

  // Scroll Controller for pagination
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchCourses();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isMoreLoading.value &&
        _currentPage < _totalPages) {
      fetchCourses(isLoadMore: true);
    }
  }

  Future<void> fetchCourses({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isMoreLoading.value = true;
      _currentPage++;
    } else {
      isLoading.value = true;
      _currentPage = 1;
      courseList.clear();
    }

    try {
      final response = await _api.get(
        ApiEndpoints.browseCourses,
        query: {
          'page': _currentPage,
          'limit': _pageSize,
          'searchTerm': searchTerm.value,
          'enrollment': selectedFilter.value,
          'sort': '-createdAt',
        },
      );

      final courseResponse = CourseListResponse.fromJson(response.data);
      
      if (isLoadMore) {
        courseList.addAll(courseResponse.data);
      } else {
        courseList.assignAll(courseResponse.data);
      }
      
      _totalPages = courseResponse.pagination.totalPage;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load courses: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchTerm.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchCourses();
    });
  }

  void changeFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchCourses();
    }
  }

  Future<void> enrollInCourse(BuildContext context, CourseModel course) async {
    try {
      // Show local loading if needed (optional)
      final res = await _api.post(
        ApiEndpoints.enrollments,
        body: {'courseId': course.id},
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        // Update local list item status
        final index = courseList.indexWhere((item) => item.id == course.id);
        if (index != -1) {
          courseList[index] = courseList[index].copyWith(
            enrollment: EnrollmentModel(status: 'ACTIVE', completionPercentage: 0),
          );
          courseList.refresh();
        }

        // Navigate to details
        if (context.mounted) {
          context.pushNamed(
            AppRoutes.studentCourseDetails,
            pathParameters: {'slug': course.slug},
          );
        }
      }
    } catch (e) {
      Get.snackbar('Enrollment Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
