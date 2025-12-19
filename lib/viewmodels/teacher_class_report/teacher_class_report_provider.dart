import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_class_report_repository.dart';
import '../../services/teacher_class_report_seervice.dart';
import 'teacher_class_report_view_model.dart';
import 'teacher_class_report_state.dart';

// 1. Service
final teacherClassReportServiceProvider = Provider((ref) => TeacherClassReportService());

// 2. Repository
final teacherClassReportRepositoryProvider = Provider((ref) {
  return TeacherClassReportRepository(ref.watch(teacherClassReportServiceProvider));
});

// 3. ViewModel
final teacherClassReportViewModelProvider = StateNotifierProvider.autoDispose<TeacherClassReportViewModel, TeacherClassReportState>((ref) {
  return TeacherClassReportViewModel(ref.watch(teacherClassReportRepositoryProvider));
});