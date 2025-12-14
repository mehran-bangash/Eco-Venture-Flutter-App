import 'dart:convert';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import '../models/parent_safety_settings_model.dart';
import '../models/parent_alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. SETTINGS (WRITE) ---
  // Fix: Saves directly to 'parent_settings/childId' so Child App can find it easily.
  Future<void> updateSafetySettings(
    String childId,
    ParentSafetySettingsModel settings,
  ) async {
    try {
      await _database.ref('parent_settings/$childId').set(settings.toMap());
    } catch (e) {
      throw Exception("Failed to update settings: $e");
    }
  }

  // Stream Settings (Read back for Parent UI)

  Stream<ParentSafetySettingsModel> getSettingsStream(String childId) {
    return _database.ref('parent_settings/$childId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        return ParentSafetySettingsModel.fromMap(
          Map<String, dynamic>.from(data),
        );
      }
      return ParentSafetySettingsModel();
    });
  }

  // --- 2. ALERTS ---
  Stream<List<ParentAlertModel>> getAlertsStream(String childId) {
    return _database.ref('safety_alerts/$childId').onValue.map((event) {
      final data = event.snapshot.value;
      final List<ParentAlertModel> alerts = [];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            alerts.add(
              ParentAlertModel.fromMap(
                key.toString(),
                Map<String, dynamic>.from(value),
              ),
            );
          }
        });
      }
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  // --- FIX: RESOLVE & NOTIFY CHILD ---
  Future<void> updateAlertStatus(
    String childId,
    String alertId,
    String newStatus,
  ) async {
    // 1. Update Firebase
    await _database.ref('safety_alerts/$childId/$alertId').update({
      'status': newStatus,
    });

    // 2. Notify Child (Via Backend)
    if (newStatus == 'Resolved') {
      await _notifyChild(
        childId,
        "Report Resolved",
        "Your parent has reviewed your report.",
      );
    }
  }

  // Call Node.js Backend to send FCM
  Future<void> _notifyChild(String childUid, String title, String body) async {
    try {
      final url = Uri.parse(
        ApiConstants.notifyChildEndPoints,
      ); // Ensure this route exists in Node.js
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'childId': childUid, 'title': title, 'body': body}),
      );
    } catch (e) {
      print("Failed to notify child: $e");
    }
  }

  // --- 3. PARENT-CHILD LINKING ---
  // ... (Linking Logic Preserved) ...
  Future<String> linkChildAccount(
    String parentUid,
    String childEmail,
    String childName,
  ) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: childEmail)
        .where('role', isEqualTo: 'child')
        .limit(1)
        .get();
    if (query.docs.isEmpty) throw Exception("No child found with this email.");
    final childDoc = query.docs.first;
    final childData = childDoc.data();
    String realName = childData['name'] ?? '';
    if (realName.toLowerCase().trim() != childName.toLowerCase().trim()) {
      throw Exception("Child found, but name does not match.");
    }
    final childUid = childDoc.id;
    await _database.ref('parent_children/$parentUid/$childUid').set({
      'name': realName,
      'uid': childUid,
      'email': childEmail,
      'linkedAt': DateTime.now().toIso8601String(),
    });
    await _firestore.collection('users').doc(childUid).update({
      'parent_id': parentUid,
    });
    return childUid;
  }

  Future<List<Map<String, dynamic>>> getLinkedChildren(String parentUid) async {
    final snapshot = await _database.ref('parent_children/$parentUid').get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  Future<void> unlinkChildAccount(String parentUid, String childUid) async {
    await _database.ref('parent_children/$parentUid/$childUid').remove();
  }

  Future<void> escalateReportToTeacher(
    String childId,
    ParentAlertModel alert,
    String note,
  ) async {
    try {
      // 1. Get Parent ID (Current User)
      String? parentId = await SharedPreferencesHelper.instance.getUserId();
      final newKey = _database.ref().push().key!;

      final childDoc = await _firestore.collection('users').doc(childId).get();
      final teacherId = childDoc.data()?['teacher_id'];

      if (teacherId != null) {
        await _database.ref('Teacher_Content/$teacherId/inbox/$newKey').set({
          'type': 'Safety Report',
          'childId': childId,
          'parentId': parentId, // <--- ADDED PARENT ID
          'reportTitle': alert.title,
          'reportDesc': alert.description,
          'parentNote': note,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'Pending',
        });
        print("Report escalated to Teacher $teacherId");
      }
    } catch (e) {
      print("Escalation Error: $e");
    }
  }

  // Escalation: Copy to Admin
  Future<void> escalateReportToAdmin(
    String childId,
    ParentAlertModel alert,
    String note,
  ) async {
    try {
      final parentId = await SharedPreferencesHelper.instance.getUserId();
      final adminsSnapshot = await _firestore.collection('Admins').get();

      for (final adminDoc in adminsSnapshot.docs) {
        final adminUid = adminDoc.id;

        final newKey = _database.ref().push().key!;

        await _database.ref('Admin/$adminUid/inbox/$newKey').set({
          'type': 'Safety Report',
          'childId': childId,
          'parentId': parentId,
          'reportTitle': alert.title,
          'reportDesc': alert.description,
          'parentNote': note,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'Pending',
        });
      }

      print("Report successfully sent to Admin inbox");
    } catch (e) {
      print("Admin Escalation Error: $e");
    }
  }
}
