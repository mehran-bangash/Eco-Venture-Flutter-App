
import '../../../models/stem_challenge_read_model.dart';
import '../../../models/stem_submission_model.dart';

class ChildStemChallengesState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  final List<StemChallengeReadModel> adminChallenges;
  final List<StemChallengeReadModel> teacherChallenges;
  final Map<String, StemSubmissionModel> submissions;

  ChildStemChallengesState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.adminChallenges = const [],
    this.teacherChallenges = const [],
    this.submissions = const {},
  });

  ChildStemChallengesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    List<StemChallengeReadModel>? adminChallenges,
    List<StemChallengeReadModel>? teacherChallenges,
    Map<String, StemSubmissionModel>? submissions,
  }) {
    return ChildStemChallengesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? false,
      adminChallenges: adminChallenges ?? this.adminChallenges,
      teacherChallenges: teacherChallenges ?? this.teacherChallenges,
      submissions: submissions ?? this.submissions,
    );
  }
}