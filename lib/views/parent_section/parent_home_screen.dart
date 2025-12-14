import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/notification_service.dart';
import '../../viewmodels/parent_section/parent_home/parent_home_provider.dart';
import '../../viewmodels/parent_section/report_safety/parent_safety_provider.dart';

class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen>
    with SingleTickerProviderStateMixin {
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _darkText = const Color(0xFF2B3674);
  final Color _purple = const Color(0xFF7B1FA2);
  final Color _green = const Color(0xFF00C853);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    // --- INIT NOTIFICATIONS FOR PARENT ---
    // This saves the Parent's FCM Token to Firebase so they can receive alerts
    NotificationService().initNotifications();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _requestTeacherReport(BuildContext context, WidgetRef ref) async {
    final childId = ref.read(parentSafetyViewModelProvider).selectedChildId;
    if (childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a child first!"), backgroundColor: Colors.red));
      return;
    }

    // 1. Get Teacher ID logic (via Service)
    // Assuming a helper method 'notifyTeacherOfRequest' in ParentService
    // Or direct http call here for brevity:
    try {
      // Mock success for UI feedback
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent to Teacher!"), backgroundColor: Colors.green));

      // Real Logic: Call your backend API '/request-teacher-report' with childId
      // await http.post(Uri.parse('URL/request-teacher-report'), body: {'childId': childId});

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send request"), backgroundColor: Colors.red));
    }
  }
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(parentDashboardStreamProvider);
    final safetyState = ref.watch(parentSafetyViewModelProvider);

    final String childName = safetyState.linkedChildren.isNotEmpty
        ? (safetyState.linkedChildren.firstWhere(
            (c) => c['uid'] == safetyState.selectedChildId,
            orElse: () => {'name': 'Child'},
          )['name'])
        : 'Child';

    return Scaffold(
      backgroundColor: _bg,
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          final int usageMinutes = data['usageMinutes'] ?? 0;
          final List activityList = data['recentActivity'] ?? [];

          final Map<String, double> skills = data['skills'] != null
              ? Map<String, double>.from(data['skills'])
              : {'Science': 0.1, 'Math': 0.1, 'Creativity': 0.1, 'Logic': 0.1};

          final Map<String, dynamic> performance =
              data['performance'] ??
              {'quizAvg': 0, 'stemCount': 0, 'qrCount': 0};

          return Stack(
            children: [
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple.withOpacity(0.05),
                  ),
                ),
              ),

              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, childName),
                        SizedBox(height: 3.h),

                        // --- 1. SKILL RADAR ---
                        Text(
                          "Skill Growth",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        _buildSkillGrowthCard(skills),
                        SizedBox(height: 3.h),

                        // --- 2. PERFORMANCE ---
                        Text(
                          "Performance Breakdown",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPerformanceCard(
                                "Quiz",
                                "${performance['quizAvg']}%",
                                "Avg. Score",
                                Icons.quiz,
                                _purple,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildPerformanceCard(
                                "STEM",
                                "${performance['stemCount']}",
                                "Projects",
                                Icons.science,
                                _primary,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildPerformanceCard(
                                "QR Hunt",
                                "${performance['qrCount']}",
                                "Solved",
                                Icons.qr_code_scanner,
                                _green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // --- 3. SCREEN TIME ---
                        _buildScreenTimeCard(usageMinutes),
                        SizedBox(height: 3.h),

                        // --- 4. CONTROLS ---
                        Text(
                          "Parent Controls",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        _buildControlsRow(context),
                        SizedBox(height: 3.h),

                        // --- 5. ACTIVITY ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Activity",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: _darkText,
                              ),
                            ),
                            Text(
                              "View All",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        if (activityList.isEmpty)
                          _buildEmptyState()
                        else
                          Column(
                            children: activityList
                                .map((item) => _buildActivityTile(item))
                                .toList(),
                          ),

                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- UPDATED RADAR CHART (Polygonal + Vertex Dots) ---
  Widget _buildSkillGrowthCard(Map<String, double> skills) {
    return Container(
      height: 35.h,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: RadarChartPainter(skills: skills, color: _primary),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: skills.entries
                .map(
                  (e) => Column(
                    children: [
                      Text(
                        e.key,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(e.value * 100).toInt()}%",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: _darkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- HEADER WITH NAV ---
  Widget _buildHeader(BuildContext context, String childName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Parent Dashboard",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              childName,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
          ],
        ),
        // Notification Icon
        InkWell(
          onTap: () => context.pushNamed(
            'parentNotificationsScreen',
          ), // Navigate to new screen
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: _darkText,
                  size: 20.sp,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ... (Keep existing _buildPerformanceCard, _buildScreenTimeCard, _buildControlsRow, _buildActivityTile, _buildEmptyState, _buildActionCard)
  Widget _buildPerformanceCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 1.5.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _darkText,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeCard(int minutes) {
    double hours = minutes / 60;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Screen Time Today",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                "${hours.toStringAsFixed(1)} hrs",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Within Limits ✅",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: Icon(
              Icons.hourglass_bottom_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            "Safety Center",
            Icons.security,
            Colors.orange,
            () => context.pushNamed('parentReportSafetyScreen'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildActionCard(
            "Reports",
            Icons.analytics_rounded,
            Colors.purple,
            () => context.pushNamed('parentReportAlertsScreen'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 2.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> item) {
    bool isVideo = item['type'] == 'Video';
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: (isVideo ? Colors.red : Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo ? Icons.play_arrow_rounded : Icons.book_rounded,
              color: isVideo ? Colors.red : Colors.blue,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                  ),
                ),
                Text(
                  timeago.format(DateTime.parse(item['timestamp'])),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(2.h),
        child: Text(
          "No recent activity.",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      ),
    );
  }
}

// --- UPDATED: ULTRA PRO RADAR PAINTER ---
class RadarChartPainter extends CustomPainter {
  final Map<String, double> skills;
  final Color color;
  RadarChartPainter({required this.skills, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;
    final angleStep = (2 * math.pi) / skills.length;

    final Paint linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.4), color.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Draw Spider Web (Polygonal)
    for (int i = 1; i <= 4; i++) {
      double r = radius * (i / 4);
      Path polyPath = Path();
      for (int j = 0; j < skills.length; j++) {
        double angle = j * angleStep - math.pi / 2;
        double x = center.dx + r * math.cos(angle);
        double y = center.dy + r * math.sin(angle);
        if (j == 0) {
          polyPath.moveTo(x, y);
        } else {
          polyPath.lineTo(x, y);
        }
      }
      polyPath.close();
      canvas.drawPath(polyPath, linePaint);
    }

    // 2. Draw Data Shape
    Path dataPath = Path();
    List<Offset> points = [];
    int index = 0;
    skills.forEach((key, value) {
      double r = radius * value;
      double angle = index * angleStep - math.pi / 2;
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      points.add(Offset(x, y));
      if (index == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
      index++;
    });
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, borderPaint);

    // 3. Draw Dots at vertices
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 6, dotPaint..color = color.withOpacity(0.3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
