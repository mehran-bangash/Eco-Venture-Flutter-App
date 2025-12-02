import 'dart:async';
import 'package:rxdart/rxdart.dart'; // Ensure rxdart is in pubspec
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/shared_preferences_helper.dart';

class ChildRewardsService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- LIVE STATS STREAM ---
  Stream<Map<String, dynamic>> getRealTimeStats() {

    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {'points': 0, 'quizCount': 0, 'stemCount': 0, 'qrCount': 0};
      } else {
        print("DEBUG: Rewards Listening for UID: $uid");

        // 1. Quiz Stream
        final quizStream = _database.ref('child_quiz_progress/$uid').onValue;
        // 2. STEM Stream
        final stemStream = _database.ref('student_stem_submissions/$uid').onValue;
        // 3. QR Stream
        final qrStream = _database.ref('child_qr_progress/$uid').onValue;

        // Combine all 3 streams
        yield* Rx.combineLatest3(
            quizStream,
            stemStream,
            qrStream,
                (DatabaseEvent quizEvent, DatabaseEvent stemEvent, DatabaseEvent qrEvent) {

              int totalPoints = 0;
              int quizCount = 0;
              int stemCount = 0;
              int qrCount = 0;

              // --- CALC QUIZ ---
              final quizData = quizEvent.snapshot.value;
              if (quizData is Map) {
                quizData.forEach((cat, topics) {
                  if (topics is Map) {
                    topics.forEach((topic, levels) {
                      if (levels is Map) {
                        levels.forEach((lvl, data) {
                          final map = Map<String, dynamic>.from(data as Map);
                          if (map['is_passed'] == true) {
                            quizCount++;
                            totalPoints += 20; // 20 pts per level
                          }
                        });
                      } else if (levels is List) {
                        // Handle List case (Firebase array issue)
                        for(var data in levels) {
                          if (data != null && data is Map) {
                            if (data['is_passed'] == true) {
                              quizCount++;
                              totalPoints += 20;
                            }
                          }
                        }
                      }
                    });
                  }
                });
              }

              // --- CALC STEM ---
              final stemData = stemEvent.snapshot.value;
              if (stemData is Map) {
                stemData.forEach((key, val) {
                  final map = Map<String, dynamic>.from(val as Map);
                  if (map['status'] == 'approved') {
                    stemCount++;
                    totalPoints += (map['points_awarded'] as int? ?? 0);
                  }
                });
              }

              // --- CALC QR ---
              final qrData = qrEvent.snapshot.value;
              if (qrData is Map) {
                qrData.forEach((key, val) {
                  final map = Map<String, dynamic>.from(val as Map);
                  // Add scoreEarned
                  totalPoints += (map['score_earned'] as int? ?? 0);
                  if (map['is_completed'] == true) qrCount++;
                });
              }

              print("DEBUG REWARDS: Points: $totalPoints, Quizzes: $quizCount, QR: $qrCount");

              return {
                'points': totalPoints,
                'quizCount': quizCount,
                'stemCount': stemCount,
                'qrCount': qrCount,
              };
            }
        );
      }
    });
  }
}