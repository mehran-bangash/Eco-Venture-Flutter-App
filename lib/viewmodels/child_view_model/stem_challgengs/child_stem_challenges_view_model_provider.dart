import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_stem_challenges_repository.dart';
import '../../../services/child_stem_challenges_service.dart';
import '../../../services/cloudinary_service.dart';
import 'child_stem_challenges_view_model.dart';
import 'child_stem_challenges_state.dart';

// --- LEVEL 1: SERVICES ---

// 1. Child STEM Service
final childStemChallengesServiceProvider = Provider<ChildStemChallengesService>((ref) {
  return ChildStemChallengesService();
});

// 2. Cloudinary Service (Defined locally to fix the error)
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

// --- LEVEL 2: REPOSITORY ---
final childStemChallengesRepositoryProvider = Provider<ChildStemChallengesRepository>((ref) {
  return ChildStemChallengesRepository(ref.watch(childStemChallengesServiceProvider));
});

// --- LEVEL 3: VIEWMODEL ---
final childStemChallengesViewModelProvider =
StateNotifierProvider<ChildStemChallengesViewModel, ChildStemChallengesState>((ref) {
  return ChildStemChallengesViewModel(
    ref.watch(childStemChallengesRepositoryProvider), // For DB
    ref.watch(cloudinaryServiceProvider),             // For Image Uploads (Direct Service)
  );
});