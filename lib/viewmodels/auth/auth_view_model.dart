import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import 'auth_state.dart';
import '../../repositories/auth/auth_repo.dart';
import '../../services/shared_preferences_helper.dart';
import '../child_view_model/inbox_report/child_safety_provider.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;
  final Ref _ref;

  AuthViewModel(this._repo, this._ref, [AuthState? initialState])
      : super(initialState ?? AuthState.initial()) {
    _listenToSessionValidity();
  }

  void _listenToSessionValidity() {
    _ref.listen(childSafetyServiceProvider, (previous, service) {
      service.sessionValidStream.listen((isValid) {
        if (!isValid && state.role?.toLowerCase() == 'child') {
          state = state.copyWith(isSessionInvalid: true);
        }
      });
    });
  }

  Future<void> signUp(String email, String password, String role, String name, String ageGroup, {VoidCallback? onSuccess}) async {
    state = state.copyWith(isSignUpLoading: true, signUpError: null, isSessionInvalid: false);
    try {
      final user = await _repo.signUpUser(email, password, role, name, ageGroup);
      if (user == null) throw "Signup failed: user is null";

      if (user.role.toLowerCase() == 'teacher') {
        state = state.copyWith(isSignUpLoading: false, user: user, role: user.role, navigateToRole: 'pendingTeacher');
        onSuccess?.call();
        return;
      }

      await _saveUserLocally(user);
      state = state.copyWith(isSignUpLoading: false, user: user, role: user.role, userId: user.uid, navigateToRole: user.role);
      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(isSignUpLoading: false, signUpError: e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> signInUser(String email, String password, {Function? onSuccess}) async {
    state = state.copyWith(isSignInLoading: true, signInError: null);
    try {
      final user = await _repo.loginUser(email, password);
      if (user == null) throw "Authentication failed.";

      if (user.role.toLowerCase() == 'child') {
        final service = _ref.read(childSafetyServiceProvider);
        if (await service.isAccountActive(user.uid)) {
          state = state.copyWith(isSignInLoading: false, signInError: "Account active on another device.");
          return;
        }
        await service.registerSession(user.uid);
      }

      await _saveUserLocally(user);
      state = state.copyWith(isSignInLoading: false, user: user, role: user.role, userId: user.uid, navigateToRole: user.role);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains("pending approval")) {
        state = state.copyWith(isSignInLoading: false, navigateToRole: 'pendingTeacher');
        if (onSuccess != null) onSuccess();
      } else {
        state = state.copyWith(isSignInLoading: false, signInError: e.toString());
      }
    }
  }

  Future<void> continueWithGoogle(String role, {Function? onSuccess}) async {
    state = state.copyWith(isGoogleLoading: true, googleError: null, isSessionInvalid: false);
    try {
      final user = await _repo.sendTokenOfGoogle(role);
      if (user == null) throw "Google login failed: user is null";

      await _saveUserLocally(user);
      state = state.copyWith(isGoogleLoading: false, user: user, userId: user.uid, role: user.role, navigateToRole: user.role);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains("pending approval")) {
        state = state.copyWith(isGoogleLoading: false, navigateToRole: 'pendingTeacher');
        if (onSuccess != null) onSuccess();
      } else {
        state = state.copyWith(isGoogleLoading: false, googleError: e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  Future<void> forgotPassword(String email, {Function? onSuccess}) async {
    state = state.copyWith(isForgotPasswordLoading: true, forgotPasswordError: null);
    try {
      await _repo.forgotUser(email);
      state = state.copyWith(isForgotPasswordLoading: false);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isForgotPasswordLoading: false, forgotPasswordError: e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isSignOutLoading: true);
    try {
      final uid = state.userId ?? SharedPreferencesHelper.instance.getUserId();
      if (uid != null && state.role?.toLowerCase() == 'child') {
        await _ref.read(childSafetyServiceProvider).clearSession(uid);
      }
      await _repo.logout();
      await SharedPreferencesHelper.instance.clearAll();
      state = AuthState.initial().copyWith(isFirstTime: false);
    } catch (e) {
      state = AuthState.initial().copyWith(isFirstTime: false);
    }
  }

  Future<void> completeOnboarding() async {
    await SharedPreferencesHelper.instance.saveIsFirstTime(false);
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> _saveUserLocally(UserModel user) async {
    await SharedPreferencesHelper.instance.saveUserId(user.uid);
    await SharedPreferencesHelper.instance.saveUserAgeGroup(user.ageGroup);
    await SharedPreferencesHelper.instance.saveUserRole(user.role);
    await SharedPreferencesHelper.instance.saveUserName(user.displayName);
    await SharedPreferencesHelper.instance.saveUserEmail(user.email);
    final phoneNumber = await _repo.getUserNumber(user.uid);
    await SharedPreferencesHelper.instance.saveUserPhoneNumber(phoneNumber);
  }

  void clearErrors() => state = state.copyWith(signInError: null, signUpError: null, forgotPasswordError: null, googleError: null);
  void resetNavigation() => state = state.copyWith(navigateToRole: null);
}