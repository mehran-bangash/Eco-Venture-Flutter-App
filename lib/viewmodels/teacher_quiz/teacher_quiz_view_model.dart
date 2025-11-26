import 'dart:async';
import 'dart:io';
import 'package:eco_venture/viewmodels/teacher_quiz/teacher_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz_topic_model.dart';
import '../../repositories/teacher_quiz_repoistory.dart';
import '../../services/cloudinary_service.dart';


class TeacherQuizViewModel extends StateNotifier<TeacherQuizState> {
  final TeacherQuizRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _quizSubscription;

  TeacherQuizViewModel(this._repository, this._cloudinaryService) : super(TeacherQuizState());

  // --- LOAD QUIZZES ---
  void loadQuizzes(String category) {
    _quizSubscription?.cancel();
    state = state.copyWith(isLoading: true);

    _quizSubscription = _repository.watchQuizzes(category).listen(
            (data) {
          state = state.copyWith(isLoading: false, quizzes: data);
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  // --- ADD QUIZ ---
  Future<void> addQuiz(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedTopic = await _processImages(topic);
      await _repository.addQuiz(processedTopic);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- UPDATE QUIZ ---
  Future<void> updateQuiz(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedTopic = await _processImages(topic);
      await _repository.updateQuiz(processedTopic);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- DELETE QUIZ ---
  Future<void> deleteQuiz(String id, String category) async {
    try {
      await _repository.deleteQuiz(id, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  // --- HELPER: UPLOAD IMAGES ---
  Future<QuizTopicModel> _processImages(QuizTopicModel topic) async {
    List<QuizLevelModel> updatedLevels = [];

    for (var level in topic.levels) {
      List<QuestionModel> updatedQuestions = [];

      for (var q in level.questions) {
        String? imgUrl = q.imageUrl;

        // If it's a local file path, upload it
        if (imgUrl != null && !imgUrl.startsWith('http')) {
          final file = File(imgUrl);
          if (file.existsSync()) {
            // Use specific TEACHER PRESET: eco_teacher_quiz
            imgUrl = await _cloudinaryService.uploadTeacherQuizImage(file);
          } else {
            imgUrl = null;
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