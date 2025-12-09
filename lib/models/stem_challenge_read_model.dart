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

  // PARENT FILTERING FIELDS
  final bool isSensitive;
  final List<String> tags;

  // NEW FIELDS FOR DUAL FETCH
  final String createdBy; // 'admin' or 'teacher'
  final String creatorId;

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
    this.isSensitive = false, // Default to false
    this.tags = const [], // Default empty
    this.createdBy = 'admin',
    this.creatorId = '',
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
      // ADD THESE TWO LINES:
      isSensitive: map['isSensitive'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      createdBy: map['created_by'] ?? 'admin',
      creatorId: map['creator_id'] ?? '',
    );
  }

  // Add toMap() method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'points': points,
      'imageUrl': imageUrl,
      'materials': materials,
      'steps': steps,
      'isSensitive': isSensitive, // ADD THIS
      'tags': tags, // ADD THIS
      'created_by': createdBy,
      'creator_id': creatorId,
    };
  }

  // Updated copyWith method to include isSensitive and tags
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
    bool? isSensitive, // ADD THIS
    List<String>? tags, // ADD THIS
    String? createdBy,
    String? creatorId,
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
      isSensitive: isSensitive ?? this.isSensitive, // ADD THIS
      tags: tags ?? this.tags, // ADD THIS
      createdBy: createdBy ?? this.createdBy,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}