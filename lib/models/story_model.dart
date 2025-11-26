class StoryPage {
  final String text;
  final String imageUrl;

  StoryPage({required this.text, required this.imageUrl});

  factory StoryPage.fromMap(Map<String, dynamic> map) {
    return StoryPage(
      text: map['text'] ?? '',
      imageUrl: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'image': imageUrl};
  }
}

class StoryModel {
  final String id;
  final String adminId;
  final String title;
  final String description; // Added
  final String? thumbnailUrl; // Made nullable
  final List<StoryPage> pages;
  final DateTime uploadedAt; // Added
  final int likes;
  final int dislikes;
  final int views;
  final Map<String, bool> userLikes;

  StoryModel({
    this.id = '',
    this.adminId = '',
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.pages,
    required this.uploadedAt,
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
    Map<String, bool>? userLikes,
  }) : userLikes = userLikes ?? {};

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    final pagesList = (map['pages'] as List<dynamic>?)
        ?.map((e) => StoryPage.fromMap(Map<String, dynamic>.from(e)))
        .toList() ??
        [];

    return StoryModel(
      id: map['id'] ?? '',
      adminId: map['adminId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      pages: pagesList,
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
      likes: (map['likes'] as num? ?? 0).toInt(),
      dislikes: (map['dislikes'] as num? ?? 0).toInt(),
      views: (map['views'] as num? ?? 0).toInt(),
      userLikes: Map<String, bool>.from(map['userLikes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'pages': pages.map((e) => e.toMap()).toList(),
      'uploadedAt': uploadedAt.toIso8601String(),
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
      'userLikes': userLikes,
    };
  }

  StoryModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? description,
    String? thumbnailUrl,
    List<StoryPage>? pages,
    DateTime? uploadedAt,
    int? likes,
    int? dislikes,
    int? views,
    Map<String, bool>? userLikes,
  }) {
    return StoryModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pages: pages ?? this.pages,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      userLikes: userLikes ?? this.userLikes,
    );
  }
}