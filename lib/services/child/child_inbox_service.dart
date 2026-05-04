
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/child/child_report_model.dart';
import '../../models/parent/parent_safety_settings_model.dart';
import '../shared_preferences_helper.dart';

class ChildInboxService {
  final rtdb.FirebaseDatabase _database = rtdb.FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final BehaviorSubject<int> _usageController = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<bool> _isSessionValid = BehaviorSubject<bool>.seeded(true);

  Timer? _usageTimer;
  Timer? _heartbeatTimer;
  StreamSubscription? _authSubscription;
  int _currentMinutes = 0;

  static const String _keyUsageDate = 'safety_usage_date';
  static const String _keyUsageMinutes = 'safety_usage_minutes';

  ChildInboxService() {
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((user) async {
      // FIX 2: Use ONLY FirebaseAuth user — do NOT fall back to SharedPreferences.
      // When user logs out, FirebaseAuth emits null. If we fall back to
      // SharedPreferences, uid is never null and _stopTimer() is never called,
      // so the timer keeps running after logout / app close.
      final String? uid = user?.uid;

      if (uid == null) {
        // User logged out — stop everything immediately.
        _stopTimer();
        _usageController.add(0); // Reset UI to 0 on logout
        return;
      }

      _startTrackingSequence(uid);
    });
  }

  Stream<bool> get sessionValidStream => _isSessionValid.stream;

  Future<bool> isAccountActive(String uid) async {
    try {
      final snapshot = await _database.ref('active_sessions/$uid').get();
      if (!snapshot.exists) return false;
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final lastHeartbeat = data['last_heartbeat'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - lastHeartbeat) < (4 * 60 * 60 * 1000);
    } catch (e) {
      return false;
    }
  }

  Future<void> registerSession(String uid) async {
    await _database.ref('active_sessions/$uid').set({
      'last_heartbeat': rtdb.ServerValue.timestamp,
    });
    _isSessionValid.add(true);
    _startHeartbeat(uid);
  }

