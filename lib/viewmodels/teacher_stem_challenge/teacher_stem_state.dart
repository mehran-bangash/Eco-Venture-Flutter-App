import '../../models/stem_challenge_model.dart';
class TeacherStemState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<StemChallengeModel> challenges;

  TeacherStemState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.challenges = const [],
  });

  TeacherStemState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<StemChallengeModel>? challenges,
  }) {
    return TeacherStemState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      challenges: challenges ?? this.challenges,
    );
  }
}