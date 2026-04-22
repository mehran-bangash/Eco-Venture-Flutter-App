class TeacherStudentActivityModel {
  final String title;
  final String type;
  final DateTime timestamp;

  TeacherStudentActivityModel({
    required this.title,
    required this.type,
    required this.timestamp,
  });

  factory TeacherStudentActivityModel.fromMap(Map<String, dynamic> map) {
    return TeacherStudentActivityModel(
      title: map['title'] ?? 'Unknown Activity',
      type: map['type'] ?? 'Unknown',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
