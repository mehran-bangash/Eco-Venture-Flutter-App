import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/stem_submission_model.dart';
import '../../../repositories/child_stem_challenges_repository.dart';
import '../../../services/cloudinary_service.dart';
import 'child_stem_challenges_state.dart';

class ChildStemChallengesViewModel extends StateNotifier<ChildStemChallengesState> {
  final ChildStemChallengesRepository _repository;
  final CloudinaryService _cloudinaryService;

  StreamSubscription? _challengesSubscription;
  StreamSubscription? _submissionsSubscription;

  ChildStemChallengesViewModel(this._repository, this._cloudinaryService)
      : super(ChildStemChallengesState()) {
    _loadSubmissionHistory();
  }

  void loadChallenges(String category) {
    _challengesSubscription?.cancel();
    state = state.copyWith(isLoading: true);
    _challengesSubscription = _repository.getChallengesStream(category).listen(
          (challenges) => state = state.copyWith(isLoading: false, challenges: challenges),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  void _loadSubmissionHistory() {
    _submissionsSubscription = _repository.getSubmissionsStream().listen(
          (historyMap) => state = state.copyWith(submissions: historyMap),
      onError: (e) => print("Error loading history: $e"),
    );
  }

  // --- CHANGE 2: Accept List<File> ---
  Future<void> submitChallengeWithProof({
    required StemSubmissionModel submission,
    required List<File> proofImages, // Changed from single File
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Step A: Upload MULTIPLE Images
      final List<String> imageUrls = await _cloudinaryService.uploadMultipleTaskImages(proofImages);

      if (imageUrls.isEmpty) {
        throw Exception("Failed to upload images. Please try again.");
      }

      // Step B: Update Model with URL List
      final finalSubmission = submission.copyWith(
        proofImageUrls: imageUrls, // Updated field
        status: 'pending',
      );

      // Step C: Save
      await _repository.submitChallenge(finalSubmission);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _challengesSubscription?.cancel();
    _submissionsSubscription?.cancel();
    super.dispose();
  }
}