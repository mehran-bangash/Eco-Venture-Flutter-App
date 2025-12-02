import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/child_progress_model.dart';
import '../../../repositories/child_quiz_repository.dart';
import 'child_quiz_state.dart';

class ChildQuizViewModel extends StateNotifier<ChildQuizState> {
  final ChildQuizRepository _repository;

  // Independent Subscriptions
  StreamSubscription? _adminTopicSub;
  StreamSubscription? _teacherTopicSub;

  StreamSubscription? _adminCatSub;
  StreamSubscription? _teacherCatSub;
  StreamSubscription? _progressSub;

  ChildQuizViewModel(this._repository) : super(ChildQuizState()) {
    _loadUserProgress();
    _loadCategories();
  }

  // --- LOAD CATEGORIES (Both Admin & Teacher) ---
  void _loadCategories() {
    // Admin Cats
    _adminCatSub = _repository.getAdminCategories().listen((cats) {
      state = state.copyWith(adminCategories: cats);
    });

    // Teacher Cats
    _teacherCatSub = _repository.getTeacherCategories().listen((cats) {
      state = state.copyWith(teacherCategories: cats);
    });
  }

  // --- LOAD TOPICS (Controlled separately by UI Dropdowns) ---

  void loadAdminTopics(String category) {
    _adminTopicSub?.cancel();
    // Don't set global isLoading = true here to avoid flickering the whole screen
    // Just listen for new data
    _adminTopicSub = _repository.getAdminTopics(category).listen((topics) {
      state = state.copyWith(adminTopics: topics);
    });
  }

  void loadTeacherTopics(String category) {
    _teacherTopicSub?.cancel();
    _teacherTopicSub = _repository.getTeacherTopics(category).listen((topics) {
      state = state.copyWith(teacherTopics: topics);
    });
  }

  // --- PROGRESS ---
  void _loadUserProgress() {
    _progressSub = _repository.getProgressStream().listen((progressMap) {
      state = state.copyWith(progress: progressMap);
    });
  }

  Future<void> saveLevelResult(ChildQuizProgressModel result) async {
    try {
      await _repository.saveLevelResult(result);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to save: $e");
    }
  }

  @override
  void dispose() {
    _adminTopicSub?.cancel();
    _teacherTopicSub?.cancel();
    _adminCatSub?.cancel();
    _teacherCatSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }
}