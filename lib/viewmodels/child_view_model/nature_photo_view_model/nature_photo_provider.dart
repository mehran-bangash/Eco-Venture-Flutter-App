
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/nature_repository.dart';
import 'nature_photo_state.dart';
import 'nature_photo_view_model.dart';
final natureProvider = StateNotifierProvider<NatureViewModel, NatureState>((ref) {
  return NatureViewModel(NatureRepository());
});