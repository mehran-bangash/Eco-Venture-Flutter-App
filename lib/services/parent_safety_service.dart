import 'dart:convert';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import '../models/parent_safety_settings_model.dart';
import '../models/parent_alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            final map = Map<String, dynamic>.from(value);

            // MAP FIELDS CORRECTLY
            // 1. Title/Source
            String title = map['issueType'] ?? map['title'] ?? 'Alert';
            String desc =
                map['details'] ?? map['body'] ?? map['description'] ?? '';

            // 2. Content Context
            // If the report has content info, append it to description for clarity if model doesn't support it directly yet,
            // or better, ensure ParentAlertModel has these fields (I will update Model next).
            // For now, pass raw map values to the model factory.

            alerts.add(ParentAlertModel.fromMap(key.toString(), map));
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
    // 1. Update Database
    await _database.ref('safety_alerts/$childId/$alertId').update({
      'status': newStatus,
    });

    // 2. FIX: Notify Child
    if (newStatus == 'Resolved') {
      // Call Node.js
      final url = Uri.parse(
        'https://eco-venture-backend.onrender.com/notify-child',
      );
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'childId': childId,
          'title': 'Safety Report Resolved',
          'body': 'Your parent has reviewed your report.',
        }),
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
      // 1. Get Child Profile to find Teacher ID
      // (Assuming you have a way to get the teacher ID, typically stored in child profile)
      // For now, we write to a global 'escalated_reports' node or 'teacher_inbox' if we know the ID.

      // Let's assume we save to a specific node that Teachers listen to:
      final newKey = _database.ref().push().key!;

      await _database.ref('teacher_reports/$newKey').set({
        'childId': childId,
        'originalReportId': alert.id,
        'title': alert.title,
        'description': alert.description,
        'parentNote': note,
        'status': 'Escalated',
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'Safety',
      });
    } catch (e) {
      print("Escalation Error: $e");
    }
  }

  Future<void> escalateReportToAdmin(
    String childId,
    ParentAlertModel alert,
    String note,
  ) async {
    final newKey = _database.ref().push().key!;
    await _database.ref('admin_reports/$newKey').set({
      'childId': childId,
      'issue': alert.title,
      'details': alert.description,
      'parentNote': note,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
