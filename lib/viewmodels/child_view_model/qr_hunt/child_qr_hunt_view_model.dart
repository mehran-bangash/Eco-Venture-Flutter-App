import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/qr_hunt_read_model.dart';
import '../../../repositories/child/child_qr_hunt_repository.dart';
import '../../../services/child/free_tts_service.dart';
import '../../../services/child/tts_service.dart';
import '../../../services/shared_preferences_helper.dart';
import 'child_qr_hunt_state.dart';


class ChildQrHuntViewModel extends StateNotifier<ChildQrHuntState> {
  final ChildQrHuntRepository _repository;
  final TtsService _geminiService;
  final FreeTtsService _freeService;

  StreamSubscription? _huntsSub;
  StreamSubscription? _progressSub;

  ChildQrHuntViewModel(this._repository, this._geminiService, this._freeService)
      : super(ChildQrHuntState()) {
    loadHunts();
    _initProgressStream();
  }

  // --- TTS LOGIC (Gemini Commented for Future Use) ---
  Future<Uint8List?> getClueAudio(String text, String language) async {
    state = state.copyWith(isSpeaking: true);
    try {
      /* // FUTURE PREMIUM LOGIC:
      final audioBytes = await _geminiService.generateSpeech(text, language);
      if (audioBytes != null) return audioBytes;
      */

      // CURRENT FREE LOGIC: Direct local speech
      await _freeService.speak(text, language);
      return null;
    } catch (e) {
      debugPrint("Speech error: $e");
      return null;
    } finally {
      state = state.copyWith(isSpeaking: false);
    }
  }

  // --- REPOSITORY LOGIC ---
  Future<void> loadHunts() async {
    state = state.copyWith(isLoading: true);
    _huntsSub?.cancel();
    final String ageGroup = SharedPreferencesHelper.instance.getUserAgeGroup() ?? "6 - 8";

    _huntsSub = _repository.getHunts(ageGroup).listen(
          (data) => state = state.copyWith(hunts: data, isLoading: false),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  void _initProgressStream() {
    _progressSub = _repository.getProgress().listen(
          (data) => state = state.copyWith(progressMap: data),
      onError: (e) => debugPrint("Progress Stream Error: $e"),
    );
  }

  Future<void> validateScan(String scannedCode, QrHuntReadModel hunt) async {
    QrHuntProgressModel? currentProgress = state.progressMap[hunt.id];

    currentProgress ??= QrHuntProgressModel(
      huntId: hunt.id,
      currentClueIndex: 0,
      totalClues: hunt.clues.length,
      isCompleted: false,
      scoreEarned: 0,
      startTime: DateTime.now(),
    );

    if (currentProgress.isCompleted) return;

    final String expectedCode = "${hunt.id}_${currentProgress.currentClueIndex}";

    if (scannedCode == expectedCode) {
      final newProgress = currentProgress.advanceStep(hunt.clues.length, hunt.points);
      await _repository.updateProgress(newProgress);
      state = state.copyWith(scanSuccess: true);
    } else {
      state = state.copyWith(errorMessage: "Wrong Code! Keep looking.");
    }
  }

  void resetFlags() => state = state.copyWith(scanSuccess: false, errorMessage: null);

  @override
  void dispose() {
    _huntsSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }
}