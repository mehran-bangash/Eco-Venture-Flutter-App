class UserProfileState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? userProfile;

  UserProfileState({
    required this.isLoading,
    this.error,
    this.userProfile,
  });

  factory UserProfileState.initial() {
    return UserProfileState(
      isLoading: false,
      error: null,
      userProfile: null,
    );
  }

  UserProfileState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userProfile,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
