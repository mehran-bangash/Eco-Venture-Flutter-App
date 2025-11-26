import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_repoistory.dart';
import 'teacher_auth_view_model.dart';
import 'teacher_auth_state.dart';

// 1. Repository Provider (Using Singleton)
final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository.getInstance;
});

// 2. ViewModel Provider
final teacherAuthViewModelProvider = StateNotifierProvider<TeacherAuthViewModel, TeacherAuthState>((ref) {
  return TeacherAuthViewModel(ref.watch(teacherRepositoryProvider));
});