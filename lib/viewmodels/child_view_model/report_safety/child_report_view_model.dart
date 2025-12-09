import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/child_report_model.dart';
import '../../../repositories/child_safety_repository.dart';
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
    state = state.copyWith(isLoading: true);

    _reportSub = _repository.getReports().listen(
            (data) {
          // Update state with new list
          state = state.copyWith(isLoading: false, reports: data);
        },
        onError: (e) {
          print("Report Stream Error: $e");
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

      await _repository.submitReport(report, screenshot);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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