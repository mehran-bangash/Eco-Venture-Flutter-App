import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/child_progress_model.dart';
import '../../../repositories/child_quiz_repositories.dart';
import 'child_quiz_state.dart';

class ChildQuizViewModel extends StateNotifier<ChildQuizState> {
  final ChildQuizRepository _repository;

  StreamSubscription? _quizSubscription;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _categoriesSubscription; // NEW

  ChildQuizViewModel(this._repository) : super(ChildQuizState()) {
    _loadUserProgress();
    _loadCategories(); // NEW: Start listening to categories immediately
  }

  // New: Load Categories
  void _loadCategories() {
    _categoriesSubscription = _repository.getCategoriesStream().listen((cats) {
      state = state.copyWith(categoryNames: cats);
    });
  }

  void loadQuizzes(String category) {
    _quizSubscription?.cancel();
    state = state.copyWith(isLoading: true);

    _quizSubscription = _repository.getQuizzesStream(category).listen(
          (quizzes) {
        state = state.copyWith(
          isLoading: false,
          quizzes: quizzes,
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.toString());
      },
    );
  }

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

  Future<void> saveQuizResult(ChildQuizProgressModel result) async {
    try {
      await _repository.saveProgress(result);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to save progress: $e");
    }
  }

  @override
  void dispose() {
    _quizSubscription?.cancel();
    _progressSubscription?.cancel();
    _categoriesSubscription?.cancel(); // Dispose new subscription
    super.dispose();
  }
}