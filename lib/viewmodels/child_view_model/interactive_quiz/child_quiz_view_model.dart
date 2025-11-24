import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/child_progress_model.dart';
import '../../../repositories/child_quiz_repositories.dart';
import 'child_quiz_state.dart';

class ChildQuizViewModel extends StateNotifier<ChildQuizState> {
  final ChildQuizRepository _repository;

  StreamSubscription? _topicSubscription;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _categoriesSubscription;

  ChildQuizViewModel(this._repository) : super(ChildQuizState()) {
    _loadUserProgress();
    _loadCategories();
  }

  // Load Category List
  void _loadCategories() {
    _categoriesSubscription = _repository.getCategoriesStream().listen((cats) {
      state = state.copyWith(categoryNames: cats);
    });
  }

  // 1. Load TOPICS for a Category
  void loadTopics(String category) {
    _topicSubscription?.cancel();
    state = state.copyWith(isLoading: true);

    _topicSubscription = _repository.getTopicsStream(category).listen(
          (topics) {
        state = state.copyWith(
          isLoading: false,
          topics: topics,
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.toString());
      },
    );
  }

  // 2. Load Progress (Unlock Logic)
  void _loadUserProgress() {
    _progressSubscription = _repository.getProgressStream().listen(
          (progressMap) {
        state = state.copyWith(progress: progressMap);
      },
      onError: (error) {
        print("Error loading progress: $error");
      },
    );
  }

  // 3. Save Level Result
  Future<void> saveLevelResult(ChildQuizProgressModel result) async {
    try {
      await _repository.saveLevelResult(result);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to save progress: $e");
    }
  }

  @override
  void dispose() {
    _topicSubscription?.cancel();
    _progressSubscription?.cancel();
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}