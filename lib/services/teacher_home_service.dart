
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import '../models/user_model.dart';

class TeacherHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getStudentsForTeacher() async {
    try {
      final teacherId = await SharedPreferencesHelper.instance.getUserId();
      if (teacherId == null) {
        throw Exception("Teacher is not logged in.");
      }

      final querySnapshot = await _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child') // CORRECTED: Changed 'student' to 'child'
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Return an empty list if no students are found
      }

      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        data['uid'] = doc.id; // Manually add the document ID to the map
        return UserModel.fromMap(data);
      }).toList();

    } catch (e) {
      // In a real app, you might want to log this error
      print("Error fetching students: $e");
      // Re-throw the exception to be handled by the ViewModel
      throw Exception("Failed to fetch students. Please try again.");
    }
  }
}
