

class StemChallengeModel {
  String? id;
  String? adminId;
  final String title;
  final String category;
  final String difficulty;
  final int points;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> videoUrls;
  final String? thumbnailUrl;
  final List<String> materials;
  final List<String> steps;
  final bool isSensitive;
  final List<String> tags;
  final String ageGroup;
  final DateTime createdAt;

  StemChallengeModel({
    this.id,
    this.adminId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.points,
    this.imageUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.videoUrls = const [],
    this.thumbnailUrl,
    required this.materials,
    this.isSensitive = false,
    this.tags = const [],
    required this.steps,
    required this.ageGroup,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'points': points,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'videoUrls': videoUrls,
      'thumbnailUrl': thumbnailUrl,
      'materials': materials,
      'steps': steps,
      'tags': tags,
      'isSensitive': isSensitive,
      'ageGroup': ageGroup,
      // FIXED for Realtime Database: Convert to String
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StemChallengeModel.fromMap(String id, Map<String, dynamic> map) {
    return StemChallengeModel(
      id: id,
      adminId: map['adminId'],
      title: map['title'] ?? '',
      category: map['category'] ?? 'Science',
      difficulty: map['difficulty'] ?? 'Easy',
      points: map['points'] is int ? map['points'] : int.tryParse(map['points'].toString()) ?? 0,
      imageUrl: map['imageUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      thumbnailUrl: map['thumbnailUrl'],
      materials: List<String>.from(map['materials'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      isSensitive: map['isSensitive'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      ageGroup: map['ageGroup'] ?? '6 - 8',
      // FIXED: Parse from ISO String
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  StemChallengeModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? category,
    String? difficulty,
    int? points,
    String? imageUrl,
    List<String>? imageUrls,
    String? videoUrl,
    List<String>? videoUrls,
    String? thumbnailUrl,
    List<String>? materials,
    List<String>? tags,
    bool? isSensitive,
    List<String>? steps,
    String? ageGroup,
    DateTime? createdAt,
  }) {
    return StemChallengeModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      videoUrls: videoUrls ?? this.videoUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      materials: materials ?? this.materials,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      isSensitive: isSensitive ?? this.isSensitive,
      ageGroup: ageGroup ?? this.ageGroup,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}