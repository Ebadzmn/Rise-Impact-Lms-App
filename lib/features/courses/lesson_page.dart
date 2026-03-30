import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../routes/app_routes.dart';
import '../../data/models/lesson_detail_model.dart';
import 'lesson_controller.dart';

class LessonPage extends StatelessWidget {
  final String courseId;
  final String lessonId;

  const LessonPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    // Unique tag for controller instance
    final controller = Get.find<LessonController>(tag: '${courseId}_${lessonId}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(controller.lessonData.value?.title ?? 'Lesson Content')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final lesson = controller.lessonData.value;
        if (lesson == null) {
          return const Center(child: Text('Lesson not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentHeader(lesson),
              const Divider(),
              _buildLessonContent(context, controller, lesson),
              _buildObjectives(lesson),
              _buildAttachments(lesson),
              const SizedBox(height: 100), // Space for action button
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        final lesson = controller.lessonData.value;
        if (lesson == null || controller.isLoading.value) return const SizedBox.shrink();

        return _buildActionSection(context, controller, lesson);
      }),
    );
  }

  Widget _buildContentHeader(LessonDetailModel lesson) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(BuildContext context, LessonController controller, LessonDetailModel lesson) {
    switch (lesson.type.toUpperCase()) {
      case 'VIDEO':
        return _buildVideoPlayer(lesson);
      case 'READING':
        return _buildReadingContent(lesson);
      case 'QUIZ':
        return _buildQuizContent(context, lesson);
      default:
        return _buildReadingContent(lesson);
    }
  }

  Widget _buildVideoPlayer(LessonDetailModel lesson) {
    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_filled, color: Colors.white, size: 64),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                lesson.video?.duration ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // In a real app, integrate video_player package here
          const Text('Video content placeholder', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildReadingContent(LessonDetailModel lesson) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: HtmlWidget(
        lesson.readingContent ?? 'No content available.',
        textStyle: const TextStyle(fontSize: 16, height: 1.6),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, LessonDetailModel lesson) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F3EB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE6D6C4)),
        ),
        child: Column(
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFD88B2F)),
            const SizedBox(height: 16),
            const Text(
              'Lesson Quiz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your knowledge on this topic!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (lesson.quiz?.quizId != null) {
                   context.pushNamed(AppRoutes.quiz, pathParameters: {'id': lesson.quiz!.quizId});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD88B2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectives(LessonDetailModel lesson) {
    if (lesson.learningObjectives.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Objectives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...lesson.learningObjectives.map((obj) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF6A7554)),
                const SizedBox(width: 8),
                Expanded(child: Text(obj, style: const TextStyle(fontSize: 15))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAttachments(LessonDetailModel lesson) {
    if (lesson.attachments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...lesson.attachments.map((file) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_present_outlined, color: Colors.blue),
            title: Text(file.title, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.download_outlined),
            onTap: () {},
          )),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, LessonController controller, LessonDetailModel lesson) {
    if (lesson.type.toUpperCase() == 'QUIZ') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Obx(() => ElevatedButton(
          onPressed: controller.isCompleting.value ? null : () => controller.markAsComplete(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A7554),
            disabledBackgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: controller.isCompleting.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Mark Complete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        )),
      ),
    );
  }
}
