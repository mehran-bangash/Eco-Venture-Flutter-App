import '../../models/stem_challenge_model.dart';
import '../../services/teacher/teacher_all_module_service.dart';

class TeacherStemRepository {
  final TeacherAllModuleService _db;

  TeacherStemRepository(this._db);

  Future<void> addChallenge(StemChallengeModel challenge) async {
    await _db.addStemChallenge(challenge);
  }

  Future<void> updateChallenge(StemChallengeModel challenge) async {
    await _db.updateStemChallenge(challenge);
  }

  Future<void> deleteChallenge(String id, String category) async {
    await _db.deleteStemChallenge(id, category);
  }

  Stream<List<StemChallengeModel>> watchChallenges(String category) {
    return _db.getTeacherStemChallengesStream(category);
  }
}