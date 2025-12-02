
import 'dart:async';
import 'package:state_notifier/state_notifier.dart';
import '../../../models/qr_hunt_read_model.dart';
import '../../../repositories/child_qr_hunt_repository.dart';
import 'child_qr_hunt_state.dart';

class ChildQrHuntViewModel extends StateNotifier<ChildQrHuntState> {
  final ChildQrHuntRepository _repository;
  StreamSubscription? _huntsSub;
  StreamSubscription? _progressSub;

  ChildQrHuntViewModel(this._repository) : super(ChildQrHuntState()) {
    _initStreams();
  }

  void _initStreams() {
    state = state.copyWith(isLoading: true);

    _huntsSub = _repository.getHunts().listen((data) {
      state = state.copyWith(hunts: data, isLoading: false);
    });

    _progressSub = _repository.getProgress().listen((data) {
      state = state.copyWith(progressMap: data);
    });
  }

  // --- CORE: VALIDATE SCAN ---
  Future<void> validateScan(String scannedCode, QrHuntReadModel hunt) async {
    // Get current progress (or start new)
    QrHuntProgressModel? currentProgress = state.progressMap[hunt.id];

    currentProgress ??= QrHuntProgressModel(
      huntId: hunt.id,
      currentClueIndex: 0,
      totalClues: hunt.clues.length,
      isCompleted: false,
      scoreEarned: 0,
      startTime: DateTime.now(),
    );

    if (currentProgress.isCompleted) return; // Already done

    // Expected Code Logic: "HUNTID_INDEX" (e.g. "hunt123_0")
    final String expectedCode = "${hunt.id}_${currentProgress
        .currentClueIndex}";

    if (scannedCode == expectedCode) {
      // MATCH! Advance Step
      final newProgress = currentProgress.advanceStep(
          hunt.clues.length, hunt.points);

      // Save
      await _repository.updateProgress(newProgress);
      state = state.copyWith(scanSuccess: true); // Trigger UI celebration
    } else {
      state = state.copyWith(errorMessage: "Wrong Code! Keep looking.");
    }
  }

  void resetFlags() {
    state =
        state.copyWith(scanSuccess: false, errorMessage: null); // Reset trigger
  }

  @override
  void dispose() {
    _huntsSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }

}