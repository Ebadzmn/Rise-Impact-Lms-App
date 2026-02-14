import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import 'dashboard_controller.dart';
import '../home/home_page.dart';
import '../courses/courses_page.dart';
import '../progress/progress_page.dart';
import '../community/community_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomePage(),
            CoursesPage(),
            ProgressPage(),
            CommunityPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
        ),
      ),
    );
  }
}
