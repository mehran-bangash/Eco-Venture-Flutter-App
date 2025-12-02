import 'dart:async';
import 'package:rxdart/rxdart.dart'; // Make sure this is in pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/video_model.dart';
import '../models/story_model.dart';
import '../services/shared_preferences_helper.dart';

class VideoStoryService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getTeacherId() async {
    try {
      // 1. Get Current User
      final user = await SharedPreferencesHelper.instance.getUserId();

      if (user == null) {
        print("DEBUG: No User Logged In (Prefs). Cannot fetch Teacher ID.");
        return null;
      }

      // 2. Fetch Document directly from Firestore
      final doc = await _firestore.collection('users').doc(user).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // 3. Check for 'teacher_id'
        if (data.containsKey('teacher_id') && data['teacher_id'] != null) {
          final String teacherId = data['teacher_id'];
          // Cache it locally for faster future access
          await SharedPreferencesHelper.instance.saveChildTeacherId(teacherId);
          return teacherId;
        }
      }
    } catch (e) {
      print("ERROR fetching teacher ID from Firestore: $e");
    }
    return null;
  }

  // ================= VIDEOS (DUAL FETCH) =================

  Stream<List<VideoModel>> getVideosStream() {
    // 1. Admin Stream
    final adminStream = _database.ref('Public/Videos').onValue.map((event) {
      return _parseVideos(event.snapshot.value, isTeacher: false);
    }).handleError((e) => <VideoModel>[]);

    // 2. Teacher Stream (Reactive)
    return _auth.authStateChanges().asyncExpand((user) async* {
      final teacherId = await _getTeacherId();

      if (teacherId != null && teacherId.isNotEmpty) {

        // --- DEBUG PROBE: Check structure ---
        _database.ref('Teacher_Content/$teacherId').get().then((snap) {
          print("🔍 VIDEO PROBE: Keys under Teacher: ${(snap.value as Map?)?.keys}");
        });

        final teacherStream = _database.ref('Teacher_Content/$teacherId/Multimedia/Videos').onValue.map((event) {
          return _parseVideos(event.snapshot.value, isTeacher: true);
        }).handleError((e) => <VideoModel>[]);

        yield* Rx.combineLatest2(
            adminStream.startWith([]),
            teacherStream.startWith([]),
                (List<VideoModel> admin, List<VideoModel> teacher) {
              final combined = [...admin, ...teacher];
              combined.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
              return combined;
            }
        );
      } else {
        yield* adminStream;
      }
    });
  }

  List<VideoModel> _parseVideos(dynamic data, {required bool isTeacher}) {
    if (data == null) return [];
    final List<VideoModel> videos = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            map['id'] = key;
            if (isTeacher) map['created_by'] = 'teacher';
            videos.add(VideoModel.fromMap(map));
          }
        });
      }
    } catch (e) { print("Video Parse Error: $e"); }
    return videos;
  }

  // --- UPDATE VIDEO INTERACTIONS ---
  Future<void> updateVideoInteraction(String videoId, String creatorId, String createdBy, Map<String, dynamic> updates) async {
    // If teacher, use teacher path. If Admin (default), use Public.
    // Note: creatorId must be the Teacher's UID for this to work.
    String path;
    if (createdBy == 'teacher') {
      if (creatorId.isEmpty) return; // Safety check
      path = 'Teacher_Content/$creatorId/Multimedia/Videos/$videoId';
    } else {
      path = 'Public/Videos/$videoId';
    }
    await _database.ref(path).update(updates);
  }


  // ================= STORIES (DUAL FETCH) =================

  Stream<List<StoryModel>> getStoriesStream() {
    final adminStream = _database.ref('Public/Stories').onValue.map((event) {
      return _parseStories(event.snapshot.value, isTeacher: false);
    }).handleError((e) => <StoryModel>[]);

    return _auth.authStateChanges().asyncExpand((user) async* {
      final teacherId = await _getTeacherId();

      if (teacherId != null && teacherId.isNotEmpty) {
        final teacherStream = _database.ref('Teacher_Content/$teacherId/Multimedia/Stories').onValue.map((event) {
          return _parseStories(event.snapshot.value, isTeacher: true);
        }).handleError((e) => <StoryModel>[]);

        yield* Rx.combineLatest2(
            adminStream.startWith([]),
            teacherStream.startWith([]),
                (List<StoryModel> admin, List<StoryModel> teacher) {
              final combined = [...admin, ...teacher];
              combined.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
              return combined;
            }
        );
      } else {
        yield* adminStream;
      }
    });
  }

  List<StoryModel> _parseStories(dynamic data, {required bool isTeacher}) {
    if (data == null) return [];
    final List<StoryModel> stories = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            map['id'] = key;
            if (isTeacher) map['created_by'] = 'teacher';
            stories.add(StoryModel.fromMap(map));
          }
        });
      }
    } catch (e) { print("Story Parse Error: $e"); }
    return stories;
  }

  Future<void> updateStoryInteraction(String storyId, String creatorId, String createdBy, Map<String, dynamic> updates) async {
    String path;
    if (createdBy == 'teacher') {
      if (creatorId.isEmpty) return;
      path = 'Teacher_Content/$creatorId/Multimedia/Stories/$storyId';
    } else {
      path = 'Public/Stories/$storyId';
    }
    await _database.ref(path).update(updates);
  }

}