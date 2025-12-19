import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_safety_repository.dart';
import '../../services/teacher_student_service.dart';
import 'teacher_safety_state.dart';

class TeacherSafetyViewModel extends StateNotifier<TeacherSafetyState> {
  final TeacherSafetyRepository _repository;
  final TeacherStudentService _studentService = TeacherStudentService();

  StreamSubscription? _sub;

  TeacherSafetyViewModel(this._repository) : super(TeacherSafetyState()) {
    // FIX: Start loading immediately when screen opens
    loadInbox();
  }

  // FIX: Changed from private (_loadInbox) to public (loadInbox)
  void loadInbox() {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();

    _sub = _repository.getInbox().listen(
      (data) {
        // print(" ViewModel: Loaded ${data.length} reports");
        state = state.copyWith(isLoading: false, alerts: data);
      },
      onError: (e) {
        print(" ViewModel Error: $e");
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      },
    );
  }

  Future<List<Map<String, String>>> getMyStudents() async {
    // This helper is for the dropdown in Send Report screen
    // In a real app, you might fetch this from a StudentProvider
    return [];
  }

  Future<void> markResolved(String reportId, String? childId) async {
    try {
      await _repository.markResolved(reportId, childId);
      // No need to manually update state, the stream listener will auto-update UI
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to resolve: $e");
    }
  }

  Future<void> sendParentMessage(
    String studentId,
    String title,
    String msg,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendParentRemark(studentId, title, msg);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> sendAdminReport(String title, String msg, String type) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendAdminReport(title, msg, type);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
