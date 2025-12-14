import '../services/teacher_student_service.dart';
import '../models/teacher_student_detail_model.dart';

class TeacherStudentRepository {
  final TeacherStudentService _service;

  TeacherStudentRepository(this._service);

  Stream<TeacherStudentDetailModel> getStudentDetail(String studentId) {
    return _service.getStudentDetailStream(studentId).map((data) {
      return TeacherStudentDetailModel(
        studentId: data['studentId'],
        name: data['name'],
        email: data['email'],
        totalXP: data['totalXP'],
        currentLevel: data['currentLevel'],
        quizzesPassed: data['quizCount'],
        stemSubmitted: data['stemSub'],
        stemApproved: data['stemApp'],
        qrHuntsCompleted: data['qrCount'],
        recentActivity: data['activity'],
      );
    });
  }

  // --- NEW: Expose Review Logic ---
  Future<void> reviewSubmission(String studentId, String challengeId, String status, int points, String feedback) async {
    await _service.reviewStemSubmission(
        studentId: studentId,
        challengeId: challengeId,
        status: status,
        points: points,
        feedback: feedback
    );
  }
}