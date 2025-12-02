import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_qr_hunt_repository.dart';
import '../../../services/child_qr_hunt_service.dart';
import 'child_qr_hunt_state.dart';
import 'child_qr_hunt_view_model.dart';

final childQrHuntServiceProvider = Provider((ref) => ChildQrHuntService());

final childQrHuntRepositoryProvider = Provider(
  (ref) => ChildQrHuntRepository(ref.watch(childQrHuntServiceProvider)),
);

final childQrHuntViewModelProvider =
    StateNotifierProvider<ChildQrHuntViewModel, ChildQrHuntState>((ref) {
      return ChildQrHuntViewModel(ref.watch(childQrHuntRepositoryProvider));
    });
