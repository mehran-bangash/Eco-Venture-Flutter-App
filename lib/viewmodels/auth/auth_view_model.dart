import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;

  AuthViewModel(this._repo) : super(AuthState.initial());

  Future<void> signUp(String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repo.signUpUser(email, password, role);

      state = state.copyWith(
        isLoading: false,
        user: user,
        navigateToRole: user?.role,
      );


    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  void resetNavigation() {
    state = state.copyWith(navigateToRole: null);
  }

}