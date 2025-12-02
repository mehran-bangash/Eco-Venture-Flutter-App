import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../services/child_stem_challenges_service.dart';

class ChildStemChallengesRepository {
  final ChildStemChallengesService _service;

  ChildStemChallengesRepository(this._service);

  Stream<List<StemChallengeReadModel>> getAdminChallenges(String category) {
    return _service.getAdminChallengesStream(category);
  }

  Stream<List<StemChallengeReadModel>> getTeacherChallenges(String category) {
    return _service.getTeacherChallengesStream(category);
  }

  Future<void> submitChallenge(StemSubmissionModel submission) async {
    await _service.submitChallenge(submission);
  }

  Stream<Map<String, StemSubmissionModel>> getSubmissionsStream() {
    return _service.getStudentSubmissionsStream();
  }
}