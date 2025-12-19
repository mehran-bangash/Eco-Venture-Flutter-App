
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TeacherNotificationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getTeacherId() async {
    String? id = _auth.currentUser?.uid;
    id ??= await SharedPreferencesHelper.instance.getUserId();
    return id;
  }

  // --- FETCH NOTIFICATIONS ---
  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return Stream.fromFuture(_getTeacherId()).asyncExpand((teacherId) {
      if (teacherId == null) {
        return Stream.value([]);
      }

      // Listen to 'teacher_notifications/{teacherId}'
      return _database.ref('teacher_notifications/$teacherId').onValue.map((event) {
        final data = event.snapshot.value;
        final List<Map<String, dynamic>> notifications = [];

        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final map = Map<String, dynamic>.from(value);
              map['id'] = key;
              // Ensure timestamp exists for sorting
              map['timestamp'] ??= DateTime.now().toIso8601String();
              notifications.add(map);
            }
          });
        }

        // Sort by newest first
        notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        return notifications;
      });
    });
  }

  // --- DELETE NOTIFICATION ---
  Future<void> deleteNotification(String notificationId) async {
    final teacherId = await _getTeacherId();
    if (teacherId != null) {
      await _database.ref('teacher_notifications/$teacherId/$notificationId').remove();
    }
  }
}