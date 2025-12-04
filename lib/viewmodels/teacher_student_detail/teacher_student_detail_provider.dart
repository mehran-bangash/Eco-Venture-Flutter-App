import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_student_detail_repository.dart';
import '../../services/teacher_student_detail_service.dart';
import 'teacher_student_detail_state.dart';
import 'teacher_student_detail_view_model.dart';

// Provider for the Service
final teacherStudentDetailServiceProvider = Provider<TeacherStudentDetailService>((ref) {
  return TeacherStudentDetailService();
});

// Provider for the Repository
final teacherStudentDetailRepositoryProvider = Provider<TeacherStudentDetailRepository>((ref) {
  final service = ref.watch(teacherStudentDetailServiceProvider);
  return TeacherStudentDetailRepository(service);
});

// Provider for the ViewModel, using .autoDispose and .family to pass in the studentId
final teacherStudentDetailViewModelProvider =
    StateNotifierProvider.autoDispose.family<TeacherStudentDetailViewModel, TeacherStudentDetailState, String>((ref, studentId) {
  final repository = ref.watch(teacherStudentDetailRepositoryProvider);
  return TeacherStudentDetailViewModel(repository, studentId);
});
