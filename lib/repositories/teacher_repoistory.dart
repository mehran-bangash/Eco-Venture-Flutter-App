import '../core/config/api_constants.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_helper.dart';
import 'dart:async';

class TeacherRepository {
  TeacherRepository._();

  static final TeacherRepository getInstance = TeacherRepository._();
  final ApiService _apiService = ApiService();

  Future<void> addStudent(String name, String email, String password) async {
    // 1. Get the Current Teacher's ID
    final String? teacherId = await SharedPreferencesHelper.instance
        .getUserId();

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
      // 2. SEND TO NODE.JS WITH 60 SECOND TIMEOUT
      // Render Cold Start takes ~50s. We force the app to wait 60s.
      await _apiService
          .sendUserToken(ApiConstants.createStudentEndPoint, requestBody)
          .timeout(const Duration(seconds: 60));
    } on TimeoutException catch (_) {
      // 3. BETTER ERROR MESSAGE IF IT STILL FAILS
      throw Exception(
        "Server is waking up... checks your student list, the account might be created.",
      );
    } catch (e) {
      // 4. RETHROW OTHER ERRORS (Like "Email already exists")
      rethrow;
    }
  }
}
