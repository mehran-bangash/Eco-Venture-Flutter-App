import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildStemChallengesService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================================================
  // 1. FETCHING DATA (View Logic)
  // ==================================================

  /// Fetches the list of STEM challenges for a specific category from the Public node.
  /// Logic: Reads from 'Public/StemChallenges/{category}'
  Stream<List<StemChallengeReadModel>> getPublicStemChallengesStream(String category) {
    // If category is 'All', we might need to fetch all categories and flatten them.
    // For simplicity in this structure, we often query by specific category.
    // If 'All' is passed, we might need a different approach or client-side merging.
    // Here is the logic for a specific category path:

    Query query;
    if (category == 'All') {
      // Note: Querying root 'Public/StemChallenges' might return a map of categories
      query = _database.ref('Public/StemChallenges');
    } else {
      query = _database.ref('Public/StemChallenges/$category');
    }

    return query.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final List<StemChallengeReadModel> challenges = [];
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;

        if (category == 'All') {
          // Structure: { Science: {id1: data}, Tech: {id2: data} }
          mapData.forEach((catKey, catData) {
            final innerMap = catData as Map<dynamic, dynamic>;
            innerMap.forEach((key, value) {
              final challengeMap = Map<String, dynamic>.from(value as Map);
              challenges.add(StemChallengeReadModel.fromMap(key.toString(), challengeMap));
            });
          });
        } else {
          // Structure: { id1: data, id2: data }
          mapData.forEach((key, value) {
            final challengeMap = Map<String, dynamic>.from(value as Map);
            challenges.add(StemChallengeReadModel.fromMap(key.toString(), challengeMap));
          });
        }

        return challenges;
      } catch (e) {
        print("Error parsing public STEM challenges: $e");
        return [];
      }
    });
  }

  // ==================================================
  // 2. SUBMISSION & REVIEW (Task Logic)
  // ==================================================

  /// Submits a student's work for a specific challenge.
  /// Logic: Writes to 'student_stem_submissions/{student_id}/{challenge_id}'
  /// Status starts as 'pending'.
  Future<void> submitChallenge(StemSubmissionModel submission) async {
    try {
      // 1. Get Valid Student ID
      String? studentId = await SharedPreferencesHelper.instance.getUserId();
      studentId ??= _auth.currentUser?.uid;

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

  /// Fetches the student's history of submissions (to show Pending/Approved badges).
  /// Returns a Map: { challengeId : StemSubmissionModel }
  Stream<Map<String, StemSubmissionModel>> getStudentSubmissionsStream() async* {
    String? studentId = await SharedPreferencesHelper.instance.getUserId();
    studentId ??= _auth.currentUser?.uid;

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