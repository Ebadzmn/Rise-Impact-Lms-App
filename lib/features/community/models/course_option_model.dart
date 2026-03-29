class CourseOptionModel {
  final String id;
  final String title;

  CourseOptionModel({
    required this.id,
    required this.title,
  });

  factory CourseOptionModel.fromJson(Map<String, dynamic> json) {
    return CourseOptionModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseOptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
