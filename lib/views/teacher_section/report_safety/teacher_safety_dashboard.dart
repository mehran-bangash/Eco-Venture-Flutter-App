import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../models/teacher_report_model.dart';
import '../../../viewmodels/teacher_safety_report/teacher_safety_provider.dart';

class TeacherSafetyDashboard extends ConsumerStatefulWidget {
  const TeacherSafetyDashboard({super.key});

  @override
  ConsumerState<TeacherSafetyDashboard> createState() => _TeacherSafetyDashboardState();
}

class _TeacherSafetyDashboardState extends ConsumerState<TeacherSafetyDashboard> {
  final Color _primary = const Color(0xFFD32F2F);
  final Color _secondary = const Color(0xFF1976D2);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  @override
  void initState() {
    super.initState();
    // Trigger a refresh to ensure fresh data is loaded when screen opens
    Future.microtask(() {
      ref.refresh(teacherSafetyViewModelProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherSafetyViewModelProvider);
    final alerts = state.alerts;

    // Stats
    final pendingCount = alerts.where((a) => a.status == 'Pending').length;
    final resolvedCount = alerts.where((a) => a.status == 'Resolved').length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Safety Center",
          style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. OVERVIEW CARDS ---
            Row(
              children: [
                Expanded(child: _buildStatCard("Pending", "$pendingCount", Icons.warning_amber_rounded, Colors.orange)),
                SizedBox(width: 4.w),
                Expanded(child: _buildStatCard("Resolved", "$resolvedCount", Icons.check_circle_outline, Colors.green)),
              ],
            ),
            SizedBox(height: 4.h),

            // --- 2. ACTIONS ---
            Text("Quick Actions", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                    child: _buildActionCard(
                        "Contact Admin",
                        "Report bugs or request features",
                        Icons.admin_panel_settings_rounded,
                        _secondary,
                            () => context.pushNamed('teacherSendReportScreen', extra: {'type': 'Admin'})
                    )
                ),
                SizedBox(width: 3.w),
                Expanded(
                    child: _buildActionCard(
                        "Parent Remarks",
                        "Send progress updates",
                        Icons.family_restroom_rounded,
                        Colors.purple,
                            () => context.pushNamed('teacherSendReportScreen', extra: {'type': 'Parent'})
                    )
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // --- 3. INBOX ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Inbox", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
                if (pendingCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                    decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text("$pendingCount New", style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                  )
              ],
            ),
            SizedBox(height: 2.h),

            if (alerts.isEmpty)
              Center(child: Text("No reports found.", style: GoogleFonts.poppins(color: Colors.grey)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (c, i) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  return _buildAlertTile(alerts[index]);
                },
              ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border(left: BorderSide(color: color, width: 4))),
      child: Row(children: [Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18.sp)), SizedBox(width: 3.w), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _textDark)), Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: _textGrey))])]),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(height: 18.h, padding: EdgeInsets.all(3.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: color.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20.sp)), SizedBox(height: 1.5.h), Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _textDark)), SizedBox(height: 0.5.h), Text(subtitle, style: GoogleFonts.poppins(fontSize: 10.sp, color: _textGrey, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis)])));
  }

  Widget _buildAlertTile(TeacherReportModel alert) {
    bool isPending = alert.status == 'Pending';
    return GestureDetector(
      onTap: () => context.pushNamed('teacherReportDetailScreen', extra: alert),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Row(children: [Container(padding: EdgeInsets.all(2.5.w), decoration: BoxDecoration(color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: Icon(isPending ? Icons.priority_high_rounded : Icons.check_rounded, color: isPending ? Colors.orange : Colors.green, size: 18.sp)), SizedBox(width: 3.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(alert.title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _textDark)), SizedBox(height: 0.5.h), Text("${alert.fromName} • ${timeago.format(alert.timestamp)}", style: GoogleFonts.poppins(fontSize: 11.sp, color: _textGrey))])), Icon(Icons.chevron_right_rounded, color: _textGrey, size: 18.sp)]),
      ),
    );
  }
}