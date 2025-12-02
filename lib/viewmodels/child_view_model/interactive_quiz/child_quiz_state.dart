

import '../../../models/child_progress_model.dart';
import '../../../models/quiz_topic_model.dart';

class ChildQuizState {
  final bool isLoading;
  final String? errorMessage;

  // --- SEPARATE DATA LISTS ---
  final List<QuizTopicModel> adminTopics;
  final List<QuizTopicModel> teacherTopics;

  // --- SEPARATE CATEGORY LISTS ---
  final List<String> adminCategories;
  final List<String> teacherCategories;

  final Map<String, ChildQuizProgressModel> progress;

  ChildQuizState({
    this.isLoading = false,
    this.errorMessage,
    this.adminTopics = const [],
    this.teacherTopics = const [],
    this.adminCategories = const [],
    this.teacherCategories = const [],
    this.progress = const {},
  });

  ChildQuizState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<QuizTopicModel>? adminTopics,
    List<QuizTopicModel>? teacherTopics,
    List<String>? adminCategories,
    List<String>? teacherCategories,
    Map<String, ChildQuizProgressModel>? progress,
  }) {
    return ChildQuizState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      adminTopics: adminTopics ?? this.adminTopics,
      teacherTopics: teacherTopics ?? this.teacherTopics,
      adminCategories: adminCategories ?? this.adminCategories,
      teacherCategories: teacherCategories ?? this.teacherCategories,
      progress: progress ?? this.progress,
    );
  }
}