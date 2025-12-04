class TeacherStudentStatsModel {
  final int totalPoints;
  final double quizAverage;
  final int tasksDone; // This can represent all tasks combined
  final int qrFinds;
  final int stemTasksDone; // Specifically for STEM tasks

  TeacherStudentStatsModel({
    this.totalPoints = 0,
    this.quizAverage = 0.0,
    this.tasksDone = 0,
    this.qrFinds = 0,
    this.stemTasksDone = 0, // Initialize the new field
  });

  // An initial state for when data is loading
  factory TeacherStudentStatsModel.initial() {
    return TeacherStudentStatsModel(
      totalPoints: 0,
      quizAverage: 0.0,
      tasksDone: 0,
      qrFinds: 0,
      stemTasksDone: 0, // Add to initial factory
    );
  }
}
