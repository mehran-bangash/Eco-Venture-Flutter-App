import 'dart:async';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:firebase_database/firebase_database.dart';
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

  /// Atomically increments the view count for a story.
  Future<void> incrementStoryView(String storyId) async {
    final ref = _database.ref('Public/Stories/$storyId/views');
    await ref.set(ServerValue.increment(1));
  }

  /// Handles like/dislike for stories
  Future<void> toggleStoryLikeDislike({
    required String storyId,
    required bool isLiking,
  }) async {
    // Get the User ID from your helper
    final String? userId = await SharedPreferencesHelper.instance.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception("User is not logged in.");
    }
    // --- NEW STORY LOGIC ---

    /// Fetch all public stories as StoryModel
    Future<List<StoryModel>> fetchPublicStories() async {
      final snapshot = await _database.ref('Public/Stories').get();
      if (!snapshot.exists) {
        print("NO STORIES FOUND IN Public/Stories");
        return [];
      }

      final value = snapshot.value;
      List<StoryModel> stories = [];

      // Match the same robust logic as fetchPublicVideos
      if (value is Map) {
        value.forEach((key, val) {
          if (val == null) return;
          final map = Map<String, dynamic>.from(val);
          map['id'] = key;
          // Use the robust StoryModel.fromMap we fixed
          stories.add(StoryModel.fromMap(map));
        });
      }
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          if (value[i] == null) continue;
          final map = Map<String, dynamic>.from(value[i]);
          map['id'] = i.toString();
          stories.add(StoryModel.fromMap(map));
        }
      }
      return stories;
    }

    // Point to the Stories node
    final storyRef = _database.ref('Public/Stories/$storyId');

    final result = await storyRef.runTransaction((Object? currentData) {
      if (currentData == null || currentData is! Map) {
        // Node is missing, create it
        return Transaction.success({
          "id": storyId,
          "likes": isLiking ? 1 : 0,
          "dislikes": isLiking ? 0 : 1,
          "views": 0,
          "userLikes": { userId: isLiking },
        });
      }

      // Use 'story' variable for clarity
      Map<String, dynamic> story = Map<String, dynamic>.from(currentData);
      story.putIfAbsent("likes", () => 0);
      story.putIfAbsent("dislikes", () => 0);
      story.putIfAbsent("views", () => 0);
      story.putIfAbsent("userLikes", () => {});
      Map<String, dynamic> userLikes = Map<String, dynamic>.from(story["userLikes"]);

      bool? previous = userLikes[userId];

      if (isLiking) {
        if (previous == true) {
          story["likes"] -= 1;
          userLikes.remove(userId);
        } else {
          story["likes"] += 1;
          if (previous == false) story["dislikes"] -= 1;
          userLikes[userId] = true;
        }
      } else {
        if (previous == false) {
          story["dislikes"] -= 1;
          userLikes.remove(userId);
        } else {
          story["dislikes"] += 1;
          if (previous == true) story["likes"] -= 1;
          userLikes[userId] = false;
        }
      }
      story["userLikes"] = userLikes;
      return Transaction.success(story);
    });

    if (result.committed) {
      print("✅ STORY LIKE/DISLIKE UPDATE SUCCESS");
    } else {
      print("❌ FAILED TO COMMIT STORY LIKE/DISLIKE");
      throw Exception("Story transaction failed");
    }
  }


}