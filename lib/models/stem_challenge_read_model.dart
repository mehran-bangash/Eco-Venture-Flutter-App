class StemChallengeReadModel {
  final String id;
  final String adminId;
  final String title;
  final String category;
  final String difficulty;
  final int points;
  final String? imageUrl;
  final List<String> materials;
  final List<String> steps;

  StemChallengeReadModel({
    required this.id,
    required this.adminId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.points,
    this.imageUrl,
    required this.materials,
    required this.steps,
  });

  factory StemChallengeReadModel.fromMap(String id, Map<String, dynamic> map) {
    return StemChallengeReadModel(
      id: id,
      adminId: map['adminId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      points: map['points']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      materials: List<String>.from(map['materials'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
    );
  }

  // Added CopyWith Method
  StemChallengeReadModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? category,
    String? difficulty,
    int? points,
    String? imageUrl,
    List<String>? materials,
    List<String>? steps,
  }) {
    return StemChallengeReadModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      materials: materials ?? this.materials,
      steps: steps ?? this.steps,
    );
  }
}