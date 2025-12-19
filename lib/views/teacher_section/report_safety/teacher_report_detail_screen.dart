import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import '../../../../models/teacher_report_model.dart';
import '../../../viewmodels/teacher_safety_report/teacher_safety_provider.dart';


class TeacherReportDetailScreen extends ConsumerWidget {
  final TeacherReportModel reportData;
  const TeacherReportDetailScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color _bg = const Color(0xFFF4F7FE);
    final Color _textDark = const Color(0xFF1B2559);

    // Logic to check if content is attached (ID or specific title)
    final bool isContentReport = reportData.contentId != null ||
        (reportData.title != 'Alert' && !reportData.title.contains('Behavior'));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Report Details", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(radius: 20.sp, backgroundColor: Colors.red.shade50, child: const Icon(Icons.warning_amber_rounded, color: Colors.red)),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reportData.title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
                        Text(reportData.fromName, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                    decoration: BoxDecoration(color: reportData.status == 'Pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(reportData.status, style: TextStyle(color: reportData.status == 'Pending' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                  )
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // --- REPORTED CONTENT (If applicable) ---
            if (isContentReport) ...[
              Text("Report Context", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _textDark)),
              SizedBox(height: 1.5.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
                child: Row(
                  children: [
                    Container(height: 60, width: 60, color: Colors.grey.shade200, child: const Icon(Icons.play_circle_outline)),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reportData.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                          if(reportData.contentId != null) Text("ID: ${reportData.contentId}", style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],

            // --- FULL DETAILS ---
            Text("Full Description", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _textDark)),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(
                reportData.description.isEmpty ? "No detailed description provided." : reportData.description,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[800], height: 1.5),
              ),
            ),

            SizedBox(height: 5.h),

            // --- ACTIONS ---
            if (reportData.status == 'Pending')
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(teacherSafetyViewModelProvider.notifier).markResolved(reportData.id, reportData.childId);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Mark as Resolved", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}