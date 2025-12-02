
import '../models/qr_hunt_read_model.dart';
import '../services/child_qr_hunt_service.dart';

class ChildQrHuntRepository {
  final ChildQrHuntService _service;

  ChildQrHuntRepository(this._service);

  Stream<List<QrHuntReadModel>> getHunts() => _service.getHuntsStream();

  Stream<Map<String, QrHuntProgressModel>> getProgress() => _service.getProgressStream();

  Future<void> updateProgress(QrHuntProgressModel progress) async {
    await _service.saveProgress(progress);
  }
}