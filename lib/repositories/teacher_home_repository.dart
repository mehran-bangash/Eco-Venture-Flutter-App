import '../models/user_model.dart';
import '../services/teacher_home_service.dart';

class TeacherHomeRepository {
  final TeacherHomeService _teacherHomeService;

  TeacherHomeRepository(this._teacherHomeService);

  Future<List<UserModel>> getStudentsForTeacher() async {
    // This method calls the corresponding method in the service layer.
    // This abstracts the data source logic from the ViewModel.
    try {
      return await _teacherHomeService.getStudentsForTeacher();
    } catch (e) {
      // The repository can re-throw the exception to be handled by the ViewModel.
      print("Error in TeacherHomeRepository: $e");
      rethrow; // Correct way to re-throw the caught exception
    }
  }
}
