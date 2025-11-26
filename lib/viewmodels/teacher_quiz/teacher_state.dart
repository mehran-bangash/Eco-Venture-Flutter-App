import '../../models/quiz_topic_model.dart';

class TeacherQuizState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<QuizTopicModel> quizzes;

  TeacherQuizState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.quizzes = const [],
  });

  TeacherQuizState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<QuizTopicModel>? quizzes,
  }) {
    return TeacherQuizState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      quizzes: quizzes ?? this.quizzes,
    );
  }
}