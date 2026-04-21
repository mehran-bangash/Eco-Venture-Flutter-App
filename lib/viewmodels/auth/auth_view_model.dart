import 'dart:ui';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth/auth_repo.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;

  AuthViewModel(this._repo, [AuthState? initialState])
      : super(initialState ?? AuthState.initial());


  // Future<void> loadSession() async {
  //   final prefs = SharedPreferencesHelper.instance;
  //
  //   final bool isFirstTime = prefs.getIsFirstTime();
  //   final String? userId = prefs.getUserId();
  //   final String? role = prefs.getUserRole();
  //
  //   state = state.copyWith(
  //     isFirstTime: isFirstTime,
  //     userId: userId,
  //     role: role,
  //   );
  // }

  /// Logic: Handles Email/Password Registration
  Future<void> signUp(
    String email,
    String password,
    String role,
    String name,
    String ageGroup, {
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isSignUpLoading: true, signUpError: null);

    try {
      final user = await _repo.signUpUser(
        email,
        password,
        role,
        name,
        ageGroup,
      );

      if (user == null) {
        state = state.copyWith(
          isSignUpLoading: false,
          signUpError: "Signup failed: user is null",
        );
        return;
      }

      // Persist user details locally for session management and classification
      await SharedPreferencesHelper.instance.saveUserId(user.uid);
      await SharedPreferencesHelper.instance.saveUserAgeGroup(user.ageGroup);
      await SharedPreferencesHelper.instance.saveUserRole(user.role);
      await SharedPreferencesHelper.instance.saveUserName(user.displayName);

      // Update state and trigger navigation
      state = state.copyWith(
        isSignUpLoading: false,
        user: user,
        navigateToRole: user.role,
      );

      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(
        isSignUpLoading: false,
        signUpError: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  /// Logic: Handles Email/Password Login with enhanced error cleanup
  Future<void> signInUser(
    String email,
    String password, {
    Function? onSuccess,
  }) async {
    state = state.copyWith(isSignInLoading: true, signInError: null);

    try {
      final user = await _repo.loginUser(email, password);

      if (user == null) {
        state = state.copyWith(
          isSignInLoading: false,
          signInError: "Authentication failed. Please try again.",
        );
        return;
      }

      // Persist critical data for the handshake and student filtering logic
      await SharedPreferencesHelper.instance.saveUserId(user.uid);
      await SharedPreferencesHelper.instance.saveUserAgeGroup(user.ageGroup);
      await SharedPreferencesHelper.instance.saveUserRole(user.role);
      await SharedPreferencesHelper.instance.saveUserName(user.displayName);

      state = state.copyWith(
        isSignInLoading: false,
        user: user,
        role: user.role,
        userId: user.uid,
        signInError: null,
        navigateToRole: user.role,
      );

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isSignInLoading: false,
        signInError: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  /// Logic: Standard Password Reset
  Future<void> forgotPassword(String email, {Function? onSuccess}) async {
    state = state.copyWith(
      isForgotPasswordLoading: true,
      forgotPasswordError: null,
    );

    try {
      await _repo.forgotUser(email);
      state = state.copyWith(isForgotPasswordLoading: false);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isForgotPasswordLoading: false,
        forgotPasswordError: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  /// Logic: Handles Google Auth Handshake
  Future<void> continueWithGoogle(String role, {Function? onSuccess}) async {
    state = state.copyWith(isGoogleLoading: true, googleError: null);

    try {
      final user = await _repo.sendTokenOfGoogle(role);
      if (user == null) {
        state = state.copyWith(
          isGoogleLoading: false,
          googleError: "Google login failed: user is null",
        );
        return;
      }

      // Persist local info
      await SharedPreferencesHelper.instance.saveUserId(user.uid);
      await SharedPreferencesHelper.instance.saveUserAgeGroup(user.ageGroup);
      await SharedPreferencesHelper.instance.saveUserRole(user.role);
      await SharedPreferencesHelper.instance.saveUserName(user.displayName);

      state = state.copyWith(
        isGoogleLoading: false,
        user: user,
        userId: user.uid,
        role: user.role,
        navigateToRole: user.role,
      );

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isGoogleLoading: false,
        googleError: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  /// Logic: Completely wipes the session and local preferences
  Future<void> signOut() async {
    state = state.copyWith(isSignOutLoading: true);
    try {
      await _repo.logout();
      await SharedPreferencesHelper.instance.clearAll();

      // Reset state but keep isFirstTime as false since they already onboarded
      state = AuthState.initial().copyWith(isFirstTime: false);
    } catch (e) {
      state = state.copyWith(
          isSignOutLoading: false,
          signOutError: e.toString().replaceAll("Exception: ", "")
      );
    }
  }

  Future<void> completeOnboarding() async {
    await SharedPreferencesHelper.instance.saveIsFirstTime(false);
    state = state.copyWith(isFirstTime: false);
  }

  void clearErrors() {
    state = state.copyWith(
      signInError: null,
      signUpError: null,
      forgotPasswordError: null,
      googleError: null,
    );
  }

  void resetNavigation() {
    state = state.copyWith(navigateToRole: null);
  }
}
