import '../core/config/api_constants.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_helper.dart';

class TeacherRepository {
  TeacherRepository._();

  static final TeacherRepository getInstance = TeacherRepository._();
  final ApiService _apiService = ApiService();

  Future<void> addStudent(String name, String email, String password) async {
    // 1. Get the Current Teacher's ID (The "Link")
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

    // 2. Send to Node.js via your existing ApiService
    await _apiService.sendUserToken(
      ApiConstants.createStudentEndPoint,
      requestBody,
    );
  }
}