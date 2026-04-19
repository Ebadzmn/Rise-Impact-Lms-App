import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/quiz_model.dart';

class QuizResultPage extends StatelessWidget {
  final QuizResultModel result;

  const QuizResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Quiz Result',
          showBackButton: false,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildResultHeader(),
            const SizedBox(height: 32),
            _buildScoreCard(),
            const SizedBox(height: 32),
            if (result.showResults) _buildAnswerReview(),
            const SizedBox(height: 40),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Icon(
          result.passed ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          size: 100,
          color: result.passed ? Colors.green : Colors.redAccent,
        ),
        const SizedBox(height: 16),
        Text(
          result.passed ? 'Pass ✅' : 'Fail ❌',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          result.passed ? 'You passed the quiz successfully.' : 'You didn\'t reach the passing score.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F3EB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6D6C4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Score', '${result.score}/${result.maxScore}'),
          _buildScoreItem('Percentage', '${result.percentage.toStringAsFixed(1)}%'),
          if (result.timeSpent != null) _buildScoreItem('Time spent', result.timeSpent!),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAnswerReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Review',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...result.answers.map((answer) => _buildReviewCard(answer)),
      ],
    );
  }

  Widget _buildReviewCard(QuestionReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.questionTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildReviewOption('Selected Option ID', review.selectedOptionId, review.isCorrect),
          const SizedBox(height: 8),
          _buildReviewOption('Result', review.isCorrect ? 'Correct' : 'Wrong', review.isCorrect),
          const SizedBox(height: 8),
          _buildReviewOption('Marks Awarded', review.marksAwarded.toStringAsFixed(2), review.marksAwarded > 0),
          if (review.correctOptionId != null && review.correctOptionId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildReviewOption('Correct Option ID', review.correctOptionId!, true),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewOption(String label, String value, bool isCorrect) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.redAccent,
            ),
          ),
        ),
        Icon(
          isCorrect ? Icons.check_circle_outline : Icons.close_rounded,
          size: 16,
          color: isCorrect ? Colors.green : Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pop(), // Back to Course
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A7554),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Back to Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
