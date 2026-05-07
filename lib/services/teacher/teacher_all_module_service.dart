import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/qr_hunt_model.dart';
import '../../models/quiz_topic_model.dart';
import '../../models/stem_challenge_model.dart';
import '../../models/story_model.dart';
import '../../models/video_model.dart';
import '../shared_preferences_helper.dart';


class TeacherAllModuleService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateKey() => _database.ref().push().key!;

  // Helper to get Teacher ID safely
  Future<String> _getTeacherId() async {
    String? id = SharedPreferencesHelper.instance.getUserId();
    id ??= _auth.currentUser?.uid;
    if (id == null) throw Exception("Teacher ID not found. Please login.");
    return id;
  }

  // ==================================================
  //  TEACHER QUIZ MODULE
  // ==================================================

  Future<void> addQuizTopic(QuizTopicModel topic) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final topicWithMeta = topic.copyWith(id: newKey, creatorId: teacherId, createdBy: 'teacher');
      final path = 'Teacher_Content/$teacherId/Quizzes/${topic.category}/$newKey';
      await _database.ref(path).set(topicWithMeta.toMap());
    } catch (e) {
      throw Exception('Failed to add quiz: $e');
    }
  }

  Future<void> updateQuizTopic(QuizTopicModel topic) async {
    if (topic.id == null) throw Exception("Topic ID is missing");
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Quizzes/${topic.category}/${topic.id}';
      await _database.ref(path).update(topic.toMap());
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  Future<void> deleteQuizTopic(String topicId, String category) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/Quizzes/$category/$topicId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  Stream<List<QuizTopicModel>> getTeacherQuizzesStream(String category) async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/Quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
      final List<QuizTopicModel> topics = [];
      mapData.forEach((key, value) {
        final topicMap = Map<String, dynamic>.from(value as Map);
        topics.add(QuizTopicModel.fromMap(key.toString(), category, topicMap));
      });
      return topics;
    });
  }

  // ==================================================
  //  TEACHER STEM MODULE
  // ==================================================

  Future<void> addStemChallenge(StemChallengeModel challenge) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final challengeWithMeta = challenge.copyWith(id: newKey, adminId: teacherId);
      final path = 'Teacher_Content/$teacherId/StemChallenges/${challenge.category}/$newKey';
      // toMap now returns valid Realtime Database types (Strings)
      await _database.ref(path).set(challengeWithMeta.toMap());
    } catch (e) {
      throw Exception('Failed to add STEM challenge: $e');
    }
  }


  Future<void> updateStemChallenge(StemChallengeModel challenge) async {
    if (challenge.id == null) throw Exception("Challenge ID is missing");
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/StemChallenges/${challenge.category}/${challenge.id}';
      await _database.ref(path).update(challenge.toMap());
    } catch (e) {
      throw Exception('Failed to update STEM challenge: $e');
    }
  }

  Future<void> deleteStemChallenge(String challengeId, String category) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/StemChallenges/$category/$challengeId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete STEM challenge: $e');
    }
  }
  Stream<List<StemChallengeModel>> getTeacherStemChallengesStream(String category) async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/StemChallenges/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final List<StemChallengeModel> challenges = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final challengeMap = Map<String, dynamic>.from(value);
            challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
          }
        });
      }
      return challenges;
    });
  }

  // ==================================================
  //  TEACHER MULTIMEDIA MODULE
  // ==================================================

  Future<void> addVideo(VideoModel video) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final path = 'Teacher_Content/$teacherId/Multimedia/Videos/$newKey';
      await _database.ref(path).set(video.copyWith(id: newKey, adminId: teacherId).toMap());
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
      final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
      final List<VideoModel> videos = [];
      mapData.forEach((key, value) {
        final videoMap = Map<String, dynamic>.from(value as Map);
        videoMap['id'] = key.toString();
        videos.add(VideoModel.fromMap(videoMap));
      });
      return videos;
    });
  }

  Future<void> addStory(StoryModel story) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final path = 'Teacher_Content/$teacherId/Multimedia/Stories/$newKey';
      await _database.ref(path).set(story.copyWith(id: newKey, adminId: teacherId).toMap());
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
      final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
      final List<StoryModel> stories = [];
      mapData.forEach((key, value) {
        final storyMap = Map<String, dynamic>.from(value as Map);
        storyMap['id'] = key.toString();
        stories.add(StoryModel.fromMap(storyMap));
      });
      return stories;
    });
  }

  // ==================================================
  //  TEACHER QR HUNT MODULE
  // ==================================================

  Future<void> addQrHunt(QrHuntModel hunt) async {
    try {
      final teacherId = await _getTeacherId();
      final newKey = _generateKey();
      final path = 'Teacher_Content/$teacherId/QrHunts/$newKey';
      await _database.ref(path).set(hunt.copyWith(id: newKey, adminId: teacherId).toMap());
    } catch (e) {
      throw Exception('Failed to add QR hunt: $e');
    }
  }

  Future<void> updateQrHunt(QrHuntModel hunt) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/QrHunts/${hunt.id}';
      await _database.ref(path).update(hunt.toMap());
    } catch (e) {
      throw Exception('Failed to update QR hunt: $e');
    }
  }

  Future<void> deleteQrHunt(String huntId) async {
    try {
      final teacherId = await _getTeacherId();
      final path = 'Teacher_Content/$teacherId/QrHunts/$huntId';
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to delete QR hunt: $e');
    }
  }

  Stream<List<QrHuntModel>> getTeacherQrHuntsStream() async* {
    final teacherId = await _getTeacherId();
    yield* _database.ref('Teacher_Content/$teacherId/QrHunts').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
      final List<QrHuntModel> hunts = [];
      mapData.forEach((key, value) {
        hunts.add(QrHuntModel.fromMap(key.toString(), Map<String, dynamic>.from(value)));
      });
      return hunts;
    });
  }
}
