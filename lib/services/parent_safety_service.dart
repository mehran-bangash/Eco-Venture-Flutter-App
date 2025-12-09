import 'package:firebase_database/firebase_database.dart';
import '../models/parent_safety_settings_model.dart';
import '../models/parent_alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ParentSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. SETTINGS (WRITE) ---
  // Fix: Saves directly to 'parent_settings/childId' so Child App can find it easily.
  Future<void> updateSafetySettings(String childId, ParentSafetySettingsModel settings) async {
    try {
      print("DEBUG: Saving settings for Child: $childId");
      // This path must match what the Child App listens to
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
            final map = Map<String, dynamic>.from(value);
            // Ensure ID is passed if missing in map
            alerts.add(ParentAlertModel.fromMap(key.toString(), map));
          }
        });
      }
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  Future<void> updateAlertStatus(String childId, String alertId, String newStatus) async {
    await _database.ref('safety_alerts/$childId/$alertId').update({'status': newStatus});
  }

  // --- 3. PARENT-CHILD LINKING ---
  Future<String> linkChildAccount(String parentUid, String childEmail, String childName) async {
    final query = await _firestore.collection('users')
        .where('email', isEqualTo: childEmail)
        .where('role', isEqualTo: 'child')
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception("No child found with this email.");

    final childDoc = query.docs.first;
    final childData = childDoc.data();

    // Name Check (Case Insensitive)
    String realName = childData['name'] ?? '';
    if (realName.toLowerCase().trim() != childName.toLowerCase().trim()) {
      throw Exception("Child found, but name does not match.");
    }

    final childUid = childDoc.id;

    // Add to Parent's List
    await _database.ref('parent_children/$parentUid/$childUid').set({
      'name': realName,
      'uid': childUid,
      'email': childEmail,
      'linkedAt': DateTime.now().toIso8601String(),
    });

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

  Future<void> unlinkChildAccount(String parentUid, String childUid) async {
    await _database.ref('parent_children/$parentUid/$childUid').remove();
    // Do not delete 'parent_id' from Firestore to preserve history if needed,
    // or uncomment next line to fully detach:
    // await _firestore.collection('users').doc(childUid).update({'parent_id': FieldValue.delete()});
  }
}
