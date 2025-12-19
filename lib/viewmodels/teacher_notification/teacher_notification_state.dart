
class TeacherNotificationState {
  final bool isLoading;
  final List<Map<String, dynamic>> notifications;
  final String? errorMessage;

  TeacherNotificationState({
    this.isLoading = true,
    this.notifications = const [],
    this.errorMessage,
  });

  TeacherNotificationState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? notifications,
    String? errorMessage,
  }) {
    return TeacherNotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}

