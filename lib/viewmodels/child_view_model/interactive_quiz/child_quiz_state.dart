import '../../../models/child_progress_model.dart';
import '../../../models/quiz_model.dart';


class ChildQuizState {
  final bool isLoading;
  final String? errorMessage;
  final List<QuizModel> quizzes;
  final Map<String, ChildQuizProgressModel> progress;
  final List<String> categoryNames; // NEW: Holds dynamic categories

  ChildQuizState({
    this.isLoading = false,
    this.errorMessage,
    this.quizzes = const [],
    this.progress = const {},
    this.categoryNames = const [], // Default empty
  });

  ChildQuizState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<QuizModel>? quizzes,
    Map<String, ChildQuizProgressModel>? progress,
    List<String>? categoryNames,
  }) {
    return ChildQuizState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      quizzes: quizzes ?? this.quizzes,
      progress: progress ?? this.progress,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }
}