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

  Future<String?> _getTeacherId() async {
    String? id = _auth.currentUser?.uid;
    id ??= SharedPreferencesHelper.instance.getUserId();
    return id;
  }

  Future<void> _notifyChild(String childUid, String title, String body) async {
    await _sendPushNotification(targetId: childUid, role: 'child', title: title, body: body);
  }

  // --- RESTORED: STATUS UPDATE LOGIC ---
  Future<void> updateReportStatus(String reportId, String newStatus, String? childId) async {
    try {
      final parentReportRef = _database.ref('parent_to_teacher_reports/$reportId');
      final snapshot = await parentReportRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final String? originalId = data['originalReportId'];

        await parentReportRef.update({
          'status': newStatus,
          'teacherStatus': newStatus,
          'resolvedAt': DateTime.now().toIso8601String(),
        });

        if (childId != null && originalId != null) {
          await _database.ref('safety_alerts/$childId/$originalId').update({
            'teacherStatus': newStatus,
          });
        }
        return;
      }

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

  // --- RESTORED: PARENT REMARK LOGIC ---
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

  // --- TRICK: ROBUST PARSER FOR ADMIN REPORTS ---
  List<TeacherReportModel> _parseAdminReports(dynamic data) {
    if (data == null) return [];
    final List<TeacherReportModel> reports = [];
    try {
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            map['id'] = key;

            if (map['status'] == null || map['status'].toString().isEmpty) {
              map['status'] = map['adminStatus'] ?? 'Pending';
            }

            if (map['title'] == null) {
              map['title'] = map['reportTitle'] ?? 'Support Request';
            }

            map['fromName'] = "Support Admin";

            reports.add(TeacherReportModel.fromMap(key, map));
          }
        });
      }
    } catch (e) {
      print("Error parsing admin reports: $e");
    }
    return reports;
  }

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

            if (targetTeacherId != null && reportTeacherId != targetTeacherId) return;
            if (childId != null && map['recipient'] != 'Teacher') return;

            map['id'] = key;
            if (map['status'] == null || map['status'].toString().isEmpty) {
              map['status'] = 'Pending';
            }

            if (map['title'] == null) {
              map['title'] = map['reportTitle'] ?? map['issueType'] ?? 'Alert';
            }

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

  Future<void> reportToAdmin(String title, String message, String type) async {
    try {
      final teacherId = await _getTeacherId();
      if (teacherId == null) throw Exception("Teacher session not found.");

      final teacherDoc = await _firestore.collection('users').doc(teacherId).get();
      final String teacherName = teacherDoc.data()?['name'] ?? "Teacher";

      final newKey = _database.ref('teacher_to_admin_reports').push().key!;

      await _database.ref('teacher_to_admin_reports/$newKey').set({
        'title': title,
        'description': message,
        'type': type,
        'fromTeacherId': teacherId,
        'fromTeacherName': teacherName,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'Pending',
        'adminStatus': 'Pending',
        'isAdminEscalated': true,
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

      final directInboxStream = _database
          .ref('Teacher_Content/$teacherId/inbox')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent"))
          .startWith([]);

      final parentToTeacherStream = _database
          .ref('parent_to_teacher_reports')
          .onValue
          .map((event) => _parseReports(event.snapshot.value, "Parent", targetTeacherId: teacherId))
          .startWith([]);

      return _firestore
          .collection('users')
          .where('teacher_id', isEqualTo: teacherId)
          .where('role', isEqualTo: 'child')
          .snapshots()
          .switchMap((snapshot) {
        List<Stream<List<TeacherReportModel>>> allStreams = [
          directInboxStream,
          parentToTeacherStream,
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

  Stream<List<TeacherReportModel>> getAdminInboxStream() {
    return Stream.fromFuture(_getTeacherId()).switchMap((teacherId) {
      if (teacherId == null) return Stream.value([]);

      return _database
          .ref('teacher_to_admin_reports')
          .orderByChild('fromTeacherId')
          .equalTo(teacherId)
          .onValue
          .map((event) {
        final reports = _parseAdminReports(event.snapshot.value);
        reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return reports;
      })
          .startWith([]);
    });
  }
}