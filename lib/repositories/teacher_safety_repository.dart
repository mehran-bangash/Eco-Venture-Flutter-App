import '../services/teacher_safety_service.dart';
import '../models/teacher_report_model.dart';


class TeacherSafetyRepository {
  final TeacherSafetyService _service;

  TeacherSafetyRepository(this._service);

  Stream<List<TeacherReportModel>> getInbox() => _service.getInboxStream();

  Future<void> markResolved(String reportId, String? childId) async {
    await _service.updateReportStatus(reportId, 'Resolved', childId);
  }

  Future<void> sendParentRemark(String studentId, String title, String msg) async {
    await _service.sendRemarkToParent(studentId: studentId, title: title, message: msg);
  }

  Future<void> sendAdminReport(String title, String msg, String type) async {
    await _service.reportToAdmin(title, msg, type);
  }
}