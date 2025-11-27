import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_teacher_database.dart';
import '../../services/cloudinary_service.dart';
import '../../repositories/teacher_treasure_hunt_repository.dart';
import 'teacher_treasure_hunt_view_model.dart';
import 'teacher_treasure_hunt_state.dart';

// 1. Services
final firebaseTeacherDbProvider = Provider((ref) => FirebaseTeacherDatabase());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// 2. Repository
final teacherQrHuntRepositoryProvider = Provider<TeacherTreasureHuntRepository>((ref) {
  return TeacherTreasureHuntRepository(ref.watch(firebaseTeacherDbProvider));
});

// 3. ViewModel
final teacherTreasureHuntViewModelProvider = StateNotifierProvider<TeacherTreasureHuntViewModel, TeacherTreasureHuntState>((ref) {
  return TeacherTreasureHuntViewModel(
    ref.watch(teacherQrHuntRepositoryProvider),
    ref.watch(cloudinaryServiceProvider),
  );
});