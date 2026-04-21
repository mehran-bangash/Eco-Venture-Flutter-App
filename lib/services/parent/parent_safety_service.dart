import 'dart:convert';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import '../../models/parent_safety_settings_model.dart';
import '../../models/parent_alert_model.dart';
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

  Stream<List<ParentAlertModel>> getAlertsStream(String childId) {
    return _database.ref('safety_alerts/$childId').onValue.map((event) {
      final data = event.snapshot.value;
      final List<ParentAlertModel> alerts = [];

      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            alerts.add(ParentAlertModel.fromMap(key.toString(), map));
          }
        });
      }

      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  Future<void> updateAlertStatus(
    String childId,
    String alertId,
    String newStatus,
  ) async {
    await _database.ref('safety_alerts/$childId/$alertId').update({
      'status': newStatus,
    });

    if (newStatus == 'Resolved') {
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

  Future<void> _notifyChild(String childUid, String title, String body) async {
    try {
      final url = Uri.parse(ApiConstants.notifyChildEndPoints);
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'childId': childUid, 'title': title, 'body': body}),
      );
    } catch (e) {
      print("Failed to notify child: $e");
    }
  }

  // --- UPDATED LINKING LOGIC ---

  // --- UPDATED LINKING LOGIC WITH ROLE VALIDATION ---
  Future<String> linkChildAccount(
      String parentUid,
      String childEmail,
      String childName,
      ) async {
    // 1. Find account by email only first to check existence and role
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: childEmail)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("No account found with this email.");
    }

    final childDoc = query.docs.first;
    final childData = childDoc.data();
    final childUid = childDoc.id;

    // 2. REQUIREMENT: Strict Role Validation
    if (childData['role'] != 'child') {
      throw Exception("The account linked to this email is not a child account.");
    }

    // 3. REQUIREMENT: Check if child is already in Parent's list (RTDB)
    final existingCheck = await _database
        .ref('parent_children/$parentUid/$childUid')
        .get();
    if (existingCheck.exists) {
      throw Exception("${childData['name'] ?? 'This child'} is already linked to your account.");
    }

    // 4. Name validation (Case insensitive)
    String realName = childData['name'] ?? '';
    if (realName.toLowerCase().trim() != childName.toLowerCase().trim()) {
      throw Exception("Found account, but the name does not match our records.");
    }

    // 5. Perform Linking
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


  Future<void> unlinkChildAccount(String parentUid, String childUid) async {
    await _database.ref('parent_children/$parentUid/$childUid').remove();
    await _firestore.collection('users').doc(childUid).update({
      'parent_id': FieldValue.delete(),
    });
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

  Future<void> escalateReportToTeacher(
    String childId,
    ParentAlertModel alert,
    String note,
  ) async {
    try {
      final childDoc = await _firestore.collection('users').doc(childId).get();
      if (!childDoc.exists) throw Exception("Student profile not found.");

      final data = childDoc.data();
      final String? teacherId = data?['teacher_id'];

      if (teacherId == null || teacherId.trim().isEmpty) {
        throw Exception(
          "This student is not assigned to a teacher. Escalation cancelled.",
        );
      }

      final newKey = _database.ref('parent_to_teacher_reports').push().key!;

      await _database.ref('parent_to_teacher_reports/$newKey').set({
        'teacherId': teacherId,
        'childId': childId,
        'originalReportId': alert.id,
        'title': alert.title,
        'description': alert.description,
        'parentNote': note,
        'status': 'Escalated',
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'Safety',
        'senderName': 'Parent',
      });
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> escalateReportToAdmin(
    String childId,
    ParentAlertModel alert,
    String note,
  ) async {
    final newKey = _database.ref('parent_to_admin_reports').push().key!;
    await _database.ref('parent_to_admin_reports/$newKey').set({
      'childId': childId,
      'issue': alert.title,
      'details': alert.description,
      'parentNote': note,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
