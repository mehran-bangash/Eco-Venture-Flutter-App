import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class ParentReportAlertsScreen extends StatefulWidget {
  const ParentReportAlertsScreen({super.key});

  @override
  State<ParentReportAlertsScreen> createState() => _ParentReportAlertsScreenState();
}

class _ParentReportAlertsScreenState extends State<ParentReportAlertsScreen> {
  // --- COLORS ---
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFF78909C);

  // Mock Data based on your image
  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Content Flag',
      'description': 'Attempted to access restricted content (Horror Genre).',
      'time': '5m ago',
      'icon': Icons.flag_rounded,
      'status': 'Pending',
      'isCritical': true,
    },
    {
      'title': 'Time Limit Reached',
      'description': 'Daily screen time limit has been exceeded.',
      'time': '2h ago',
      'icon': Icons.timer_rounded,
      'status': 'Pending',
      'isCritical': false,
    },
    {
      'title': 'Content Flag',
      'description': 'Viewed a video outside the approved list.',
      'time': '2 days ago',
      'icon': Icons.flag_rounded,
      'status': 'Resolved',
      'isCritical': true,
    },
  ];

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
          "Reports & Alerts",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(5.w),
        itemCount: _alerts.length,
        separatorBuilder: (c, i) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return _buildAlertCard(_alerts[index]);
        },
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    bool isPending = alert['status'] == 'Pending';
    Color statusColor = isPending ? Colors.orange : Colors.green;
    Color iconColor = alert['isCritical'] ? Colors.redAccent : Colors.blue;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(alert['icon'], color: _textGrey, size: 18.sp), // Muted icon color like image
                  SizedBox(width: 2.w),
                  Text(
                    alert['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              Text(
                alert['time'],
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: _textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // Description
          Text(
            alert['description'],
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: const Color(0xFF546E7A), // Blue-Grey for text body
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),

          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alert['status'],
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),

              // Review Button (Only if Pending)
              if (isPending)
                ElevatedButton(
                  onPressed: () {
                    // Handle Review Logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5), // Blue Button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    elevation: 0,
                  ),
                  child: Text(
                    "Review Now",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}