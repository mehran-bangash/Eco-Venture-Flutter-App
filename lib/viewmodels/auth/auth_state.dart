import '../../models/user_model.dart';

class AuthState {
  // Email login state
  final bool isEmailLoading;
  final String? emailError;

  // Google login state
  final bool isGoogleLoading;
  final String? googleError;

  // Common fields
  final UserModel? user;
  final String? navigateToRole;

  AuthState({
    this.isEmailLoading = false,
    this.emailError,
    this.isGoogleLoading = false,
    this.googleError,
    this.user,
    this.navigateToRole,
  });

  AuthState copyWith({
    bool? isEmailLoading,
    String? emailError,
    bool? isGoogleLoading,
    String? googleError,
    UserModel? user,
    String? navigateToRole,
  }) {
    return AuthState(
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      emailError: emailError ?? this.emailError,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      googleError: googleError ?? this.googleError,
      user: user ?? this.user,
      navigateToRole: navigateToRole ?? this.navigateToRole,
    );
  }

  factory AuthState.initial() => AuthState();
}
