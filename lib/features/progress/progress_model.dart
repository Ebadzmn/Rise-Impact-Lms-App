class ProgressModel {
  final int overallPercentage;
  final int points;
  final Streak streak;
  final List<CourseProgress> courses;

  ProgressModel({
    required this.overallPercentage,
    required this.points,
    required this.streak,
    required this.courses,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      overallPercentage: json['overallPercentage'] ?? 0,
      points: json['points'] ?? 0,
      streak: Streak.fromJson(json['streak'] ?? {}),
      courses: (json['courses'] as List? ?? [])
          .map((e) => CourseProgress.fromJson(e))
          .toList(),
    );
  }
}

class Streak {
  final int current;
  final int longest;

  Streak({
    required this.current,
    required this.longest,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      current: json['current'] ?? 0,
      longest: json['longest'] ?? 0,
    );
  }
}

class CourseProgress {
  final String title;
  final int completionPercentage;

  CourseProgress({
    required this.title,
    required this.completionPercentage,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      title: json['title'] ?? '',
      completionPercentage: json['completionPercentage'] ?? 0,
    );
  }
}
