class QuizTopicModel {
  String? id;
  final String category;
  final String topicName;
  final List<QuizLevelModel> levels;

  QuizTopicModel({
    this.id,
    required this.category,
    required this.topicName,
    required this.levels,
  });

  factory QuizTopicModel.fromMap(String id, String category, Map<String, dynamic> map) {
    var rawLevels = map['levels'];
    List<QuizLevelModel> parsedLevels = [];

    if (rawLevels != null) {
      if (rawLevels is Map) {
        rawLevels.forEach((key, value) {
          if (value is Map) {
            parsedLevels.add(QuizLevelModel.fromMap(key.toString(), Map<String, dynamic>.from(value)));
          }
        });
      } else if (rawLevels is List) {
        for (var i = 0; i < rawLevels.length; i++) {
          final item = rawLevels[i];
          if (item != null && item is Map) {
            parsedLevels.add(QuizLevelModel.fromMap(i.toString(), Map<String, dynamic>.from(item)));
          }
        }
      }
    }

    parsedLevels.sort((a, b) => a.order.compareTo(b.order));

    return QuizTopicModel(
      id: id,
      category: category,
      topicName: map['topic_name'] ?? '',
      levels: parsedLevels,
    );
  }

  // --- ADDED COPYWITH ---
  QuizTopicModel copyWith({
    String? id,
    String? category,
    String? topicName,
    List<QuizLevelModel>? levels,
  }) {
    return QuizTopicModel(
      id: id ?? this.id,
      category: category ?? this.category,
      topicName: topicName ?? this.topicName,
      levels: levels ?? this.levels,
    );
  }
}

class QuizLevelModel {
  final int order;
  final String title;
  final int passingPercentage;
  final int points;
  final List<QuestionModel> questions;

  QuizLevelModel({
    required this.order,
    required this.title,
    required this.passingPercentage,
    required this.points,
    required this.questions,
  });

  factory QuizLevelModel.fromMap(String orderKey, Map<String, dynamic> map) {
    return QuizLevelModel(
      order: int.tryParse(orderKey) ?? map['order'] ?? 1,
      title: map['title'] ?? '',
      passingPercentage: map['passing_percentage']?.toInt() ?? 60,
      points: map['points']?.toInt() ?? 0,
      questions: List<QuestionModel>.from(
        (map['questions'] as List<dynamic>? ?? []).map<QuestionModel>(
              (x) => QuestionModel.fromMap(Map<String, dynamic>.from(x as Map)),
        ),
      ),
    );
  }

  // --- ADDED COPYWITH ---
  QuizLevelModel copyWith({
    int? order,
    String? title,
    int? passingPercentage,
    int? points,
    List<QuestionModel>? questions,
  }) {
    return QuizLevelModel(
      order: order ?? this.order,
      title: title ?? this.title,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      points: points ?? this.points,
      questions: questions ?? this.questions,
    );
  }
}

class QuestionModel {
  final String question;
  final List<String> options;
  final String answer;
  final String? imageUrl;

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

  // --- ADDED COPYWITH ---
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