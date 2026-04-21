import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth/auth_repo.dart';
import '../../services/shared_preferences_helper.dart';
import 'auth_state.dart';
import 'auth_view_model.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo.getInstance;
});

final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.read(authRepoProvider);
  final prefs = SharedPreferencesHelper.instance;

  // ✅ Read prefs synchronously right here — SharedPreferences is
  // already initialized in main() so this is safe and instant
  final initialState = AuthState.fromPrefs(
    isFirstTime: prefs.getIsFirstTime(),
    userId: prefs.getUserId(),
    role: prefs.getUserRole(),
  );

  return AuthViewModel(repo, initialState);
});