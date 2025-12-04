import '../../models/teacher_student_activity_model.dart';
import '../../models/teacher_student_stats_model.dart';

class TeacherStudentDetailState {
  final bool isLoading;
  final String? errorMessage;
  final TeacherStudentStatsModel stats;
  final List<TeacherStudentActivityModel> activities;

  TeacherStudentDetailState({
    this.isLoading = true, // Default to loading on initialization
    this.errorMessage,
    TeacherStudentStatsModel? stats,
    this.activities = const [],
  }) : stats = stats ?? TeacherStudentStatsModel.initial();

  TeacherStudentDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    TeacherStudentStatsModel? stats,
    List<TeacherStudentActivityModel>? activities,
  }) {
    return TeacherStudentDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      stats: stats ?? this.stats,
      activities: activities ?? this.activities,
    );
  }
}
