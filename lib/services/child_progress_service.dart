import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/shared_preferences_helper.dart';


class ChildProgressService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<Map<String, dynamic>> getProgressStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {};
      } else {
        // Define streams
        final quizStream = _database.ref('child_quiz_progress/$uid').onValue;
        final stemStream = _database.ref('student_stem_submissions/$uid').onValue;
        final qrStream = _database.ref('child_qr_progress/$uid').onValue;
        // 4. Multimedia Stream
        final mediaStream = _database.ref('child_activity_log/$uid').onValue;

        // Merge All Streams (using .cast to avoid type errors)
        yield* Rx.combineLatest4(
            quizStream.cast<DatabaseEvent?>().startWith(null),
            stemStream.cast<DatabaseEvent?>().startWith(null),
            qrStream.cast<DatabaseEvent?>().startWith(null),
            mediaStream.cast<DatabaseEvent?>().startWith(null),
                (DatabaseEvent? quizEvent, DatabaseEvent? stemEvent, DatabaseEvent? qrEvent, DatabaseEvent? mediaEvent) {

              final quizData = quizEvent?.snapshot.value;
              final stemData = stemEvent?.snapshot.value;
              final qrData = qrEvent?.snapshot.value;
              final mediaData = mediaEvent?.snapshot.value;

              // --- DEBUG PRINT ---
              if (mediaData != null) {
                print("✅ FOUND MULTIMEDIA HISTORY: $mediaData");
              } else {
                print("⚠️ Multimedia History is NULL/Empty");
              }

              return _aggregateData(quizData, stemData, qrData, mediaData);
            }
        );
      }
    });
  }

  Map<String, dynamic> _aggregateData(dynamic quizData, dynamic stemData, dynamic qrData, dynamic mediaData) {
    int totalPoints = 0;
    List<Map<String, dynamic>> timeline = [];
    Map<String, int> skillCounts = {'Science': 0, 'Math': 0, 'Logic': 0, 'Creativity': 0};

    // ... (Quiz, STEM, QR logic remains same) ...
    // 1. PROCESS QUIZZES
    if (quizData is Map) {
      _processRecursiveQuiz(quizData, (data) {
        if (data['is_passed'] == true) {
          totalPoints += 20;
          _addToTimeline(timeline, "Passed Quiz Level", "Quiz", data['attempt_date']);
          _updateSkills(skillCounts, data['category'] ?? 'General');
        }
      });
    }

    // 2. PROCESS STEM
    if (stemData is Map) {
      stemData.forEach((key, val) {
        if (val is Map) {
          final map = Map<String, dynamic>.from(val);
          if (map['status'] == 'approved') {
            totalPoints += (map['points_awarded'] as int? ?? 0);
            _addToTimeline(timeline, "Completed ${map['challenge_title']}", "STEM", map['submitted_at']);
            _updateSkills(skillCounts, map['category'] ?? 'Creativity');
          }
        }
      });
    }

    // 3. PROCESS QR
    if (qrData is Map) {
      qrData.forEach((key, val) {
        if (val is Map) {
          final map = Map<String, dynamic>.from(val);
          if (map['is_completed'] == true) {
            totalPoints += (map['score_earned'] as int? ?? 0);
            _addToTimeline(timeline, "Finished Treasure Hunt", "QR Hunt", map['completed_time']);
            _updateSkills(skillCounts, 'Logic');
          }
        }
      });
    }

    // 4. PROCESS MULTIMEDIA HISTORY
    if (mediaData != null) {
      // Helper to process single item
      void processItem(dynamic item) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          totalPoints += 5; // XP

          String typeLabel = map['type'] == 'Video' ? 'Video' : 'Story';

          _addToTimeline(
              timeline,
              "Viewed: ${map['title']}",
              typeLabel,
              map['timestamp']
          );
          _updateSkills(skillCounts, map['category'] ?? 'Creativity');
        }
      }

      if (mediaData is Map) {
        mediaData.forEach((key, val) => processItem(val));
      } else if (mediaData is List) {
        for (var item in mediaData) {
          if (item != null) processItem(item);
        }
      }
    }

    timeline.sort((a, b) => b['date'].compareTo(a['date']));

    return {
      'totalPoints': totalPoints,
      'timeline': timeline,
      'skills': skillCounts,
    };
  }

  // Helper functions
  void _processRecursiveQuiz(dynamic data, Function(Map<String, dynamic>) onFound) {
    if (data is Map) {
      if (data.containsKey('is_passed')) { onFound(Map<String, dynamic>.from(data)); }
      else { data.forEach((k, v) => _processRecursiveQuiz(v, onFound)); }
    } else if (data is List) {
      for(var item in data) { if(item != null) _processRecursiveQuiz(item, onFound); }
    }
  }

  void _addToTimeline(List<Map<String, dynamic>> list, String title, String type, String? dateStr) {
    if (dateStr != null) {
      list.add({
        'title': title,
        'type': type,
        'date': DateTime.tryParse(dateStr) ?? DateTime.now(),
      });
    }
  }

  void _updateSkills(Map<String, int> skills, String category) {
    if (category.contains('Science') || category.contains('Ecosystem')) {
      skills['Science'] = (skills['Science']! + 1);
    } else if (category.contains('Math')) {
      skills['Math'] = (skills['Math']! + 1);
    } else if (category.contains('Technology') || category.contains('Engineering')) {
      skills['Creativity'] = (skills['Creativity']! + 1);
    } else {
      skills['Logic'] = (skills['Logic']! + 1);
    }
  }
}