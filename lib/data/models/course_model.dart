class CourseModel {
  final String id;
  final String title;
  final String? thumbnail;
  final String description;
  final int totalLessons;
  final double averageRating;
  final int enrollmentCount;
  final String slug;
  final EnrollmentModel? enrollment;

  CourseModel({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.description,
    required this.totalLessons,
    required this.averageRating,
    required this.enrollmentCount,
    required this.slug,
    this.enrollment,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      thumbnail: json['thumbnail']?.toString(),
      description: json['description']?.toString() ?? '',
      totalLessons: json['totalLessons'] is int ? json['totalLessons'] : int.tryParse(json['totalLessons']?.toString() ?? '0') ?? 0,
      averageRating: (json['averageRating'] is num) ? (json['averageRating'] as num).toDouble() : double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      enrollmentCount: json['enrollmentCount'] is int ? json['enrollmentCount'] : int.tryParse(json['enrollmentCount']?.toString() ?? '0') ?? 0,
      slug: json['slug']?.toString() ?? '',
      enrollment: json['enrollment'] != null ? EnrollmentModel.fromJson(json['enrollment']) : null,
    );
  }

  CourseModel copyWith({EnrollmentModel? enrollment}) {
    return CourseModel(
      id: id,
      title: title,
      thumbnail: thumbnail,
      description: description,
      totalLessons: totalLessons,
      averageRating: averageRating,
      enrollmentCount: enrollmentCount,
      slug: slug,
      enrollment: enrollment ?? this.enrollment,
    );
  }
}

class EnrollmentModel {
  final String status;
  final int completionPercentage;

  EnrollmentModel({
    required this.status,
    required this.completionPercentage,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      status: json['status']?.toString() ?? 'NONE',
      completionPercentage: json['completionPercentage'] is int ? json['completionPercentage'] : int.tryParse(json['completionPercentage']?.toString() ?? '0') ?? 0,
    );
  }
}

class CourseListResponse {
  final List<CourseModel> data;
  final PaginationModel pagination;

  CourseListResponse({
    required this.data,
    required this.pagination,
  });

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    return CourseListResponse(
      data: (json['data'] as List?)?.map((e) => CourseModel.fromJson(e)).toList() ?? [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationModel {
  final int totalPage;

  PaginationModel({required this.totalPage});

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalPage: json['totalPage'] is int ? json['totalPage'] : int.tryParse(json['totalPage']?.toString() ?? '1') ?? 1,
    );
  }
}
