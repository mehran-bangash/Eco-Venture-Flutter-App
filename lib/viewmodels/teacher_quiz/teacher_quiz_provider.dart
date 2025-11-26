import 'package:eco_venture/viewmodels/teacher_quiz/teacher_quiz_view_model.dart';
import 'package:eco_venture/viewmodels/teacher_quiz/teacher_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_quiz_repoistory.dart';
import '../../services/firebase_teacher_database.dart';
import '../../services/cloudinary_service.dart';


// 1. Services
// (CloudinaryService is reused from User App Services)
final firebaseTeacherDbProvider = Provider((ref) => FirebaseTeacherDatabase());
// We define CloudinaryService provider locally here if not global, or reuse global one.
// Assuming global one:
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// 2. Repository
final teacherQuizRepositoryProvider = Provider<TeacherQuizRepository>((ref) {
  return TeacherQuizRepository(ref.watch(firebaseTeacherDbProvider));
});

// 3. ViewModel
final teacherQuizViewModelProvider = StateNotifierProvider<TeacherQuizViewModel, TeacherQuizState>((ref) {
  return TeacherQuizViewModel(
    ref.watch(teacherQuizRepositoryProvider),
    ref.watch(cloudinaryServiceProvider), // Direct Service Injection
  );
});