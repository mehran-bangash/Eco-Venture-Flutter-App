import 'package:firebase_database/firebase_database.dart';
import '../models/parent_safety_settings_model.dart';
import '../models/parent_alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ParentSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. SETTINGS ---
  Future<void> updateSafetySettings(String childId, ParentSafetySettingsModel settings) async {
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
        return ParentSafetySettingsModel.fromMap(Map<String, dynamic>.from(data));
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
            alerts.add(ParentAlertModel.fromMap(key.toString(), Map<String, dynamic>.from(value)));
          }
        });
      }
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  // FIX: Added missing method
  Future<void> updateAlertStatus(String childId, String alertId, String newStatus) async {
    await _database.ref('safety_alerts/$childId/$alertId').update({'status': newStatus});
  }

  // --- 3. PARENT-CHILD LINKING (NEW) ---

  Future<String> linkChildAccount(String parentUid, String childEmail, String childName) async {
    // 1. Find Child by Email in Firestore
    final query = await _firestore.collection('users')
        .where('email', isEqualTo: childEmail)
        .where('role', isEqualTo: 'child')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("No child found with this email.");
    }

    final childDoc = query.docs.first;
    final childData = childDoc.data();

    // 2. Verify Name (Simple case-insensitive check)
    String realName = childData['name'] ?? '';
    if (realName.toLowerCase().trim() != childName.toLowerCase().trim()) {
      throw Exception("Child found, but name does not match.");
    }

    final childUid = childDoc.id;

    // 3. Add to Parent's List in RTDB
    await _database.ref('parent_children/$parentUid/$childUid').set({
      'name': realName,
      'uid': childUid,
      'email': childEmail,
      'linkedAt': DateTime.now().toIso8601String(),
    });

    // 4. Add Parent ID to Child's Profile (Firestore)
    await _firestore.collection('users').doc(childUid).update({'parent_id': parentUid});

    return childUid;
  }

  Future<List<Map<String, dynamic>>> getLinkedChildren(String parentUid) async {
    final snapshot = await _database.ref('parent_children/$parentUid').get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
  // Remove child from parent's list
  Future<void> unlinkChildAccount(String parentUid, String childUid) async {
    // Remove from parent_children node
    await _database.ref('parent_children/$parentUid/$childUid').remove();

    // Optional: Remove link from child's profile in Firestore
    await _firestore.collection('users').doc(childUid).update({
      'parent_id': FieldValue.delete()
    });
  }
}
