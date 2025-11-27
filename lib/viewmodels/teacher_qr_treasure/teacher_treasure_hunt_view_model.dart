import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/qr_hunt_model.dart';
import '../../repositories/teacher_treasure_hunt_repository.dart';
import '../../services/cloudinary_service.dart';
import 'teacher_treasure_hunt_state.dart';

class TeacherTreasureHuntViewModel extends StateNotifier<TeacherTreasureHuntState> {
  final TeacherTreasureHuntRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _streamSub;

  TeacherTreasureHuntViewModel(this._repository, this._cloudinaryService) : super(TeacherTreasureHuntState());

  void loadHunts() {
    _streamSub?.cancel();
    state = state.copyWith(isLoading: true);
    _streamSub = _repository.watchHunts().listen(
          (data) => state = state.copyWith(isLoading: false, hunts: data),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addHunt(QrHuntModel hunt, File? qrImageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      // Upload QR Image if provided (generated locally)
      String? qrUrl;
      if (qrImageFile != null) {
        qrUrl = await _cloudinaryService.uploadTeacherQrImage(qrImageFile);
      }

      final finalHunt = hunt.copyWith(qrCodeUrl: qrUrl);
      await _repository.addHunt(finalHunt);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateHunt(QrHuntModel hunt, File? newQrImageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      String? qrUrl = hunt.qrCodeUrl;

      // Upload new image if changed
      if (newQrImageFile != null) {
        qrUrl = await _cloudinaryService.uploadTeacherQrImage(newQrImageFile);
      }

      final finalHunt = hunt.copyWith(qrCodeUrl: qrUrl);
      await _repository.updateHunt(finalHunt);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteHunt(String id) async {
    try {
      await _repository.deleteHunt(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}