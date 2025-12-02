class VideoModel {
  final String id;
  final String adminId;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String? thumbnailUrl;
  final String duration;
  final DateTime uploadedAt;
  final int likes;
  final int dislikes;
  final int views;
  final String status;
  final String createdBy; // 'admin' or 'teacher'
  final Map<String, bool> userLikes;

  VideoModel({
    required this.id,
    required this.adminId,
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
    this.createdBy = 'admin',
    Map<String, bool>? userLikes,
  }) : userLikes = userLikes ?? {};

  // --- 1. TO MAP (Required for Firebase Write) ---
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
      'created_by': createdBy,
      'userLikes': userLikes, // Firebase handles Map<String,bool> natively usually, or convert manually if needed
    };
  }

  // --- 2. FROM MAP ---
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    int safeInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

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
      likes: safeInt(map['likes']),
      dislikes: safeInt(map['dislikes']),
      views: safeInt(map['views']),
      status: map['status'] ?? 'published',
      createdBy: map['created_by'] ?? 'admin',
      userLikes: Map<String, bool>.from(map['userLikes'] ?? {}),
    );
  }

  // --- 3. COPY WITH ---
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
    String? createdBy,
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
      createdBy: createdBy ?? this.createdBy,
      userLikes: userLikes ?? this.userLikes,
    );
  }
}