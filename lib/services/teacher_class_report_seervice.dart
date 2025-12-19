import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/teacher_class_report_model.dart';
import '../services/shared_preferences_helper.dart';


class TeacherClassReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getTeacherId() async {
    String? id = _auth.currentUser?.uid;
    id ??= await SharedPreferencesHelper.instance.getUserId();
    return id;
  }

  Stream<TeacherClassReportModel> getClassReportStream() {
    return Stream.fromFuture(_getTeacherId()).switchMap((teacherId) {
      if (teacherId == null) {
        return Stream.value(TeacherClassReportModel.empty());
      }

      return _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child')
          .snapshots()
          .switchMap((snapshot) {

        if (snapshot.docs.isEmpty) {
          return Stream.value(TeacherClassReportModel.empty());
        }

        List<Stream<StudentRankItem>> studentStreams = [];

        for (var doc in snapshot.docs) {
          final studentId = doc.id;
          final studentName = doc.data()['name'] ?? 'Student';
          final imgUrl = doc.data()['imgUrl'];

          final quizStream = _database.ref('child_quiz_progress/$studentId').onValue;
          final stemStream = _database.ref('student_stem_submissions/$studentId').onValue;
          final qrStream = _database.ref('child_qr_progress/$studentId').onValue;

          // Combine per student
          final studentStatStream = Rx.combineLatest3(
              quizStream, stemStream, qrStream,
                  (DatabaseEvent quiz, DatabaseEvent stem, DatabaseEvent qr) {
                int points = 0;
                int sQuizCount = 0;
                int sStemCount = 0;
                int sQrCount = 0;

                // A. Quiz
                final quizData = quiz.snapshot.value;
                if (quizData is Map) {
                  _processRecursive(quizData, (d) {
                    if(d['is_passed'] == true) {
                      points += 20;
                      sQuizCount++;
                    }
                  });
                }

                // B. STEM
                final stemData = stem.snapshot.value;
                if (stemData is Map) {
                  stemData.forEach((k, v) {
                    if (v is Map) {
                      final map = Map<String, dynamic>.from(v);
                      if (map['status'] == 'approved') {
                        points += (map['points_awarded'] as int? ?? 0);
                        sStemCount++;
                      }
                    }
                  });
                }

                // C. QR
                final qrData = qr.snapshot.value;
                if (qrData is Map) {
                  qrData.forEach((k, v) {
                    if (v is Map) {
                      final map = Map<String, dynamic>.from(v);
                      if (map['is_completed'] == true) {
                        points += (map['score_earned'] as int? ?? 0);
                        sQrCount++;
                      }
                    }
                  });
                }

                return StudentRankItem(
                  uid: studentId,
                  name: studentName,
                  totalPoints: points,
                  avatarUrl: imgUrl,
                  quizCount: sQuizCount,
                  stemCount: sStemCount,
                  qrCount: sQrCount,
                );
              }
          ).handleError((e) {
            print("Error processing student $studentName: $e");
            return StudentRankItem(uid: studentId, name: studentName, totalPoints: 0);
          });

          studentStreams.add(studentStatStream);
        }

        // Aggregate All Students
        return Rx.combineLatest(studentStreams, (List<StudentRankItem> students) {
          final List<StudentRankItem> sortedStudents = List.from(students);
          sortedStudents.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

          int totalStudents = sortedStudents.length;
          int totalPoints = 0;
          int totalQuizzes = 0;
          int totalStem = 0;
          int totalQr = 0;

          for(var s in sortedStudents) {
            totalPoints += s.totalPoints;
            totalQuizzes += s.quizCount;
            totalStem += s.stemCount;
            totalQr += s.qrCount;
          }

          double avg = totalStudents == 0 ? 0 : totalPoints / totalStudents;

          return TeacherClassReportModel(
            totalStudents: totalStudents,
            classAverageScore: avg,
            totalQuizzesPassed: totalQuizzes,
            totalStemSubmissions: totalStem,
            totalQrHuntsSolved: totalQr,
            studentRankings: sortedStudents,
          );
        });
      });
    });
  }

  void _processRecursive(dynamic data, Function(Map<String, dynamic>) onFound) {
    if (data is Map) {
      if (data.containsKey('is_passed')) { onFound(Map<String, dynamic>.from(data)); }
      else { data.forEach((k, v) => _processRecursive(v, onFound)); }
    } else if (data is List) {
      for(var item in data) { if(item != null) _processRecursive(item, onFound); }
    }
  }
}