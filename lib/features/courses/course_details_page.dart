import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Course Details',
          showBackButton: true,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A7554), // Sage Green background
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Mastery',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Master the fundamentals of credit scores, credit reports, and building a strong credit history. Learn proven strategies to improve your credit and make informed financial decisions.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            label: 'Level',
                            value: 'Beginner',
                            icon: Icons.bar_chart,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            label: 'Duration',
                            value: '4 weeks',
                            icon: Icons.access_time,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            label: 'Progress',
                            value: '65%',
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        color: const Color(0xFFD88B2F), // Mustard
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCourseContent(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD88B2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_outlined, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Continue Learning',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // 'Courses' tab is active
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.home);
          if (index == 1) {
            context.go(AppRoutes.home);
          } // Basic navigation back to main layout for now
          // Ideally navigation logic would be centralized or passed down
        },
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Content',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 modules • 9 lessons',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildModuleTile(
            moduleNumber: 1,
            title: 'Understanding Credit Basics',
            lessonsCompleted: 3,
            totalLessons: 3,
            isExpanded: true,
            children: [
              _buildLessonTile(
                context,
                title: 'What is Credit?',
                duration: '12 min',
                icon: Icons.play_arrow_outlined,
                isCompleted: true,
              ),
              _buildLessonTile(
                context,
                title: 'Credit Scores Explained',
                duration: '15 min',
                icon: Icons.article_outlined,
                isCompleted: true,
              ),
              _buildLessonTile(
                context,
                title: 'Credit Reports 101',
                duration: '18 min',
                icon: Icons.play_arrow_outlined,
                isCompleted: true,
              ),
              _buildQuizTile(
                context,
                title: 'Module 1 Quiz',
                details: '10 questions • Score: 90%',
                isCompleted: true,
              ),
            ],
          ),
          const Divider(height: 1),
          _buildModuleTile(
            moduleNumber: 2,
            title: 'Building Good Credit',
            lessonsCompleted: 1,
            totalLessons: 3,
            isExpanded: false,
            children: [],
          ),
          const Divider(height: 1),
          _buildModuleTile(
            moduleNumber: 3,
            title: 'Advanced Credit Management',
            lessonsCompleted: 0,
            totalLessons: 3,
            isExpanded: false,
            children: [],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required int moduleNumber,
    required String title,
    required int lessonsCompleted,
    required int totalLessons,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF6A7554), // Olive Green
            shape: BoxShape.circle,
          ),
          child: Text(
            '$moduleNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          '$lessonsCompleted/$totalLessons lessons completed',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        children: children,
      ),
    );
  }

  Widget _buildLessonTile(
    BuildContext context, {
    required String title,
    required String duration,
    required IconData icon,
    bool isCompleted = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (icon == Icons.play_arrow_outlined) {
          context.push(AppRoutes.courseVideo);
        } else if (icon == Icons.article_outlined) {
          context.push(AppRoutes.resourceDetails);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFCFA), // Very light mint/white
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light Green
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF66BB6A), // Medium Green
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download_outlined,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTile(
    BuildContext context, {
    required String title,
    required String details,
    bool isCompleted = false,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.lessonCompletion);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F3EB), // Light Beige
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6D6C4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFDFF7F2), // Light Teal
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF26A69A), // Teal
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
