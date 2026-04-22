class TeacherClassReportModel {
  final int totalStudents;
  final double classAverageScore;
  final int totalQuizzesPassed;
  final int totalStemSubmissions;
  final int totalQrHuntsSolved;

  final List<StudentRankItem> studentRankings;

  TeacherClassReportModel({
    this.totalStudents = 0,
    this.classAverageScore = 0.0,
    this.totalQuizzesPassed = 0,
    this.totalStemSubmissions = 0,
    this.totalQrHuntsSolved = 0,
    this.studentRankings = const [],
  });

  factory TeacherClassReportModel.empty() {
    return TeacherClassReportModel();
  }
}

class StudentRankItem {
  final String uid;
  final String name;
  final int totalPoints;
  final String? avatarUrl;

  // NEW: Breakdown for aggregation
  final int quizCount;
  final int stemCount;
  final int qrCount;

  StudentRankItem({
    required this.uid,
    required this.name,
    required this.totalPoints,
    this.avatarUrl,
    this.quizCount = 0,
    this.stemCount = 0,
    this.qrCount = 0,
  });
}