import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/child_progress_model.dart';
import '../models/quiz_model.dart';
import '../services/shared_preferences_helper.dart';

class ChildQuizService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. FETCH QUIZZES
  Stream<List<QuizModel>> getPublicQuizzesStream(String category) {
    return _database.ref('Public/Quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QuizModel> quizzes = [];

        mapData.forEach((key, value) {
          final quizMap = Map<String, dynamic>.from(value as Map);
          quizzes.add(QuizModel.fromMap(key.toString(), quizMap));
        });

        quizzes.sort((a, b) => a.order.compareTo(b.order));
        return quizzes;
      } catch (e) {
        print("Error parsing public quizzes: $e");
        return [];
      }
    });
  }

  // 2. FETCH USER PROGRESS
  Stream<Map<String, ChildQuizProgressModel>> getChildProgressStream() async* {
    String? childId = await SharedPreferencesHelper.instance.getUserId();
    if (childId == null) childId = _auth.currentUser?.uid;

    if (childId == null) {
      yield {};
      return;
    }

    yield* _database.ref('child_quiz_progress/$childId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};

      try {
        final Map<String, ChildQuizProgressModel> progressMap = {};
        final Map<dynamic, dynamic> categories = data as Map<dynamic, dynamic>;

        categories.forEach((catKey, quizzesMap) {
          final Map<dynamic, dynamic> quizzes = quizzesMap as Map<dynamic, dynamic>;
          quizzes.forEach((quizId, quizData) {
            final safeData = Map<String, dynamic>.from(quizData as Map);
            progressMap[quizId.toString()] = ChildQuizProgressModel.fromMap(safeData);
          });
        });
        return progressMap;
      } catch (e) {
        print("Error parsing child progress: $e");
        return {};
      }
    });
  }

  // 3. SAVE PROGRESS
  Future<void> saveQuizResult(ChildQuizProgressModel progress) async {
    String? childId = await SharedPreferencesHelper.instance.getUserId();
    if (childId == null) childId = _auth.currentUser?.uid;
    if (childId == null) throw Exception("Child not logged in");

    final path = 'child_quiz_progress/$childId/${progress.category}/${progress.quizId}';
    final snapshot = await _database.ref(path).get();

    final bool passedNow = progress.attemptPercentage >= 60;

    if (snapshot.exists) {
      final existingData = Map<String, dynamic>.from(snapshot.value as Map);
      final existingProgress = ChildQuizProgressModel.fromMap(existingData);
      final bool finalPassedStatus = existingProgress.isPassed || passedNow;
      final updatedMap = progress.toMap();
      updatedMap['is_passed'] = finalPassedStatus;
      updatedMap['attempts'] = existingProgress.attempts + 1;

      await _database.ref(path).update(updatedMap);
    } else {
      final map = progress.toMap();
      map['is_passed'] = passedNow;
      map['attempts'] = 1;
      await _database.ref(path).set(map);
    }
  }

  // --- 4. NEW: FETCH CATEGORIES ---
  // Fetches the list of category names (keys) from Public/Quizzes
  Stream<List<String>> getCategoriesStream() {
    return _database.ref('Public/Quizzes').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <String>[];

      try {
        final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
        // The keys are the category names (e.g., 'Animals', 'Space')
        return map.keys.map((key) => key.toString()).toList();
      } catch (e) {
        print("Error fetching categories: $e");
        return <String>[];
      }
    });
  }
}