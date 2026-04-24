import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/teacher/teacher_report_model.dart';
import '../shared_preferences_helper.dart';

class TeacherSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _backendUrl = "https://eco-venture-backend.onrender.com";

  Future<String?> _getTeacherId() async {
    String? id = _auth.currentUser?.uid;
    id ??= SharedPreferencesHelper.instance.getUserId();
    return id;
  }
  Future<void> _notifyChild(String childUid, String title, String body) async {
    await _sendPushNotification(targetId: childUid, role: 'child', title: title, body: body);
  }


  // --- CRITICAL FIX: DATA MAPPING & FLEXIBLE FILTERING ---
  List<TeacherReportModel> _parseReports(
      dynamic data,
      String fromSource, {
        String? childId,
        String? targetTeacherId,
      }) {
    if (data == null) return [];
    final List<TeacherReportModel> reports = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);

            final reportTeacherId = map['teacherId'] ?? map['teacher_id'] ?? map['targetId'];

            if (targetTeacherId != null && reportTeacherId != targetTeacherId) {
              return;
            }

            if (childId != null && map['recipient'] != 'Teacher') {
              return;
            }

            map['id'] = key;

            // FIX: Explicitly check for status in Parent Reports
            // If the parent app doesn't send 'status', we force it to 'Pending' or 'Escalated'
            if (map['status'] == null || map['status'].toString().isEmpty) {
              map['status'] = 'Pending';
            }

            if (map['title'] == null) {
              map['title'] = map['reportTitle'] ?? map['issueType'] ?? 'Alert';
            }

            String desc = map['description'] ?? map['reportDesc'] ?? map['details'] ?? '';
            String note = map['parentNote'] ?? '';
            if (note.isNotEmpty) desc += "\n\nParent Note: $note";
            map['description'] = desc;

            if (map['fromName'] == null) {
              map['fromName'] = fromSource == "Parent"
                  ? (map['senderName'] ?? map['parentName'] ?? "Parent")
                  : "Student: $fromSource";
            }

            if (childId != null) map['childId'] = childId;

            reports.add(TeacherReportModel.fromMap(key, map));
          }
        });
      }
    } catch (e) {
      print("Error parsing: $e");
    }
    return reports;
  }

  Future<void> updateReportStatus(String reportId, String newStatus, String? childId) async {
    try {
      final parentReportRef = _database.ref('parent_to_teacher_reports/$reportId');
      final snapshot = await parentReportRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final String? originalId = data['originalReportId'];

        // 1. Update Parent Escalation node (Both status and teacherStatus)
        await parentReportRef.update({
          'status': newStatus,
          'teacherStatus': newStatus, // FIX: Syncing the second field
          'resolvedAt': DateTime.now().toIso8601String(),
        });

        // 2. Sync back to the Parent's Dashboard (safety_alerts node)
        if (childId != null && originalId != null) {
          await _database.ref('safety_alerts/$childId/$originalId').update({
            'teacherStatus': newStatus,
            // We don't force 'status' to resolved here if you want Parent to
            // manually close their local view, but usually, it's better to sync:
            // 'status': newStatus,
          });
        }
        return;
      }

      // 3. Direct Child Alert Logic
      if (childId != null) {
        await _database.ref('safety_alerts/$childId/$reportId').update({
          'status': newStatus,
        });

        if (newStatus == 'Resolved') {
          await _notifyChild(childId, "Report Resolved", "Your teacher has reviewed your report.");
        }
      }
    } catch (e) {
      print("Error updating report status: $e");
    }
  }

  Future<void> sendRemarkToParent({
    required String studentId,
    required String title,
    required String message,
  }) async {
    final childDoc = await _firestore.collection('users').doc(studentId).get();
    final parentId = childDoc.data()?['parent_id'];

    if (parentId == null) throw Exception("This student has no linked parent.");

    await _database.ref('parent_notifications/$parentId').push().set({
      'title': title,
      'body': message,
      'type': 'remark',
      'childId': studentId,
      'from': 'Teacher',
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _sendPushNotification(
      targetId: parentId,
      role: 'parent',
      title: "New Teacher Remark",
      body: message,
    );
  }

  Future<void> reportToAdmin(String title, String message, String type) async {
    try {
      final teacherId = await _getTeacherId();
      if (teacherId == null) throw Exception("Teacher session not found.");

      // 1. Fetch Teacher's Name from Firestore
      final teacherDoc = await _firestore.collection('users').doc(teacherId).get();
      final String teacherName = teacherDoc.data()?['name'] ?? "Teacher";

      final newKey = _database.ref('teacher_to_admin_reports').push().key!;

      // 2. Set comprehensive report data
      await _database.ref('teacher_to_admin_reports/$newKey').set({
        'title': title,
        'description': message,
        'type': type,
        'fromTeacherId': teacherId,
        'fromTeacherName': teacherName, // Included teacher name
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'Pending',            // Primary status
        'adminStatus': 'Pending',       // Resolution tracking status
        'isAdminEscalated': true,       // Flag for admin visibility
        'senderRole': 'Teacher',
      });
    } catch (e) {
      throw Exception("Failed to send report to admin: $e");
    }
  }

  Future<void> _sendPushNotification({
    required String targetId,
    required String role,
    required String title,
    required String body,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.notifyChildEndPoints);
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'childId': targetId, 'title': title, 'body': body}),
      );
    } catch (e) {
      print("Notify Error: $e");
    }
  }


  Stream<List<TeacherReportModel>> getInboxStream() {
    return Stream.fromFuture(_getTeacherId()).switchMap((teacherId) {
      if (teacherId == null) return Stream.value([]);

      // A. Teacher's Direct Inbox
      final directInboxStream = _database
          .ref('Teacher_Content/$teacherId/inbox')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent"))
          .startWith([]);

      // B. Global Parent-to-Teacher Reports
      final parentToTeacherStream = _database
          .ref('parent_to_teacher_reports')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent", targetTeacherId: teacherId))
          .startWith([]);

      // C. NEW: Teacher-to-Admin Reports (Tracking your own requests)
      final teacherToAdminStream = _database
          .ref('teacher_to_admin_reports')
          .orderByChild('fromTeacherId')
          .equalTo(teacherId)
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Support Admin"))
          .startWith([]);

      // D. Student Alerts from Firestore Linked Students
      return _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child')
          .snapshots()
          .switchMap((snapshot) {
        List<Stream<List<TeacherReportModel>>> allStreams = [
          directInboxStream,
          parentToTeacherStream,
          teacherToAdminStream, // Added to the merge
        ];

        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final childId = doc.id;
            final studentName = doc.data()['name'] ?? 'Student';
            final childAlertStream = _database
                .ref('safety_alerts/$childId')
                .onValue
                .map((event) => _parseReports(event.snapshot.value, studentName, childId: childId))
                .startWith([]);
            allStreams.add(childAlertStream);
          }
        }

        return Rx.combineLatest(allStreams, (List<List<TeacherReportModel>> lists) {
          final all = lists.expand((x) => x).toList();
          all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return all;
        });
      });
    });
  }
}