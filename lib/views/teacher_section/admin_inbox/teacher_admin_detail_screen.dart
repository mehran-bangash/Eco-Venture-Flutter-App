import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../models/teacher/teacher_report_model.dart';

class TeacherAdminDetailScreen extends StatelessWidget {
  final TeacherReportModel report;
  const TeacherAdminDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final bool isResolved = report.status.toLowerCase() == 'resolved';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Icon(isResolved ? Icons.check_circle : Icons.pending, color: isResolved ? Colors.green : Colors.orange),
                  SizedBox(width: 3.w),
                  Text("Status: ${report.status}", style: TextStyle(fontWeight: FontWeight.bold, color: isResolved ? Colors.green : Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(report.title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text("Category: ${report.type}", style: const TextStyle(color: Colors.grey)),
            // Fixed: Removed 'const' because .h is an extension method
            Divider(height: 4.h),
            Text("Description:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text(report.description, style: GoogleFonts.poppins(height: 1.5)),
          ],
        ),
      ),
    );
  }
}