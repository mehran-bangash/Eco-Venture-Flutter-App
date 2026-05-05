import '../../models/quiz_topic_model.dart';

class TeacherQuizState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<QuizTopicModel> quizzes;
  final QuizTopicModel? draftTopic; // Added to support "Edit before Upload"

  TeacherQuizState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.quizzes = const [],
    this.draftTopic,
  });

  TeacherQuizState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<QuizTopicModel>? quizzes,
    QuizTopicModel? draftTopic,
  }) {
    return TeacherQuizState(
      isLoading: isLoading ?? this.isLoading,
      // Note: keeping your logic where isSuccess resets to false if not provided
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      quizzes: quizzes ?? this.quizzes,
      draftTopic: draftTopic ?? this.draftTopic,
    );
  }
}