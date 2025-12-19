import '../../models/teacher_class_report_model.dart';

class TeacherClassReportState {
  final bool isLoading;
  final TeacherClassReportModel? report;
  final String? errorMessage;

  TeacherClassReportState({
    this.isLoading = true, // Start loading
    this.report,
    this.errorMessage,
  });

  TeacherClassReportState copyWith({
    bool? isLoading,
    TeacherClassReportModel? report,
    String? errorMessage,
  }) {
    return TeacherClassReportState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      errorMessage: errorMessage,
    );
  }
}