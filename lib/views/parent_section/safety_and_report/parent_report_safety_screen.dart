import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../viewmodels/parent_section/report_safety/parent_safety_provider.dart';

// --- LIVE STREAM PROVIDER ---
// Fetches 'child_usage_stats/{childId}/daily'
final childUsageStreamProvider = StreamProvider.autoDispose.family<int, String>((ref, childId) {
  return FirebaseDatabase.instance
      .ref('child_usage_stats/$childId/daily')
      .onValue
      .map((event) {
    return (event.snapshot.value as int?) ?? 0;
  });
});

class ParentReportSafetyScreen extends ConsumerStatefulWidget {
  const ParentReportSafetyScreen({super.key});

  @override
  ConsumerState<ParentReportSafetyScreen> createState() => _ParentReportSafetyScreenState();
}

class _ParentReportSafetyScreenState extends ConsumerState<ParentReportSafetyScreen> {
  final Color _primary = const Color(0xFF1E88E5);
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF263238);
  final Color _textGrey = const Color(0xFF78909C);

  @override
  Widget build(BuildContext context) {
    // 1. Get Settings & Alerts
    final state = ref.watch(parentSafetyViewModelProvider);
    final settings = state.settings;

    // 2. Get Child Name & ID
    final String childName = _getChildName(state.selectedChildId, state.linkedChildren);
    final int alertsCount = state.alerts.where((a) => a.status == 'Pending').length;
    final String timeLimitStr = _formatHours(settings.dailyLimitHours);

    // 3. FETCH LIVE USAGE
    final AsyncValue<int> usageAsync = state.selectedChildId != null
        ? ref.watch(childUsageStreamProvider(state.selectedChildId!))
        : const AsyncData(0);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp), onPressed: () => context.pop()),
        centerTitle: true,
        title: Text("Safety & Controls", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUMMARY CARD (Live Data)
            usageAsync.when(
              data: (usedMinutes) {
                double limitMinutes = settings.dailyLimitHours * 60;
                double progress = limitMinutes > 0 ? (usedMinutes / limitMinutes).clamp(0.0, 1.0) : 0.0;

                return _buildSummaryHeader(
                    childName,
                    _formatMinutes(usedMinutes), // REAL TIME from Firebase
                    timeLimitStr,
                    progress,
                    settings.isAppPaused
                );
              },
              loading: () => _buildSummaryHeader(childName, "...", timeLimitStr, 0.0, settings.isAppPaused),
              error: (_,__) => _buildSummaryHeader(childName, "0m", timeLimitStr, 0.0, settings.isAppPaused),
            ),

            SizedBox(height: 4.h),
            Text("Controls", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 2.h),

            _buildPremiumControlCard("Screen Time", "Limit: $timeLimitStr", Icons.hourglass_bottom_rounded, [const Color(0xFF42A5F5), const Color(0xFF1E88E5)], () => context.pushNamed('parentScreenTimeScreen'), "Manage"),
            SizedBox(height: 2.5.h),
            _buildPremiumControlCard("Content Filters", settings.blockScaryContent ? "Strict Mode" : "Standard", Icons.shield_rounded, [const Color(0xFF66BB6A), const Color(0xFF43A047)], () => context.pushNamed('parentContentFiltersScreen'), "Customize"),
            SizedBox(height: 2.5.h),
            _buildPremiumControlCard("Reports & Alerts", alertsCount > 0 ? "Attention Needed" : "All Clear", Icons.notifications_active_rounded, [const Color(0xFFFFA726), const Color(0xFFFB8C00)], () => context.pushNamed('parentReportAlertsScreen'), alertsCount > 0 ? "$alertsCount New" : "View", isAlert: alertsCount > 0),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _getChildName(String? id, List<Map<String, dynamic>> children) {
    if (id == null) return "Child";
    final child = children.firstWhere((c) => c['uid'] == id, orElse: () => {});
    return child['name'] ?? "Child";
  }

  String _formatHours(double value) {
    int hours = value.floor();
    int minutes = ((value - hours) * 60).round();
    if (minutes == 0) return "${hours}h";
    return "${hours}h ${minutes}m";
  }

  String _formatMinutes(int totalMinutes) {
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    if (h == 0) return "${m}m";
    return "${h}h ${m}m";
  }

  Widget _buildSummaryHeader(String name, String used, String limit, double progress, bool isPaused) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [_primary, const Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: CircleAvatar(radius: 22.sp, backgroundColor: Colors.white.withOpacity(0.2), child: Icon(Icons.child_care_rounded, color: Colors.white, size: 26.sp))), SizedBox(width: 3.w), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)), Container(margin: EdgeInsets.only(top: 0.5.h), padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h), decoration: BoxDecoration(color: isPaused ? Colors.redAccent : Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(isPaused ? "Paused" : "Active", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w500)))])]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp), Text("Protected", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp))])
        ]),
        SizedBox(height: 3.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Daily Usage", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp)), RichText(text: TextSpan(children: [TextSpan(text: used, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)), TextSpan(text: " / $limit", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp))]))]),
        SizedBox(height: 1.5.h),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 1.2.h, backgroundColor: Colors.black.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
      ]),
    );
  }

  Widget _buildPremiumControlCard(String title, String subtitle, IconData icon, List<Color> gradientColors, VoidCallback onTap, String actionText, {bool isAlert = false}) {
    return GestureDetector(onTap: onTap, child: Container(height: 20.h, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF8F9FF)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 2)], border: Border.all(color: Colors.white, width: 2)), child: Stack(children: [Positioned(right: -20, bottom: -20, child: Transform.rotate(angle: -0.2, child: Icon(icon, size: 80.sp, color: gradientColors[0].withOpacity(0.05)))), Padding(padding: EdgeInsets.all(5.w), child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Container(padding: EdgeInsets.all(4.w), decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))]), child: Icon(icon, color: Colors.white, size: 26.sp)), SizedBox(width: 5.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _textDark)), SizedBox(height: 0.5.h), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12.sp, color: _textGrey, height: 1.4, fontWeight: FontWeight.w500))])), Column(mainAxisAlignment: MainAxisAlignment.center, children: [if (isAlert) Container(padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.redAccent.withOpacity(0.3))), child: Text("!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 14.sp))) else Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade600, size: 14.sp))])]))])));
  }
}