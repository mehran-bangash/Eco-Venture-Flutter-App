class ChildQuizProgressModel {
  final String topicId; // Changed from quizId to topicId
  final String category;
  final int levelOrder;

  final int correctAnswers;
  final int wrongAnswers;
  final double attemptPercentage;
  final DateTime attemptDate;

  final List<Map<String, dynamic>> questionDetails;
  final bool isPassed;
  final int attempts;

  ChildQuizProgressModel({
    required this.topicId,
    required this.category,
    required this.levelOrder,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.attemptPercentage,
    required this.attemptDate,
    this.questionDetails = const [],
    required this.isPassed,
    required this.attempts,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic_id': topicId,
      'category': category,
      'level_order': levelOrder,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'attempt_percentage': attemptPercentage,
      'attempt_date': attemptDate.toIso8601String(),
      'question_details': questionDetails,
      'is_passed': isPassed,
      'attempts': attempts,
    };
  }

  factory ChildQuizProgressModel.fromMap(Map<String, dynamic> map) {
    return ChildQuizProgressModel(
      topicId: map['topic_id'] ?? '',
      category: map['category'] ?? '',
      levelOrder: map['level_order']?.toInt() ?? 0,
      correctAnswers: map['correct_answers']?.toInt() ?? 0,
      wrongAnswers: map['wrong_answers']?.toInt() ?? 0,
      attemptPercentage: (map['attempt_percentage'] ?? 0).toDouble(),
      attemptDate: DateTime.tryParse(map['attempt_date'] ?? '') ?? DateTime.now(),
      questionDetails: List<Map<String, dynamic>>.from(
        (map['question_details'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
      isPassed: map['is_passed'] ?? false,
      attempts: map['attempts']?.toInt() ?? 0,
    );
  }

  // --- UPDATED COPYWITH ---
  ChildQuizProgressModel copyWith({
    String? topicId,
    String? category,
    int? levelOrder,
    int? correctAnswers,
    int? wrongAnswers,
    double? attemptPercentage,
    DateTime? attemptDate,
    List<Map<String, dynamic>>? questionDetails,
    bool? isPassed,
    int? attempts,
  }) {
    return ChildQuizProgressModel(
      topicId: topicId ?? this.topicId,
      category: category ?? this.category,
      levelOrder: levelOrder ?? this.levelOrder,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      attemptPercentage: attemptPercentage ?? this.attemptPercentage,
      attemptDate: attemptDate ?? this.attemptDate,
      questionDetails: questionDetails ?? this.questionDetails,
      isPassed: isPassed ?? this.isPassed,
      attempts: attempts ?? this.attempts,
    );
  }
}