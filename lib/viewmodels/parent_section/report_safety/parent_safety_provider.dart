import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/parent_safety_repository.dart';
import '../../../services/parent_safety_service.dart';
import 'parent_safety_view_model.dart';
import 'parent_safety_state.dart';

// 1. Service
final parentSafetyServiceProvider = Provider((ref) => ParentSafetyService());

// 2. Repository
final parentSafetyRepositoryProvider = Provider((ref) {
  return ParentSafetyRepository(ref.watch(parentSafetyServiceProvider));
});

// 3. ViewModel
final parentSafetyViewModelProvider = StateNotifierProvider<ParentSafetyViewModel, ParentSafetyState>((ref) {
  return ParentSafetyViewModel(ref.watch(parentSafetyRepositoryProvider));
});


