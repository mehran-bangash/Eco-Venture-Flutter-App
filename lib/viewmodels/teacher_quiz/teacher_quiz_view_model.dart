import 'dart:async';
import 'dart:io';
import 'package:eco_venture/viewmodels/teacher_quiz/teacher_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz_topic_model.dart';
import '../../repositories/teacher/teacher_quiz_repoistory.dart';
import '../../services/cloudinary_service.dart';

class TeacherQuizViewModel extends StateNotifier<TeacherQuizState> {
  final TeacherQuizRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _quizSubscription;

  TeacherQuizViewModel(this._repository, this._cloudinaryService)
    : super(TeacherQuizState());

  // --- DRAFT MANAGEMENT ---
  void startDraft(QuizTopicModel? existingTopic) {
    state = state.copyWith(draftTopic: existingTopic ?? QuizTopicModel.empty());
  }

  void updateDraftQuestion(
    int levelIndex,
    int questionIndex,
    QuestionModel updatedQuestion,
  ) {
    if (state.draftTopic == null) return;
    final levels = List<QuizLevelModel>.from(state.draftTopic!.levels);
    final questions = List<QuestionModel>.from(levels[levelIndex].questions);
    questions[questionIndex] = updatedQuestion;
    levels[levelIndex] = levels[levelIndex].copyWith(questions: questions);
    state = state.copyWith(
      draftTopic: state.draftTopic!.copyWith(levels: levels),
    );
  }

  // --- LOAD ---
  void loadQuizzes(String category) {
    _quizSubscription?.cancel();
    state = state.copyWith(isLoading: true);
    _quizSubscription = _repository
        .watchQuizzes(category)
        .listen(
          (data) {
            state = state.copyWith(isLoading: false, quizzes: data);
          },
          onError: (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: e.toString(),
            );
          },
        );
  }

  // --- DELETE (FIXED SIGNATURE) ---
  /// This now accepts String ID to match your Dashboard UI
  Future<void> deleteQuiz(String id, String category) async {
    try {
      // 1. Find the full data in local state to get image URLs before deleting
      final topicToDelete = state.quizzes.firstWhere((q) => q.id == id);

      // 2. Cleanup Cloudinary
      for (var level in topicToDelete.levels) {
        for (var q in level.questions) {
          if (q.imageUrl != null && q.imageUrl!.startsWith('http')) {
            await _cloudinaryService.deleteImage(q.imageUrl);
          }
        }
      }

      // 3. Delete from Firebase
      await _repository.deleteQuiz(id, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  // --- ADD / UPDATE ---
  Future<void> addQuiz(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedTopic = await _processImages(topic);
      await _repository.addQuiz(processedTopic);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        draftTopic: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateQuiz(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedTopic = await _processImages(topic);
      await _repository.updateQuiz(processedTopic);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        draftTopic: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  Future<QuizTopicModel> _processImages(QuizTopicModel topic) async {
    List<QuizLevelModel> updatedLevels = [];
    for (var level in topic.levels) {
      List<QuestionModel> updatedQuestions = [];
      for (var q in level.questions) {
        String? imgUrl = q.imageUrl;
        if (imgUrl != null && !imgUrl.startsWith('http')) {
          final file = File(imgUrl);
          if (file.existsSync()) {
            imgUrl = await _cloudinaryService.uploadTeacherQuizImage(file);
          }
        }
        updatedQuestions.add(q.copyWith(imageUrl: imgUrl));
      }
      updatedLevels.add(level.copyWith(questions: updatedQuestions));
    }
    return topic.copyWith(levels: updatedLevels);
  }

  @override
  void dispose() {
    _quizSubscription?.cancel();
    super.dispose();
  }
}
