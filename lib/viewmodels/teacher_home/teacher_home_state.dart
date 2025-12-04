import '../../models/user_model.dart';

class TeacherHomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<UserModel> students;

  TeacherHomeState({
    this.isLoading = true, // Default to loading, as we fetch on initialization
    this.errorMessage,
    this.students = const [],
  });

  TeacherHomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? students,
  }) {
    return TeacherHomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Allow clearing the error message
      students: students ?? this.students,
    );
  }
}
