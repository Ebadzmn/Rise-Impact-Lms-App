class QuizAttemptModel {
  final String quizTitle;
  final String courseName;
  final int percentage;
  final bool passed;
  final DateTime completedAt;

  QuizAttemptModel({
    required this.quizTitle,
    required this.courseName,
    required this.percentage,
    required this.passed,
    required this.completedAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      quizTitle: json['quizTitle'] ?? '',
      courseName: json['courseName'] ?? '',
      percentage: json['percentage'] ?? 0,
      passed: json['passed'] ?? false,
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
