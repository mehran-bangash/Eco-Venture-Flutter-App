import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_home_repository.dart';
import '../../services/teacher_home_service.dart';
import 'teacher_home_state.dart';
import 'teacher_home_view_model.dart';

// Provider for the data service
final teacherHomeServiceProvider = Provider<TeacherHomeService>((ref) {
  return TeacherHomeService();
});

// Provider for the repository
final teacherHomeRepositoryProvider = Provider<TeacherHomeRepository>((ref) {
  final service = ref.watch(teacherHomeServiceProvider);
  return TeacherHomeRepository(service);
});

// Provider for the ViewModel (StateNotifier)
final teacherHomeViewModelProvider = StateNotifierProvider<TeacherHomeViewModel, TeacherHomeState>((ref) {
  final repository = ref.watch(teacherHomeRepositoryProvider);
  return TeacherHomeViewModel(repository);
});
