import '../../models/teacher/teacher_class_report_model.dart';

class TeacherClassReportState {
  final bool isLoading;
  final TeacherClassReportModel? report;
  final String? errorMessage;
  final String? selectedAgeCategory;
  final String searchQuery;

  TeacherClassReportState({
    this.isLoading = true, // Start loading
    this.report,
    this.errorMessage,
    this.selectedAgeCategory = "All",
    this.searchQuery = "",
  });

  TeacherClassReportState copyWith({
    bool? isLoading,
    TeacherClassReportModel? report,
      String? errorMessage,  String? selectedAgeCategory,  String? searchQuery,
  }) {
    return TeacherClassReportState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAgeCategory: selectedAgeCategory ?? this.selectedAgeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}