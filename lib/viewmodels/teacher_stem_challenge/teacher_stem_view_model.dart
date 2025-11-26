import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stem_challenge_model.dart';
import '../../repositories/teacher_stem_repository.dart';
import '../../services/cloudinary_service.dart';
import 'teacher_stem_state.dart'; // Ensure this file exists

class TeacherStemViewModel extends StateNotifier<TeacherStemState> {
  final TeacherStemRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _streamSubscription;

  TeacherStemViewModel(this._repository, this._cloudinaryService) : super(TeacherStemState());

  // --- LOAD ---
  void loadChallenges(String category) {
    _streamSubscription?.cancel();
    state = state.copyWith(isLoading: true);

    _streamSubscription = _repository.watchChallenges(category).listen(
            (data) {
          state = state.copyWith(isLoading: false, challenges: data);
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  // --- ADD ---
  Future<void> addChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedChallenge = await _processImage(challenge);
      await _repository.addChallenge(processedChallenge);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- UPDATE ---
  Future<void> updateChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedChallenge = await _processImage(challenge);
      await _repository.updateChallenge(processedChallenge);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- DELETE ---
  Future<void> deleteChallenge(String id, String category) async {
    try {
      await _repository.deleteChallenge(id, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  // --- HELPER: UPLOAD IMAGE ---
  Future<StemChallengeModel> _processImage(StemChallengeModel challenge) async {
    String? imgUrl = challenge.imageUrl;

    // Check if local file
    if (imgUrl != null && !imgUrl.startsWith('http')) {
      final file = File(imgUrl);
      if (file.existsSync()) {
        // Use new TEACHER STEM preset
        imgUrl = await _cloudinaryService.uploadTeacherStemImage(file);
      } else {
        imgUrl = null;
      }
    }

    return challenge.copyWith(imageUrl: imgUrl);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}