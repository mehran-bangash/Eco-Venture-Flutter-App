import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_home_repository.dart';
import 'teacher_home_state.dart';

class TeacherHomeViewModel extends StateNotifier<TeacherHomeState> {
  final TeacherHomeRepository _repository;

  // The initial state is set here. isLoading is true by default in the state file.
  TeacherHomeViewModel(this._repository) : super(TeacherHomeState()) {
    fetchStudents();
  }

  // NEW (Remove the underscore)
  Future<void> fetchStudents() async {
    try {
      state = state.copyWith(isLoading: true); // Optional: Add loading state while refreshing
      final students = await _repository.getStudentsForTeacher();
      state = state.copyWith(students: students, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed: ${e.toString()}");
    }
  }
}
