import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/teacher_student_activity_model.dart';
import '../models/teacher_student_stats_model.dart';

class TeacherStudentDetailService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- 1. FETCH RECENT ACTIVITY ---
  Future<List<TeacherStudentActivityModel>> getRecentActivity(String studentId) async {
    try {
      final snapshot = await _database
          .ref('child_activity_log/$studentId')
          .orderByChild('timestamp')
          .limitToLast(5)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final activities = data.values
          .map((activityData) => TeacherStudentActivityModel.fromMap(Map<String, dynamic>.from(activityData as Map)))
          .toList();

      // Sort by timestamp descending (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities;
    } catch (e) {
      print("Error fetching recent activity: $e");
      return [];
    }
  }

  // --- 2. FETCH AND CALCULATE ALL STATS ---
  Future<TeacherStudentStatsModel> getStudentStats(String studentId) async {
    try {
      // Fetch all data concurrently for efficiency
      final results = await Future.wait([
        _database.ref('child_quiz_progress/$studentId').get(),
        _database.ref('student_stem_submissions/$studentId').get(),
        _database.ref('child_qr_progress/$studentId').get(),
      ]);

      final quizSnapshot = results[0];
      final stemSnapshot = results[1];
      final qrSnapshot = results[2];

      // --- Process Quiz Data ---
      int quizPoints = 0;
      int passedQuizCount = 0;
      List<double> quizPercentages = [];
      if (quizSnapshot.exists && quizSnapshot.value is Map) {
        _parseQuizData(quizSnapshot.value, (data) {
          if (data['is_passed'] == true) {
            quizPoints += 20; // 20 points per passed level as per child_rewards_service
            passedQuizCount++;
            quizPercentages.add((data['attempt_percentage'] as num).toDouble());
          }
        });
      }

      // --- Process STEM Data ---
      int stemPoints = 0;
      int stemTasksDone = 0;
      if (stemSnapshot.exists && stemSnapshot.value is Map) {
        final stemData = Map<String, dynamic>.from(stemSnapshot.value as Map);
        stemData.forEach((_, submissionData) {
          final submission = Map<String, dynamic>.from(submissionData as Map);
          if (submission['status'] == 'approved') {
            stemTasksDone++;
            stemPoints += (submission['points_awarded'] as int? ?? 0);
          }
        });
      }

      // --- Process QR Data ---
      int qrPoints = 0;
      int qrFinds = 0;
      if (qrSnapshot.exists && qrSnapshot.value is Map) {
        final qrData = Map<String, dynamic>.from(qrSnapshot.value as Map);
        qrData.forEach((_, huntData) {
          final hunt = Map<String, dynamic>.from(huntData as Map);
          qrPoints += (hunt['score_earned'] as int? ?? 0);
          if (hunt['is_completed'] == true) {
            qrFinds++;
          }
        });
      }

      // --- Final Calculations ---
      final totalPoints = quizPoints + stemPoints + qrPoints;
      final double quizAverage = quizPercentages.isEmpty ? 0.0 : quizPercentages.reduce((a, b) => a + b) / quizPercentages.length;
      final tasksDone = qrFinds + stemTasksDone;

      return TeacherStudentStatsModel(
        totalPoints: totalPoints,
        quizAverage: quizAverage,
        tasksDone: tasksDone,
        qrFinds: qrFinds,
        stemTasksDone: stemTasksDone,
      );

    } catch (e) {
      print("Error calculating student stats: $e");
      return TeacherStudentStatsModel.initial(); // Return default model on error
    }
  }

  // Helper to recursively parse the nested quiz progress data
  void _parseQuizData(dynamic data, void Function(Map<String, dynamic>) onLevelFound) {
    if (data is Map) {
      // Check if this map is a quiz level object (leaf node)
      if (data.containsKey('is_passed') && data.containsKey('attempt_percentage')) {
        onLevelFound(Map<String, dynamic>.from(data));
      } else {
        // Otherwise, recurse deeper
        data.forEach((_, value) {
          _parseQuizData(value, onLevelFound);
        });
      }
    } else if (data is List) {
      // If it's a list, iterate and recurse
      for (var item in data) {
        if (item != null) {
          _parseQuizData(item, onLevelFound);
        }
      }
    }
  }
}
