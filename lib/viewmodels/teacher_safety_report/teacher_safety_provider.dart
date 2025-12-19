import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/teacher_safety_service.dart';
import '../../repositories/teacher_safety_repository.dart';
import 'teacher_safety_view_model.dart';
import 'teacher_safety_state.dart';

// 1. Service
final teacherSafetyServiceProvider = Provider((ref) => TeacherSafetyService());

// 2. Repository
final teacherSafetyRepositoryProvider = Provider((ref) {
  return TeacherSafetyRepository(ref.watch(teacherSafetyServiceProvider));
});

// 3. ViewModel
final teacherSafetyViewModelProvider = StateNotifierProvider.autoDispose<TeacherSafetyViewModel, TeacherSafetyState>((ref) {
  return TeacherSafetyViewModel(ref.watch(teacherSafetyRepositoryProvider));
});