import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/child_report_model.dart';
import '../services/shared_preferences_helper.dart';
import '../models/parent_safety_settings_model.dart'; // Reuse existing model
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Direct usage for sync

class ChildSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final BehaviorSubject<int> _usageController = BehaviorSubject<int>.seeded(0);
  Timer? _usageTimer;
  StreamSubscription? _authSubscription;

  static const String _keyUsageDate = 'safety_usage_date';
  static const String _keyUsageMinutes = 'safety_usage_minutes';
  final String _id = DateTime.now().millisecondsSinceEpoch.toString().substring(8);

  ChildSafetyService() {
    print("🔹 [$_id] SAFETY SERVICE: Created (Singleton)");
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authSubscription?.cancel();

    // Emit initial 0 minutes for UI
    if (!_usageController.isClosed) _usageController.add(0);

    _authSubscription = _auth.authStateChanges().listen((user) async {
      // Use Firebase UID if available, otherwise fallback to SharedPreferences
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) {
        print("🔹 [$_id] No user ID yet. Waiting...");
        return;
      }

      print("🔹 [$_id] User ID available: $uid");
      _startTrackingSequence(uid);
    });
  }

  Future<void> _startTrackingSequence(String uid) async {
    // 1️⃣ Fetch Role
    String? role = await SharedPreferencesHelper.instance.getUserRole();

    if (role == null) {
      // Try Firestore fallback
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        role = doc.data()?['role'];
        if (role != null) {
          await SharedPreferencesHelper.instance.saveUserRole(role);
        }
      } catch (e) {
        print("Firestore Error: $e");
      }
    }

    if (role == null) {
      print("❌ [$_id] Role not found. Cannot start timer.");
      return;
    }

    if (role != 'child') {
      print("🛡️ [$_id] Role is '$role'. Timer DISABLED.");
      _stopTimer();
      return;
    }

    print("✅ [$_id] Valid Child ($uid). Initializing Timer...");
    _initTimer(uid);
  }

  Future<void> _initTimer(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_keyUsageDate) ?? "";
    int minutes = 0;

    if (lastDate != todayStr) {
      await prefs.setString(_keyUsageDate, todayStr);
      await prefs.setInt(_keyUsageMinutes, 0);
    } else {
      minutes = prefs.getInt(_keyUsageMinutes) ?? 0;
    }

    // Emit initial usage for UI
    if (!_usageController.isClosed) _usageController.add(minutes);
    _syncToFirebase(uid, minutes);

    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      minutes++;
      if (!_usageController.isClosed) _usageController.add(minutes);
      await prefs.setInt(_keyUsageMinutes, minutes);
      _syncToFirebase(uid, minutes);
      print("⏱️ [$_id] TICK: $minutes mins");
    });
  }

  Future<void> _syncToFirebase(String uid, int minutes) async {
    try {
      await _database.ref('child_usage_stats/$uid/daily').set(minutes);
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  void _stopTimer() {
    _usageTimer?.cancel();
    _usageTimer = null;
    print("🛑 [$_id] Timer Stopped.");
  }

  Stream<int> get usageMinutesStream => _usageController.stream;

  void dispose() {
    print("♻️ [$_id] Disposing Service");
    _authSubscription?.cancel();
    _stopTimer();
    _usageController.close();
  }

  // Reports
  Future<void> submitReport(ChildReportModel report) async {
    try {
      String? uid = _auth.currentUser?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) throw Exception("User not logged in");

      final newKey = _database.ref().push().key!;
      final reportWithMeta = report.copyWith(childId: uid);
      final data = reportWithMeta.toMap();
      data['id'] = newKey;
      await _database.ref('safety_alerts/$uid/$newKey').set(data);
    } catch (e) {
      throw Exception("Failed: $e");
    }
  }

  Stream<List<ChildReportModel>> getReportsStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) {
        yield [];
      } else {
        yield* _database.ref('safety_alerts/$uid').onValue.map((event) {
          final data = event.snapshot.value;
          final List<ChildReportModel> reports = [];
          if (data != null && data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                final map = Map<String, dynamic>.from(value);
                map['id'] = key.toString();
                reports.add(ChildReportModel.fromMap(key.toString(), map));
              }
            });
          }
          reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return reports;
        });
      }
    });
  }

  Stream<ParentSafetySettingsModel> getSafetySettingsStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? await SharedPreferencesHelper.instance.getUserId();
      if (uid == null) {
        yield ParentSafetySettingsModel();
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
}


