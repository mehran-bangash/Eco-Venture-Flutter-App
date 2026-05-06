import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child/child_qr_hunt_repository.dart';
import '../../../services/child/free_tts_service.dart';
import '../../../services/child/child_qr_hunt_service.dart';
import '../../../services/child/tts_service.dart';
import 'child_qr_hunt_view_model.dart';
import 'child_qr_hunt_state.dart';

final ttsServiceProvider = Provider((ref) => TtsService());
final freeTtsServiceProvider = Provider((ref) => FreeTtsService());
final childQrHuntServiceProvider = Provider((ref) => ChildQrHuntService());

final childQrHuntRepositoryProvider = Provider((ref) {
  final service = ref.watch(childQrHuntServiceProvider);
  return ChildQrHuntRepository(service);
});

final childQrHuntViewModelProvider =
StateNotifierProvider<ChildQrHuntViewModel, ChildQrHuntState>((ref) {
  final repository = ref.watch(childQrHuntRepositoryProvider);
  final gemini = ref.watch(ttsServiceProvider);
  final free = ref.watch(freeTtsServiceProvider);

  return ChildQrHuntViewModel(repository, gemini, free);
});