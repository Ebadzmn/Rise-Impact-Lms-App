class LessonDetailModel {
  final String id;
  final String title;
  final String description;
  final List<String> learningObjectives;
  final List<AttachmentModel> attachments;
  final String type; // VIDEO, READING, QUIZ
  final VideoInfo? video;
  final String? readingContent;
  final LessonContentFile? contentFile;
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
    this.contentFile,
    this.quiz,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final dynamic rawVideo =
        data['video'] ??
        data['videoUrl'] ??
        data['video_url'] ??
        data['videoURL'];
    final dynamic rawContentFile =
        data['contentFile'] ??
        data['content_file'] ??
        data['readingFile'] ??
        data['reading_file'];
    final dynamic rawReadingContent =
        data['readingContent'] ??
        data['reading_content'] ??
        data['content'] ??
        data['body'];

    return LessonDetailModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'No Title',
      description: data['description']?.toString() ?? '',
      learningObjectives:
          (data['learningObjectives'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      attachments:
          (data['attachments'] as List?)
              ?.map((e) => AttachmentModel.fromJson(e))
              .toList() ??
          [],
      type: data['type']?.toString().toUpperCase() ?? 'VIDEO',
      video: VideoInfo.fromAny(rawVideo),
      readingContent: rawReadingContent?.toString(),
      contentFile: LessonContentFile.fromAny(rawContentFile),
      quiz: data['quiz'] != null ? QuizInfo.fromAny(data['quiz']) : null,
    );
  }
}

class LessonContentFile {
  final String url;
  final String name;

  LessonContentFile({required this.url, required this.name});

  static LessonContentFile? fromAny(dynamic raw) {
    if (raw == null) return null;

    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return null;
      final guessedName = value.split('/').isNotEmpty
          ? value.split('/').last
          : 'reading_material.pdf';
      return LessonContentFile(url: value, name: guessedName);
    }

    if (raw is Map<String, dynamic>) {
      return LessonContentFile.fromJson(raw);
    }

    if (raw is Map) {
      return LessonContentFile.fromJson(Map<String, dynamic>.from(raw));
    }

    return null;
  }

  factory LessonContentFile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : json;
    final url = data['url']?.toString().trim() ?? '';
    final name =
        data['name']?.toString().trim() ??
        data['fileName']?.toString().trim() ??
        data['title']?.toString().trim() ??
        '';

    return LessonContentFile(url: url, name: name);
  }
}

class VideoInfo {
  final String? url;
  final String? duration;

  VideoInfo({this.url, this.duration});

  static String? _pickUrl(Map<String, dynamic> data) {
    final value =
        data['url'] ??
        data['videoUrl'] ??
        data['video_url'] ??
        data['videoURL'] ??
        data['link'] ??
        data['src'] ??
        data['file'];

    final url = value?.toString().trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  factory VideoInfo.fromAny(dynamic raw) {
    if (raw == null) return VideoInfo();

    if (raw is String) {
      final direct = raw.trim();
      return VideoInfo(url: direct.isEmpty ? null : direct);
    }

    if (raw is Map<String, dynamic>) {
      return VideoInfo.fromJson(raw);
    }

    if (raw is Map) {
      return VideoInfo.fromJson(Map<String, dynamic>.from(raw));
    }

    return VideoInfo();
  }

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final source = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    return VideoInfo(
      url: _pickUrl(source),
      duration:
          source['duration']?.toString() ?? source['videoDuration']?.toString(),
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
