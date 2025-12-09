import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/child_report_model.dart';
import '../../../viewmodels/child_view_model/report_safety/child_safety_provider.dart';

class ChildSafetyDashboard extends ConsumerStatefulWidget {
  const ChildSafetyDashboard({super.key});

  @override
  ConsumerState<ChildSafetyDashboard> createState() =>
      _ChildSafetyDashboardState();
}

class _ChildSafetyDashboardState extends ConsumerState<ChildSafetyDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Load Reports Logic
    Future.microtask(
      () => ref.read(childReportViewModelProvider.notifier).loadReports(),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Helper: Minutes to "1h 20m"
  String _formatMinutes(int minutes) {
    if (minutes <= 0) return "0m";
    int h = minutes ~/ 60;
    int m = minutes % 60;
    if (h > 0) return "${h}h ${m}m";
    return "${m}m";
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch Reports List
    final reportState = ref.watch(childReportViewModelProvider);
    final reports = reportState.reports;

    // 2. Watch Parent Settings (To get the Limit)
    final settingsAsync = ref.watch(childSafetySettingsProvider);

    // 3. Watch Live Usage (To get Minutes Used)
    final usageAsync = ref.watch(childUsageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowCircle(Colors.blue, 300),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildGlowCircle(Colors.purple, 300),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "Safety Center",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // --- REAL TIME INDICATOR ---
                  settingsAsync.when(
                    loading: () => _buildLoadingCircle(),
                    error: (err, stack) => Center(
                      child: Text(
                        "Error loading settings",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    data: (settings) {
                      return usageAsync.when(
                        loading: () =>
                            _buildLoadingCircle(), // Wait for usage to load
                        error: (_, __) => Text("Error usage"),
                        data: (usedMinutes) {
                          // CALCULATE REMAINING TIME
                          final int totalLimitMinutes =
                              (settings.dailyLimitHours * 60).round();
                          int remainingMinutes =
                              totalLimitMinutes - usedMinutes;
                          if (remainingMinutes < 0) remainingMinutes = 0;

                          // Progress for Circle (1.0 = Full Time Left, 0.0 = Time Up)
                          final double progress = totalLimitMinutes == 0
                              ? 0.0
                              : (remainingMinutes / totalLimitMinutes).clamp(
                                  0.0,
                                  1.0,
                                );

                          final bool isPaused = settings.isAppPaused;
                          final bool isTimeUp = remainingMinutes <= 0;

                          Color statusColor = const Color(0xFF00E5FF);
                          if (isPaused) {
                            statusColor = Colors.red;
                          } else if (isTimeUp)
                            statusColor = Colors.orange;

                          return Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse Effect (Only if active)
                                if (!isPaused && !isTimeUp)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 65.w,
                                        height: 65.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: statusColor.withOpacity(
                                                0.2 * _pulseController.value,
                                              ),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                // Progress Circle
                                SizedBox(
                                  width: 60.w,
                                  height: 60.w,
                                  child: CircularProgressIndicator(
                                    value: progress, // Updates every minute
                                    strokeWidth: 15,
                                    backgroundColor: Colors.white10,
                                    valueColor: AlwaysStoppedAnimation(
                                      statusColor,
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),

                                // Text Info
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPaused
                                          ? Icons.pause_circle_filled
                                          : (isTimeUp
                                                ? Icons.hourglass_empty
                                                : Icons.timer_rounded),
                                      color: statusColor,
                                      size: 24.sp,
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      isPaused
                                          ? "PAUSED"
                                          : (isTimeUp
                                                ? "TIME'S UP"
                                                : _formatMinutes(
                                                    remainingMinutes,
                                                  )),
                                      style: GoogleFonts.poppins(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      isPaused
                                          ? "By Parent"
                                          : "Remaining Today",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  SizedBox(height: 6.h),

                  // Report Button
                  GestureDetector(
                    onTap: ()async {
                      context.pushNamed('childReportIssueScreen');
                      final String? role=await SharedPreferencesHelper.instance.getUserRole();
                      print( "$role");
                    },

                    child: Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Report an Issue",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Tell us if something is wrong",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white54,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    "Recent Reports",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Reports List
                  Expanded(
                    child: reportState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : reports.isEmpty
                        ? Center(
                            child: Text(
                              "No reports yet. Stay safe!",
                              style: GoogleFonts.poppins(color: Colors.white30),
                            ),
                          )
                        : ListView.separated(
                            itemCount: reports.length,
                            separatorBuilder: (c, i) => SizedBox(height: 2.h),
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return _buildReportCard(report);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCircle() {
    return Container(
      height: 30.h,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.cyan),
    );
  }

  Widget _buildReportCard(ChildReportModel report) {
    bool isResolved = report.status == 'Resolved';
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_rounded,
            color: isResolved ? Colors.green : Colors.orange,
            size: 20.sp,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.contentTitle ?? report.issueType,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "To: ${report.recipient} • ${timeago.format(report.timestamp)}",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: isResolved
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              report.status,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: isResolved ? Colors.greenAccent : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
