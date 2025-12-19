import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/parent_alert_model.dart';
import '../../../viewmodels/parent_section/report_safety/parent_safety_provider.dart';

class ParentReportDetailScreen extends ConsumerStatefulWidget {
  final ParentAlertModel alert;

  const ParentReportDetailScreen({super.key, required this.alert});

  @override
  ConsumerState<ParentReportDetailScreen> createState() =>
      _ParentReportDetailScreenState();
}

class _ParentReportDetailScreenState
    extends ConsumerState<ParentReportDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final Color _bg = const Color(0xFFF5F7FA);

  void _escalate(String target) {
    final childId = ref.read(parentSafetyViewModelProvider).selectedChildId;
    if (childId == null) return;

    if (target == 'Teacher') {
      ref
          .read(parentSafetyServiceProvider)
          .escalateReportToTeacher(childId, widget.alert, _noteController.text);
    } else {
      ref
          .read(parentSafetyServiceProvider)
          .escalateReportToAdmin(childId, widget.alert, _noteController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Report forwarded to $target"),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Check if content context exists
    bool hasContent = widget.alert.contentTitle != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Report Details",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
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
            // HEADER
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 24.sp,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alert.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeago.format(widget.alert.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.alert.status == 'Resolved'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.alert.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                        color: widget.alert.status == 'Resolved'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // CONTENT CONTEXT (FIXED)
            if (hasContent) ...[
              Text(
                "Reported Content",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Title: ${widget.alert.contentTitle}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      "Type: ${widget.alert.contentType ?? 'Unknown'}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    if (widget.alert.contentId != null)
                      Text(
                        "ID: ${widget.alert.contentId}",
                        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],

            // DESCRIPTION
            Text(
              "Description",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.alert.description.isEmpty
                    ? "No details provided."
                    : widget.alert.description,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // ACTION: ESCALATE (Input)
            Text(
              "Take Action",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Add a note for Teacher/Admin...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _escalate('Teacher'),
                          icon: Icon(Icons.school, size: 16.sp),
                          label: Text(
                            "Report to Teacher",
                            style: TextStyle(fontSize: 11.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _escalate('Admin'),
                          icon: Icon(Icons.admin_panel_settings, size: 16.sp),
                          label: Text(
                            "Report to Admin",
                            style: TextStyle(fontSize: 11.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // RESOLVE BUTTON
            if (widget.alert.status == 'Pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(parentSafetyViewModelProvider.notifier)
                        .markAlertResolved(widget.alert.id);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    "Mark as Resolved (Local)",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
