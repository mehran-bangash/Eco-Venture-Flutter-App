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
// --- UPDATED STORY MODEL ---

class StoryModel {
  final String id;
  final String adminId;
  final String title;
  final String thumbnailUrl;
  final List<StoryPage> pages;
  final int likes;
  final int dislikes;
  final int views;
  final Map<String, bool> userLikes;

  StoryModel({
    required this.id,
    required this.adminId,
    required this.title,
    required this.thumbnailUrl,
    required this.pages,
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
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      pages: pagesList,

      // --- FIX 1: Added Type-Safe Parsing for Counters ---
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
      'thumbnailUrl': thumbnailUrl,
      'pages': pages.map((e) => e.toMap()).toList(),
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
      'userLikes': userLikes,
    };
  }

  // --- FIX 2: Added the 'copyWith' Method ---
  // This is required for the ViewModel's optimistic UI updates.
  StoryModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? thumbnailUrl,
    List<StoryPage>? pages,
    int? likes,
    int? dislikes,
    int? views,
    Map<String, bool>? userLikes,
  }) {
    return StoryModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pages: pages ?? this.pages,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      userLikes: userLikes ?? this.userLikes,
    );
  }
}