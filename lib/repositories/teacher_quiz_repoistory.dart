import '../models/quiz_topic_model.dart';
import '../services/firebase_teacher_database.dart';

class TeacherQuizRepository {
  final FirebaseTeacherDatabase _db;

  TeacherQuizRepository(this._db);

  Future<void> addQuiz(QuizTopicModel topic) async {
    await _db.addQuizTopic(topic);
  }

  Future<void> updateQuiz(QuizTopicModel topic) async {
    await _db.updateQuizTopic(topic);
  }

  Future<void> deleteQuiz(String topicId, String category) async {
    await _db.deleteQuizTopic(topicId, category);
  }

  Stream<List<QuizTopicModel>> watchQuizzes(String category) {
    return _db.getTeacherQuizzesStream(category);
  }
}