import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/teacher_report_model.dart';
import '../shared_preferences_helper.dart';

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

      // A. Teacher's Direct Inbox (Old Path)
      final directInboxStream = _database
          .ref('Teacher_Content/$teacherId/inbox')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent"))
          .startWith([]);

      // B. Global Parent-to-Teacher Reports (New Path)
      final parentToTeacherStream = _database
          .ref('parent_to_teacher_reports')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent", targetTeacherId: teacherId))
          .startWith([]);

      // C. Fetch Students -> Listen to Child Reports
      return _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child')
          .snapshots()
          .switchMap((snapshot) {

        // Start with base streams that are always active
        List<Stream<List<TeacherReportModel>>> allStreams = [
          directInboxStream,
          parentToTeacherStream,
        ];

        // Add individual streams for every linked student's safety alerts
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final childId = doc.id;
            final studentName = doc.data()['name'] ?? 'Student';

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
        }

        return Rx.combineLatest(allStreams, (
            List<List<TeacherReportModel>> separateLists,
            ) {
          final allReports = separateLists.expand((x) => x).toList();
          // Ensure consistent sorting: newest messages at the top
          allReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return allReports;
        });
      });
    });
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

            // FIX: Support both 'teacherId' and 'teacher_id' for filtering
            final reportTeacherId = map['teacherId'] ?? map['teacher_id'] ?? map['targetId'];

            // FILTER 1: If from parent_to_teacher_reports, only show to the intended teacher
            if (targetTeacherId != null && reportTeacherId != targetTeacherId) {
              return;
            }

            // FILTER 2: If looking at Child Alerts, only show if sent to Teacher
            if (childId != null && map['recipient'] != 'Teacher') {
              return;
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

            // 3. Map From Name (Check senderName field as well)
            if (map['fromName'] == null) {
              map['fromName'] = fromSource == "Parent"
                  ? (map['senderName'] ?? map['parentName'] ?? "Parent")
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

  Future<void> updateReportStatus(String reportId, String newStatus, String? childId) async {
    final teacherId = await _getTeacherId();

    if (childId != null) {
      await _database.ref('safety_alerts/$childId/$reportId').update({'status': newStatus});
    } else {
      // Update both possible locations for generic parent reports
      await _database.ref('Teacher_Content/$teacherId/inbox/$reportId').update({'status': newStatus});
      await _database.ref('parent_to_teacher_reports/$reportId').update({'status': newStatus});
    }

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