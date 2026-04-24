import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/teacher/teacher_all_module_service.dart';
import '../../services/cloudinary_service.dart';
import '../../repositories/teacher/teacher_stem_repository.dart';
import 'teacher_stem_view_model.dart';
import 'teacher_stem_state.dart';

// 1. Services (Reuse from previous providers if available, or define here)
// Assuming we reuse the ones defined in Quiz Provider to act as singletons
final firebaseTeacherDbProvider = Provider((ref) => TeacherAllModuleService());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// 2. Repository
final teacherStemRepositoryProvider = Provider<TeacherStemRepository>((ref) {
  return TeacherStemRepository(ref.watch(firebaseTeacherDbProvider));
});

// 3. ViewModel
final teacherStemViewModelProvider = StateNotifierProvider<TeacherStemViewModel, TeacherStemState>((ref) {
  return TeacherStemViewModel(
    ref.watch(teacherStemRepositoryProvider),
    ref.watch(cloudinaryServiceProvider),
  );
});