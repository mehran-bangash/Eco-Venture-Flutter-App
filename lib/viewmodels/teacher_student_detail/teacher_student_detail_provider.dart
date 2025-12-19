import 'package:eco_venture/viewmodels/teacher_student_detail/teacher_student_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/teacher_student_service.dart';
import '../../repositories/teacher_student_repository.dart';
import 'teacher_student_detail_view_model.dart';

// Service
final teacherStudentServiceProvider = Provider((ref) => TeacherStudentService());

// Repository
final teacherStudentRepositoryProvider = Provider((ref) {
  return TeacherStudentRepository(ref.watch(teacherStudentServiceProvider));
});

// ViewModel (Detail View)
final teacherStudentDetailViewModelProvider = StateNotifierProvider.autoDispose<TeacherStudentDetailViewModel, TeacherStudentDetailState>((ref) {
  return TeacherStudentDetailViewModel(ref.watch(teacherStudentRepositoryProvider));
});

// --- NEW: STREAM PROVIDER FOR DASHBOARD (Fixes Issue #4) ---
final teacherStudentsStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(teacherStudentServiceProvider).getStudentsStream();
});