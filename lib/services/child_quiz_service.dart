import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/child_progress_model.dart';
import '../models/quiz_topic_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildQuizService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. FETCH TOPICS (From Public Node)
  Stream<List<QuizTopicModel>> getPublicTopicsStream(String category) {
    return _database.ref('Public/Quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final List<QuizTopicModel> topics = [];

        // Handle Map (Standard)
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final topicMap = Map<String, dynamic>.from(value);
              topics.add(QuizTopicModel.fromMap(key.toString(), category, topicMap));
            }
          });
        }
        // Handle List (Firebase Array Optimization)
        else if (data is List) {
          for (var item in data) {
            if (item != null && item is Map) {
              final topicMap = Map<String, dynamic>.from(item);
              topics.add(QuizTopicModel.fromMap(topicMap['id'] ?? 'unknown', category, topicMap));
            }
          }
        }

        return topics;
      } catch (e) {
        print("Error parsing public topics: $e");
        return [];
      }
    });
  }

  // 2. FETCH USER PROGRESS (ULTRA-ROBUST FIX)
  Stream<Map<String, ChildQuizProgressModel>> getChildProgressStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid;
      if (uid == null) uid = await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {};
      } else {
        yield* _database.ref('child_quiz_progress/$uid').onValue.map((event) {
          final data = event.snapshot.value;
          if (data == null) return {};

          try {
            final Map<String, ChildQuizProgressModel> progressMap = {};

            // Level 1: Category (Should be Map, but check safety)
            if (data is Map) {
              data.forEach((catKey, topicsData) {
                // Level 2: Topics (Should be Map)
                if (topicsData is Map) {
                  topicsData.forEach((topicId, levelsData) {
                    // Level 3: Levels (CRITICAL: Can be Map OR List)
                    _parseLevelsSafe(topicId.toString(), levelsData, progressMap);
                  });
                } else if (topicsData is List) {
                  // Rare edge case for Topics array
                  for(var tData in topicsData) {
                    if (tData is Map) {
                      // We might not have topicId here easily if it was a list key,
                      // so we rely on data content or skip.
                    }
                  }
                }
              });
            }

            return progressMap;
          } catch (e) {
            print("Error parsing child progress: $e");
            return {};
          }
        });
      }
    });
  }

  // --- HELPER: Handle Map vs List for Levels ---
  void _parseLevelsSafe(String topicId, dynamic levelsData, Map<String, ChildQuizProgressModel> progressMap) {
    if (levelsData == null) return;

    // Case A: It's a Map (e.g. "1": {...}, "2": {...})
    if (levelsData is Map) {
      levelsData.forEach((levelKey, levelVal) {
        _addModelToMap(levelVal, progressMap);
      });
    }
    // Case B: It's a List (e.g. [null, {...}, {...}])
    // Firebase turns numeric keys "1", "2" into an array where index 0 is null.
    else if (levelsData is List) {
      for (var item in levelsData) {
        if (item != null) {
          _addModelToMap(item, progressMap);
        }
      }
    }
  }

  void _addModelToMap(dynamic data, Map<String, ChildQuizProgressModel> progressMap) {
    try {
      // Ensure data is actually a Map before conversion
      if (data is! Map) return;

      final safeData = Map<String, dynamic>.from(data);
      final model = ChildQuizProgressModel.fromMap(safeData);

      // Create key: "TopicID_LevelOrder"
      final key = "${model.topicId}_${model.levelOrder}";
      progressMap[key] = model;
    } catch (e) {
      print("Skipping invalid progress entry: $e");
    }
  }

  // 3. SAVE PROGRESS
  Future<void> saveLevelResult(ChildQuizProgressModel progress) async {
    String? childId = await SharedPreferencesHelper.instance.getUserId();
    if (childId == null) childId = _auth.currentUser?.uid;
    if (childId == null) throw Exception("Child not logged in");

    // Save path
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

  // 4. GET CATEGORIES
  Stream<List<String>> getCategoriesStream() {
    return _database.ref('Public/Quizzes').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <String>[];

      try {
        if (data is Map) {
          return data.keys.map((key) => key.toString()).toList();
        }
        return <String>[];
      } catch (e) {
        print("Error fetching categories: $e");
        return <String>[];
      }
    });
  }
}