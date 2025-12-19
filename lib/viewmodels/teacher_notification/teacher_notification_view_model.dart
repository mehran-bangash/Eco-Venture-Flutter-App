import 'dart:async';
import 'package:eco_venture/viewmodels/teacher_notification/teacher_notification_state.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../repositories/teacher_notification_repository.dart';

class TeacherNotificationViewModel extends StateNotifier<TeacherNotificationState> {
  final TeacherNotificationRepository _repository;
  StreamSubscription? _sub;

  TeacherNotificationViewModel(this._repository) : super(TeacherNotificationState()) {
    _loadNotifications();
  }

  void _loadNotifications() {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();

    _sub = _repository.getNotifications().listen(
            (data) {
          state = state.copyWith(isLoading: false, notifications: data);
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  Future<void> deleteNotification(String id) async {
    try {
      // Optimistic update
      final currentList = [...state.notifications];
      currentList.removeWhere((n) => n['id'] == id);
      state = state.copyWith(notifications: currentList);

      await _repository.deleteNotification(id);
    } catch (e) {
      // Revert if needed, or just log error
      print("Delete Error: $e");
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}