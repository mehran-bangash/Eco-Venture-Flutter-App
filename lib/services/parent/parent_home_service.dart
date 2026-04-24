import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class ParentHomeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> getChildDashboardStream(String childUid) {
    final usageStream = _database
        .ref('child_usage_stats/$childUid/daily')
        .onValue;
    final activityStream = _database
        .ref('child_activity_log/$childUid')
        .limitToLast(10)
        .onValue;
    final quizStream = _database.ref('child_quiz_progress/$childUid').onValue;
    final stemStream = _database
        .ref('student_stem_submissions/$childUid')
        .onValue;
    final qrStream = _database.ref('child_qr_progress/$childUid').onValue;

    return Rx.combineLatest5(
      usageStream,
      activityStream,
      quizStream,
      stemStream,
      qrStream,
      (usage, activity, quiz, stem, qr) {
        int totalXP = 0;
        int quizCount = 0;
        double totalQuizScore = 0;
        int stemCount = 0;
        int qrCount = 0;
        List<Map<String, dynamic>> recentList = [];
        Map<String, int> skillCounts = {
          'Science': 0,
          'Math': 0,
          'Logic': 0,
          'Creativity': 0,
        };

        // 1. Process Multimedia Activity
        if (activity.snapshot.value is Map) {
          (activity.snapshot.value as Map).forEach((k, v) {
            recentList.add(Map<String, dynamic>.from(v as Map));
          });
        }

        // 2. Process Quizzes
        final quizData = quiz.snapshot.value;
        if (quizData != null) {
          _processRecursive(quizData, (data) {
            // REAL calculation for Average
            double score = (data['attempt_percentage'] ?? 0).toDouble();
            totalQuizScore += score;
            quizCount++;

            if (data['is_passed'] == true) {
              totalXP += 20;
              _updateSkills(skillCounts, data['category'] ?? '');
              recentList.add({
                'title': "Passed: ${data['topic_name'] ?? 'Quiz'}",
                'type': 'Quiz',
                'timestamp': data['attempt_date'],
              });
            }
          });
        }

        // 3. Process STEM
        final stemData = stem.snapshot.value;
        if (stemData is Map) {
          stemData.forEach((k, v) {
            final map = Map<String, dynamic>.from(v as Map);
            if (map['status'] == 'approved') {
              stemCount++;
              totalXP += (map['points_awarded'] as int? ?? 0);
              _updateSkills(skillCounts, map['category'] ?? 'Creativity');
              recentList.add({
                'title': "Completed: ${map['challenge_title']}",
                'type': 'STEM',
                'timestamp': map['submitted_at'],
              });
            }
          });
        }

        // 4. Process QR
        final qrData = qr.snapshot.value;
        if (qrData is Map) {
          qrData.forEach((k, v) {
            final map = Map<String, dynamic>.from(v as Map);
            if (map['is_completed'] == true) {
              qrCount++;
              totalXP += (map['score_earned'] as int? ?? 0);
              _updateSkills(skillCounts, 'Logic');
              recentList.add({
                'title': "Found Treasure: ${map['title'] ?? 'QR Hunt'}",
                'type': 'QR Hunt',
                'timestamp': map['completed_time'],
              });
            }
          });
        }

        recentList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        // FINAL CALCULATIONS: Removed all hardcoded placeholders
        double realQuizAvg = quizCount > 0 ? (totalQuizScore / quizCount) : 0.0;

        // Normalize skills based on activity (no dummy 0.05)
        int totalSkills = skillCounts.values.fold(0, (sum, val) => sum + val);
        Map<String, double> normalizedSkills = {};
        skillCounts.forEach((key, value) {
          normalizedSkills[key] = totalSkills > 0 ? (value / totalSkills) : 0.0;
        });

        return {
          'usageMinutes': (usage.snapshot.value as int?) ?? 0,
          'recentActivity': recentList,
          'totalXP': totalXP,
          'currentLevel': (totalXP / 200).floor() + 1,
          'skills': normalizedSkills,
          'performance': {
            'quizAvg': realQuizAvg.toInt(),
            'stemCount': stemCount,
            'qrCount': qrCount,
          },
        };
      },
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
      for (var item in data) {
        if (item != null) _processRecursive(item, onFound);
      }
    }
  }

  void _updateSkills(Map<String, int> skills, String category) {
    final c = category.toLowerCase();
    if (c.contains('science') || c.contains('ecosystem')) {
      skills['Science'] = (skills['Science']! + 1);
    } else if (c.contains('math')) {
      skills['Math'] = (skills['Math']! + 1);
    } else if (c.contains('tech') || c.contains('eng')) {
      skills['Creativity'] = (skills['Creativity']! + 1);
    } else {
      skills['Logic'] = (skills['Logic']! + 1);
    }
  }

  // (Link/Unlink methods stay the same as they were already real logic)
  Future<String> linkChildAccount(
    String pUid,
    String email,
    String name,
  ) async {
    final q = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'child')
        .limit(1)
        .get();
    if (q.docs.isEmpty) throw Exception("No child found.");
    final childUid = q.docs.first.id;
    await _database.ref('parent_children/$pUid/$childUid').set({
      'name': name,
      'uid': childUid,
      'email': email,
      'linkedAt': DateTime.now().toIso8601String(),
    });
    await _firestore.collection('users').doc(childUid).update({
      'parent_id': pUid,
    });
    return childUid;
  }

  Future<List<Map<String, dynamic>>> getLinkedChildren(String pUid) async {
    final s = await _database.ref('parent_children/$pUid').get();
    if (!s.exists) return [];
    return (s.value as Map).values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> unlinkChildAccount(String pUid, String cUid) async {
    await _database.ref('parent_children/$pUid/$cUid').remove();
    await _firestore.collection('users').doc(cUid).update({
      'parent_id': FieldValue.delete(),
    });
  }
}
