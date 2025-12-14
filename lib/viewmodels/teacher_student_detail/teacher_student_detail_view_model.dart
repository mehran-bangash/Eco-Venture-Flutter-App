import 'dart:async';
import 'package:eco_venture/viewmodels/teacher_student_detail/teacher_student_detail_state.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../repositories/teacher_student_repository.dart';

class TeacherStudentDetailViewModel
    extends StateNotifier<TeacherStudentDetailState> {
  final TeacherStudentRepository _repository;
  StreamSubscription? _sub;

  TeacherStudentDetailViewModel(this._repository)
    : super(TeacherStudentDetailState());

  void loadStudent(String studentId) {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();

    _sub = _repository
        .getStudentDetail(studentId)
        .listen(
          (data) {
            state = state.copyWith(isLoading: false, student: data);
          },
          onError: (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: e.toString(),
            );
          },
        );
  }

  // --- NEW: Action to Review STEM ---
  Future<void> markStemSubmission({
    required String studentId,
    required String challengeId,
    required bool approved,
    required int points,
    required String feedback,
  }) async {
    try {
      final status = approved ? 'approved' : 'rejected';
      await _repository.reviewSubmission(
        studentId,
        challengeId,
        status,
        points,
        feedback,
      );
      // Success: Stream will auto-update the UI stats
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to review: $e");
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
