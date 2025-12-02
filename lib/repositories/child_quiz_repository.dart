import '../models/child_progress_model.dart';
import '../models/quiz_topic_model.dart';
import '../services/child_quiz_service.dart';

class ChildQuizRepository {
  final ChildQuizService _service;

  ChildQuizRepository(this._service);

  // --- ADMIN DATA ---
  Stream<List<QuizTopicModel>> getAdminTopics(String category) {
    return _service.getAdminTopicsStream(category);
  }

  Stream<List<String>> getAdminCategories() {
    return _service.getAdminCategoriesStream();
  }

  // --- TEACHER DATA ---
  Stream<List<QuizTopicModel>> getTeacherTopics(String category) {
    return _service.getTeacherTopicsStream(category);
  }

  Stream<List<String>> getTeacherCategories() {
    return _service.getTeacherCategoriesStream();
  }

  // --- PROGRESS ---
  Stream<Map<String, ChildQuizProgressModel>> getProgressStream() {
    return _service.getChildProgressStream();
  }

  Future<void> saveLevelResult(ChildQuizProgressModel progress) async {
    await _service.saveLevelResult(progress);
  }
}