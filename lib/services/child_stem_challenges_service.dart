import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../services/shared_preferences_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart'; // ADD THIS IMPORT
import '../services/shared_preferences_helper.dart';
import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../models/parent_safety_settings_model.dart';

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

  // ==================================================
  //  PARENT SAFETY SETTINGS STREAM (EXACTLY SAME AS YOUR QUIZ SERVICE)
  // ==================================================

  Stream<ParentSafetySettingsModel> _getSafetySettings() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) {
        yield ParentSafetySettingsModel(); // Default: No restrictions
      } else {
        yield* _database.ref('parent_settings/$uid').onValue.map((event) {
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            return ParentSafetySettingsModel.fromMap(Map<String, dynamic>.from(data));
          }
          return ParentSafetySettingsModel();
        });
      }
    });
  }

  // ==================================================
  //  1. FETCH ADMIN CHALLENGES WITH PARENT FILTERS (YOUR PATTERN)
  // ==================================================

  Stream<List<StemChallengeReadModel>> getAdminChallengesStream(String category) {
    final dataStream = _database.ref('Public/StemChallenges/$category').onValue.map((event) {
      return _parseChallenges(event.snapshot.value);
    }).handleError((e) {
      print("Admin Stream Error: $e");
      return <StemChallengeReadModel>[];
    });

    // YOUR EXACT PATTERN: Combine with settings and apply filters
    return Rx.combineLatest2(dataStream, _getSafetySettings(),
            (List<StemChallengeReadModel> challenges, ParentSafetySettingsModel settings) {
          return _applyStemFilters(challenges, settings, category);
        }
    );
  }

  // ==================================================
  //  2. FETCH TEACHER CHALLENGES WITH PARENT FILTERS (YOUR PATTERN)
  // ==================================================

  Stream<List<StemChallengeReadModel>> getTeacherChallengesStream(String category) {
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      Stream<List<StemChallengeReadModel>> teacherDataStream;

      if (teacherId != null && teacherId.isNotEmpty) {
        print("DEBUG: Fetching Teacher STEM from: Teacher_Content/$teacherId/StemChallenges/$category");
        teacherDataStream = _database.ref('Teacher_Content/$teacherId/StemChallenges/$category')
            .onValue.map((event) {
          return _parseChallenges(event.snapshot.value);
        }).handleError((e) {
          print("Teacher Stream Error: $e");
          return <StemChallengeReadModel>[];
        });
      } else {
        teacherDataStream = Stream.value([]);
      }

      final settingsStream = _getSafetySettings();

      // YOUR EXACT PATTERN: Combine with settings and apply filters
      return Rx.combineLatest2(teacherDataStream, settingsStream,
              (List<StemChallengeReadModel> challenges, ParentSafetySettingsModel settings) {
            return _applyStemFilters(challenges, settings, category);
          }
      );
    });
  }

  // ==================================================
  //  STEM-SPECIFIC FILTER LOGIC (APPROPRIATE FOR STEM CONTENT)
  // ==================================================

  List<StemChallengeReadModel> _applyStemFilters(
      List<StemChallengeReadModel> challenges,
      ParentSafetySettingsModel settings,
      String category) {

    return challenges.where((challenge) {
      // 1. Block Dangerous/Inappropriate STEM Content
      if (settings.blockScaryContent) {
        if (_isDangerousOrInappropriateStem(challenge, category)) {
          print("🚫 Parent blocked inappropriate STEM content: ${challenge.title}");
          return false;
        }
      }

      // 2. Educational Only Mode - STEM Specific
      if (settings.educationalOnlyMode) {
        if (!_isEducationalStem(challenge, category)) {
          print("📚 Educational mode - blocked non-educational STEM: ${challenge.title}");
          return false;
        }
      }

      // 3. Block Social Interaction for STEM
      if (settings.blockSocialInteraction) {
        if (_isSocialStemChallenge(challenge)) {
          print("👥 Social interaction blocked for STEM: ${challenge.title}");
          return false;
        }
      }

      return true;
    }).toList();
  }

  // STEM-SPECIFIC: Check for dangerous or inappropriate STEM content
  bool _isDangerousOrInappropriateStem(StemChallengeReadModel challenge, String category) {
    // 1. Check if challenge is marked as sensitive
    if (challenge.isSensitive == true) {
      return true;
    }

    // 2. Check tags for dangerous STEM content
    if (challenge.tags.isNotEmpty) {
      const dangerousStemTags = [
        'dangerous', 'hazardous', 'chemicals', 'explosive', 'fire',
        'electricity', 'high-voltage', 'radiation', 'toxic', 'sharp',
        'adult-supervision', 'mature', 'complex', 'advanced'
      ];

      if (challenge.tags.any((tag) => dangerousStemTags.contains(tag.toLowerCase()))) {
        return true;
      }
    }

    // 3. Check title for dangerous STEM keywords
    const dangerousStemKeywords = [
      'dangerous', 'hazard', 'explosive', 'chemical', 'acid',
      'fire', 'flame', 'burn', 'electric', 'shock', 'voltage',
      'radiation', 'toxic', 'poison', 'sharp', 'blade', 'cut',
      'advanced', 'complex', 'professional', 'expert'
    ];

    final titleLower = challenge.title.toLowerCase();
    if (dangerousStemKeywords.any((word) => titleLower.contains(word))) {
      return true;
    }

    // 4. Check category for potentially dangerous STEM areas
    const potentiallyDangerousCategories = [
      'Chemistry', 'Physics', 'Electronics', 'Engineering',
      'Robotics', 'Tools', 'Experiments'
    ];

    final categoryLower = category.toLowerCase();
    if (potentiallyDangerousCategories.any((cat) => categoryLower.contains(cat.toLowerCase()))) {
      // For dangerous categories, also check if it's age-appropriate
      // This could be enhanced with age restrictions
      return false; // Don't auto-block, just flag for review
    }

    return false;
  }

  // STEM-SPECIFIC: Check if content is educational STEM
  bool _isEducationalStem(StemChallengeReadModel challenge, String category) {
    // STEM is inherently educational, but check for non-educational categories

    // 1. Check tags for entertainment vs educational
    if (challenge.tags.isNotEmpty) {
      const educationalStemTags = ['educational', 'learning', 'academic', 'science', 'math'];
      const entertainmentTags = ['game', 'fun', 'entertainment', 'play', 'toy'];

      if (educationalStemTags.any((tag) => challenge.tags.contains(tag))) return true;
      if (entertainmentTags.any((tag) => challenge.tags.contains(tag))) return false;
    }

    // 2. STEM Educational categories
    const educationalStemCategories = [
      'Science', 'Technology', 'Engineering', 'Math', 'Mathematics',
      'Physics', 'Chemistry', 'Biology', 'Coding', 'Programming',
      'Robotics', 'Electronics', 'Astronomy', 'Geology', 'Ecology',
      'Environmental Science', 'Computer Science', 'Data Science'
    ];

    // 3. Non-educational/entertainment categories
    const nonEducationalCategories = [
      'Games', 'Entertainment', 'Fun', 'Toys', 'Hobbies',
      'Just for Fun', 'Recreation', 'Leisure'
    ];

    // Check if category is educational STEM
    final isEducationalCategory = educationalStemCategories.any(
            (eduCat) => category.toLowerCase().contains(eduCat.toLowerCase())
    );

    // Check if category is non-educational
    final isNonEducationalCategory = nonEducationalCategories.any(
            (nonEduCat) => category.toLowerCase().contains(nonEduCat.toLowerCase())
    );

    // STEM categories are educational by default
    if (isEducationalCategory) return true;

    // Non-educational categories should be blocked in educational mode
    if (isNonEducationalCategory) return false;

    // Default: Allow STEM challenges (they're usually educational)
    return true;
  }

  // STEM-SPECIFIC: Check if challenge involves social interaction
  bool _isSocialStemChallenge(StemChallengeReadModel challenge) {
    // STEM social interaction keywords
    const socialStemKeywords = [
      'collaborate', 'teamwork', 'group project', 'pair programming',
      'discuss', 'share results', 'presentation', 'debate',
      'competition', 'contest', 'challenge others', 'multiplayer'
    ];

    // Check title
    final titleLower = challenge.title.toLowerCase();
    if (socialStemKeywords.any((word) => titleLower.contains(word))) {
      return true;
    }

    // Check tags
    if (challenge.tags.isNotEmpty) {
      const socialStemTags = ['collaborative', 'team', 'group', 'social', 'multiplayer', 'competitive'];
      if (challenge.tags.any((tag) => socialStemTags.contains(tag.toLowerCase()))) {
        return true;
      }
    }

    return false;
  }

  // ==================================================
  //  HELPER PARSER (Keep your existing)
  // ==================================================

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

  // ==================================================
  //  SUBMISSION METHODS (Keep your existing ones - UNCHANGED)
  // ==================================================

  Future<void> submitChallenge(StemSubmissionModel submission) async {
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