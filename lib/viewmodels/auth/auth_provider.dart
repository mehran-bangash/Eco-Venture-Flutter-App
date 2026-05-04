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
  // Use watch to react to repository changes if necessary
  final repo = ref.watch(authRepoProvider);
  final prefs = SharedPreferencesHelper.instance;

  // Read prefs synchronously
  final initialState = AuthState.fromPrefs(
    isFirstTime: prefs.getIsFirstTime(),
    userId: prefs.getUserId(),
    role: prefs.getUserRole(),
  );

  // Logic: Pass 'ref' as the second argument to match the updated constructor
  return AuthViewModel(repo, ref, initialState);
});