import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_safety_settings_model.dart';
import '../models/qr_hunt_read_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildQrHuntService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HELPER: GET TEACHER ID (Robust Logic) ---
  Future<String?> _getTeacherId() async {
    try {
      // 1. Get Current User ID (Prefs first for speed/safety)
      final user = await SharedPreferencesHelper.instance.getUserId();

      if (user == null) {
        // Fallback to Auth
        if (_auth.currentUser != null) return null; // If auth is null, return null
        return null;
      }

      // 2. Fetch Document directly from Firestore
      final doc = await _firestore.collection('users').doc(user).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // 3. Check for 'teacher_id'
        if (data.containsKey('teacher_id') && data['teacher_id'] != null) {
          final String teacherId = data['teacher_id'];
          // Cache it locally
          await SharedPreferencesHelper.instance.saveChildTeacherId(teacherId);
          return teacherId;
        }
      }
    } catch (e) {
      print("ERROR fetching teacher ID: $e");
    }
    return null;
  }

  // --- HELPER: GET SAFETY SETTINGS STREAM ---
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
  //  1. FETCH HUNTS (Dual Source + Filtering)
  // ==================================================

  Stream<List<QrHuntReadModel>> getHuntsStream() {
    // Stream A: Admin Content (Always Active)
    final adminStream = _database.ref('Public/QrHunts').onValue.map((event) {
      return _parseHunts(event.snapshot.value, isTeacher: false);
    }).handleError((e) {
      print("Admin Stream Error: $e");
      return <QrHuntReadModel>[];
    });

    // Stream B: Safety Settings
    final settingsStream = _getSafetySettings();

    // Stream C: Dynamic Teacher Content
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      Stream<List<QrHuntReadModel>> teacherStream;

      if (teacherId != null && teacherId.isNotEmpty) {
        teacherStream = _database.ref('Teacher_Content/$teacherId/QrHunts').onValue.map((event) {
          return _parseHunts(event.snapshot.value, isTeacher: true);
        }).handleError((e) {
          print("Teacher Stream Error: $e");
          return <QrHuntReadModel>[];
        });
      } else {
        teacherStream = Stream.value([]);
      }

      // Merge: Combine Admin + Teacher + Settings
      // startWith([]) prevents the stream from hanging if one source is empty/slow
      return Rx.combineLatest3(
          adminStream.startWith([]),
          teacherStream.startWith([]),
          settingsStream,
              (List<QrHuntReadModel> adminList, List<QrHuntReadModel> teacherList, ParentSafetySettingsModel settings) {
            final combined = [...adminList, ...teacherList];

            // Apply Parent Filters
            return _applyFilters(combined, settings);
          }
      );
    });
  }

  List<QrHuntReadModel> _applyFilters(
      List<QrHuntReadModel> hunts,
      ParentSafetySettingsModel settings,
      ) {
    // Keyword groups specific to QR hunts (location + safety)
    const unsafeLocationKeywords = [
      'railway', 'train', 'bridge', 'highway', 'road', 'cliff', 'river', 'lake',
       'construction', 'site', 'factory', 'powerstation', 'substation',
      'mine', 'quarry', 'tunnel', 'restricted', 'danger', 'private property'
    ];

    const violenceKeywords = [
      'gun', 'weapon', 'knife', 'shoot', 'kill', 'attack', 'murder', 'blood'
    ];

    const strangerDangerKeywords = [
      'meet', 'come alone', 'alone', 'secret place', 'come here', 'midnight',
      'after dark', 'hidden spot', 'pick up'
    ];

    const illegalKeywords = [
      'steal', 'rob', 'burglary', 'bomb', 'explode'
    ];

    final allSensitive = [
      ...unsafeLocationKeywords,
      ...violenceKeywords,
      ...strangerDangerKeywords,
      ...illegalKeywords,
    ];

    String normalize(String s) => s.toLowerCase();

    return hunts.where((hunt) {
      final title = normalize(hunt.title);
      final cluesText = normalize(hunt.clues.join(' ')); // join clues

      // 1) Parent blocks "scary"/unsafe content: scan text for sensitive keywords
      if (settings.blockScaryContent) {
        for (final kw in allSensitive) {
          if (title.contains(kw) || cluesText.contains(kw)) {
            return false;
          }
        }
      }

      // 2) Educational-only mode: allow only educational hunts by heuristic
      if (settings.educationalOnlyMode) {
        final isEducational = title.contains('learn') ||
            title.contains('quiz') ||
            title.contains('puzzle') ||
            cluesText.contains('learn') ||
            cluesText.contains('fact') ||
            cluesText.contains('knowledge');

        if (!isEducational) return false;
      }

      // Passed all checks
      return true;
    }).toList();
  }


  // --- Helper to Parse Data & Tag Source ---
  List<QrHuntReadModel> _parseHunts(dynamic data, {required bool isTeacher}) {
    if (data == null) return [];
    final List<QrHuntReadModel> hunts = [];

    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);

            // Create Model (Standard Parse)
            QrHuntReadModel model = QrHuntReadModel.fromMap(key.toString(), map);

            // FORCE THE TAG: Override 'createdBy' based on the source folder
            hunts.add(QrHuntReadModel(
                id: model.id,
                title: model.title,
                points: model.points,
                difficulty: model.difficulty,
                clues: model.clues,
                // Explicitly set this flag
                createdBy: isTeacher ? 'teacher' : 'admin',
                creatorId: model.creatorId
            ));
          }
        });
      }
    } catch (e) {
      print("Error parsing QR hunts: $e");
    }
    return hunts;
  }

  // ==================================================
  //  2. FETCH PROGRESS
  // ==================================================
  Stream<Map<String, QrHuntProgressModel>> getProgressStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) { yield {}; } else {
        yield* _database.ref('child_qr_progress/$uid').onValue.map((event) {
          final data = event.snapshot.value;
          if (data == null) return {};

          final Map<String, QrHuntProgressModel> progressMap = {};
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                progressMap[key.toString()] = QrHuntProgressModel.fromMap(Map<String, dynamic>.from(value));
              }
            });
          }
          return progressMap;
        });
      }
    });
  }

  // ==================================================
  //  3. SAVE PROGRESS (Scan Update)
  // ==================================================
  Future<void> saveProgress(QrHuntProgressModel progress) async {
    String? uid = await SharedPreferencesHelper.instance.getUserId();
    uid ??= _auth.currentUser?.uid;

    if (uid == null) return;

    await _database.ref('child_qr_progress/$uid/${progress.huntId}').set(progress.toMap());
  }
}