import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_progress_model.dart';
import '../models/quiz_topic_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildQuizService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HELPER: FIND TEACHER ID ---
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

  // ==================================================
  //  1. ADMIN CONTENT (Public)
  // ==================================================

  Stream<List<QuizTopicModel>> getAdminTopicsStream(String category) {
    return _database.ref('Public/Quizzes/$category').onValue.map((event) {
      return _parseTopics(event.snapshot.value, category);
    }).handleError((e) => <QuizTopicModel>[]);
  }

  Stream<List<String>> getAdminCategoriesStream() {
    return _database.ref('Public/Quizzes').onValue.map((event) {
      return _extractKeys(event.snapshot.value);
    });
  }

  // ==================================================
  //  2. TEACHER CONTENT (Classroom)
  // ==================================================

  Stream<List<QuizTopicModel>> getTeacherTopicsStream(String category) {
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      if (teacherId != null && teacherId.isNotEmpty) {
        return _database.ref('Teacher_Content/$teacherId/Quizzes/$category').onValue.map((event) {
          return _parseTopics(event.snapshot.value, category);
        }).handleError((e) => <QuizTopicModel>[]);
      } else {
        return Stream.value([]);
      }
    });
  }

  Stream<List<String>> getTeacherCategoriesStream() {
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      if (teacherId != null && teacherId.isNotEmpty) {
        return _database.ref('Teacher_Content/$teacherId/Quizzes').onValue.map((event) {
          return _extractKeys(event.snapshot.value);
        });
      } else {
        return Stream.value([]);
      }
    });
  }

  // ==================================================
  //  HELPERS
  // ==================================================

  List<QuizTopicModel> _parseTopics(dynamic data, String category) {
    if (data == null) return [];
    try {
      final List<QuizTopicModel> topics = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final topicMap = Map<String, dynamic>.from(value);
            topics.add(QuizTopicModel.fromMap(key.toString(), category, topicMap));
          }
        });
      } else if (data is List) {
        for (var item in data) {
          if (item != null && item is Map) {
            final topicMap = Map<String, dynamic>.from(item);
            topics.add(QuizTopicModel.fromMap(topicMap['id'] ?? 'unknown', category, topicMap));
          }
        }
      }
      return topics;
    } catch (e) {
      return [];
    }
  }

  List<String> _extractKeys(dynamic data) {
    if (data is Map) {
      final keys = data.keys.map((k) => k.toString()).toList();
      keys.sort();
      return keys;
    }
    return [];
  }

  // ==================================================
  //  PROGRESS LOGIC (FIXED)
  // ==================================================

  // 2. FETCH USER PROGRESS
  Stream<Map<String, ChildQuizProgressModel>> getChildProgressStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {};
      } else {
        // Listen to the entire progress node
        yield* _database.ref('child_quiz_progress/$uid').onValue.map((event) {
          final data = event.snapshot.value;
          final Map<String, ChildQuizProgressModel> progressMap = {};

          if (data != null) {
            // print("DEBUG: Parsing Progress Data...");
            _parseRecursiveProgress(data, progressMap);
          }

          return progressMap;
        });
      }
    });
  }

  // Robust Recursive Parser that handles Lists and Maps
  void _parseRecursiveProgress(dynamic data, Map<String, ChildQuizProgressModel> progressMap) {
    if (data is Map) {
      // Check if this IS a progress object (Leaf Node)
      if (data.containsKey('level_order') && data.containsKey('topic_id')) {
        _addModelToMap(data, progressMap);
      } else {
        // Not a leaf, recurse into children
        data.forEach((k, v) => _parseRecursiveProgress(v, progressMap));
      }
    } else if (data is List) {
      // Handle Arrays (Firebase converts keys "0", "1" to List)
      for (var item in data) {
        if (item != null) {
          _parseRecursiveProgress(item, progressMap);
        }
      }
    }
  }

  void _addModelToMap(dynamic data, Map<String, ChildQuizProgressModel> progressMap) {
    try {
      if (data is! Map) return;
      final safeData = Map<String, dynamic>.from(data);
      final model = ChildQuizProgressModel.fromMap(safeData);

      // Key Format: "TopicID_LevelOrder"
      // Example: "-OfII6llw2egstbu9d5__1"
      final key = "${model.topicId}_${model.levelOrder}";
      progressMap[key] = model;

      // print("DEBUG: Found Progress: $key (Passed: ${model.isPassed})");
    } catch (e) {
      // print("Skipping invalid entry: $e");
    }
  }

  // 3. SAVE PROGRESS
  Future<void> saveLevelResult(ChildQuizProgressModel progress) async {
    String? childId = await SharedPreferencesHelper.instance.getUserId();
    childId ??= _auth.currentUser?.uid;
    if (childId == null) throw Exception("Child not logged in");

    final path = 'child_quiz_progress/$childId/${progress.category}/${progress.topicId}/${progress.levelOrder}';

    final snapshot = await _database.ref(path).get();
    final bool passedNow = progress.attemptPercentage >= 60;

    if (snapshot.exists && snapshot.value is Map) {
      final existingData = Map<String, dynamic>.from(snapshot.value as Map);
      final existingProgress = ChildQuizProgressModel.fromMap(existingData);

      final bool finalPassedStatus = existingProgress.isPassed || passedNow;

      final updatedMap = progress.toMap();
      updatedMap['is_passed'] = finalPassedStatus;
      updatedMap['attempts'] = existingProgress.attempts + 1;

      await _database.ref(path).update(updatedMap);
    } else {
      final map = progress.toMap();
      map['is_passed'] = passedNow;
      map['attempts'] = 1;
      await _database.ref(path).set(map);
    }
  }
}