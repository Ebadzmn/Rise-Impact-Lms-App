import 'package:get/get.dart';

class CoursesController extends GetxController {
  final RxString selectedFilter = 'All Courses'.obs;
  final List<String> filters = ['All Courses', 'In Progress', 'Completed'];

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
