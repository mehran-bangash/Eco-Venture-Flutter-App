import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_repoistory.dart';
import '../../services/shared_preferences_helper.dart'; // Import Helper
import 'teacher_auth_state.dart';

class TeacherAuthViewModel extends StateNotifier<TeacherAuthState> {
  final TeacherRepository _repository;

  TeacherAuthViewModel(this._repository) : super(TeacherAuthState());

  Future<void> addStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Create Student on Backend
      await _repository.addStudent(name, email, password);

      // 2. Save Child Info locally (Optional but requested)
      // This stores the child's details in separate keys so they don't overwrite the teacher's login.
      await SharedPreferencesHelper.instance.saveChildName(name);
      await SharedPreferencesHelper.instance.saveChildEmail(email);

      // Also save the teacher's ID as the "Child's Teacher" for future reference
      String? currentTeacherId = await SharedPreferencesHelper.instance.getUserId();
      if (currentTeacherId != null) {
        await SharedPreferencesHelper.instance.saveChildTeacherId(currentTeacherId);
        await SharedPreferencesHelper.instance.saveIsTeacherAdded(true);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetState() {
    state = TeacherAuthState();
  }
}