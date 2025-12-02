import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/qr_hunt_read_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildQrHuntService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HELPER: GET TEACHER ID (Reuse Logic) ---
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

  // 1. FETCH HUNTS (Dual Stream)

  // 1. FETCH HUNTS (Dual Stream with Explicit Tagging)
  Stream<List<QrHuntReadModel>> getHuntsStream() {
    // Stream A: Admin (Default is 'admin', so no change needed)
    final adminStream = _database.ref('Public/QrHunts').onValue.map((event) {
      return _parseHunts(event.snapshot.value, isTeacher: false);
    });

    // Stream B: Teacher
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      if (teacherId != null && teacherId.isNotEmpty) {
        final teacherStream = _database.ref('Teacher_Content/$teacherId/QrHunts').onValue.map((event) {
          // FIX: Pass true here
          return _parseHunts(event.snapshot.value, isTeacher: true);
        });

        return Rx.combineLatest2(
            adminStream.startWith([]),
            teacherStream.startWith([]),
                (List<QrHuntReadModel> admin, List<QrHuntReadModel> teacher) {
              return [...admin, ...teacher];
            }
        );
      } else {
        return adminStream;
      }
    });
  }

  List<QrHuntReadModel> _parseHunts(dynamic data, {required bool isTeacher}) {
    if (data == null) return [];
    final List<QrHuntReadModel> hunts = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);

            // FIX: Force the correct creator tag based on source
            // Note: We assume QrHuntReadModel has a copyWith or we modify the map before creation

            QrHuntReadModel model = QrHuntReadModel.fromMap(key.toString(), map);

            // Manually override the createdBy field for the UI logic
            if (isTeacher) {
              // If your model is immutable, create a new instance or use copyWith
              // Assuming QrHuntReadModel has copyWith (if not, add it or use constructor)
              // Fallback: Modifying map BEFORE creating model is safer if copyWith is missing
              // But wait, fromMap reads 'created_by' key. Let's update logic below:
            }

            // ALTERNATIVE PARSING (Modifying Map directly):
            // map['created_by'] = isTeacher ? 'teacher' : 'admin';
            // hunts.add(QrHuntReadModel.fromMap(key.toString(), map));

            // BETTER: Use copyWith if available, or constructor
            hunts.add(QrHuntReadModel(
                id: model.id,
                title: model.title,
                points: model.points,
                difficulty: model.difficulty,
                clues: model.clues,
                // FORCE THE TAG HERE
                createdBy: isTeacher ? 'teacher' : 'admin',
                creatorId: model.creatorId
            ));
          }
        });
      }
    } catch (e) { print("Parse Error: $e"); }
    return hunts;
  }

  // 2. FETCH PROGRESS
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
              progressMap[key] = QrHuntProgressModel.fromMap(Map<String, dynamic>.from(value as Map));
            });
          }
          return progressMap;
        });
      }
    });
  }

  // 3. SAVE PROGRESS (Scan Update)
  Future<void> saveProgress(QrHuntProgressModel progress) async {
    String? uid = await SharedPreferencesHelper.instance.getUserId();
    uid ??= _auth.currentUser?.uid;
    if (uid == null) return;

    await _database.ref('child_qr_progress/$uid/${progress.huntId}').set(progress.toMap());
  }
}