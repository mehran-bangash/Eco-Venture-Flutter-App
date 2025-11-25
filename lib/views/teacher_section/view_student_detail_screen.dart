import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StudentDetailScreen extends StatelessWidget {

  final Map<String, dynamic> studentData;

  const StudentDetailScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF1565C0);
    final Color bg = const Color(0xFFF4F7FE);
    final Color textDark = const Color(0xFF1B2559);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. ULTRA PRO HEADER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 6.h, bottom: 5.h, left: 5.w, right: 5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text("Student Profile", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp)),
                      IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: Colors.white, size: 22.sp)),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Profile Image
                  Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                    child: CircleAvatar(
                      radius: 38.sp,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(studentData['avatar'] ?? 'assets/images/boy_1.png'),
                      onBackgroundImageError: (_,__) => Icon(Icons.person, size: 40.sp, color: primary),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Name
                  Text(
                    studentData['name'] ?? "Student Name",
                    style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    "ID: ST-2024-001 • Adventure Class 4B",
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),

            // --- 2. PERFORMANCE STATS (No Attendance) ---
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Learning Overview", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: textDark)),
                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      _buildStatCard("Total Points", "1,250", Icons.star_rounded, Colors.amber),
                      SizedBox(width: 4.w),
                      _buildStatCard("Quiz Avg", "85%", Icons.pie_chart_rounded, Colors.purple),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _buildStatCard("Tasks Done", "12", Icons.task_alt_rounded, Colors.green),
                      SizedBox(width: 4.w),
                      // REPLACED ATTENDANCE WITH QR FINDS
                      _buildStatCard("QR Finds", "8 Items", Icons.qr_code_scanner_rounded, Colors.teal),
                    ],
                  ),
                ],
              ),
            ),

            // --- 3. RECENT ACTIVITY (Learning Only) ---
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recent Activity", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: textDark)),
                  SizedBox(height: 2.5.h),
                  _buildActivityItem("Completed 'Solar System' Quiz", "Yesterday, 10:30 AM", Icons.check_circle, Colors.green),
                  Divider(color: Colors.grey.shade100, height: 3.h),
                  _buildActivityItem("Submitted 'Water Filter' Task", "2 days ago", Icons.upload_file, Colors.orange),
                  Divider(color: Colors.grey.shade100, height: 3.h),
                  // REPLACED "Joined Class" WITH "Watched Video"
                  _buildActivityItem("Watched 'Life of Plants'", "3 days ago", Icons.play_circle_fill_rounded, Colors.redAccent),
                ],
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(4.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 2.h),
            Text(value, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B2559))),
            Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1B2559))),
              SizedBox(height: 0.5.h),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[500])),
            ],
          ),
        )
      ],
    );
  }
}