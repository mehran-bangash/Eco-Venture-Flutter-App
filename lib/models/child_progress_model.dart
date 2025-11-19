class ChildQuizProgressModel {
  final String quizId;
  final String category;
  final int order; // Unlocks Level 1, 2, 3...

  // --- NEW TRACKING FIELDS ---
  final int correctAnswers;
  final int wrongAnswers;
  final double attemptPercentage; // e.g., 85.5
  final DateTime attemptDate;

  // --- IMPORTANT EXTRAS FOR ANALYTICS ---
  final List<Map<String, dynamic>> questionDetails; // [{"q": "Lion sound?", "isCorrect": true}]

  // Summary
  final bool isPassed;
  final int attempts; // Total times tried

  ChildQuizProgressModel({
    required this.quizId,
    required this.category,
    required this.order,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.attemptPercentage,
    required this.attemptDate,
    this.questionDetails = const [],
    required this.isPassed,
    required this.attempts,
  });

  // Save to Firebase 'child_quiz_progress' node
  Map<String, dynamic> toMap() {
    return {
      'quiz_id': quizId,
      'category': category,
      'order': order,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'attempt_percentage': attemptPercentage,
      'attempt_date': attemptDate.toIso8601String(),
      'question_details': questionDetails, // Saves detailed log
      'is_passed': isPassed,
      'attempts': attempts,
    };
  }

  // Read from Firebase
  factory ChildQuizProgressModel.fromMap(Map<String, dynamic> map) {
    return ChildQuizProgressModel(
      quizId: map['quiz_id'] ?? '',
      category: map['category'] ?? '',
      order: map['order']?.toInt() ?? 0,
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

  // CopyWith Method for Immutable Updates
  ChildQuizProgressModel copyWith({
    String? quizId,
    String? category,
    int? order,
    int? correctAnswers,
    int? wrongAnswers,
    double? attemptPercentage,
    DateTime? attemptDate,
    List<Map<String, dynamic>>? questionDetails,
    bool? isPassed,
    int? attempts,
  }) {
    return ChildQuizProgressModel(
      quizId: quizId ?? this.quizId,
      category: category ?? this.category,
      order: order ?? this.order,
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