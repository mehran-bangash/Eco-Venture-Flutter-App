import 'package:eco_venture/models/user_model.dart';
import 'package:eco_venture/viewmodels/teacher_student_detail/teacher_student_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudentDetailScreen extends ConsumerWidget {
  final UserModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDetailState = ref.watch(teacherStudentDetailViewModelProvider(student.uid));

    final Color primary = const Color(0xFF1565C0);
    final Color bg = const Color(0xFFF4F7FE);
    final Color textDark = const Color(0xFF1B2559);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER (using passed student data) ---
            _buildHeader(context, primary),

            // --- 2. PERFORMANCE STATS (using ViewModel data) ---
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Learning Overview", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: textDark)),
                  SizedBox(height: 2.h),
                  if (studentDetailState.isLoading)
                    _buildStatsShimmer()
                  else if (studentDetailState.errorMessage != null)
                    Center(child: Text(studentDetailState.errorMessage!))
                  else
                    _buildStatsGrid(studentDetailState.stats),
                ],
              ),
            ),

            // --- 3. RECENT ACTIVITY (using ViewModel data) ---
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
                  if (studentDetailState.isLoading)
                    _buildActivityShimmer()
                  else if (studentDetailState.errorMessage != null)
                    const Center(child: Text("Could not load activities."))
                  else if (studentDetailState.activities.isEmpty)
                    const Center(child: Text("No recent activity found."))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentDetailState.activities.length,
                      itemBuilder: (context, index) {
                        final activity = studentDetailState.activities[index];
                        return _buildActivityItem(
                          activity.title,
                          timeago.format(activity.timestamp),
                          _getIconForActivityType(activity.type),
                          _getColorForActivityType(activity.type),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 3.h),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary) {
    return Container(
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
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
            child: CircleAvatar(
              radius: 38.sp,
              backgroundColor: Colors.white,
              backgroundImage: student.imgUrl != null && student.imgUrl!.isNotEmpty
                  ? NetworkImage(student.imgUrl!)
                  : const AssetImage('assets/images/boy_1.png') as ImageProvider,
              onBackgroundImageError: (_, __) => Icon(Icons.person, size: 40.sp, color: primary),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            student.displayName,
            style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Text(
            "ID: ${student.uid.substring(0, 10)}...", // Displaying a shortened UID for privacy
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard("Total Points", stats.totalPoints.toString(), Icons.star_rounded, Colors.amber),
            SizedBox(width: 4.w),
            _buildStatCard("Quiz Avg", "${stats.quizAverage.toStringAsFixed(1)}%", Icons.pie_chart_rounded, Colors.purple),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildStatCard("QR Finds", "${stats.qrFinds} Items", Icons.qr_code_scanner_rounded, Colors.teal),
            SizedBox(width: 4.w),
            _buildStatCard("STEM Tasks", stats.stemTasksDone.toString(), Icons.science_rounded, Colors.blue),
          ],
        ),
      ],
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
              Text(title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1B2559)), overflow: TextOverflow.ellipsis),
              SizedBox(height: 0.5.h),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[500])),
            ],
          ),
        )
      ],
    );
  }

  IconData _getIconForActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.check_circle;
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'story':
        return Icons.book_rounded;
      case 'stem':
        return Icons.upload_file;
      default:
        return Icons.star;
    }
  }

  Color _getColorForActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Colors.green;
      case 'video':
        return Colors.redAccent;
      case 'story':
        return Colors.blueAccent;
      case 'stem':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(children: [Expanded(child: _shimmerBox()), SizedBox(width: 4.w), Expanded(child: _shimmerBox())]),
          SizedBox(height: 2.h),
          Row(children: [Expanded(child: _shimmerBox()), SizedBox(width: 4.w), Expanded(child: _shimmerBox())]),
        ],
      ),
    );
  }

  Widget _buildActivityShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            children: [
              Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 2.h, width: 60.w, color: Colors.white),
                    SizedBox(height: 1.h),
                    Container(height: 1.5.h, width: 30.w, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget _shimmerBox() => Container(height: 20.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)));
}