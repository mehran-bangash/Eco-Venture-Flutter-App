import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stem_challenge_model.dart';
import '../../repositories/teacher/teacher_stem_repository.dart';
import '../../services/cloudinary_service.dart';
import 'teacher_stem_state.dart';

class TeacherStemViewModel extends StateNotifier<TeacherStemState> {
  final TeacherStemRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _streamSubscription;

  TeacherStemViewModel(this._repository, this._cloudinaryService)
    : super(TeacherStemState());

  void loadChallenges(String category) {
    _streamSubscription?.cancel();
    state = state.copyWith(isLoading: true);
    _streamSubscription = _repository
        .watchChallenges(category)
        .listen(
          (data) => state = state.copyWith(isLoading: false, challenges: data),
          onError: (e) => state = state.copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
  }

  Future<void> addChallenge(StemChallengeModel challenge) async {
    // Proactive Check: Ensure at least one media exists
    if (challenge.imageUrl == null &&
        challenge.imageUrls.isEmpty &&
        challenge.videoUrls.isEmpty) {
      state = state.copyWith(
        errorMessage: "Please upload at least one image or video.",
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final processedChallenge = await _processMedia(challenge);
      await _repository.addChallenge(processedChallenge);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateChallenge(StemChallengeModel updatedChallenge) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Get the current version from state to find what's being removed
      final oldChallenge = state.challenges.firstWhere(
        (c) => c.id == updatedChallenge.id,
      );

      // 2. Process new media
      final processedChallenge = await _processMedia(updatedChallenge);

      // 3. CLEANUP: Delete removed images from Cloudinary
      for (var oldUrl in oldChallenge.imageUrls) {
        if (!processedChallenge.imageUrls.contains(oldUrl)) {
          await _cloudinaryService.deleteFile(oldUrl, isVideo: false);
        }
      }

      // 4. CLEANUP: Delete removed videos from Cloudinary
      for (var oldUrl in oldChallenge.videoUrls) {
        if (!processedChallenge.videoUrls.contains(oldUrl)) {
          await _cloudinaryService.deleteFile(oldUrl, isVideo: true);
        }
      }

      // 5. CLEANUP: Legacy single image
      if (oldChallenge.imageUrl != null &&
          oldChallenge.imageUrl != processedChallenge.imageUrl) {
        await _cloudinaryService.deleteFile(
          oldChallenge.imageUrl,
          isVideo: false,
        );
      }

      await _repository.updateChallenge(processedChallenge);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteChallenge(String id, String category) async {
    try {
      final challenge = state.challenges.firstWhere((c) => c.id == id);
      for (var url in challenge.imageUrls)
        await _cloudinaryService.deleteFile(url, isVideo: false);
      for (var url in challenge.videoUrls)
        await _cloudinaryService.deleteFile(url, isVideo: true);
      if (challenge.imageUrl != null)
        await _cloudinaryService.deleteFile(challenge.imageUrl, isVideo: false);

      await _repository.deleteChallenge(id, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  Future<StemChallengeModel> _processMedia(StemChallengeModel challenge) async {
    List<String> finalImageUrls = [];
    List<String> finalVideoUrls = [];
    String? finalSingleImageUrl = challenge.imageUrl;

    for (var path in challenge.imageUrls) {
      if (!path.startsWith('http')) {
        final file = File(path);
        if (file.existsSync()) {
          final url = await _cloudinaryService.uploadTeacherStemImage(file);
          if (url != null) finalImageUrls.add(url);
        }
      } else {
        finalImageUrls.add(path);
      }
    }

    for (var path in challenge.videoUrls) {
      if (!path.startsWith('http')) {
        final file = File(path);
        if (file.existsSync()) {
          final res = await _cloudinaryService.uploadTeacherStemFile(
            file,
            isVideo: true,
          );
          if (res is Map && res.containsKey('url'))
            finalVideoUrls.add(res['url']);
        }
      } else {
        finalVideoUrls.add(path);
      }
    }

    if (finalSingleImageUrl != null &&
        !finalSingleImageUrl.startsWith('http')) {
      final file = File(finalSingleImageUrl);
      if (file.existsSync()) {
        finalSingleImageUrl = await _cloudinaryService.uploadTeacherStemImage(
          file,
        );
      }
    }

    return challenge.copyWith(
      imageUrl: finalSingleImageUrl,
      imageUrls: finalImageUrls,
      videoUrls: finalVideoUrls,
    );
  }
}
