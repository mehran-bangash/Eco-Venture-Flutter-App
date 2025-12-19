import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_safety_report/teacher_safety_provider.dart';
class TeacherSendReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extra; // {'type': 'Admin' or 'Parent'}
  const TeacherSendReportScreen({super.key, required this.extra});

  @override
  ConsumerState<TeacherSendReportScreen> createState() =>
      _TeacherSendReportScreenState();
}

class _TeacherSendReportScreenState
    extends ConsumerState<TeacherSendReportScreen> {
  String _selectedType = 'Remark';
  String? _selectedStudentId;
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();

  final List<String> _types = [
    'Behavior Remark',
    'Progress Update',
    'Urgent Issue',
  ];
  final List<String> _bugTypes = [
    'App Crash',
    'Feature Request',
    'Content Error',
  ];

  // Real Data List
  List<Map<String, String>> _students = [];
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    if (widget.extra['type'] == 'Parent') {
      _fetchMyStudents();
    }
  }

  Future<void> _fetchMyStudents() async {
    // 1. Get Teacher ID
    String? teacherId = FirebaseAuth.instance.currentUser?.uid;
    teacherId ??= await SharedPreferencesHelper.instance.getUserId();

    if (teacherId == null) return;

    // 2. Query Firestore
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('teacher_id', isEqualTo: teacherId)
        .where('role', isEqualTo: 'child')
        .get();

    List<Map<String, String>> loaded = [];
    for (var doc in snap.docs) {
      loaded.add({'id': doc.id, 'name': doc.data()['name'] ?? 'Student'});
    }

    if (mounted) {
      setState(() {
        _students = loaded;
        _isLoadingStudents = false;
      });
    }
  }

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) return;

    final isParent = widget.extra['type'] == 'Parent';

    if (isParent) {
      if (_selectedStudentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Select a student"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await ref
          .read(teacherSafetyViewModelProvider.notifier)
          .sendParentMessage(
        _selectedStudentId!, // Pass Child ID (Service finds Parent)
        _titleCtrl.text,
        _messageCtrl.text,
      );
    } else {
      await ref
          .read(teacherSafetyViewModelProvider.notifier)
          .sendAdminReport(_titleCtrl.text, _messageCtrl.text, _selectedType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherSafetyViewModelProvider);
    bool isAdmin = widget.extra['type'] == 'Admin';
    List<String> options = isAdmin ? _bugTypes : _types;

    // Listener for Success
    ref.listen(teacherSafetyViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Message Sent!"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(teacherSafetyViewModelProvider.notifier).resetSuccess();
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(
          isAdmin ? "Contact Admin" : "Contact Parent",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isAdmin) ...[
              Text("Select Student", style: _labelStyle),
              SizedBox(height: 1.h),
              if (_isLoadingStudents)
                const CircularProgressIndicator()
              else if (_students.isEmpty)
                Text("No students found.", style: TextStyle(color: Colors.grey))
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedStudentId,
                      hint: const Text("Choose Student"),
                      items: _students
                          .map(
                            (e) => DropdownMenuItem(
                          value: e['id'],
                          child: Text(e['name']!),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedStudentId = v),
                    ),
                  ),
                ),
              SizedBox(height: 3.h),
            ],

            Text("Subject / Type", style: _labelStyle),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              children: options
                  .map(
                    (type) => ChoiceChip(
                  label: Text(type),
                  selected: _selectedType == type,
                  onSelected: (val) => setState(() => _selectedType = type),
                  selectedColor: Colors.blueAccent.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedType == type
                        ? Colors.blue
                        : Colors.black,
                  ),
                  backgroundColor: Colors.white,
                ),
              )
                  .toList(),
            ),

            SizedBox(height: 3.h),
            Text("Title", style: _labelStyle),
            SizedBox(height: 1.h),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: "Short title...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 2.h),
            Text("Message", style: _labelStyle),
            SizedBox(height: 1.h),
            TextField(
              controller: _messageCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your message here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Send Message",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1B2559),
  );
}
