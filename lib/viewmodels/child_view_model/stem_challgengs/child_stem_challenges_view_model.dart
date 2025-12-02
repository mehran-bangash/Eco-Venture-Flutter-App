import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/stem_submission_model.dart';
import '../../../repositories/child_stem_challenge_repository.dart';
import '../../../services/cloudinary_service.dart';
import 'child_stem_challenges_state.dart';

class ChildStemChallengesViewModel extends StateNotifier<ChildStemChallengesState> {
  final ChildStemChallengesRepository _repository;
  final CloudinaryService _cloudinaryService;

  StreamSubscription? _adminSub;
  StreamSubscription? _teacherSub;
  StreamSubscription? _submissionsSub;

  ChildStemChallengesViewModel(this._repository, this._cloudinaryService)
      : super(ChildStemChallengesState()) {
    _loadSubmissionHistory();
  }

  void loadChallenges(String category) {
    _adminSub?.cancel();
    _teacherSub?.cancel();

    _adminSub = _repository.getAdminChallenges(category).listen(
          (data) => state = state.copyWith(adminChallenges: data),
      onError: (e) => print("Admin STEM Error: $e"),
    );

    _teacherSub = _repository.getTeacherChallenges(category).listen(
          (data) => state = state.copyWith(teacherChallenges: data),
      onError: (e) => print("Teacher STEM Error: $e"),
    );
  }

  void _loadSubmissionHistory() {
    _submissionsSub = _repository.getSubmissionsStream().listen(
          (historyMap) => state = state.copyWith(submissions: historyMap),
      onError: (e) => print("Error loading history: $e"),
    );
  }

  // --- FIX: Accept List<File> ---
  Future<void> submitChallengeWithProof({
    required StemSubmissionModel submission,
    required List<File> proofImages, // Updated to List
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // 1. Upload Multiple Images
      final List<String> imageUrls = await _cloudinaryService.uploadMultipleTaskImages(proofImages);

      if (imageUrls.isEmpty) {
        throw Exception("Failed to upload proof images. Please try again.");
      }

      // 2. Update Model with URL List
      final finalSubmission = submission.copyWith(
        proofImageUrls: imageUrls,
        status: 'pending',
      );

      // 3. Save
      await _repository.submitChallenge(finalSubmission);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  @override
  void dispose() {
    _adminSub?.cancel();
    _teacherSub?.cancel();
    _submissionsSub?.cancel();
    super.dispose();
  }
}