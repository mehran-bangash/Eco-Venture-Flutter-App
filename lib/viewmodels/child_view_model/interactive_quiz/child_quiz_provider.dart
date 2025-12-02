import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_quiz_repository.dart';
import '../../../services/child_quiz_service.dart';
import 'child_quiz_view_model.dart';
import 'child_quiz_state.dart';

// Service
final childQuizServiceProvider = Provider<ChildQuizService>((ref) {
  return ChildQuizService();
});

// Repository
final childQuizRepositoryProvider = Provider<ChildQuizRepository>((ref) {
  return ChildQuizRepository(ref.watch(childQuizServiceProvider));
});

// ViewModel
final childQuizViewModelProvider = StateNotifierProvider<ChildQuizViewModel, ChildQuizState>((ref) {
  return ChildQuizViewModel(ref.watch(childQuizRepositoryProvider));
});