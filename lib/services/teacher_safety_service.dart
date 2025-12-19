import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../models/teacher_report_model.dart';
import '../services/shared_preferences_helper.dart';

class TeacherSafetyService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _backendUrl = "https://eco-venture-backend.onrender.com";

  Future<String?> _getTeacherId() async {
    String? id = _auth.currentUser?.uid;
    id ??= await SharedPreferencesHelper.instance.getUserId();
    return id;
  }
  Future<void> _notifyChild(String childUid, String title, String body) async {
    await _sendPushNotification(targetId: childUid, role: 'child', title: title, body: body);
  }


  // --- 1. FETCH INBOX (MERGED STREAM) ---
  Stream<List<TeacherReportModel>> getInboxStream() {
    return Stream.fromFuture(_getTeacherId()).switchMap((teacherId) {
      if (teacherId == null) return Stream.value([]);

      // A. Teacher's Direct Inbox (Parent Reports)
      final directInboxStream = _database
          .ref('Teacher_Content/$teacherId/inbox')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent"))
          .startWith([]);

      // B. Fetch Students -> Listen to Child Reports
      return _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child')
          .snapshots()
          .switchMap((snapshot) {
            if (snapshot.docs.isEmpty) return directInboxStream;

            List<Stream<List<TeacherReportModel>>> allStreams = [
              directInboxStream,
            ];

            for (var doc in snapshot.docs) {
              final childId = doc.id;
              final studentName = doc.data()['name'] ?? 'Student';

              // Listen to Child's Alerts
              final childAlertStream = _database
                  .ref('safety_alerts/$childId')
                  .onValue
                  .map(
                    (event) => _parseReports(
                      event.snapshot.value,
                      studentName,
                      childId: childId,
                    ),
                  )
                  .startWith([]);

              allStreams.add(childAlertStream);
            }

            return Rx.combineLatest(allStreams, (
              List<List<TeacherReportModel>> separateLists,
            ) {
              final allReports = separateLists.expand((x) => x).toList();
              allReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              return allReports;
            });
          });
    });
  }

  // --- CRITICAL FIX: DATA MAPPING ---
  List<TeacherReportModel> _parseReports(
    dynamic data,
    String fromSource, {
    String? childId,
  }) {
    if (data == null) return [];
    final List<TeacherReportModel> reports = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);

            // FILTER: If looking at Child Alerts, only show if sent to Teacher
            if (childId != null && map['recipient'] != 'Teacher') {
              return; // Skip this report
            }

            // --- MAP FIELDS CORRECTLY ---
            map['id'] = key;

            // 1. Map Title
            if (map['title'] == null) {
              map['title'] = map['reportTitle'] ?? map['issueType'] ?? 'Alert';
            }

            // 2. Map Description
            String desc =
                map['description'] ?? map['reportDesc'] ?? map['details'] ?? '';
            String note = map['parentNote'] ?? '';
            if (note.isNotEmpty) desc += "\n\nParent Note: $note";
            map['description'] = desc;

            // 3. Map From Name
            if (map['fromName'] == null) {
              map['fromName'] = fromSource == "Parent"
                  ? "Parent"
                  : "Student: $fromSource";
            }

            // 4. Inject Child ID if missing
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

  // ... (Keep updateReportStatus, sendRemarkToParent, etc. unchanged) ...
  // (Paste the rest of the existing methods here)
  Future<void> updateReportStatus(String reportId, String newStatus, String? childId) async {
    final teacherId = await _getTeacherId();

    // 1. Update DB Status
    if (childId != null) {
      await _database.ref('safety_alerts/$childId/$reportId').update({'status': newStatus});
    } else {
      await _database.ref('Teacher_Content/$teacherId/inbox/$reportId').update({'status': newStatus});
    }

    // 2. NOTIFY CHILD (New Logic)
    if (newStatus == 'Resolved' && childId != null) {
      await _notifyChild(
          childId,
          "Report Resolved",
          "Your teacher has reviewed your report."
      );
    }
  }

  Future<void> sendRemarkToParent({
    required String studentId,
    required String title,
    required String message,
  }) async {
    // A. Find Parent ID
    final childDoc = await _firestore.collection('users').doc(studentId).get();
    final parentId = childDoc.data()?['parent_id'];

    if (parentId == null) throw Exception("This student has no linked parent.");

    // B. Save to PARENT'S Notification History (Was child_notifications before)
    await _database.ref('parent_notifications/$parentId').push().set({
      'title': title,
      'body': message,
      'type': 'remark', // Icon logic in Parent App handles this
      'childId': studentId,
      'from': 'Teacher',
      'timestamp': DateTime.now().toIso8601String(),
    });

    // C. Send Push (Node.js)
    await _sendPushNotification(
      targetId: parentId,
      role: 'parent',
      title: "New Teacher Remark",
      body: message,
    );
  }

  Future<void> reportToAdmin(String title, String message, String type) async {
    final teacherId = await _getTeacherId();
    final newKey = _database.ref().push().key!;
    await _database.ref('admin_reports/$newKey').set({
      'title': title,
      'description': message,
      'type': type,
      'fromTeacherId': teacherId,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'Pending',
    });
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
}
