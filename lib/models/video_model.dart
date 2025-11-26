class VideoModel {
  final String id;
  final String adminId;
  final String title;
  final String description; // Added
  final String category;
  final String videoUrl;
  final String? thumbnailUrl; // Changed to nullable
  final String duration;
  final DateTime uploadedAt; // Added
  final int likes;
  final int dislikes;
  final int views;
  final String status;
  final Map<String, bool> userLikes;

  VideoModel({
    this.id = '',
    this.adminId = '',
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.uploadedAt,
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
    this.status = 'published',
    Map<String, bool>? userLikes,
  }) : userLikes = userLikes ?? {};

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      adminId: map['adminId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? '00:00',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
      likes: (map['likes'] as num? ?? 0).toInt(),
      dislikes: (map['dislikes'] as num? ?? 0).toInt(),
      views: (map['views'] as num? ?? 0).toInt(),
      status: map['status'] ?? 'published',
      userLikes: Map<String, bool>.from(map['userLikes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'uploadedAt': uploadedAt.toIso8601String(),
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
      'status': status,
      'userLikes': userLikes,
    };
  }

  VideoModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? description,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    String? duration,
    DateTime? uploadedAt,
    int? likes,
    int? dislikes,
    int? views,
    String? status,
    Map<String, bool>? userLikes,
  }) {
    return VideoModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      status: status ?? this.status,
      userLikes: userLikes ?? this.userLikes,
    );
  }
}