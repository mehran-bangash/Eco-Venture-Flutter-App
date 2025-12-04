import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_home_repository.dart';
import 'teacher_home_state.dart';

class TeacherHomeViewModel extends StateNotifier<TeacherHomeState> {
  final TeacherHomeRepository _repository;

  // The initial state is set here. isLoading is true by default in the state file.
  TeacherHomeViewModel(this._repository) : super(TeacherHomeState()) {
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      // The initial state is already loading.
      final students = await _repository.getStudentsForTeacher();
      
      // On success, update state with the student list and set loading to false.
      state = state.copyWith(
        students: students,
        isLoading: false,
      );
    } catch (e) {
      // On error, update state with an error message and set loading to false.
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to fetch students: ${e.toString()}",
      );
    }
  }
}
