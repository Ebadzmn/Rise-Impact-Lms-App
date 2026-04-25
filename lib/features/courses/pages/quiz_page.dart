import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../quiz_controller.dart';
import '../../../data/models/quiz_model.dart';

class QuizPage extends StatelessWidget {
  final String quizId;
  final String? courseId;
  final String? lessonId;
  final String? courseSlug;
  final String? initialAttemptId;

  const QuizPage({
    super.key,
    required this.quizId,
    this.courseId,
    this.lessonId,
    this.courseSlug,
    this.initialAttemptId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>(tag: quizId);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          Get.delete<QuizController>(tag: quizId, force: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            title: 'Quiz',
            showBackButton: true,
            onBackCallback: () => context.pop(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking quiz status...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (controller.questions.isEmpty) {
            return _buildEmptyState();
          }

          return SafeArea(
            child: Column(
              children: [
                _buildProgressHeader(controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildQuestionContent(controller),
                  ),
                ),
                _buildNavigationFooter(context, controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No questions found for this quiz.'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Get.back(), child: const Text('Go Back')),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(QuizController controller) {
    final current = controller.currentQuestionIndex.value + 1;
    final total = controller.questions.length;
    final double progress = current / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildTimerWidget(controller),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: const Color(0xFFD88B2F),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget(QuizController controller) {
    if (controller.timeLeft.value == 0) return const SizedBox.shrink();

    final minutes = controller.timeLeft.value ~/ 60;
    final seconds = controller.timeLeft.value % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: controller.timeLeft.value < 60 ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, 
              size: 16, 
              color: controller.timeLeft.value < 60 ? Colors.red : Colors.blue),
          const SizedBox(width: 4),
          Text(
            timeStr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: controller.timeLeft.value < 60 ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuizController controller) {
    final question = controller.questions[controller.currentQuestionIndex.value];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 32),
        ...question.options.map((option) => _buildOptionTile(controller, question.id, option)),
      ],
    );
  }

  Widget _buildOptionTile(QuizController controller, String questionId, QuizOptionModel option) {
    final isSelected = controller.selectedAnswers[questionId] == option.id;

    return GestureDetector(
      onTap: () => controller.selectOption(questionId, option.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD88B2F).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFD88B2F) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD88B2F) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFD88B2F), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationFooter(BuildContext context, QuizController controller) {
    final isLast = controller.currentQuestionIndex.value == controller.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          if (controller.currentQuestionIndex.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (controller.currentQuestionIndex.value > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLast 
                ? (controller.isSubmitting.value ? null : () => controller.submitQuiz())
                : controller.nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? const Color(0xFF6A7554) : const Color(0xFFD88B2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: controller.isSubmitting.value 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Submitting quiz...'),
                    ],
                  )
                : Text(isLast ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
