import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/parent_alert_model.dart';
import '../../../viewmodels/parent_section/report_safety/parent_safety_provider.dart';


class ParentReportDetailScreen extends ConsumerStatefulWidget {
  final ParentAlertModel alert; // Passed from List
  const ParentReportDetailScreen({super.key, required this.alert});

  @override
  ConsumerState<ParentReportDetailScreen> createState() => _ParentReportDetailScreenState();
}

class _ParentReportDetailScreenState extends ConsumerState<ParentReportDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final Color _bg = const Color(0xFFF5F7FA);

  void _escalate(String target) {
    final childId = ref.read(parentSafetyViewModelProvider).selectedChildId;
    if (childId == null) return;

    if (target == 'Teacher') {
      ref.read(parentSafetyServiceProvider).escalateReportToTeacher(childId, widget.alert, _noteController.text);
    } else {
      ref.read(parentSafetyServiceProvider).escalateReportToAdmin(childId, widget.alert, _noteController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Report forwarded to $target"), backgroundColor: Colors.green));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    // If your Alert Model has 'screenshotUrl', display it.
    // Assuming you update ParentAlertModel to include it (it matches ChildReportModel structure)
    // String? image = widget.alert.screenshotUrl;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Report Details", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
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
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.alert.title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(timeago.format(widget.alert.timestamp), style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // --- DETAILS ---
            Text("Description", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Text(widget.alert.description, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87)),
            ),

            // --- SCREENSHOT (If available) ---
            // if (image != null) ...[
            //    SizedBox(height: 3.h),
            //    Text("Attachment", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            //    SizedBox(height: 1.h),
            //    ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(image)),
            // ],

            SizedBox(height: 4.h),

            // --- ACTION: ESCALATE ---
            Text("Take Action", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                        hintText: "Add a note for Teacher/Admin...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50
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
                          label: Text("Report to Teacher", style: TextStyle(fontSize: 11.sp)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _escalate('Admin'),
                          icon: Icon(Icons.admin_panel_settings, size: 16.sp),
                          label: Text("Report to Admin", style: TextStyle(fontSize: 11.sp)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(parentSafetyViewModelProvider.notifier).markAlertResolved(widget.alert.id);
                  context.pop();
                },
                child: Text("Mark as Resolved (Local)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}