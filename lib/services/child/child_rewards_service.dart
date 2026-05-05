import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../shared_preferences_helper.dart';

class ChildRewardsService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<Map<String, dynamic>> getRealTimeStats() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? SharedPreferencesHelper.instance.getUserId();

      if (uid == null) {
        yield {'points': 0, 'quizCount': 0, 'stemCount': 0, 'qrCount': 0, 'gameCount': 0};
      } else {
        // 1. Quiz Stream
        final quizStream = _database.ref('child_quiz_progress/$uid').onValue;
        // 2. STEM Stream
        final stemStream = _database.ref('student_stem_submissions/$uid').onValue;
        // 3. QR Stream
        final qrStream = _database.ref('child_qr_progress/$uid').onValue;
        // 4. NEW: Game Module Stream
        final gameStream = _database.ref('game_module/$uid').onValue;

        yield* Rx.combineLatest4(
            quizStream,
            stemStream,
            qrStream,
            gameStream,
                (DatabaseEvent quizEv, DatabaseEvent stemEv, DatabaseEvent qrEv, DatabaseEvent gameEv) {
              int totalPoints = 0;
              int quizCount = 0;
              int stemCount = 0;
              int qrCount = 0;
              int gameCount = 0;

              // --- QUIZ LOGIC ---
              final quizData = quizEv.snapshot.value;
              if (quizData is Map) {
                quizData.forEach((cat, topics) {
                  if (topics is Map) {
                    topics.forEach((topic, levels) {
                      if (levels is Map) {
                        levels.forEach((lvl, data) {
                          if (data['is_passed'] == true) { quizCount++; totalPoints += 20; }
                        });
                      }
                    });
                  }
                });
              }

              // --- STEM LOGIC ---
              final stemData = stemEv.snapshot.value;
              if (stemData is Map) {
                stemData.forEach((key, val) {
                  final map = Map<String, dynamic>.from(val as Map);
                  if (map['status'] == 'approved') {
                    stemCount++;
                    totalPoints += (map['points_awarded'] as int? ?? 0);
                  }
                });
              }

              // --- QR LOGIC ---
              final qrData = qrEv.snapshot.value;
              if (qrData is Map) {
                qrData.forEach((key, val) {
                  final map = Map<String, dynamic>.from(val as Map);
                  totalPoints += (map['score_earned'] as int? ?? 0);
                  if (map['is_completed'] == true) qrCount++;
                });
              }

              // --- NEW: GAME MODULE LOGIC ---
              final gameData = gameEv.snapshot.value;
              if (gameData is Map) {
                gameData.forEach((gameId, val) {
                  final map = Map<String, dynamic>.from(val as Map);
                  // Add the score from each individual game to total points
                  totalPoints += (map['score'] as int? ?? 0);
                  gameCount++;
                });
              }

              return {
                'points': totalPoints,
                'quizCount': quizCount,
                'stemCount': stemCount,
                'qrCount': qrCount,
                'gameCount': gameCount,
              };
            }
        );
      }
    });
  }
}