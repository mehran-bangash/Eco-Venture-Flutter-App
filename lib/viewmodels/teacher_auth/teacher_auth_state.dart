class TeacherAuthState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  TeacherAuthState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  TeacherAuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return TeacherAuthState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false, // Reset success on state change usually
      errorMessage: errorMessage,
    );
  }
}