import '../models/child_progress_model.dart';
import '../models/quiz_topic_model.dart';
import '../services/child_quiz_service.dart';

class ChildQuizRepository {
  final ChildQuizService _service;

  ChildQuizRepository(this._service);

  // 1. Get List of TOPICS for a Category
  Stream<List<QuizTopicModel>> getTopicsStream(String category) {
    return _service.getPublicTopicsStream(category);
  }

  // 2. Get User Progress
  Stream<Map<String, ChildQuizProgressModel>> getProgressStream() {
    return _service.getChildProgressStream();
  }

  // 3. Save Level Result
  Future<void> saveLevelResult(ChildQuizProgressModel progress) async {
    await _service.saveLevelResult(progress);
  }

  // 4. Get Categories List
  Stream<List<String>> getCategoriesStream() {
    return _service.getCategoriesStream();
  }
}