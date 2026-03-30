import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'activity_calendar_model.dart';
import 'progress_model.dart';
import 'quiz_attempt_model.dart';
import '../profile/profile_model.dart';

class ProgressController extends GetxController {
  var selectedTab = 0.obs;
  var isLoading = true.obs;
  var isCalendarLoading = true.obs;
  var progressData = Rxn<ProgressModel>();
  var quizAttemptsList = <QuizAttemptModel>[].obs;
  var isQuizLoading = true.obs;
  var activeDaysList = <int>[].obs;
  var calendarMonth = DateTime.now().month.obs;
  var calendarYear = DateTime.now().year.obs;
  var badgeData = Rxn<BadgeResponseModel>();
  var isBadgesLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProgress();
    fetchQuizAttempts();
    fetchCalendar();
    fetchBadges();
  }

  Future<void> fetchProgress() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.studentProgress);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          progressData.value = ProgressModel.fromJson(data);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch progress data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQuizAttempts() async {
    try {
      isQuizLoading.value = true;
      final response = await ApiClient.instance.get(
        ApiEndpoints.quizAttempts,
        query: {'page': 1, 'limit': 5},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List? data = response.data['data'];
        if (data != null) {
          quizAttemptsList.assignAll(
            data.map((e) => QuizAttemptModel.fromJson(e)).toList(),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch quiz attempts: $e');
    } finally {
      isQuizLoading.value = false;
    }
  }

  Future<void> fetchCalendar() async {
    try {
      isCalendarLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.activityCalendar);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final calendarModel = ActivityCalendarModel.fromJson(data);
          calendarMonth.value = calendarModel.month;
          calendarYear.value = calendarModel.year;
          activeDaysList.assignAll(calendarModel.days.map((e) => e.day).toList());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch calendar data: $e');
    } finally {
      isCalendarLoading.value = false;
    }
  }

  Future<void> fetchBadges() async {
    try {
      isBadgesLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.myBadges);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data != null) {
          badgeData.value = BadgeResponseModel.fromJson(data);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch badges: $e');
    } finally {
      isBadgesLoading.value = false;
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }
}
