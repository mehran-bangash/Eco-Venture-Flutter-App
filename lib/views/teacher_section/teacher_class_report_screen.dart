import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/teacher_class_report_model.dart';
import '../../viewmodels/teacher_class_report/teacher_class_report_provider.dart';


class TeacherClassReportScreen extends ConsumerWidget {
  const TeacherClassReportScreen({super.key});

  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _green = const Color(0xFF00C853);
  final Color _purple = const Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherClassReportViewModelProvider);
    final report = state.report ?? TeacherClassReportModel.empty();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Class Performance", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _textDark), onPressed: () => context.pop()),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(report),
            SizedBox(height: 3.h),
            Text("Activity Breakdown", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(child: _buildStatCard("Quizzes Passed", "${report.totalQuizzesPassed}", Icons.quiz, _purple)),
                SizedBox(width: 3.w),
                Expanded(child: _buildStatCard("STEM Projects", "${report.totalStemSubmissions}", Icons.science, _primary)),
                SizedBox(width: 3.w),
                Expanded(child: _buildStatCard("QR Hunts", "${report.totalQrHuntsSolved}", Icons.qr_code_scanner, _green)),
              ],
            ),
            SizedBox(height: 4.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Student Rankings", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
              Text("Total XP", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
            ]),
            SizedBox(height: 2.h),
            if (report.studentRankings.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.studentRankings.length,
                itemBuilder: (context, index) {
                  return _buildStudentRankTile(index + 1, report.studentRankings[index]);
                },
              ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TeacherClassReportModel report) {
    // FIX: Normalize value for progress bar (Assume max avg is 2000 for full bar visual, or just clamp)
    double progress = (report.classAverageScore / 2000).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primary, const Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Total Students", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp)),
              Text("${report.totalStudents}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
            ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [Icon(Icons.emoji_events, color: Colors.amber, size: 16.sp), SizedBox(width: 1.w), Text("Top Class", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold))]),
            )
          ]),
          SizedBox(height: 2.h),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Class Average XP", style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.sp)),
              // FIX: Removed % symbol, showing raw Avg Score
              Text("${report.classAverageScore.toInt()} XP", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
            ]),
            SizedBox(height: 1.h),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 0.8.h, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation(Colors.lightGreenAccent))),
          ])
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18.sp)),
        SizedBox(height: 1.h),
        Text(value, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textDark)),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildStudentRankTile(int rank, StudentRankItem student) {
    Color rankColor = Colors.grey.shade100;
    Color iconColor = Colors.grey;
    if (rank == 1) { rankColor = const Color(0xFFFFD700).withOpacity(0.2); iconColor = const Color(0xFFFFD700); }
    else if (rank == 2) { rankColor = const Color(0xFFC0C0C0).withOpacity(0.2); iconColor = const Color(0xFFC0C0C0); }
    else if (rank == 3) { rankColor = const Color(0xFFCD7F32).withOpacity(0.2); iconColor = const Color(0xFFCD7F32); }

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle), child: Center(child: Text("#$rank", style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 11.sp)))),
        SizedBox(width: 3.w),
        CircleAvatar(backgroundColor: _primary.withOpacity(0.1), backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null, child: student.avatarUrl == null ? Icon(Icons.person, color: _primary, size: 16.sp) : null),
        SizedBox(width: 3.w),
        Expanded(child: Text(student.name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _textDark))),
        Container(padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text("${student.totalPoints} XP", style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: _primary)))
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(padding: EdgeInsets.all(4.w), width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(Icons.group_off_rounded, size: 30.sp, color: Colors.grey.shade300), SizedBox(height: 1.h), Text("No students or activity found yet.", style: GoogleFonts.poppins(color: Colors.grey))]));
  }
}