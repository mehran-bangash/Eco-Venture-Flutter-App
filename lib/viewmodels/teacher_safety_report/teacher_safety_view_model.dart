import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/teacher/teacher_report_model.dart';
import '../../repositories/teacher/teacher_safety_repository.dart';
import 'teacher_safety_state.dart';

class TeacherSafetyViewModel extends StateNotifier<TeacherSafetyState> {
  final TeacherSafetyRepository _repo;
  StreamSubscription? _subscription;

  TeacherSafetyViewModel(this._repo) : super(TeacherSafetyState());

  /// Logic: Initializes the stream listener for the main inbox.
  Future<void> fetchReports() async {
    if (state.isLoading && state.alerts.isNotEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    await _subscription?.cancel();
    _subscription = _repo.getInbox().listen(
          (alertsList) {
        state = state.copyWith(
            isLoading: false,
            alerts: alertsList,
            errorMessage: null
        );
      },
      onError: (error) {
        state = state.copyWith(
            isLoading: false,
            errorMessage: "Failed to sync inbox: $error"
        );
      },
    );
  }

  /// NEW: Method to provide the Admin-specific stream to the UI
  Stream<List<TeacherReportModel>> getAdminReports() {
    return _repo.getAdminInbox();
  }

  Future<void> markResolved(String reportId, String? childId) async {
    try {
      await _repo.markResolved(reportId, childId);
    } catch (e) {
      state = state.copyWith(errorMessage: "Could not resolve: $e");
    }
  }

  Future<void> sendParentMessage(String studentId, String title, String msg) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.sendParentRemark(studentId, title, msg);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> sendAdminReport(String title, String msg, String type) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.sendAdminReport(title, msg, type);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}