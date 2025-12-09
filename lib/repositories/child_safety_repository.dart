import 'dart:io';
import '../models/child_report_model.dart';
import '../models/parent_safety_settings_model.dart';
import '../services/child_safety_service.dart';
import '../services/cloudinary_service.dart';
class ChildSafetyRepository {
  final ChildSafetyService _safetyService;
  final CloudinaryService _cloudinaryService;

  ChildSafetyRepository(this._safetyService, this._cloudinaryService);

  // Submit Report
  Future<void> submitReport(ChildReportModel report, File? screenshot) async {
    String? imageUrl;
    if (screenshot != null) {
      imageUrl = await _cloudinaryService.uploadReportScreenshot(screenshot);
    }
    final finalReport = report.copyWith(screenshotUrl: imageUrl);
    await _safetyService.submitReport(finalReport);
  }

  // NEW: Get Reports
  Stream<List<ChildReportModel>> getReports() {
    return _safetyService.getReportsStream();
  }

  // Watch Settings
  Stream<ParentSafetySettingsModel> watchSafetySettings() {
    return _safetyService.getSafetySettingsStream();
  }
}