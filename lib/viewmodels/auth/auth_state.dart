import '../../models/user_model.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final String? navigateToRole;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.navigateToRole,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
    String? navigateToRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      navigateToRole: navigateToRole ?? this.navigateToRole,
    );
  }

  factory AuthState.initial() => AuthState();
}
