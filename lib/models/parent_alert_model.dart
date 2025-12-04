class ParentAlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String status; // 'Pending', 'Resolved'
  final bool isCritical;

  ParentAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status = 'Pending',
    this.isCritical = false,
  });

  factory ParentAlertModel.fromMap(String id, Map<String, dynamic> map) {
    return ParentAlertModel(
      id: id,
      title: map['title'] ?? 'Alert',
      description: map['description'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      isCritical: map['is_critical'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'is_critical': isCritical,
    };
  }
}