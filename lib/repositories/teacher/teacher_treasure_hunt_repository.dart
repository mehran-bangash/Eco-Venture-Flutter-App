import '../../models/qr_hunt_model.dart';
import '../../services/teacher/teacher_all_module_service.dart';

class TeacherTreasureHuntRepository {
  final TeacherAllModuleService _db;

  TeacherTreasureHuntRepository(this._db);

  Future<void> addHunt(QrHuntModel hunt) async => await _db.addQrHunt(hunt);
  Future<void> updateHunt(QrHuntModel hunt) async => await _db.updateQrHunt(hunt);
  Future<void> deleteHunt(String id) async => await _db.deleteQrHunt(id);
  Stream<List<QrHuntModel>> watchHunts() => _db.getTeacherQrHuntsStream();
}