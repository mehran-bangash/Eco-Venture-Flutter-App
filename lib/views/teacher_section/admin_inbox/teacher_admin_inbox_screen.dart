import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/teacher/teacher_report_model.dart';
import '../../../viewmodels/teacher_safety_report/teacher_safety_provider.dart';

class TeacherAdminInboxScreen extends ConsumerWidget {
  const TeacherAdminInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic: Listen directly to the dedicated Admin stream
    final adminStream = ref.watch(teacherSafetyViewModelProvider.notifier).getAdminReports();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Support History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
      ),
      body: StreamBuilder<List<TeacherReportModel>>(
        stream: adminStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final adminAlerts = snapshot.data ?? [];

          if (adminAlerts.isEmpty) {
            return const Center(child: Text("No support requests yet"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: adminAlerts.length,
            itemBuilder: (context, index) {
              final report = adminAlerts[index];
              final bool isResolved = report.status.toLowerCase() == 'resolved' ||
                  report.status.toLowerCase() == 'completed';

              return GestureDetector(
                onTap: () => context.pushNamed('teacherAdminDetail', extra: report),
                child: Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    leading: CircleAvatar(
                      backgroundColor: (isResolved ? Colors.green : Colors.orange).withOpacity(0.1),
                      child: Icon(isResolved ? Icons.check_circle : Icons.bug_report,
                          color: isResolved ? Colors.green : Colors.orange),
                    ),
                    title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${report.type} • ${timeago.format(report.timestamp)}"),
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            report.status.toUpperCase(),
                            style: TextStyle(
                                color: isResolved ? Colors.green : Colors.orange,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}