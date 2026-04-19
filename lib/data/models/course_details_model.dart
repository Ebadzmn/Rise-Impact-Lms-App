class CourseDetailModel {
  final String id;
  final String title;
  final String? thumbnail;
  final String description;
  final double averageRating;
  final int enrollmentCount;
  final String? totalDuration;
  final String slug;
  final EnrollmentDetail? enrollment;
  final List<ModuleModel> curriculum;
  final List<String> completedLessons;
  final String? lastAccessedLesson;

  CourseDetailModel({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.description,
    required this.averageRating,
    required this.enrollmentCount,
    this.totalDuration,
    required this.slug,
    this.enrollment,
    required this.curriculum,
    required this.completedLessons,
    this.lastAccessedLesson,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    // If nested in "data"
    final data = json['data'] ?? json;
    
    return CourseDetailModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'No Title',
      thumbnail: data['thumbnail']?.toString(),
      description: data['description']?.toString() ?? '',
      averageRating: (data['averageRating'] is num) ? (data['averageRating'] as num).toDouble() : double.tryParse(data['averageRating']?.toString() ?? '0') ?? 0.0,
      enrollmentCount: data['enrollmentCount'] is int ? data['enrollmentCount'] : int.tryParse(data['enrollmentCount']?.toString() ?? '0') ?? 0,
      totalDuration: data['totalDuration']?.toString(),
      slug: data['slug']?.toString() ?? '',
      enrollment: data['enrollment'] != null ? EnrollmentDetail.fromJson(data['enrollment']) : null,
      curriculum: (data['curriculum'] as List?)?.map((e) => ModuleModel.fromJson(e)).toList() ?? [],
      completedLessons: (data['completedLessons'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lastAccessedLesson: data['lastAccessedLesson']?.toString(),
    );
  }

  CourseDetailModel copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? description,
    double? averageRating,
    int? enrollmentCount,
    String? totalDuration,
    String? slug,
    EnrollmentDetail? enrollment,
    List<ModuleModel>? curriculum,
    List<String>? completedLessons,
    String? lastAccessedLesson,
  }) {
    return CourseDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
      averageRating: averageRating ?? this.averageRating,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      totalDuration: totalDuration ?? this.totalDuration,
      slug: slug ?? this.slug,
      enrollment: enrollment ?? this.enrollment,
      curriculum: curriculum ?? this.curriculum,
      completedLessons: completedLessons ?? this.completedLessons,
      lastAccessedLesson: lastAccessedLesson ?? this.lastAccessedLesson,
    );
  }
}

class EnrollmentDetail {
  final String status;
  final int completionPercentage;

  EnrollmentDetail({
    required this.status,
    required this.completionPercentage,
  });

  factory EnrollmentDetail.fromJson(Map<String, dynamic> json) {
    return EnrollmentDetail(
      status: json['status']?.toString() ?? 'NONE',
      completionPercentage: json['completionPercentage'] is int ? json['completionPercentage'] : int.tryParse(json['completionPercentage']?.toString() ?? '0') ?? 0,
    );
  }

  EnrollmentDetail copyWith({
    String? status,
    int? completionPercentage,
  }) {
    return EnrollmentDetail(
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

class ModuleModel {
  final String title;
  final List<LessonModel> lessons;

  ModuleModel({
    required this.title,
    required this.lessons,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      title: json['title']?.toString() ?? 'Untitled Module',
      lessons: (json['lessons'] as List?)?.map((e) => LessonModel.fromJson(e)).toList() ?? [],
    );
  }
}

class LessonModel {
  final String id;
  final String title;
  final String type; // VIDEO, READING, QUIZ
  final String? duration;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    this.duration,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Lesson',
      type: json['type']?.toString() ?? 'VIDEO',
      duration: json['duration']?.toString(),
    );
  }
}
