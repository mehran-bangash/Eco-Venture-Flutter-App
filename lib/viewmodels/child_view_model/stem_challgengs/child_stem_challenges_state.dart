

import '../../../models/stem_challenge_read_model.dart';
import '../../../models/stem_submission_model.dart';

class ChildStemChallengesState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess; // For submission success snackbar

  // Data
  final List<StemChallengeReadModel> challenges; // The available tasks
  final Map<String, StemSubmissionModel> submissions; // History (Key: Challenge ID)

  ChildStemChallengesState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.challenges = const [],
    this.submissions = const {},
  });

  ChildStemChallengesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    List<StemChallengeReadModel>? challenges,
    Map<String, StemSubmissionModel>? submissions,
  }) {
    return ChildStemChallengesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? false, // Default to false to reset triggers
      challenges: challenges ?? this.challenges,
      submissions: submissions ?? this.submissions,
    );
  }
}