import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildStemChallengesService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HELPER: FIND TEACHER ID (Using SharedPrefs UID) ---
  Future<String?> _getTeacherId() async {
    try {
      // 1. Get Current User
      final user = await SharedPreferencesHelper.instance.getUserId();

      if (user == null) {
        print("DEBUG: No User Logged In (Prefs). Cannot fetch Teacher ID.");
        return null;
      }

      // 2. Fetch Document directly from Firestore
      final doc = await _firestore.collection('users').doc(user).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // 3. Check for 'teacher_id'
        if (data.containsKey('teacher_id') && data['teacher_id'] != null) {
          final String teacherId = data['teacher_id'];
          // Cache it locally for faster future access
          await SharedPreferencesHelper.instance.saveChildTeacherId(teacherId);
          return teacherId;
        }
      }
    } catch (e) {
      print("ERROR fetching teacher ID from Firestore: $e");
    }
    return null;
  }

  // 1. FETCH ADMIN CHALLENGES
  Stream<List<StemChallengeReadModel>> getAdminChallengesStream(String category) {
    return _database.ref('Public/StemChallenges/$category').onValue.map((event) {
      return _parseChallenges(event.snapshot.value);
    }).handleError((e) {
      print("Admin Stream Error: $e");
      return <StemChallengeReadModel>[];
    });
  }

  // 2. FETCH TEACHER CHALLENGES
  Stream<List<StemChallengeReadModel>> getTeacherChallengesStream(String category) {
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      if (teacherId != null && teacherId.isNotEmpty) {
        print("DEBUG: Fetching Teacher STEM from: Teacher_Content/$teacherId/StemChallenges/$category");
        return _database.ref('Teacher_Content/$teacherId/StemChallenges/$category').onValue.map((event) {
          return _parseChallenges(event.snapshot.value);
        });
      } else {
        return Stream.value([]);
      }
    });
  }

  // Helper Parser
  List<StemChallengeReadModel> _parseChallenges(dynamic data) {
    if (data == null) return [];
    try {
      final List<StemChallengeReadModel> challenges = [];
      if (data is Map) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          challenges.add(StemChallengeReadModel.fromMap(key.toString(), map));
        });
      }
      return challenges;
    } catch (e) {
      print("Error parsing STEM challenges: $e");
      return [];
    }
  }

  // ... (Keep submitChallenge & getStudentSubmissionsStream unchanged) ...
  // (Just paste the existing submission logic here from previous version)

  Future<void> submitChallenge(StemSubmissionModel submission) async {
    // ... (Reuse previous logic)
    try {
      // 1. Get Valid Student ID
      String? studentId = await SharedPreferencesHelper.instance.getUserId();
      if (studentId == null) studentId = _auth.currentUser?.uid;

      if (studentId == null) throw Exception("Student not logged in");

      // 2. Prepare Path
      // Path: student_stem_submissions / student_123 / challenge_abc
      final path = 'student_stem_submissions/$studentId/${submission.challengeId}';

      // 3. Prepare Data (Ensure strict status)
      // We force the status to 'pending' on new submissions just to be safe,
      // though the ViewModel/Model usually handles defaults.
      final submissionData = submission.copyWith(
        studentId: studentId, // Ensure ID matches auth
        status: 'pending',
        teacherFeedback: null, // Reset feedback on new submission
        pointsAwarded: 0,      // Reset points until approved
      ).toMap();

      // 4. Save to RTDB
      await _database.ref(path).set(submissionData);

    } catch (e) {
      throw Exception("Failed to submit challenge: $e");
    }
  }

  Stream<Map<String, StemSubmissionModel>> getStudentSubmissionsStream() async* {
    // ... (Reuse previous logic)
    String? studentId = await SharedPreferencesHelper.instance.getUserId();
    if (studentId == null) studentId = _auth.currentUser?.uid;

    if (studentId == null) {
      yield {};
      return;
    }

    final path = 'student_stem_submissions/$studentId';

    yield* _database.ref(path).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};

      try {
        final Map<String, StemSubmissionModel> submissions = {};
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;

        mapData.forEach((challengeId, value) {
          final submissionMap = Map<String, dynamic>.from(value as Map);
          // We use the challengeId as the key for easy lookup in the UI
          submissions[challengeId.toString()] = StemSubmissionModel.fromMap(challengeId.toString(), submissionMap);
        });

        return submissions;
      } catch (e) {
        print("Error parsing student submissions: $e");
        return {};
      }
    });
  }
}