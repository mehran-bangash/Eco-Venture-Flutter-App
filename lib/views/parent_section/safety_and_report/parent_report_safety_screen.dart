
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class ParentReportSafetyScreen extends StatefulWidget {
  const ParentReportSafetyScreen({super.key});

  @override
  State<ParentReportSafetyScreen> createState() => _ParentReportSafetyScreenState();
}

class _ParentReportSafetyScreenState extends State<ParentReportSafetyScreen> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF1E88E5); // Trustworthy Blue
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF263238);
  final Color _textGrey = const Color(0xFF78909C);

  // Mock Data for Dashboard Summary
  final String _childName = "Ali"; // In real app, fetch from selected child
  final String _screenTimeUsed = "1h 45m";
  final String _screenTimeLimit = "2h 00m";
  final int _alertsCount = 2;

  @override
  Widget build(BuildContext context) {
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
          "Safety & Controls",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          // Removed Settings Icon as requested
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SUMMARY DASHBOARD ---
            _buildSummaryHeader(),
            SizedBox(height: 4.h),

            // --- 2. CONTROL MODULES ---
            Text(
              "Controls",
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            SizedBox(height: 2.h),

            // Screen Time Card (Premium Design)
            _buildPremiumControlCard(
              title: "Screen Time",
              subtitle: "Set limits & breaks",
              icon: Icons.hourglass_bottom_rounded,
              gradientColors: [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
              onTap: () {
                // Navigate
                context.goNamed('parentScreenTimeScreen');
              },
              actionText: "Manage",
            ),
            SizedBox(height: 2.5.h),

            // Content Filter Card
            _buildPremiumControlCard(
              title: "Content Filters",
              subtitle: "Block sensitive topics",
              icon: Icons.shield_rounded,
              gradientColors: [const Color(0xFF66BB6A), const Color(0xFF43A047)],
              onTap: () {
                // Navigate
                context.goNamed('parentContentFiltersScreen');
              },
              actionText: "Customize",
            ),
            SizedBox(height: 2.5.h),

            // Reports & Alerts Card
            _buildPremiumControlCard(
              title: "Reports & Alerts",
              subtitle: "View usage logs & alerts",
              icon: Icons.notifications_active_rounded,
              gradientColors: [const Color(0xFFFFA726), const Color(0xFFFB8C00)],
              onTap: () {
                // Navigate
                context.goNamed('parentReportAlertsScreen');
              },
              actionText: _alertsCount > 0 ? "$_alertsCount New Alerts" : "View Report",
              isAlert: _alertsCount > 0,
            ),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSummaryHeader() {
    double progress = 0.75;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22.sp,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.child_care_rounded, color: Colors.white, size: 26.sp),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _childName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0.5.h),
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Active Now",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
                  Text(
                    "Protected",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 3.h),

          // Time Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Daily Usage", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp)),
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(text: _screenTimeUsed, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                      TextSpan(text: " / $_screenTimeLimit", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp)),
                    ]
                ),
              )
            ],
          ),
          SizedBox(height: 1.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 1.2.h,
              backgroundColor: Colors.black.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- ULTRA PRO CARD (RE-DESIGNED) ---
  Widget _buildPremiumControlCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required String actionText,
    bool isAlert = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20.h, // Taller for better layout
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFF8F9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Stack(
          children: [
            // 1. Decorative Background Icon (Faded)
            Positioned(
              right: -20,
              bottom: -20,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  icon,
                  size: 80.sp,
                  color: gradientColors[0].withOpacity(0.05),
                ),
              ),
            ),

            // 2. Main Content
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Container with Gradient
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 26.sp),
                  ),

                  SizedBox(width: 5.w),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: _textGrey,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Arrow / Badge
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAlert)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                              "!",
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 14.sp)
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade600, size: 14.sp),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
