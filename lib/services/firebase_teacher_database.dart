import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/qr_hunt_model.dart';
import '../models/quiz_topic_model.dart';
import '../models/stem_challenge_model.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
import '../services/shared_preferences_helper.dart';

class FirebaseTeacherDatabase {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateKey() => _database.ref().push().key!;

  // Helper to get Teacher ID safely
  Future<String> _getTeacherId() async {
    String? id = await SharedPreferencesHelper.instance.getUserId();
    id ??= _auth.currentUser?.uid;
    if (id == null) throw Exception("Teacher ID not found. Please login.");
    return id;
  }

  // ==================================================
  //  TEACHER QUIZ MODULE
  // ==================================================

  // 1. ADD QUIZ
  Future<void> addQuizTopic(QuizTopicModel topic) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();

      final topicWithMeta = topic.copyWith(
        id: newKey,
        creatorId: teacherId,
        createdBy: 'teacher',
      );

      final Map<String, dynamic> data = topicWithMeta.toMap();

      // Path: Teacher_Content/{TeacherID}/Quizzes/{Category}/{TopicID}
      final path = 'Teacher_Content/$teacherId/Quizzes/${topic.category}/$newKey';

      await _database.ref(path).set(data);

    } catch (e) {
      throw Exception('Failed to add quiz: $e');
    }
  }

  // 2. UPDATE QUIZ
  Future<void> updateQuizTopic(QuizTopicModel topic) async {
    if (topic.id == null) throw Exception("Topic ID is missing");
    try {
      final teacherId = await _getTeacherId();

      final topicWithMeta = topic.copyWith(
        creatorId: teacherId,
        createdBy: 'teacher',
      );

      final Map<String, dynamic> data = topicWithMeta.toMap();
      final path = 'Teacher_Content/$teacherId/Quizzes/${topic.category}/${topic.id}';

      await _database.ref(path).update(data);
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  // 3. DELETE QUIZ
  Future<void> deleteQuizTopic(String topicId, String category) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Quizzes/$category/$topicId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // 4. FETCH QUIZZES (Stream)
  Stream<List<QuizTopicModel>> getTeacherQuizzesStream(String category) async* {
    final teacherId = await _getTeacherId();

    yield* _database.ref('Teacher_Content/$teacherId/Quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QuizTopicModel> topics = [];

        mapData.forEach((key, value) {
          final topicMap = Map<String, dynamic>.from(value as Map);
          topics.add(QuizTopicModel.fromMap(key.toString(), category, topicMap));
        });

        return topics;
      } catch (e) {
        print("Error parsing teacher quizzes: $e");
        return [];
      }
    });
  }

  // ==================================================
  //  TEACHER STEM MODULE
  // ==================================================

  // 1. ADD STEM CHALLENGE
  Future<void> addStemChallenge(StemChallengeModel challenge) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();

      final challengeWithMeta = challenge.copyWith(
        id: newKey,
        adminId: teacherId, // Store Teacher ID here (reusing 'adminId' field)
      );

      final Map<String, dynamic> data = challengeWithMeta.toMap();

      // Path: Teacher_Content/{TeacherID}/StemChallenges/{Category}/{ChallengeID}
      final path = 'Teacher_Content/$teacherId/StemChallenges/${challenge.category}/$newKey';

      await _database.ref(path).set(data);

    } catch (e) {
      throw Exception('Failed to add STEM challenge: $e');
    }
  }

  // 2. UPDATE STEM CHALLENGE
  Future<void> updateStemChallenge(StemChallengeModel challenge) async {
    if (challenge.id == null) throw Exception("Challenge ID is missing");
    try {
      final teacherId = await _getTeacherId();

      final challengeWithMeta = challenge.copyWith(
        adminId: teacherId,
      );

      final Map<String, dynamic> data = challengeWithMeta.toMap();
      final path = 'Teacher_Content/$teacherId/StemChallenges/${challenge.category}/${challenge.id}';

      await _database.ref(path).update(data);
    } catch (e) {
      throw Exception('Failed to update STEM challenge: $e');
    }
  }

  // 3. DELETE STEM CHALLENGE
  Future<void> deleteStemChallenge(String challengeId, String category) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/StemChallenges/$category/$challengeId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete STEM challenge: $e');
    }
  }

  // 4. FETCH STEM CHALLENGES (Stream)
  Stream<List<StemChallengeModel>> getTeacherStemChallengesStream(String category) async* {
    final teacherId = await _getTeacherId();

    print("DEBUG: Fetching STEM from: Teacher_Content/$teacherId/StemChallenges/$category");

    yield* _database.ref('Teacher_Content/$teacherId/StemChallenges/$category').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) {
        print("DEBUG: No data found at this path.");
        return [];
      }

      final List<StemChallengeModel> challenges = [];

      if (data is Map) {
        data.forEach((key, value) {
          try {
            // 1. Validate it's a Map
            if (value is Map) {
              final challengeMap = Map<String, dynamic>.from(value);

              // 2. Ensure ID exists
              challengeMap['id'] = key.toString();

              // 3. Parse safely
              challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
            }
          } catch (e) {
            print("⚠️ Skipped invalid STEM challenge ($key): $e");
          }
        });
      }

      print("DEBUG: Successfully parsed ${challenges.length} challenges.");
      return challenges;
    });
  }

  // ==================================================
  //  TEACHER MULTIMEDIA MODULE (Videos)
  // ==================================================

  Future<void> addVideo(VideoModel video) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final videoWithMeta = video.copyWith(id: newKey, adminId: teacherId);

      final path = 'Teacher_Content/$teacherId/Multimedia/Videos/${newKey}';
      await _database.ref(path).set(videoWithMeta.toMap());
    } catch (e) {
      throw Exception('Failed to add video: $e');
    }
  }

  Future<void> updateVideo(VideoModel video) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Multimedia/Videos/${video.id}';
      await _database.ref(path).update(video.toMap());
    } catch (e) {
      throw Exception('Failed to update video: $e');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Multimedia/Videos/$videoId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  Stream<List<VideoModel>> getTeacherVideosStream() async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/Multimedia/Videos').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<VideoModel> videos = [];
        mapData.forEach((key, value) {
          // FIX: Ensure ID is inside the map and call fromMap with 1 argument
          final videoMap = Map<String, dynamic>.from(value as Map);
          videoMap['id'] = key.toString(); // Inject ID into map
          videos.add(VideoModel.fromMap(videoMap));
        });
        return videos;
      } catch (e) {
        print("Error parsing videos: $e");
        return [];
      }
    });
  }

  // ==================================================
  //  TEACHER MULTIMEDIA MODULE (Stories)
  // ==================================================

  Future<void> addStory(StoryModel story) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final storyWithMeta = story.copyWith(id: newKey, adminId: teacherId);

      final path = 'Teacher_Content/$teacherId/Multimedia/Stories/${newKey}';
      await _database.ref(path).set(storyWithMeta.toMap());
    } catch (e) {
      throw Exception('Failed to add story: $e');
    }
  }

  Future<void> updateStory(StoryModel story) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Multimedia/Stories/${story.id}';
      await _database.ref(path).update(story.toMap());
    } catch (e) {
      throw Exception('Failed to update story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Multimedia/Stories/$storyId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  Stream<List<StoryModel>> getTeacherStoriesStream() async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/Multimedia/Stories').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<StoryModel> stories = [];
        mapData.forEach((key, value) {
          // FIX: Ensure ID is inside the map and call fromMap with 1 argument
          final storyMap = Map<String, dynamic>.from(value as Map);
          storyMap['id'] = key.toString(); // Inject ID
          stories.add(StoryModel.fromMap(storyMap));
        });
        return stories;
      } catch (e) {
        print("Error parsing stories: $e");
        return [];
      }
    });
  }


  // ==================================================
  //  TEACHER QR HUNT MODULE
  // ==================================================

  // 1. ADD HUNT
  Future<void> addQrHunt(QrHuntModel hunt) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final huntWithMeta = hunt.copyWith(id: newKey, adminId: teacherId);

      final path = 'Teacher_Content/$teacherId/QrHunts/$newKey';
      await _database.ref(path).set(huntWithMeta.toMap());
    } catch (e) {
      throw Exception('Failed to add QR hunt: $e');
    }
  }

  // 2. UPDATE HUNT
  Future<void> updateQrHunt(QrHuntModel hunt) async {
    if (hunt.id == null) throw Exception("Hunt ID missing");
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/QrHunts/${hunt.id}';
      await _database.ref(path).update(hunt.toMap());
    } catch (e) {
      throw Exception('Failed to update QR hunt: $e');
    }
  }

  // 3. DELETE HUNT
  Future<void> deleteQrHunt(String huntId) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/QrHunts/$huntId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete QR hunt: $e');
    }
  }

  // 4. FETCH HUNTS
  Stream<List<QrHuntModel>> getTeacherQrHuntsStream() async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/QrHunts').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QrHuntModel> hunts = [];
        mapData.forEach((key, value) {
          // Ensure ID is injected correctly
          final huntMap = Map<String, dynamic>.from(value as Map);
          huntMap['id'] = key.toString();
          hunts.add(QrHuntModel.fromMap(key.toString(), huntMap));
        });
        return hunts;
      } catch (e) {
        print("Error parsing QR hunts: $e");
        return [];
      }
    });
  }
}