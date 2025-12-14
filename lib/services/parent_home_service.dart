import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class ParentHomeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FETCH CHILD'S FULL PROFILE & STATS ---
  Stream<Map<String, dynamic>> getChildDashboardStream(String childUid) {
    // 1. Usage Stats (Live)
    final usageStream = _database.ref('child_usage_stats/$childUid/daily').onValue;

    // 2. Recent Activity Log (Multimedia)
    final activityStream = _database.ref('child_activity_log/$childUid').limitToLast(5).onValue;

    // 3. Quiz Progress
    final quizStream = _database.ref('child_quiz_progress/$childUid').onValue;

    // 4. STEM & QR (New Streams for Full Accuracy)
    final stemStream = _database.ref('student_stem_submissions/$childUid').onValue;
    final qrStream = _database.ref('child_qr_progress/$childUid').onValue;

    return Rx.combineLatest5(
        usageStream, activityStream, quizStream, stemStream, qrStream,
            (DatabaseEvent usage, DatabaseEvent activity, DatabaseEvent quiz, DatabaseEvent stem, DatabaseEvent qr) {

          // --- A. USAGE ---
          int minutesUsed = (usage.snapshot.value as int?) ?? 0;

          // --- B. RECENT ACTIVITY ---
          List<Map<String, dynamic>> recentList = [];
          if (activity.snapshot.value is Map) {
            final map = activity.snapshot.value as Map;
            map.forEach((k, v) {
              recentList.add(Map<String, dynamic>.from(v as Map));
            });
          }
          recentList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          // --- C. AGGREGATE SKILLS & XP ---
          int totalXP = 0;
          int quizCount = 0;
          int stemCount = 0;
          int qrCount = 0;

          // Skill Counters
          Map<String, int> skillCounts = {
            'Science': 0, 'Math': 0, 'Logic': 0, 'Creativity': 0
          };

          // 1. Process Quizzes
          final quizData = quiz.snapshot.value;
          if (quizData != null) {
            _processRecursive(quizData, (data) {
              if (data['is_passed'] == true) {
                totalXP += 20;
                quizCount++;
                _updateSkills(skillCounts, data['category'] ?? '');
              }
            });
          }

          // 2. Process STEM
          final stemData = stem.snapshot.value;
          if (stemData is Map) {
            stemData.forEach((k, v) {
              final map = Map<String, dynamic>.from(v as Map);
              if (map['status'] == 'approved') {
                stemCount++;
                totalXP += (map['points_awarded'] as int? ?? 0);
                _updateSkills(skillCounts, map['category'] ?? 'Creativity');
              }
            });
          }

          // 3. Process QR
          final qrData = qr.snapshot.value;
          if (qrData is Map) {
            qrData.forEach((k, v) {
              final map = Map<String, dynamic>.from(v as Map);
              if (map['is_completed'] == true) {
                qrCount++;
                totalXP += (map['score_earned'] as int? ?? 0);
                _updateSkills(skillCounts, 'Logic');
              }
            });
          }

          // --- D. NORMALIZE SKILLS (0.0 to 1.0) ---
          // Target: 5 tasks to fill the radar chart
          const double target = 5.0;
          Map<String, double> normalizedSkills = {};
          skillCounts.forEach((key, value) {
            // Ensure it shows at least a tiny bit if > 0
            normalizedSkills[key] = (value == 0) ? 0.05 : (value / target).clamp(0.2, 1.0);
          });

          return {
            'usageMinutes': minutesUsed,
            'recentActivity': recentList,
            'totalXP': totalXP,
            'currentLevel': (totalXP / 200).floor() + 1,
            'skills': normalizedSkills, // REAL DATA
            'performance': {
              'quizAvg': 85, // Placeholder until detailed quiz tracking
              'stemCount': stemCount,
              'qrCount': qrCount
            }
          };
        }
    );
  }

  // --- HELPERS (Same as Child Service) ---
  void _processRecursive(dynamic data, Function(Map<String, dynamic>) onFound) {
    if (data is Map) {
      if (data.containsKey('is_passed')) { onFound(Map<String, dynamic>.from(data)); }
      else { data.forEach((k, v) => _processRecursive(v, onFound)); }
    } else if (data is List) {
      for(var item in data) { if(item != null) _processRecursive(item, onFound); }
    }
  }

  void _updateSkills(Map<String, int> skills, String category) {
    final c = category.toLowerCase();
    if (c.contains('science') || c.contains('ecosystem')) skills['Science'] = (skills['Science']! + 1);
    else if (c.contains('math')) skills['Math'] = (skills['Math']! + 1);
    else if (c.contains('tech') || c.contains('eng')) skills['Creativity'] = (skills['Creativity']! + 1);
    else skills['Logic'] = (skills['Logic']! + 1);
  }
}