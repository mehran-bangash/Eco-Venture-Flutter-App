import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../models/child/child_report_model.dart';
import '../../../repositories/child/child_safety_repository.dart';
import '../../../services/shared_preferences_helper.dart';
import 'child_report_state.dart';

// --- VIEW MODEL ---
class ChildReportViewModel extends StateNotifier<ChildReportState> {
  final ChildSafetyRepository _repository;
  StreamSubscription? _reportSub;

  ChildReportViewModel(this._repository) : super(ChildReportState());

  // Init: Start listening automatically if you want, or call from UI
  // Here we keep it manual via loadReports to control lifecycle
  void loadReports() {
    _reportSub?.cancel();
    // Logic: Explicitly clear reports list when starting a load
    state = state.copyWith(isLoading: true, reports: []);

    _reportSub = _repository.getReports().listen(
            (data) {
          state = state.copyWith(isLoading: false, reports: data);
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  Future<void> sendReport({
    required String recipient,
    required String issueType,
    required String details,
    File? screenshot,
    Map<String, dynamic>? contextData,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final report = ChildReportModel(
        recipient: recipient,
        issueType: issueType,
        details: details,
        timestamp: DateTime.now(),
        contentId: contextData?['id'],
        contentTitle: contextData?['title'],
        contentType: contextData?['type'],
      );

      // 1. Save to Firebase
      await _repository.submitReport(report, screenshot);

      // 2. NOTIFY PARENT (Call Node.js)
      if (recipient == 'Parent') {
        await _notifyParent(report);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _notifyParent(ChildReportModel report) async {
    try {
      final childId = SharedPreferencesHelper.instance.getUserId();
      if (childId == null) return;

      final url = Uri.parse(ApiConstants.notifyParentEndPoint);

      await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'childId': childId,
            'title': 'Safety Alert: ${report.issueType}',
            'body': 'Your child reported an issue: ${report.details.isEmpty ? "No details" : report.details}',
          })
      );
      print("🔔 Parent Notified Successfully");
    } catch (e) {
      print("⚠️ Failed to notify parent: $e");
      // Don't fail the whole action, just log it
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  @override
  void dispose() {
    _reportSub?.cancel();
    super.dispose();
  }
}