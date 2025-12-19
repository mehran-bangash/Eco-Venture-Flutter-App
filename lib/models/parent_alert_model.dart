class ParentAlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String status;
  final bool isCritical;

  // NEW: Context Data
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
    this.contentId,
    this.contentTitle,
    this.contentType,
  });

  factory ParentAlertModel.fromMap(String id, Map<String, dynamic> map) {
    // Map diverse keys to standard fields
    String title = map['title'] ?? map['issueType'] ?? 'Alert';
    String desc = map['description'] ?? map['details'] ?? map['body'] ?? '';

    return ParentAlertModel(
      id: id,
      title: title,
      description: desc,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      isCritical: map['is_critical'] ?? false,
      contentId: map['contentId'],
      contentTitle: map['contentTitle'],
      contentType: map['contentType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'is_critical': isCritical,
      'contentId': contentId,
      'contentTitle': contentTitle,
      'contentType': contentType,
    };
  }
}