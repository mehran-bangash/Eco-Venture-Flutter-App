import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

// Import your models (make sure path is correct)
import '../models/story_model.dart';
import '../models/video_model.dart';

class DatabaseVideoStory {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Fetch all public videos as VideoModel
  Future<List<VideoModel>> fetchPublicVideos() async {
    final snapshot = await _database.ref('Public/Videos').get();

    if (!snapshot.exists) {
      print("NO VIDEOS FOUND IN PUBLIC/Videos");
      return [];
    }

    final value = snapshot.value;

    print("RAW SNAPSHOT VALUE = $value");
    print("TYPE = ${value.runtimeType}");

    List<VideoModel> videos = [];

    // Case 1: Firebase returns Map
    if (value is Map) {
      value.forEach((key, val) {
        if (val == null) return;

        final map = Map<String, dynamic>.from(val);
        map['id'] = key;

        videos.add(VideoModel.fromMap(map));
      });
    }

    // Case 2: Firebase returns a List (very rare but possible)
    if (value is List) {
      for (int i = 0; i < value.length; i++) {
        if (value[i] == null) continue;

        final map = Map<String, dynamic>.from(value[i]);
        map['id'] = i.toString();

        videos.add(VideoModel.fromMap(map));
      }
    }

    print("FETCHED VIDEOS LENGTH = ${videos.length}");

    return videos;
  }



  /// Fetch all public stories as StoryModel
  Future<List<StoryModel>> fetchPublicStories() async {
    final snapshot = await _database.ref('Public/Stories').get();
    if (!snapshot.exists) return [];

    final Map data = snapshot.value as Map;
    return data.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value);
      map['id'] = e.key;
      return StoryModel.fromMap(map);
    }).toList();
  }

  /// Atomically increments the view count for a video.
  /// This one works because it's a simple write.
  Future<void> incrementVideoView(String videoId) async {
    final ref = _database.ref('Public/Videos/$videoId/views');
    await ref.set(ServerValue.increment(1));
  }

  Future<void> toggleVideoLikeDislike({
    required String videoId,
    required String userId,
    required bool isLiking,
  }) async {
    final videoRef = _database.ref('Public/Videos/$videoId');

    print("🔹 LIKE/DISLIKE START");
    print("Video ID = $videoId");
    print("User ID = $userId");
    print("Action = ${isLiking ? "LIKE" : "DISLIKE"}");

    final result = await videoRef.runTransaction((Object? currentData) {
      // If node is missing -> CREATE IT
      if (currentData == null || currentData is! Map) {
        print("⚠️ VIDEO NODE MISSING — CREATING DEFAULT NODE...");

        return Transaction.success({
          "id": videoId,
          "likes": 0,
          "dislikes": 0,
          "views": 0,
          "userLikes": { userId: isLiking },
        });
      }

      Map<String, dynamic> video = Map<String, dynamic>.from(currentData);

      video.putIfAbsent("likes", () => 0);
      video.putIfAbsent("dislikes", () => 0);
      video.putIfAbsent("views", () => 0);
      video.putIfAbsent("userLikes", () => {});

      Map<String, dynamic> userLikes =
      Map<String, dynamic>.from(video["userLikes"]);

      bool? previous = userLikes[userId];

      // Logic handling
      if (isLiking) {
        if (previous == true) {
          video["likes"] -= 1;
          userLikes.remove(userId);
        } else {
          video["likes"] += 1;
          if (previous == false) video["dislikes"] -= 1;
          userLikes[userId] = true;
        }
      } else {
        if (previous == false) {
          video["dislikes"] -= 1;
          userLikes.remove(userId);
        } else {
          video["dislikes"] += 1;
          if (previous == true) video["likes"] -= 1;
          userLikes[userId] = false;
        }
      }

      video["userLikes"] = userLikes;

      print("📌 VIDEO AFTER UPDATE = $video");

      return Transaction.success(video);
    });

    if (result.committed) {
      print("✅ LIKE/DISLIKE UPDATE SUCCESS");
    } else {
      print("❌ FAILED TO COMMIT LIKE/DISLIKE");
    }
  }


}