import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class ClassReportScreen extends StatelessWidget {
  const ClassReportScreen({super.key});

  // --- COLORS ---
  final Color _primary = const Color(0xFF00C853); // Success Green Theme
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Class Analytics",
          style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SUMMARY CARDS ---
            Row(
              children: [
                _buildSummaryCard("Avg Score", "82%", Icons.pie_chart_rounded, Colors.blue),
                SizedBox(width: 4.w),
                // REPLACED ACTIVE WITH COMPLETION RATE
                _buildSummaryCard("Completion", "88%", Icons.check_circle_rounded, Colors.orange),
              ],
            ),
            SizedBox(height: 2.h),

            // Full width card for tasks
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primary, const Color(0xFF00E676)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.task_alt_rounded, color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 4.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Submissions", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                      Text("142 Tasks", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text("+12 Today", style: GoogleFonts.poppins(color: _primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                  )
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // --- 2. WEEKLY PERFORMANCE CHART ---
            Text("Weekly Learning Progress", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 2.h),
            Container(
              height: 25.h,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBarDay("Quiz", 0.7, Colors.blue),
                  _buildBarDay("STEM", 0.5, Colors.purple),
                  _buildBarDay("Videos", 0.8, Colors.redAccent),
                  _buildBarDay("QR", 0.4, Colors.teal),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // --- 3. NEEDS ATTENTION (Focus on Scores/Tasks) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Needs Attention ⚠️", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark)),
                Text("View All", style: GoogleFonts.poppins(fontSize: 12.sp, color: _primary, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 2.h),
            _buildStudentAlertCard("Ahmed Ali", "Failed 'Solar System' Quiz", "assets/images/boy_1.png"),
            SizedBox(height: 1.5.h),
            _buildStudentAlertCard("Sarah Khan", "Missed 'Water Filter' Task", "assets/images/girl_1.png"),

            SizedBox(height: 4.h),

            // --- 4. TOP PERFORMERS (Points Based) ---
            Text("Top Learners ⭐", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 2.h),
            _buildTopPerformerCard(1, "Zain Malik", "1,450 pts", "assets/images/boy_2.png"),
            SizedBox(height: 1.5.h),
            _buildTopPerformerCard(2, "Fatima Noor", "1,320 pts", "assets/images/girl_2.png"),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                Spacer(),
                Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 14.sp),
                Text(" 5%", style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(value, style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _textDark)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, color: _textGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarDay(String label, double pct, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 4.w,
          height: 15.h * pct,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        ),
        SizedBox(height: 1.h),
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: _textGrey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStudentAlertCard(String name, String issue, String avatar) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: Colors.redAccent, width: 4)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.sp,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: AssetImage(avatar),
            onBackgroundImageError: (_,__) => const Icon(Icons.person),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _textDark)),
                Text(issue, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text("Review", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTopPerformerCard(int rank, String name, String points, String avatar) {
    Color rankColor = rank == 1 ? Colors.amber : Colors.grey.shade400;
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Text("#$rank", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w900, color: rankColor)),
          SizedBox(width: 3.w),
          CircleAvatar(
            radius: 20.sp,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: AssetImage(avatar),
            onBackgroundImageError: (_,__) => const Icon(Icons.person),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _textDark)),
                Text("Star Student", style: GoogleFonts.poppins(fontSize: 11.sp, color: _textGrey)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14.sp),
                SizedBox(width: 1.w),
                Text(points, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}