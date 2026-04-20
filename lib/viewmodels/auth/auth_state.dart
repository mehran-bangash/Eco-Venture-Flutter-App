import '../../models/user_model.dart';

class AuthState {
  // Session State (New fields for Issue #1)
  final bool isFirstTime;
  final String? userId;
  final String? role;

  // Sign In state
  final bool isSignInLoading;
  final String? signInError;

  // Sign Up state
  final bool isSignUpLoading;
  final String? signUpError;

  // signOut
  final bool isSignOutLoading;
  final String? signOutError;

  // Forgot Password state
  final bool isForgotPasswordLoading;
  final String? forgotPasswordError;

  // Google login state
  final bool isGoogleLoading;
  final String? googleError;

  // Common fields
  final UserModel? user;
  final String? navigateToRole;

  AuthState({
    this.isFirstTime = true, // Default to true until checked
    this.userId,
    this.role,
    this.isSignInLoading = false,
    this.signInError,
    this.isSignOutLoading = false,
    this.signOutError,
    this.isSignUpLoading = false,
    this.signUpError,
    this.isForgotPasswordLoading = false,
    this.forgotPasswordError,
    this.isGoogleLoading = false,
    this.googleError,
    this.user,
    this.navigateToRole,
  });

  factory AuthState.initial() => AuthState();

//  Add this new factory
  factory AuthState.fromPrefs({
    required bool isFirstTime,
    required String? userId,
    required String? role,
  }) => AuthState(
    isFirstTime: isFirstTime,
    userId: userId,
    role: role,
  );
  // Add sentinel for clearing nullable fields
  static const _clear = Object();

  AuthState copyWith({
    bool? isFirstTime,
    Object? userId = _clear,
    Object? role = _clear,
    bool? isSignInLoading,
    String? signInError,
    bool? isSignOutLoading,
    String? signOutError,
    bool? isSignUpLoading,
    String? signUpError,
    bool? isForgotPasswordLoading,
    String? forgotPasswordError,
    bool? isGoogleLoading,
    String? googleError,
    Object? user = _clear,
    Object? navigateToRole = _clear,
  }) {
    return AuthState(
      isFirstTime: isFirstTime ?? this.isFirstTime,
      userId: userId == _clear ? this.userId : userId as String?,
      role: role == _clear ? this.role : role as String?,
      isSignInLoading: isSignInLoading ?? this.isSignInLoading,
      signInError: signInError ?? this.signInError,
      isSignUpLoading: isSignUpLoading ?? this.isSignUpLoading,
      signUpError: signUpError ?? this.signUpError,
      isForgotPasswordLoading:
          isForgotPasswordLoading ?? this.isForgotPasswordLoading,
      forgotPasswordError: forgotPasswordError ?? this.forgotPasswordError,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      googleError: googleError ?? this.googleError,
      user: user == _clear ? this.user : user as UserModel?,
      isSignOutLoading: isSignOutLoading ?? this.isSignOutLoading,
      signOutError: signOutError ?? this.signOutError,
      navigateToRole: navigateToRole == _clear
          ? this.navigateToRole
          : navigateToRole as String?,
    );
  }


}
