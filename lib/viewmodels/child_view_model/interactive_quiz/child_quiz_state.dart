import '../../../models/child_progress_model.dart';
import '../../../models/quiz_topic_model.dart';


class ChildQuizState {
  final bool isLoading;
  final String? errorMessage;
  final List<QuizTopicModel> topics; // Holds Topics now
  final Map<String, ChildQuizProgressModel> progress; // Key: "TopicID_LevelOrder"
  final List<String> categoryNames;

  ChildQuizState({
    this.isLoading = false,
    this.errorMessage,
    this.topics = const [],
    this.progress = const {},
    this.categoryNames = const [],
  });

  ChildQuizState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<QuizTopicModel>? topics,
    Map<String, ChildQuizProgressModel>? progress,
    List<String>? categoryNames,
  }) {
    return ChildQuizState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      topics: topics ?? this.topics,
      progress: progress ?? this.progress,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }
}