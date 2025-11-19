import '../models/child_progress_model.dart';
import '../models/quiz_model.dart';
import '../services/child_quiz_service.dart';

class ChildQuizRepository {
  final ChildQuizService _service;

  ChildQuizRepository(this._service);

  Stream<List<QuizModel>> getQuizzesStream(String category) {
    return _service.getPublicQuizzesStream(category);
  }

  Stream<Map<String, ChildQuizProgressModel>> getProgressStream() {
    return _service.getChildProgressStream();
  }

  Future<void> saveProgress(ChildQuizProgressModel progress) async {
    await _service.saveQuizResult(progress);
  }

  // New Method
  Stream<List<String>> getCategoriesStream() {
    return _service.getCategoriesStream();
  }
}