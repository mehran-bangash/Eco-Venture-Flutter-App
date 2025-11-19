import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_quiz_repositories.dart';
import '../../../services/child_quiz_service.dart';
import 'child_quiz_view_model.dart';
import 'child_quiz_state.dart';

// --- LEVEL 1: SERVICE ---
final childQuizServiceProvider = Provider<ChildQuizService>((ref) {
  return ChildQuizService();
});

// --- LEVEL 2: REPOSITORY ---
final childQuizRepositoryProvider = Provider<ChildQuizRepository>((ref) {
  return ChildQuizRepository(ref.watch(childQuizServiceProvider));
});

// --- LEVEL 3: VIEWMODEL ---
final childQuizViewModelProvider = StateNotifierProvider<ChildQuizViewModel, ChildQuizState>((ref) {
  return ChildQuizViewModel(ref.watch(childQuizRepositoryProvider));
});