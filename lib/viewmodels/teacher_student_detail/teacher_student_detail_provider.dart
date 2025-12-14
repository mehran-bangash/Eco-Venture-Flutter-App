import 'package:eco_venture/viewmodels/teacher_student_detail/teacher_student_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/teacher_student_service.dart';
import '../../repositories/teacher_student_repository.dart';
import 'teacher_student_detail_view_model.dart';

// 1. Service
final teacherStudentServiceProvider = Provider(
  (ref) => TeacherStudentService(),
);

// 2. Repository
final teacherStudentRepositoryProvider = Provider((ref) {
  return TeacherStudentRepository(ref.watch(teacherStudentServiceProvider));
});

// 3. ViewModel
// Using .autoDispose because we want to reload when switching students
final teacherStudentDetailViewModelProvider =
    StateNotifierProvider.autoDispose<
      TeacherStudentDetailViewModel,
      TeacherStudentDetailState
    >((ref) {
      return TeacherStudentDetailViewModel(
        ref.watch(teacherStudentRepositoryProvider),
      );
    });
