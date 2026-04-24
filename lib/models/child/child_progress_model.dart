class ChildQuizProgressModel {
  final String topicId;
  final String topicName; // NEW: Added to store human-readable name
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
    required this.topicName,
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
      'topic_name': topicName, // Save name to DB
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
      topicName: map['topic_name'] ?? 'Quiz', // Read name from DB
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
}