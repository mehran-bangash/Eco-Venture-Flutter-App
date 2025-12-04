import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/teacher_student_activity_model.dart';
import '../../models/teacher_student_stats_model.dart';
import '../../repositories/teacher_student_detail_repository.dart';
import 'teacher_student_detail_state.dart';

class TeacherStudentDetailViewModel extends StateNotifier<TeacherStudentDetailState> {
  final TeacherStudentDetailRepository _repository;
  final String _studentId;

  TeacherStudentDetailViewModel(this._repository, this._studentId) : super(TeacherStudentDetailState()) {
    _fetchAllStudentData();
  }

  Future<void> _fetchAllStudentData() async {
    try {
      // State is already loading by default

      // Fetch stats and activities concurrently
      final futureStats = _repository.getStudentStats(_studentId);
      final futureActivities = _repository.getRecentActivity(_studentId);

      final results = await Future.wait([futureStats, futureActivities]);

      // CORRECTED: Cast results to their specific types
      final stats = results[0] as TeacherStudentStatsModel;
      final activities = results[1] as List<TeacherStudentActivityModel>;

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        activities: activities,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load student details: ${e.toString()}",
      );
    }
  }
}
