import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../routes/app_routes.dart';
import '../../data/models/course_details_model.dart';
import 'course_details_controller.dart';

class CourseDetailsPage extends StatelessWidget {
  final String identifier;
  const CourseDetailsPage({super.key, required this.identifier});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseDetailsController>(tag: identifier);
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildSkeletonLoader();
          }

          final course = controller.courseDetail.value;
          if (course == null) {
            return _buildErrorState();
          }

          final bool isEnrolled = controller.isEnrolled.value;
          final enrollment = course.enrollment;

          return RefreshIndicator(
            onRefresh: () => controller.fetchCourseDetails(showLoading: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          course.description,
                          style: const TextStyle(
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
                                label: 'Rating',
                                value: course.averageRating.toStringAsFixed(1),
                                icon: Icons.star_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatBox(
                                label: 'Duration',
                                value: course.totalDuration ?? 'N/A',
                                icon: Icons.access_time,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatBox(
                                label: 'Students',
                                value: course.enrollmentCount.toString(),
                                icon: Icons.people_outline,
                              ),
                            ),
                          ],
                        ),
                        if (isEnrolled && enrollment != null) ...[
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${enrollment.status.capitalizeFirst}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Progress: ${enrollment.completionPercentage}%',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: enrollment.completionPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              color: const Color(0xFFD88B2F), // Mustard
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildCurriculum(context, controller, course),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEnrolled) {
                            // TODO: Handle Resume/Continue Logic
                          } else {
                            controller.enrollInCourse(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD88B2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEnrolled
                                  ? Icons.play_arrow_outlined
                                  : Icons.add_circle_outline_rounded,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEnrolled ? 'Continue Learning' : 'Start Course',
                              style: const TextStyle(
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
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          ...List.generate(
            3,
            (index) => Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Course not found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
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

  Widget _buildCurriculum(
      BuildContext context, CourseDetailsController controller, CourseDetailModel course) {
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
                  '${course.curriculum.length} modules • ${course.curriculum.fold(0, (sum, m) => sum + m.lessons.length)} lessons',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...course.curriculum.asMap().entries.map((entry) {
            final index = entry.key;
            final module = entry.value;
            return Column(
              children: [
                _buildModuleTile(
                  context: context,
                  controller: controller,
                  moduleNumber: index + 1,
                  module: module,
                  completedLessons: course.completedLessons,
                  lastAccessedId: course.lastAccessedLesson,
                ),
                if (index < course.curriculum.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required BuildContext context,
    required CourseDetailsController controller,
    required int moduleNumber,
    required ModuleModel module,
    required List<String> completedLessons,
    String? lastAccessedId,
  }) {
    final int completedCount = module.lessons.where((l) => completedLessons.contains(l.id)).length;

    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: moduleNumber == 1,
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
          module.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          '$completedCount/${module.lessons.length} lessons completed',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        children: module.lessons.map((lesson) {
          final isCompleted = completedLessons.contains(lesson.id);
          final isLastAccessed = lastAccessedId == lesson.id;

          return _buildLessonTile(
            context,
            courseId: controller.courseDetail.value?.id ?? '',
            courseSlug: controller.identifier,
            lesson: lesson,
            isCompleted: isCompleted,
            isLastAccessed: isLastAccessed,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonTile(
    BuildContext context, {
    required String courseId,
    required String courseSlug,
    required LessonModel lesson,
    bool isCompleted = false,
    bool isLastAccessed = false,
  }) {
    IconData typeIcon;
    Color bgColor;
    Color iconColor;

    switch (lesson.type.toUpperCase()) {
      case 'VIDEO':
        typeIcon = Icons.play_circle_outline;
        bgColor = const Color(0xFFE3F2FD); // Light Blue
        iconColor = const Color(0xFF2196F3);
        break;
      case 'QUIZ':
        typeIcon = Icons.quiz_outlined;
        bgColor = const Color(0xFFFFF3E0); // Light Orange
        iconColor = const Color(0xFFF57C00);
        break;
      case 'READING':
        typeIcon = Icons.picture_as_pdf_outlined;
        bgColor = const Color(0xFFE8F5E9); // Light Green
        iconColor = const Color(0xFF4CAF50);
        break;
      default:
        typeIcon = Icons.play_circle_outline;
        bgColor = const Color(0xFFF5F5F5); // Grey
        iconColor = Colors.grey.shade600;
    }

    // Overrides for special states
    if (isCompleted) {
      iconColor = const Color(0xFF66BB6A);
    }
    if (isLastAccessed) {
      bgColor = Colors.amber.shade50;
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.lessonContent,
          pathParameters: {
            'courseId': courseId,
            'lessonId': lesson.id,
          },
          queryParameters: {'slug': courseSlug},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLastAccessed ? Colors.amber.shade200 : Colors.transparent),
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
                color: isCompleted ? const Color(0xFFE8F5E9) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : typeIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (lesson.type.toUpperCase() == 'VIDEO' && lesson.duration != null)
                    Text(
                      lesson.duration!,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (isLastAccessed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Resume', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
