import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';


class TeacherStudentService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace with your actual Render URL
  final String _backendUrl = "https://eco-venture-backend.onrender.com";

  // --- STREAM STUDENT DETAIL ---
  Stream<Map<String, dynamic>> getStudentDetailStream(String studentId) {
    final profileStream = _firestore.collection('users').doc(studentId).snapshots();
    final quizStream = _database.ref('child_quiz_progress/$studentId').onValue;
    final stemStream = _database.ref('student_stem_submissions/$studentId').onValue;
    final qrStream = _database.ref('child_qr_progress/$studentId').onValue;

    return Rx.combineLatest4(
        profileStream, quizStream, stemStream, qrStream,
            (DocumentSnapshot profile, DatabaseEvent quiz, DatabaseEvent stem, DatabaseEvent qr) {

          final userData = profile.data() as Map<String, dynamic>?;
          final String name = userData?['name'] ?? 'Unknown';
          final String email = userData?['email'] ?? '';

          int totalXP = 0;
          int quizCount = 0;
          int stemSub = 0;
          int stemApp = 0;
          int qrCount = 0;
          List<Map<String, dynamic>> activity = [];

          // 1. PARSE QUIZ (Fix: Show Failed Attempts)
          final quizData = quiz.snapshot.value;
          if (quizData is Map) {
            _processRecursive(quizData, (data) {
              bool isPassed = data['is_passed'] == true;

              // Stats: Only count PASSED for points/level
              if (isPassed) {
                quizCount++;
                totalXP += 20;
              }

              // Activity: Log EVERYTHING (Pass or Fail)
              String category = data['category'] ?? 'General';
              String level = data['level_order'].toString();
              String topicName = data['topic_name'] ?? ''; // May be empty if not saved

              // Format: "Failed: Science (Level 1)"
              String title = isPassed ? "Passed: $category" : "Failed: $category";
              if (topicName.isNotEmpty) title += " - $topicName";
              title += " (Lvl $level)";

              activity.add({
                'title': title,
                'time': data['attempt_date'],
                'type': 'Quiz',
                'isPositive': isPassed, // Red for fail, Green for pass
                'score': '${data['correct_answers']} correct'
              });
            });
          }

          // 2. PARSE STEM (Fix: Descriptive Titles)
          final stemData = stem.snapshot.value;
          if (stemData is Map) {
            stemData.forEach((k, v) {
              final map = Map<String, dynamic>.from(v as Map);
              stemSub++;
              if (map['status'] == 'approved') {
                stemApp++;
                totalXP += (map['points_awarded'] as int? ?? 0);
              }
              map['id'] = k;

              String status = map['status'] ?? 'pending';
              String challengeTitle = map['challenge_title'] ?? 'Challenge';
              String category = map['category'] ?? 'STEM';

              // Format: "STEM: Water Filter (Science)"
              activity.add({
                'title': 'STEM: $challengeTitle ($category)',
                'subtitle': 'Status: ${status.toUpperCase()}',
                'time': map['submitted_at'],
                'data': map,
                'type': 'STEM',
                'isPositive': status == 'approved',
              });
            });
          }

          // 3. PARSE QR (Fix: Descriptive Titles)
          final qrData = qr.snapshot.value;
          if (qrData is Map) {
            qrData.forEach((k, v) {
              final map = Map<String, dynamic>.from(v as Map);

              // Assuming hunt title is saved in progress, if not fallback to ID
              String huntTitle = map['hunt_title'] ?? 'Treasure Hunt';
              int cluesFound = map['current_clue_index'] ?? 0;

              if (map['is_completed'] == true) {
                qrCount++;
                totalXP += (map['score_earned'] as int? ?? 0);
                activity.add({
                  'title': 'Completed: $huntTitle',
                  'time': map['completed_time'],
                  'type': 'QR',
                  'isPositive': true,
                  'subtitle': 'All clues found'
                });
              } else {
                // Also show In-Progress hunts if recently active
                activity.add({
                  'title': 'Active: $huntTitle',
                  'time': map['start_time'], // Use start time as activity time
                  'type': 'QR',
                  'isPositive': false, // Neutral/Yellow
                  'subtitle': '$cluesFound clues solved'
                });
              }
            });
          }

          activity.sort((a, b) => (b['time'] ?? '').compareTo(a['time'] ?? ''));

          return {
            'studentId': studentId,
            'name': name,
            'email': email,
            'totalXP': totalXP,
            'currentLevel': (totalXP / 200).floor() + 1,
            'quizCount': quizCount,
            'stemSub': stemSub,
            'stemApp': stemApp,
            'qrCount': qrCount,
            'activity': activity.take(30).toList(),
          };
        }
    );
  }

  void _processRecursive(dynamic data, Function(Map<String, dynamic>) onFound) {
    if (data is Map) {
      if (data.containsKey('is_passed')) {
        onFound(Map<String, dynamic>.from(data));
      } else {
        data.forEach((k, v) => _processRecursive(v, onFound));
      }
    } else if (data is List) {
      for(var item in data) { if(item != null) _processRecursive(item, onFound); }
    }
  }

  // --- REVIEW SUBMISSION & NOTIFY ---
  Future<void> reviewStemSubmission({
    required String studentId,
    required String challengeId,
    required String status,
    required int points,
    String? feedback,
  }) async {
    try {
      await _database.ref('student_stem_submissions/$studentId/$challengeId').update({
        'status': status,
        'points_awarded': status == 'approved' ? points : 0,
        'teacherFeedback': feedback ?? '',
        'reviewedAt': DateTime.now().toIso8601String(),
      });

      await _notifyChild(
          studentId,
          "STEM Challenge Reviewed",
          status == 'approved'
              ? "Your submission was approved! +$points XP"
              : "Update needed on your submission."
      );
    } catch (e) {
      print("Error reviewing: $e");
      throw Exception("Failed to review");
    }
  }

  Future<void> _notifyChild(String childUid, String title, String body) async {
    try {
      final url = Uri.parse('$_backendUrl/notify-child');
      await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'childId': childUid, 'title': title, 'body': body})
      );
    } catch (e) { print("Notify Error: $e"); }
  }
}