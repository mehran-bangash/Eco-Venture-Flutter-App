class ParentAlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String status;
  final bool isCritical;
  final String severity;
  final String? imageUrl;

  final String? teacherStatus;
  final String? adminStatus;

  final String? contentId;
  final String? contentTitle;
  final String? contentType;

  ParentAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status = 'Pending',
    this.isCritical = false,
    required this.severity,
    this.imageUrl,
    this.teacherStatus,
    this.adminStatus,
    this.contentId,
    this.contentTitle,
    this.contentType,
  });

  factory ParentAlertModel.fromMap(String id, Map<String, dynamic> map) {
    // FIX: Robust title mapping to capture "Scary Content", "Bullying", etc.
    String mappedTitle = map['issueType'] ?? map['type'] ?? map['title'] ?? 'Safety Alert';

    return ParentAlertModel(
      id: id,
      title: mappedTitle,
      description: map['description'] ?? map['details'] ?? map['body'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      isCritical: map['is_critical'] ?? false,
      severity: map['severity'] ?? (map['is_critical'] == true ? 'High' : 'Low'),
      imageUrl: map['screenshotUrl'] ?? map['imageUrl'] ?? map['image'],
      teacherStatus: map['teacherStatus'],
      adminStatus: map['adminStatus'],
      contentId: map['contentId'],
      contentTitle: map['contentTitle'],
      contentType: map['contentType'],
    );
  }
}