  void _startHeartbeat(String uid) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _database.ref('active_sessions/$uid/last_heartbeat').set(rtdb.ServerValue.timestamp);
    });
  }

  Future<void> clearSession(String uid) async {
    _heartbeatTimer?.cancel();
    _usageTimer?.cancel();

    // Final atomic sync so the last counted minute is never lost on logout.
    await _syncMinutesAtomically(uid, _currentMinutes);
    await _database.ref('active_sessions/$uid').remove();
    _isSessionValid.add(false);
  }

  Future<void> _syncMinutesAtomically(String uid, int minutes) async {
    final ref = _database.ref('child_usage_stats/$uid/daily');
    await ref.runTransaction((currentData) {
      final existing = currentData == null
          ? 0
          : (int.tryParse(currentData.toString()) ?? 0);
      // Only move forward, never backward.
      if (minutes > existing) {
        return rtdb.Transaction.success(minutes);
      }
      return rtdb.Transaction.success(existing);
    });
  }

  Future<void> _initTimer(String uid) async {
    // FIX 1: Always cancel any existing timer FIRST before starting a new one.
    // Without this, re-login spawns a second parallel timer. Both timers
    // increment _currentMinutes and emit to the stream, but the UI sees
    // double-speed increments and appears to freeze / not decrement correctly.
    _stopTimer();
    _currentMinutes = 0;

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Cloud-first fetch — never default to 0 if cloud data exists.
    try {
      final snapshot = await _database.ref('child_usage_stats/$uid/daily').get();
      if (snapshot.exists) {
        _currentMinutes = int.tryParse(snapshot.value.toString()) ?? 0;
      } else {
        _currentMinutes = prefs.getInt(_keyUsageMinutes) ?? 0;
      }
    } catch (e) {
      _currentMinutes = prefs.getInt(_keyUsageMinutes) ?? 0;
    }

    if (prefs.getString(_keyUsageDate) != todayStr) {
      _currentMinutes = 0;
      await prefs.setString(_keyUsageDate, todayStr);
      await _database.ref('child_usage_stats/$uid/daily').set(0);
    }

    // Emit cloud-fetched value immediately so UI is correct before first tick.
    _usageController.add(_currentMinutes);

    _usageTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      _currentMinutes++;
      _usageController.add(_currentMinutes);
      prefs.setInt(_keyUsageMinutes, _currentMinutes);

      try {
        await _syncMinutesAtomically(uid, _currentMinutes);
      } catch (e) {
        print("Firebase Sync Error: $e");
      }
    });
  }

  void _stopTimer() {
    _usageTimer?.cancel();
    _heartbeatTimer?.cancel();
    _usageTimer = null;
    _heartbeatTimer = null;
  }

  Stream<int> get usageMinutesStream => _usageController.stream;

  void dispose() {
    _stopTimer();
    _authSubscription?.cancel();
    _usageController.close();
    _isSessionValid.close();
  }

  Future<void> submitReport(ChildReportModel report) async {
    try {
      String? uid = _auth.currentUser?.uid ?? SharedPreferencesHelper.instance.getUserId();
      if (uid == null) throw Exception("User not logged in");
      final newKey = _database.ref().push().key!;
      final reportWithMeta = report.copyWith(childId: uid);
      final data = reportWithMeta.toMap();
      data['id'] = newKey;
      await _database.ref('safety_alerts/$uid/$newKey').set(data);
      if (report.recipient == 'Teacher') {
        final doc = await _firestore.collection('users').doc(uid).get();
        final teacherId = doc.data()?['teacher_id'];
        if (teacherId != null) {
          await _database.ref('teacher_notifications/$teacherId').push().set({
            'title': 'Safety Alert from Student',
            'body': '${report.issueType}: ${report.details}',
            'type': 'Safety',
            'timestamp': DateTime.now().toIso8601String(),
            'isRead': false,
            'reportId': newKey
          });
        }
      }
    } catch (e) {
      throw Exception("Failed to send report: $e");
    }
  }

  Stream<List<ChildReportModel>> getReportsStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? SharedPreferencesHelper.instance.getUserId();
      if (uid == null) { yield []; return; }
      yield* _database.ref('safety_alerts/$uid').onValue.map((event) {
        final List<ChildReportModel> reports = [];
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final map = Map<String, dynamic>.from(value);
              reports.add(ChildReportModel.fromMap(key.toString(), map));
            }
          });
        }
        reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return reports;
      });
    });
  }

  Stream<ParentSafetySettingsModel> getSafetySettingsStream() {
    return _auth.authStateChanges().asyncExpand((user) async* {
      String? uid = user?.uid ?? SharedPreferencesHelper.instance.getUserId();
      if (uid == null) {
        yield ParentSafetySettingsModel.fromMap({'daily_limit_hours': 24.0, 'bedtime_start': "00:00", 'bedtime_end': "00:00"});
        return;
      }
      yield* _database.ref('parent_settings/$uid').onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null) {
          return ParentSafetySettingsModel.fromMap({
            'daily_limit_hours': 24.0,
            'bedtime_start': "00:00",
            'bedtime_end': "00:00",
            'block_scary_content': false,
            'block_social_interaction': false,
            'educational_only_mode': false
          });
        }
        try {
          final Map<dynamic, dynamic> rawMap = data as Map<dynamic, dynamic>;
          final Map<String, dynamic> safeMap = {};
          rawMap.forEach((key, value) {
            String stringKey = key.toString();
            if (stringKey == 'daily_limit_hours') {
              if (value is int) safeMap[stringKey] = value.toDouble();
              else if (value is String) safeMap[stringKey] = double.tryParse(value) ?? 24.0;
              else safeMap[stringKey] = value;
            } else {
              safeMap[stringKey] = value;
            }
          });
          return ParentSafetySettingsModel.fromMap(safeMap);
        } catch (e) {
          return ParentSafetySettingsModel.fromMap({'daily_limit_hours': 24.0, 'bedtime_start': "00:00", 'bedtime_end': "00:00"});
        }
      });
    });
  }

  Future<void> _startTrackingSequence(String uid) async {
    // FIX: Race condition — Firebase auth restores the session before the login
    // flow has finished writing the role to SharedPreferences. If we check the
    // role immediately, it is null (null != 'child' → true) and _initTimer is
    // never called, so the UI always starts from 0 instead of the cloud value.
    //
    // Solution: retry the role check up to 10 times with a 500ms delay,
    // giving the login flow up to 5 seconds to persist the role.
    String? role;
    for (int i = 0; i < 10; i++) {
      role = SharedPreferencesHelper.instance.getUserRole();
      if (role != null) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (role != 'child') {
      _stopTimer();
      return;
    }
    await _initTimer(uid);
  }
}