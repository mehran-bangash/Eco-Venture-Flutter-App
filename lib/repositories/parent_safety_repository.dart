import '../models/parent_safety_settings_model.dart';
import '../models/parent_alert_model.dart';
import '../services/parent_safety_service.dart';

class ParentSafetyRepository {
  final ParentSafetyService _service;

  ParentSafetyRepository(this._service);

  // Settings
  Future<void> saveSettings(String childId, ParentSafetySettingsModel settings) async {
    await _service.updateSafetySettings(childId, settings);
  }

  Stream<ParentSafetySettingsModel> watchSettings(String childId) {
    return _service.getSettingsStream(childId);
  }

  // Alerts
  Stream<List<ParentAlertModel>> watchAlerts(String childId) {
    return _service.getAlertsStream(childId);
  }

  Future<void> resolveAlert(String childId, String alertId) async {
    await _service.updateAlertStatus(childId, alertId, 'Resolved');
  }

  // --- NEW: Linking Methods ---
  Future<String> linkChild(String parentUid, String email, String name) async {
    return await _service.linkChildAccount(parentUid, email, name);
  }

  Future<List<Map<String, dynamic>>> getLinkedChildren(String parentUid) async {
    return await _service.getLinkedChildren(parentUid);
  }
  Future<void> unlinkChild(String parentUid, String childUid) async {
    await _service.unlinkChildAccount(parentUid, childUid);
  }
}