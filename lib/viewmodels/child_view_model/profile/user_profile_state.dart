class UserProfileState {
  final bool isLoading;
  final String? error;
  final String? teacherName;
  final Map<String, dynamic>? userProfile;

  UserProfileState({
    required this.isLoading,
    this.error,
    this.teacherName,
    this.userProfile,
  });

  // This ensures the screen starts without the loading spinner
  factory UserProfileState.initial() {
    return UserProfileState(
      isLoading: false,
      error: null,
      teacherName: null,
      userProfile: null,
    );
  }

  UserProfileState copyWith({
    bool? isLoading,
    String? error,
    String? teacherName,
    Map<String, dynamic>? userProfile,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      // FIX: Use '?? this.error' so existing errors aren't cleared
      // unless you explicitly pass a new error or null.
      error: error ?? this.error,
      teacherName: teacherName ?? this.teacherName,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}