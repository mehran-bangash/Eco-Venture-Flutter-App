class StoryPage {
  final String text;
  final String imageUrl;

  StoryPage({required this.text, required this.imageUrl});

  factory StoryPage.fromMap(Map<String, dynamic> map) {
    return StoryPage(
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'imageUrl': imageUrl};
  }
}

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
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      views: map['views'] ?? 0,
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
}
