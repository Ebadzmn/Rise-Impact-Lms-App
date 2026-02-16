import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../routes/app_routes.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Mock Data
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '1. What is a good credit score range?',
      'options': ['A. 300-579', 'B. 580-669', 'C. 670-739', 'D. 740-850'],
      'correctIndex': 2,
    },
    {
      'question': '2. Which factor has the biggest impact on credit score?',
      'options': [
        'A. Payment history',
        'B. Credit utilization',
        'C. Length of credit history',
        'D. New credit',
      ],
      'correctIndex': 0,
    },
  ];

  final Map<int, int> _selectedAnswers = {};

  void _handleOptionSelect(int questionIndex, int optionIndex) {
    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
    });
  }

  void _submitQuiz() {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions to complete the lesson'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to Course Complete Page
    context.push(AppRoutes.courseComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Off-white background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Quiz',
          showBackButton: true,
          onBackCallback: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Header Icon and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE09F3E), // Orange/Gold
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Knowledge\nCheck',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF576045), // Sage Green text
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Answer these questions to complete\nthe lesson',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Questions List
              ..._questions.asMap().entries.map((entry) {
                return _buildQuestionCard(
                  questionIndex: entry.key,
                  questionData: entry.value,
                );
              }),

              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE09F3E), // Orange/Gold
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Answer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required int questionIndex,
    required Map<String, dynamic> questionData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            questionData['question'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          ...(questionData['options'] as List<String>).asMap().entries.map((
            entry,
          ) {
            int optionIndex = entry.key;
            String optionText = entry.value;
            bool isSelected = _selectedAnswers[questionIndex] == optionIndex;

            return GestureDetector(
              onTap: () => _handleOptionSelect(questionIndex, optionIndex),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE09F3E).withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE09F3E)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                              ? const Color(0xFFE09F3E)
                              : const Color(0xFF4A4A4A),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFE09F3E),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
