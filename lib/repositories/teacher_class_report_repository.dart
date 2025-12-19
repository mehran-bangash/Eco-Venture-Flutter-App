import '../models/teacher_class_report_model.dart';
import '../services/teacher_class_report_seervice.dart';

class TeacherClassReportRepository {
  final TeacherClassReportService _service;

  TeacherClassReportRepository(this._service);

  Stream<TeacherClassReportModel> getClassReport() {
    return _service.getClassReportStream();
  }
}