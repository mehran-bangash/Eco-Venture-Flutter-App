import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherReportModel {
  final String id;
  final String title;
  final String description;
  final String fromName;
  final String? childName;
  final String type;
  final String status;
  final DateTime timestamp;
  final String? imageUrl; // We keep this name for the UI

  final String? childId;
  final String? parentId;
  final String? contentId;

  TeacherReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fromName,
    this.childName,
    required this.type,
    required this.status,
    required this.timestamp,
    this.imageUrl,
    this.childId,
    this.parentId,
    this.contentId,
  });

  factory TeacherReportModel.fromMap(String id, Map<String, dynamic>? map) {
    if (map == null) return _errorReport(id);

    try {
      DateTime parsedTime;
      var rawTime = map['timestamp'] ?? map['createdAt'];
      if (rawTime is Timestamp) {
        parsedTime = rawTime.toDate();
      } else if (rawTime is String) {
        parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
      } else {
        parsedTime = DateTime.now();
      }

      String safeStr(dynamic v, String def) => (v == null || v.toString().isEmpty) ? def : v.toString();

      return TeacherReportModel(
        id: id,
        title: safeStr(map['title'], 'Alert'),
        // Logic: Check multiple keys for description
        description: safeStr(map['description'] ?? map['message'] ?? map['details'] ?? map['parentNote'], ''),
        fromName: safeStr(map['fromName'] ?? map['senderName'], 'Unknown'),
        childName: map['childName']?.toString(),
        type: safeStr(map['type'], 'General'),
        status: safeStr(map['status'], 'Pending'),
        timestamp: parsedTime,

        // FIX: Mapping multiple possible Firebase keys to the single 'imageUrl' variable
        imageUrl: map['screenshotUrl'] ?? map['imageUrl'] ?? map['image'],

        childId: map['childId']?.toString(),
        parentId: map['parentId']?.toString(),
        contentId: map['contentId']?.toString(),
      );
    } catch (e) {
      return _errorReport(id);
    }
  }

  static TeacherReportModel _errorReport(String id) {
    return TeacherReportModel(
      id: id,
      title: 'Data Error',
      description: 'Format error',
      fromName: 'System',
      status: 'Pending',
      type: 'Bug',
      timestamp: DateTime.now(),
    );
  }
}