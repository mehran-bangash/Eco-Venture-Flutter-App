class TeacherReportModel {
  final String id;
  final String title;
  final String description;
  final String fromName; // "Parent of Ali" or "Student: Sara"
  final String type; // 'Safety', 'Content', 'Bug', 'Behavior'
  final String status; // 'Pending', 'Resolved'
  final DateTime timestamp;

  // Context Data (Optional)
  final String? childId;
  final String? parentId;
  final String? contentId;

  TeacherReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fromName,
    required this.type,
    required this.status,
    required this.timestamp,
    this.childId,
    this.parentId,
    this.contentId,
  });

  factory TeacherReportModel.fromMap(String id, Map<String, dynamic> map) {
    return TeacherReportModel(
      id: id,
      title: map['title'] ?? 'Alert',
      description: map['description'] ?? '',
      fromName: map['fromName'] ?? 'Unknown',
      type: map['type'] ?? 'General',
      status: map['status'] ?? 'Pending',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      childId: map['childId'],
      parentId: map['parentId'],
      contentId: map['contentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fromName': fromName,
      'type': type,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'childId': childId,
      'parentId': parentId,
      'contentId': contentId,
    };
  }
}