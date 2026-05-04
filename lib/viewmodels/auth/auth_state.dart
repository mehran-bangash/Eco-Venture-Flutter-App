import '../../models/user_model.dart';

class AuthState {
  final bool isFirstTime;
  final String? userId;
  final String? role;

  // NEW: Session validity field to fix the routing error
  final bool isSessionInvalid;

  final bool isSignInLoading;
  final String? signInError;
  final bool isSignUpLoading;
  final String? signUpError;
  final bool isSignOutLoading;
  final String? signOutError;
  final bool isForgotPasswordLoading;
  final String? forgotPasswordError;
  final bool isGoogleLoading;
  final String? googleError;
  final UserModel? user;
  final String? navigateToRole;

  AuthState({
    this.isFirstTime = true,
    this.userId,
    this.role,
    this.isSessionInvalid = false, // Default to valid
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

  factory AuthState.fromPrefs({
    required bool isFirstTime,
    required String? userId,
    required String? role,
  }) => AuthState(
    isFirstTime: isFirstTime,
    userId: userId,
    role: role,
    isSessionInvalid: false,
  );

  static const _clear = Object();

  AuthState copyWith({
    bool? isFirstTime,
    Object? userId = _clear,
    Object? role = _clear,
    bool? isSessionInvalid, // Added to copyWith
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
      isSessionInvalid: isSessionInvalid ?? this.isSessionInvalid, // Logic added here
      isSignInLoading: isSignInLoading ?? this.isSignInLoading,
      signInError: signInError ?? this.signInError,
      isSignUpLoading: isSignUpLoading ?? this.isSignUpLoading,
      signUpError: signUpError ?? this.signUpError,
      isForgotPasswordLoading: isForgotPasswordLoading ?? this.isForgotPasswordLoading,
      forgotPasswordError: forgotPasswordError ?? this.forgotPasswordError,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      googleError: googleError ?? this.googleError,
      user: user == _clear ? this.user : user as UserModel?,
      isSignOutLoading: isSignOutLoading ?? this.isSignOutLoading,
      signOutError: signOutError ?? this.signOutError,
      navigateToRole: navigateToRole == _clear ? this.navigateToRole : navigateToRole as String?,
    );
  }
}