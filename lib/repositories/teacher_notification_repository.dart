import '../services/teacher_notification_service.dart';

class TeacherNotificationRepository {
  final TeacherNotificationService _service;

  TeacherNotificationRepository(this._service);

  Stream<List<Map<String, dynamic>>> getNotifications() {
    return _service.getNotificationsStream();
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
  }
}