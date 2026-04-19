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
    final optionId = json['optionId']?.toString() ?? json['optionID']?.toString() ?? '';
    return QuizOptionModel(
      id: optionId.isNotEmpty
          ? optionId
          : json['_id']?.toString() ?? json['id']?.toString() ?? json['uid']?.toString() ?? label,
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
  final int maxScore;
  final double percentage;
  final bool passed;
  final String? timeSpent;
  final bool showResults;
  final List<QuestionReviewModel> answers;

  QuizResultModel({
    required this.score,
    required this.maxScore,
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
      maxScore: data['maxScore'] is int ? data['maxScore'] : int.tryParse(data['maxScore']?.toString() ?? '0') ?? 0,
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
  final String selectedOptionId;
  final String? correctOptionId;
  final bool isCorrect;
  final double marksAwarded;

  QuestionReviewModel({
    required this.questionTitle,
    required this.selectedOptionId,
    this.correctOptionId,
    required this.isCorrect,
    required this.marksAwarded,
  });

  factory QuestionReviewModel.fromJson(Map<String, dynamic> json) {
    final qData = json['question'] ?? {};

    final selectedId =
        json['selectedOptionId']?.toString() ??
        json['selectedOption']?['optionId']?.toString() ??
        json['selectedOption']?['id']?.toString() ??
        json['selectedOption']?['_id']?.toString() ??
        '-';

    final correctId =
        json['correctOptionId']?.toString() ??
        json['correctOption']?['optionId']?.toString() ??
        json['correctOption']?['id']?.toString() ??
        json['correctOption']?['_id']?.toString();

    final awarded = json['marksAwarded'];

    return QuestionReviewModel(
      questionTitle: qData['title']?.toString() ?? qData['text']?.toString() ?? qData['question']?.toString() ?? 'Question',
      selectedOptionId: selectedId,
      correctOptionId: correctId,
      isCorrect: json['isCorrect'] == true,
      marksAwarded: (awarded is num) ? awarded.toDouble() : double.tryParse(awarded?.toString() ?? '0') ?? 0,
    );
  }
}
