import 'dart:ui';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;

  AuthViewModel(this._repo) : super(AuthState.initial());

  // Email/Password
  Future<void> signUp(
      String email,
      String password,
      String role,
      String name, {
        VoidCallback? onSuccess,
      }) async {
    state = state.copyWith(isSignUpLoading: true, signUpError: null);

    try {
      final user = await _repo.signUpUser(email, password, role, name);
      if (user == null) {
        state = state.copyWith(
          isSignUpLoading: false,
          signUpError: "Signup failed: user is null",
        );
        return;
      }
      state = state.copyWith(
        isSignUpLoading: false,
        user: user,
        navigateToRole: user.role,
      );
      await SharedPreferencesHelper.instance.saveUserId(user.uid);
      await SharedPreferencesHelper.instance.saveUserName(user.displayName);
      await SharedPreferencesHelper.instance.saveUserEmail(user.email);




      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(
        isSignUpLoading: false,
        signUpError: e.toString(),
      );
    }
  }

  Future<void> signInUser(
      String email,
      String password, {
        Function? onSuccess,
      }) async {
    state = state.copyWith(isSignInLoading: true,signInError: null);

    try {
      final user = await _repo.loginUser(email, password);

      state = state.copyWith(
        isSignInLoading: false,
        user: user,
        navigateToRole: user?.role,
      );

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isSignInLoading: false,
        signInError: e.toString(),
      );
    }
  }

  Future<void> forgotPassword(String email, {Function? onSuccess}) async {
    state = state.copyWith(isForgotPasswordLoading: true, forgotPasswordError: null);

    try {
      await _repo.forgotUser(email);
      state = state.copyWith(isForgotPasswordLoading: false);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isForgotPasswordLoading: false,
        forgotPasswordError: e.toString(),
      );
    }
  }

  // Google Login
  Future<void> continueWithGoogle(String role, {Function? onSuccess}) async {
    state = state.copyWith(isGoogleLoading: true, googleError: null);

    try {
      final user = await _repo.sendTokenOfGoogle(role);

      state = state.copyWith(
        isGoogleLoading: false,
        user: user,
      );

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(
        isGoogleLoading: false,
        googleError: e.toString(),
      );
    }
  }

  //  Navigation
  void resetNavigation() {
    state = state.copyWith(navigateToRole: null);
  }
}
