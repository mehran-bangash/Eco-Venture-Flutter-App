import '../../models/user_model.dart';

class AuthState {
  //  Sign In state
  final bool isSignInLoading;
  final String? signInError;

  // Sign Up state
  final bool isSignUpLoading;
  final String? signUpError;

  // Forgot Password state
  final bool isForgotPasswordLoading;
  final String? forgotPasswordError;

  //Google login state
  final bool isGoogleLoading;
  final String? googleError;

  // Common fields
  final UserModel? user;
  final String? navigateToRole;

  AuthState({
    this.isSignInLoading = false,
    this.signInError,
    this.isSignUpLoading = false,
    this.signUpError,
    this.isForgotPasswordLoading = false,
    this.forgotPasswordError,
    this.isGoogleLoading = false,
    this.googleError,
    this.user,
    this.navigateToRole,
  });

  AuthState copyWith({
    bool? isSignInLoading,
    String? signInError,
    bool? isSignUpLoading,
    String? signUpError,
    bool? isForgotPasswordLoading,
    String? forgotPasswordError,
    bool? isGoogleLoading,
    String? googleError,
    UserModel? user,
    String? navigateToRole,
  }) {
    return AuthState(
      isSignInLoading: isSignInLoading ?? this.isSignInLoading,
      signInError: signInError ?? this.signInError,
      isSignUpLoading: isSignUpLoading ?? this.isSignUpLoading,
      signUpError: signUpError ?? this.signUpError,
      isForgotPasswordLoading:
      isForgotPasswordLoading ?? this.isForgotPasswordLoading,
      forgotPasswordError: forgotPasswordError ?? this.forgotPasswordError,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      googleError: googleError ?? this.googleError,
      user: user ?? this.user,
      navigateToRole: navigateToRole ?? this.navigateToRole,
    );
  }

  factory AuthState.initial() => AuthState();
}
