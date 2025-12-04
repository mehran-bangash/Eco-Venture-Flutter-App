import '../models/teacher_student_activity_model.dart';
import '../models/teacher_student_stats_model.dart';
import '../services/teacher_student_detail_service.dart';

class TeacherStudentDetailRepository {
  final TeacherStudentDetailService _service;

  TeacherStudentDetailRepository(this._service);

  // Passes the call through to the service layer to get the stats
  Future<TeacherStudentStatsModel> getStudentStats(String studentId) async {
    try {
      return await _service.getStudentStats(studentId);
    } catch (e) {
      print("Error in TeacherStudentDetailRepository (getStudentStats): $e");
      rethrow; // Re-throw to be handled by the ViewModel
    }
  }

  // Passes the call through to the service layer to get recent activity
  Future<List<TeacherStudentActivityModel>> getRecentActivity(String studentId) async {
    try {
      return await _service.getRecentActivity(studentId);
    } catch (e) {
      print("Error in TeacherStudentDetailRepository (getRecentActivity): $e");
      rethrow; // Re-throw to be handled by the ViewModel
    }
  }
}
