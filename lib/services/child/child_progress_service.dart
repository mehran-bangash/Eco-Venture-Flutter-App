import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../shared_preferences_helper.dart';


class ChildProgressService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- MAIN AGGREGATION STREAM ---
  // If provided (Parent App), it uses the child's ID.
  Stream<Map<String, dynamic>> getProgressStream({String? childId}) {
    return _auth.authStateChanges().asyncExpand((user) async* {

      String? uid = childId ?? user?.uid ?? SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {};
      } else {
        final Stream<DatabaseEvent?> quizStream = _database.ref('child_quiz_progress/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> stemStream = _database.ref('student_stem_submissions/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> qrStream = _database.ref('child_qr_progress/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> mediaStream = _database.ref('child_activity_log/$uid').onValue.cast<DatabaseEvent?>();

        yield* Rx.combineLatest4(
            quizStream.startWith(null),
            stemStream.startWith(null),
            qrStream.startWith(null),
            mediaStream.startWith(null),
                (DatabaseEvent? quizEvent, DatabaseEvent? stemEvent, DatabaseEvent? qrEvent, DatabaseEvent? mediaEvent) {
              return _aggregateData(
                  quizEvent?.snapshot.value,
                  stemEvent?.snapshot.value,
                  qrEvent?.snapshot.value,
                  mediaEvent?.snapshot.value
              );
            }
        );
      }
    });
  }

  // --- FULL DATA AGGREGATOR ---

  Map<String, dynamic> _aggregateData(dynamic quizData, dynamic stemData, dynamic qrData, dynamic mediaData) {
    int totalPoints = 0;
    List<Map<String, dynamic>> timeline = [];
    Map<String, int> skillCounts = {'Science': 0, 'Math': 0, 'Logic': 0, 'Creativity': 0};

    // 1. PROCESS QUIZZES
    if (quizData is Map) {
      _processRecursiveQuiz(quizData, (data) {
        // OLD LOGIC: Only show in timeline if PASSED
        if (data['is_passed'] == true) {
          totalPoints += 20;

          // FIX: Show Name without ID
          String name = data['topic_name'] ?? "Quiz Level";
          _addToTimeline(timeline, "Passed: $name", "Quiz", data['attempt_date']);

          _updateSkills(skillCounts, data['category'] ?? 'General');
        }
      });
    }

    // 2. PROCESS STEM (UNCHANGED)
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

    // 3. PROCESS QR (UNCHANGED)
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

    // 4. PROCESS MULTIMEDIA (UNCHANGED)
    if (mediaData != null) {
      void processItem(dynamic item) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          totalPoints += 5;
          String typeLabel = map['type'] == 'Video' ? 'Video' : 'Story';
          _addToTimeline(timeline, map['title'] ?? 'Multimedia', typeLabel, map['timestamp']);
          _updateSkills(skillCounts, map['category'] ?? 'Creativity');
        }
      }
      if (mediaData is Map) {
        mediaData.forEach((key, val) => processItem(val));
      } else if (mediaData is List) { for (var item in mediaData) { if (item != null) processItem(item); } }
    }

    timeline.sort((a, b) => b['date'].compareTo(a['date']));

    return {
      'totalPoints': totalPoints,
      'timeline': timeline,
      'skills': skillCounts,
    };
  }

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
    final catLower = category.toLowerCase();
    if (catLower.contains('science') || catLower.contains('ecosystem') || catLower.contains('plant')) {
      skills['Science'] = (skills['Science']! + 1);
    } else if (catLower.contains('math') || catLower.contains('number')) {
      skills['Math'] = (skills['Math']! + 1);
    } else if (catLower.contains('technology') || catLower.contains('stem') || catLower.contains('art')) {
      skills['Creativity'] = (skills['Creativity']! + 1);
    } else if (catLower.contains('logic') || catLower.contains('puzzle') || catLower.contains('hunt')) {
      skills['Logic'] = (skills['Logic']! + 1);
    } else {
      skills['Creativity'] = (skills['Creativity']! + 1);
    }
  }
}
