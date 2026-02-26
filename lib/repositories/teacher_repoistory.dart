import 'dart:async'; // Required for TimeoutException
import '../../services/api_service.dart';
import '../core/config/api_constants.dart';
import '../services/shared_preferences_helper.dart';

class TeacherRepository {
  TeacherRepository._();

  static final TeacherRepository getInstance = TeacherRepository._();
  final ApiService _apiService = ApiService();

  Future<void> addStudent(String name, String email, String password) async {
    final String? teacherId = await SharedPreferencesHelper.instance.getUserId();

    if (teacherId == null) {
      throw Exception("Teacher ID not found. Please login again.");
    }

    var requestBody = {
      'email': email,
      'password': password,
      'name': name,
      'teacherId': teacherId,
    };

    try {
      await _apiService.sendUserToken(
        ApiConstants.createStudentEndPoint,
        requestBody,
      ).timeout(const Duration(seconds: 60));

    } on TimeoutException catch (_) {
      throw Exception("Server is waking up. Please check your list in 1 minute.");
    } catch (e) {
      rethrow;
    }
  }
}