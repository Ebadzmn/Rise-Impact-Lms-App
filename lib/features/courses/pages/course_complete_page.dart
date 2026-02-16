import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/custom_app_bar.dart';

class CourseCompletePage extends StatefulWidget {
  const CourseCompletePage({super.key});

  @override
  State<CourseCompletePage> createState() => _CourseCompletePageState();
}

class _CourseCompletePageState extends State<CourseCompletePage> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Course Complete',
          showBackButton: true,
          onBackCallback: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF6A7554), // Moss Green
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Course Complete!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF576045), // Sage Green text
                ),
              ),
              const SizedBox(height: 8),
              const Text('🎉', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 16),

              Text(
                "Great job! You've earned 50 points",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Points Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFED), // Beige/Light background
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          color: Color(0xFFE09F3E),
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+50',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF576045),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.workspace_premium_outlined,
                          color: Color(0xFFE09F3E),
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Points Added to Your Account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFFFD700), // Gold
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Review Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'What did you like or dislike about working with this course?',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_reviewController.text.length}/500 characters',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.home); // Done, go home
                  },
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
                    'Submit Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
