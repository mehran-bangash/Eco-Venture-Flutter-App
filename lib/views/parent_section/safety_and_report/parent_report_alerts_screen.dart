import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/parent_alert_model.dart';
import '../../../viewmodels/parent_section/report_safety/parent_safety_provider.dart'; // Add this package to pubspec


class ParentReportAlertsScreen extends ConsumerWidget {
  const ParentReportAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentSafetyViewModelProvider);
    final alerts = state.alerts;

    final Color _bg = const Color(0xFFF5F7FA);
    final Color _textDark = const Color(0xFF1B2559);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp), onPressed: () => context.pop()),
        centerTitle: true,
        title: Text("Reports & Alerts", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp)),
      ),
      body: alerts.isEmpty
          ? Center(child: Text("No alerts found.", style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.separated(
        padding: EdgeInsets.all(5.w),
        itemCount: alerts.length,
        separatorBuilder: (c, i) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return _buildAlertCard(context, ref, alerts[index]);
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, ParentAlertModel alert) {
    bool isPending = alert.status == 'Pending';
    Color statusColor = isPending ? Colors.orange : Colors.green;

    // Determine Icon
    IconData icon = Icons.notifications;
    if(alert.title.contains("Content")) {
      icon = Icons.flag_rounded;
    } else if(alert.title.contains("Time")) icon = Icons.timer_rounded;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))], border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(icon, color: Colors.grey, size: 18.sp), SizedBox(width: 2.w), Text(alert.title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B2559)))]), Text(timeago.format(alert.timestamp), style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey, fontWeight: FontWeight.w500))]),
          SizedBox(height: 1.5.h),
          Text(alert.description, style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF546E7A), height: 1.5)),
          SizedBox(height: 3.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(alert.status, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11.sp))),
            if (isPending) ElevatedButton(onPressed: () {
              // Mark Resolved Logic
              ref.read(parentSafetyViewModelProvider.notifier).markAlertResolved(alert.id);
            }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h), elevation: 0), child: Text("Mark Resolved", style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white)))
          ]),
        ],
      ),
    );
  }
}