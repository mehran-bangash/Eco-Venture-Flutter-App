class ChildReportModel {
  final String? id;
  final String? childId;
  final String recipient; // 'Parent', 'Teacher', 'Admin'
  final String issueType; // 'Scary Content', 'Bug', etc.
  final String details;
  final String? screenshotUrl;
  final DateTime timestamp;
  final String status; // 'Pending', 'Resolved'

  // Context (Optional: if reporting specific content)
  final String? contentId;
  final String? contentTitle;
  final String? contentType;

  ChildReportModel({
    this.id,
    this.childId,
    required this.recipient,
    required this.issueType,
    required this.details,
    this.screenshotUrl,
    required this.timestamp,
    this.status = 'Pending',
    this.contentId,
    this.contentTitle,
    this.contentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'recipient': recipient,
      'issueType': issueType,
      'details': details,
      'screenshotUrl': screenshotUrl,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'contentId': contentId,
      'contentTitle': contentTitle,
      'contentType': contentType,
    };
  }

  // We usually don't need fromMap on Child side (Write Only), but good practice:
  factory ChildReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ChildReportModel(
      id: id,
      childId: map['childId'],
      recipient: map['recipient'] ?? 'Parent',
      issueType: map['issueType'] ?? 'Other',
      details: map['details'] ?? '',
      screenshotUrl: map['screenshotUrl'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      contentId: map['contentId'],
      contentTitle: map['contentTitle'],
      contentType: map['contentType'],
    );
  }

  ChildReportModel copyWith({String? screenshotUrl, String? childId}) {
    return ChildReportModel(
      id: id,
      childId: childId ?? this.childId,
      recipient: recipient,
      issueType: issueType,
      details: details,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      timestamp: timestamp,
      status: status,
      contentId: contentId,
      contentTitle: contentTitle,
      contentType: contentType,
    );
  }
}