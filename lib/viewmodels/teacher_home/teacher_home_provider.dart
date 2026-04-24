import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/teacher/teacher_student_service.dart';
import 'teacher_home_state.dart';
import 'teacher_home_view_model.dart';

// 1. Provider for the TeacherStudentService (which handles the real-time stream)
final teacherStudentServiceProvider = Provider<TeacherStudentService>((ref) {
  return TeacherStudentService();
});

// 2. Updated ViewModel Provider to pass the Service instead of Repository
final teacherHomeViewModelProvider = StateNotifierProvider<TeacherHomeViewModel, TeacherHomeState>((ref) {
  final service = ref.watch(teacherStudentServiceProvider);
  return TeacherHomeViewModel(service);
});