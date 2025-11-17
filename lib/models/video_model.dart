class VideoModel {
  final String id;
  final String adminId;
  final String duration;
  final int likes;
  final int dislikes;
  final String status;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final int views;
  final Map<String, bool> userLikes;

  VideoModel({
    required this.id,
    required this.adminId,
    required this.duration,
    required this.likes,
    required this.dislikes,
    required this.status,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.views,
    Map<String, bool>? userLikes,
  }) : userLikes = userLikes ?? {};

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    // safe parse helpers
    int safeInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    // convert userLikes to Map<String,bool> safely
    final rawUserLikes = map['userLikes'];
    final Map<String, bool> userLikesMap = {};
    if (rawUserLikes is Map) {
      rawUserLikes.forEach((k, v) {
        try {
          if (v is bool) {
            userLikesMap['$k'] = v;
          } else if (v is num) {
            userLikesMap['$k'] = v != 0;
          } else if (v is String) {
            final lv = v.toLowerCase();
            userLikesMap['$k'] = (lv == 'true' || lv == '1' || lv == 'yes');
          } else {
            userLikesMap['$k'] = false;
          }
        } catch (_) {
          userLikesMap['$k'] = false;
        }
      });
    }

    return VideoModel(
      id: map['id'] ?? '',
      adminId: map['adminId'] ?? '',
      duration: map['duration'] ?? '',
      likes: safeInt(map['likes']),
      dislikes: safeInt(map['dislikes']),
      status: map['status'] ?? 'published',
      title: map['title'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      views: safeInt(map['views']),
      userLikes: userLikesMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'duration': duration,
      'likes': likes,
      'dislikes': dislikes,
      'status': status,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'views': views,
      // ensure values are proper bools
      'userLikes': userLikes.map((k, v) => MapEntry(k, v)),
    };
  }

  VideoModel copyWith({
    String? id,
    String? adminId,
    String? duration,
    int? likes,
    int? dislikes,
    String? status,
    String? title,
    String? videoUrl,
    String? thumbnailUrl,
    int? views,
    Map<String, bool>? userLikes,
  }) {
    return VideoModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      duration: duration ?? this.duration,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      status: status ?? this.status,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      views: views ?? this.views,
      userLikes: userLikes ?? Map<String, bool>.from(this.userLikes),
    );
  }
}
