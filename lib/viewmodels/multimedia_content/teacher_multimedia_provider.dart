import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_teacher_database.dart';
import '../../services/cloudinary_service.dart';
import '../../repositories/teacher_multimedia_repository.dart';
import 'teacher_multimedia_view_model.dart';
import 'teacher_multimedia_state.dart';

// Services
final firebaseTeacherDbProvider = Provider((ref) => FirebaseTeacherDatabase());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// Repository
final teacherMultimediaRepositoryProvider = Provider<TeacherMultimediaRepository>((ref) {
  return TeacherMultimediaRepository(ref.watch(firebaseTeacherDbProvider));
});

// ViewModel
final teacherMultimediaViewModelProvider = StateNotifierProvider<TeacherMultimediaViewModel, TeacherMultimediaState>((ref) {
  return TeacherMultimediaViewModel(
    ref.watch(teacherMultimediaRepositoryProvider),
    ref.watch(cloudinaryServiceProvider),
  );
});