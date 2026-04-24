import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../core/config/api_constants.dart';
import '../../repositories/teacher/teacher_repoistory.dart'; // Added repository import
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'teacher_auth_state.dart';

class TeacherAuthViewModel extends StateNotifier<TeacherAuthState> {
  // RESTORED: Accept repository in constructor
  final TeacherRepository _repository;

  TeacherAuthViewModel(this._repository) : super(TeacherAuthState());

  Future<void> addStudent({
    required String name,
    required String email,
    required String password,
    required String age,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final String? teacherId = SharedPreferencesHelper.instance.getUserId();

      if (teacherId == null || teacherId.isEmpty) {
        throw Exception("Teacher session expired. Please re-login.");
      }

      final url = Uri.parse(ApiConstants.createStudentEndpoint);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "age": age,
          "teacherId": teacherId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save Child Info locally
        await SharedPreferencesHelper.instance.saveChildName(name);
        await SharedPreferencesHelper.instance.saveChildEmail(email);
        await SharedPreferencesHelper.instance.saveChildTeacherId(teacherId);
        await SharedPreferencesHelper.instance.saveIsTeacherAdded(true);

        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage: data['error'] ?? "Failed to register student"
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetState() => state = TeacherAuthState();
}