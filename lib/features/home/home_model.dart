class HomeData {
  final UserInfo userInfo;
  final Streak streak;
  final YourProgress yourProgress;
  final List<EnrolledCourse> enrolledCourses;
  final List<RecentBadge> recentBadges;

  HomeData({
    required this.userInfo,
    required this.streak,
    required this.yourProgress,
    required this.enrolledCourses,
    required this.recentBadges,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      userInfo: UserInfo.fromJson(json['data'] ?? json['userInfo'] ?? json),
      streak: Streak.fromJson(json['streak'] ?? {}),
      yourProgress: YourProgress.fromJson(json['yourProgress'] ?? {}),
      enrolledCourses: (json['enrolledCourses'] as List?)
              ?.map((e) => EnrolledCourse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentBadges: (json['recentBadges'] as List?)
              ?.map((e) => RecentBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class UserInfo {
  final String name;
  final int points;

  UserInfo({required this.name, required this.points});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name']?.toString() ?? 'User',
      points: int.tryParse(json['points']?.toString() ?? '0') ?? 0,
    );
  }
}

class Streak {
  final int current;
  final int longest;

  Streak({required this.current, required this.longest});

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      current: int.tryParse(json['current']?.toString() ?? '0') ?? 0,
      longest: int.tryParse(json['longest']?.toString() ?? '0') ?? 0,
    );
  }
}

class YourProgress {
  final double courseProgress;
  final double quizProgress;

  YourProgress({required this.courseProgress, required this.quizProgress});

  factory YourProgress.fromJson(Map<String, dynamic> json) {
    return YourProgress(
      courseProgress: double.tryParse(json['courseProgress']?.toString() ?? '0') ?? 0.0,
      quizProgress: double.tryParse(json['quizProgress']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class EnrolledCourse {
  final String title;
  final String thumbnail;
  final double completionPercentage;
  final String slug;

  EnrolledCourse({
    required this.title,
    required this.thumbnail,
    required this.completionPercentage,
    required this.slug,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      title: json['title']?.toString() ?? 'Unknown Course',
      thumbnail: json['thumbnail']?.toString() ?? '',
      completionPercentage: double.tryParse(json['completionPercentage']?.toString() ?? '0') ?? 0.0,
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class RecentBadge {
  final String iconName;
  final String name;
  final String earnedAt;

  RecentBadge({
    required this.iconName,
    required this.name,
    required this.earnedAt,
  });

  factory RecentBadge.fromJson(Map<String, dynamic> json) {
    return RecentBadge(
      iconName: json['iconName']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Badge',
      earnedAt: json['earnedAt']?.toString() ?? '',
    );
  }
}
