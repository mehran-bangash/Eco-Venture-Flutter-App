import '../models/stem_challenge_read_model.dart';
import '../models/stem_submission_model.dart';
import '../services/child_stem_challenges_service.dart';

class ChildStemChallengesRepository {
  final ChildStemChallengesService _service;

  ChildStemChallengesRepository(this._service);

  // 1. Get List of Challenges (Read Content)
  Stream<List<StemChallengeReadModel>> getChallengesStream(String category) {
    return _service.getPublicStemChallengesStream(category);
  }

  // 2. Submit a Task (Write Submission)
  Future<void> submitChallenge(StemSubmissionModel submission) async {
    await _service.submitChallenge(submission);
  }

  // 3. Get Student History (Read Status: Pending/Approved)
  Stream<Map<String, StemSubmissionModel>> getSubmissionsStream() {
    return _service.getStudentSubmissionsStream();
  }
}