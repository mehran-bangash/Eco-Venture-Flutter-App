
import 'package:eco_venture/viewmodels/teacher_notification/teacher_notification_state.dart';
import 'package:eco_venture/viewmodels/teacher_notification/teacher_notification_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_notification_repository.dart';
import '../../services/teacher_notification_service.dart';

final teacherNotificationServiceProvider = Provider(
  (ref) => TeacherNotificationService(),
);

final teacherNotificationRepositoryProvider = Provider((ref) {
  return TeacherNotificationRepository(
    ref.watch(teacherNotificationServiceProvider),
  );
});

final teacherNotificationViewModelProvider =
    StateNotifierProvider.autoDispose<
      TeacherNotificationViewModel,
      TeacherNotificationState
    >((ref) {
      return TeacherNotificationViewModel(
        ref.watch(teacherNotificationRepositoryProvider),
      );
    });
