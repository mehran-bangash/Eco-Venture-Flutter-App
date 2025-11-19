class QuizModel {
  String? id;
  String category;
  String title;
  int order;
  int passingPercentage;
  String? imageUrl;
  List<QuestionModel> questions;

  QuizModel({
    this.id,
    required this.category,
    required this.title,
    required this.order,
    required this.passingPercentage,
    this.imageUrl,
    required this.questions,
  });

  // Factory to parse data from 'Public/Quizzes' safely
  factory QuizModel.fromMap(String id, Map<String, dynamic> map) {
    return QuizModel(
      id: id,
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      order: map['order']?.toInt() ?? 0,
      passingPercentage: map['passing_percentage']?.toInt() ?? 60,
      imageUrl: map['image_url'],
      questions: List<QuestionModel>.from(
        (map['questions'] as List<dynamic>? ?? []).map<QuestionModel>(
          // SAFE CONVERSION: Prevents "type cast" crash
              (x) => QuestionModel.fromMap(Map<String, dynamic>.from(x as Map)),
        ),
      ),
    );
  }

  // --- COPY WITH METHOD ---
  QuizModel copyWith({
    String? id,
    String? category,
    String? title,
    int? order,
    int? passingPercentage,
    String? imageUrl,
    List<QuestionModel>? questions,
  }) {
    return QuizModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      order: order ?? this.order,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      questions: questions ?? this.questions,
    );
  }
}

class QuestionModel {
  String question;
  List<String> options;
  String answer;
  String? imageUrl;

  QuestionModel({
    required this.question,
    required this.options,
    required this.answer,
    this.imageUrl,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  // --- COPY WITH METHOD ---
  QuestionModel copyWith({
    String? question,
    List<String>? options,
    String? answer,
    String? imageUrl,
  }) {
    return QuestionModel(
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}