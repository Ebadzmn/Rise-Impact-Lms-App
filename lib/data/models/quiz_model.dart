class QuizQuestionModel {
  final String id;
  final String title;
  final List<QuizOptionModel> options;

  QuizQuestionModel({
    required this.id,
    required this.title,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? json['question']?.toString() ?? json['text']?.toString() ?? 'Untitled Question';
    return QuizQuestionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? json['qid']?.toString() ?? json['questionId']?.toString() ?? title,
      title: title,
      options: (json['options'] as List?)?.map((e) => QuizOptionModel.fromJson(e)).toList() ?? [],
    );
  }
}

class QuizOptionModel {
  final String id;
  final String label;

  QuizOptionModel({required this.id, required this.label});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    final label = json['label']?.toString() ?? json['text']?.toString() ?? json['option']?.toString() ?? json['value']?.toString() ?? '';
    return QuizOptionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? json['uid']?.toString() ?? label,
      label: label,
    );
  }
}

class QuizAttemptModel {
  final String attemptId;
  final String status;
  final int? timeLimit;

  QuizAttemptModel({
    required this.attemptId,
    required this.status,
    this.timeLimit,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return QuizAttemptModel(
      attemptId: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      status: data['status']?.toString() ?? 'IN_PROGRESS',
      timeLimit: data['settings']?['timeLimit'] is int ? data['settings']['timeLimit'] : null,
    );
  }
}

class QuizResultModel {
  final int score;
  final double percentage;
  final bool passed;
  final String? timeSpent;
  final bool showResults;
  final List<QuestionReviewModel> answers;

  QuizResultModel({
    required this.score,
    required this.percentage,
    required this.passed,
    this.timeSpent,
    required this.showResults,
    required this.answers,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Safely handle quiz settings
    bool showResults = false;
    if (data['quiz'] is Map) {
      showResults = data['quiz']['settings']?['showResults'] == true;
    }

    return QuizResultModel(
      score: data['score'] is int ? data['score'] : int.tryParse(data['score']?.toString() ?? '0') ?? 0,
      percentage: (data['percentage'] is num) ? (data['percentage'] as num).toDouble() : 0.0,
      passed: data['passed'] == true,
      timeSpent: data['timeSpent']?.toString(),
      showResults: showResults,
      answers: (data['answers'] as List?)?.map((e) => QuestionReviewModel.fromJson(e)).toList() ?? [],
    );
  }
}

class QuestionReviewModel {
  final String questionTitle;
  final String selectedOption;
  final String correctOption;
  final bool isCorrect;
  final String? feedback;

  QuestionReviewModel({
    required this.questionTitle,
    required this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    this.feedback,
  });

  factory QuestionReviewModel.fromJson(Map<String, dynamic> json) {
    final qData = json['question'] ?? {};
    return QuestionReviewModel(
      questionTitle: qData['title']?.toString() ?? qData['text']?.toString() ?? qData['question']?.toString() ?? 'Question',
      selectedOption: json['selectedOption']?['label']?.toString() ?? json['selectedOption']?['text']?.toString() ?? 'None',
      correctOption: json['correctOption']?['label']?.toString() ?? json['correctOption']?['text']?.toString() ?? 'Correct Answer',
      isCorrect: json['isCorrect'] == true,
      feedback: json['feedback']?.toString(),
    );
  }
}
