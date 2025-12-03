import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_progress_repository.dart';
import '../../../services/child_progress_service.dart';
import 'child_progress_view_model.dart';
import 'child_progress_state.dart';

// 1. Service
final childProgressServiceProvider = Provider((ref) => ChildProgressService());

// 2. Repository
final childProgressRepositoryProvider = Provider((ref) {
  return ChildProgressRepository(ref.watch(childProgressServiceProvider));
});

// 3. ViewModel
final childProgressViewModelProvider = StateNotifierProvider<ChildProgressViewModel, ChildProgressState>((ref) {
  return ChildProgressViewModel(ref.watch(childProgressRepositoryProvider));
});