class LessonDetailModel {
  final String id;
  final String title;
  final String description;
  final List<String> learningObjectives;
  final List<AttachmentModel> attachments;
  final String type; // VIDEO, READING, QUIZ
  final VideoInfo? video;
  final String? readingContent;
  final QuizInfo? quiz;

  LessonDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.learningObjectives,
    required this.attachments,
    required this.type,
    this.video,
    this.readingContent,
    this.quiz,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return LessonDetailModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'No Title',
      description: data['description']?.toString() ?? '',
      learningObjectives: (data['learningObjectives'] as List?)?.map((e) => e.toString()).toList() ?? [],
      attachments: (data['attachments'] as List?)?.map((e) => AttachmentModel.fromJson(e)).toList() ?? [],
      type: data['type']?.toString().toUpperCase() ?? 'VIDEO',
      video: data['video'] != null ? VideoInfo.fromJson(data['video']) : null,
      readingContent: data['readingContent']?.toString(),
      quiz: data['quiz'] != null ? QuizInfo.fromAny(data['quiz']) : null,
    );
  }
}

class VideoInfo {
  final String? url;
  final String? duration;

  VideoInfo({this.url, this.duration});

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return VideoInfo(
      url: data['url']?.toString(),
      duration: data['duration']?.toString(),
    );
  }
}

class QuizInfo {
  final String quizId;

  QuizInfo({required this.quizId});

  factory QuizInfo.fromAny(dynamic data) {
    if (data is String) {
      return QuizInfo(quizId: data);
    } else if (data is Map<String, dynamic>) {
      return QuizInfo(
        quizId: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      );
    }
    return QuizInfo(quizId: '');
  }
}

class AttachmentModel {
  final String title;
  final String url;

  AttachmentModel({required this.title, required this.url});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      title: json['title']?.toString() ?? 'Attachment',
      url: json['url']?.toString() ?? '',
    );
  }
}
