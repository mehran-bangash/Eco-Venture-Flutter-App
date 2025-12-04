import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/shared_preferences_helper.dart';


class ChildProgressService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- MAIN AGGREGATION STREAM ---
  Stream<Map<String, dynamic>> getProgressStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {};
      } else {
        print("DEBUG: Progress Service Listening for UID: $uid");

        // 1. CAST STREAMS TO NULLABLE TYPES
        final Stream<DatabaseEvent?> quizStream = _database.ref('child_quiz_progress/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> stemStream = _database.ref('student_stem_submissions/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> qrStream = _database.ref('child_qr_progress/$uid').onValue.cast<DatabaseEvent?>();
        final Stream<DatabaseEvent?> mediaStream = _database.ref('child_activity_log/$uid').onValue.cast<DatabaseEvent?>();

        // 2. MERGE SAFELY
        yield* Rx.combineLatest4(
            quizStream.startWith(null),
            stemStream.startWith(null),
            qrStream.startWith(null),
            mediaStream.startWith(null),
                (DatabaseEvent? quizEvent, DatabaseEvent? stemEvent, DatabaseEvent? qrEvent, DatabaseEvent? mediaEvent) {

              // Extract values safely
              final quizData = quizEvent?.snapshot.value;
              final stemData = stemEvent?.snapshot.value;
              final qrData = qrEvent?.snapshot.value;
              final mediaData = mediaEvent?.snapshot.value;

              return _aggregateData(
                  quizData,
                  stemData,
                  qrData,
                  mediaData
              );
            }
        );
      }
    });
  }

  // --- DATA PARSER & AGGREGATOR ---
  Map<String, dynamic> _aggregateData(dynamic quizData, dynamic stemData, dynamic qrData, dynamic mediaData) {
    int totalPoints = 0;
    List<Map<String, dynamic>> timeline = [];

    // INITIALIZE ALL SKILLS TO 0 SO THEY ALWAYS APPEAR IN UI
    Map<String, int> skillCounts = {
      'Science': 0,
      'Math': 0,
      'Logic': 0,
      'Creativity': 0
    };

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
      void processItem(dynamic item) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          totalPoints += 5; // XP
          String typeLabel = map['type'] == 'Video' ? 'Video' : 'Story';
          _addToTimeline(timeline, "Viewed: ${map['title']}", typeLabel, map['timestamp']);
          // Multimedia contributes to general knowledge/Creativity usually
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

    // Sort Timeline
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

  // --- LOGIC FOR SKILL MAPPING ---
  void _updateSkills(Map<String, int> skills, String category) {
    final catLower = category.toLowerCase();

    // 1. SCIENCE
    if (catLower.contains('science') || catLower.contains('ecosystem') || catLower.contains('plant') || catLower.contains('animal')) {
      skills['Science'] = (skills['Science']! + 1);
    }
    // 2. MATH
    else if (catLower.contains('math') || catLower.contains('number')) {
      skills['Math'] = (skills['Math']! + 1);
    }
    // 3. CREATIVITY (Includes Engineering & Technology)
    else if (catLower.contains('technology') || catLower.contains('engineering') || catLower.contains('stem') || catLower.contains('art')) {
      skills['Creativity'] = (skills['Creativity']! + 1);
    }
    // 4. LOGIC (Includes QR Hunts)
    else if (catLower.contains('logic') || catLower.contains('puzzle') || catLower.contains('hunt')) {
      skills['Logic'] = (skills['Logic']! + 1);
    }
    else {
      // Fallback
      skills['Creativity'] = (skills['Creativity']! + 1);
    }
  }
}