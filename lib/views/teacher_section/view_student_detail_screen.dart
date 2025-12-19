import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../viewmodels/teacher_student_detail/teacher_student_detail_provider.dart';

class ViewStudentDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> studentData;
  const ViewStudentDetailScreen({super.key, required this.studentData});

  @override
  ConsumerState<ViewStudentDetailScreen> createState() =>
      _ViewStudentDetailScreenState();
}

class _ViewStudentDetailScreenState
    extends ConsumerState<ViewStudentDetailScreen> {
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);

  // --- COLORS FOR STATUS ---
  final Color _green = const Color(0xFF00C853);
  final Color _red = const Color(0xFFE53935);
  final Color _blue = const Color(0xFF2979FF);
  final Color _amber = const Color(0xFFFFAB00);

  @override
  void initState() {
    super.initState();
    final String uid = widget.studentData['uid'];
    Future.microtask(
      () => ref
          .read(teacherStudentDetailViewModelProvider.notifier)
          .loadStudent(uid),
    );
  }

  // --- UPDATED REVIEW DIALOG ---
  // void _showReviewDialog(Map<String, dynamic> activity) {
  //   if (activity['type'] != 'STEM') return;
  //
  //   final TextEditingController feedbackCtrl = TextEditingController();
  //   final TextEditingController pointsCtrl = TextEditingController(text: "50");
  //
  //   final submissionData = activity['data'] as Map<String, dynamic>;
  //   final String status = submissionData['status'] ?? 'pending';
  //
  //   /// ✅ FIX: Collect ALL image URLs
  //   final List<String> imageUrls = [];
  //
  //   void extractImages(dynamic imgs) {
  //     if (imgs is List) {
  //       for (var img in imgs) {
  //         if (img != null) imageUrls.add(img.toString());
  //       }
  //     } else if (imgs is String) {
  //       imageUrls.add(imgs);
  //     }
  //   }
  //
  //   if (submissionData['proofImageUrls'] != null) {
  //     extractImages(submissionData['proofImageUrls']);
  //   }
  //
  //   if (submissionData['proof_image_urls'] != null) {
  //     extractImages(submissionData['proof_image_urls']);
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       scrollable: true,
  //       title: Text(
  //         "Review Submission",
  //         style: GoogleFonts.poppins(
  //           fontWeight: FontWeight.bold,
  //           fontSize: 18.sp,
  //         ),
  //       ),
  //       content: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           // Challenge Title
  //           Text(
  //             "Challenge:",
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 13.sp,
  //               color: Colors.grey[700],
  //             ),
  //           ),
  //           Text(
  //             "${submissionData['challenge_title'] ?? 'Unknown'}",
  //             style: GoogleFonts.poppins(
  //               fontSize: 15.sp,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //
  //           SizedBox(height: 2.h),
  //
  //           /// ✅ FIXED: MULTIPLE IMAGES VIEW
  //           if (imageUrls.isNotEmpty)
  //             SizedBox(
  //               height: 20.h,
  //               child: ListView.separated(
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: imageUrls.length,
  //                 separatorBuilder: (_, __) => SizedBox(width: 3.w),
  //                 itemBuilder: (context, index) {
  //                   return ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Image.network(
  //                       imageUrls[index],
  //                       width: 70.w,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (c, e, s) => Container(
  //                         width: 70.w,
  //                         color: Colors.grey[200],
  //                         child: const Center(child: Icon(Icons.broken_image)),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             )
  //           else
  //             Container(
  //               height: 15.h,
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Center(child: Text("No Image Uploaded")),
  //             ),
  //
  //           SizedBox(height: 2.h),
  //
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.calendar_today_rounded,
  //                 size: 14.sp,
  //                 color: Colors.blue,
  //               ),
  //               SizedBox(width: 2.w),
  //               Text(
  //                 "Days Taken: ${submissionData['days_taken'] ?? 'N/A'}",
  //                 style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
  //               ),
  //             ],
  //           ),
  //
  //           SizedBox(height: 3.h),
  //
  //           if (status == 'pending') ...[
  //             Text(
  //               "Award Points",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 13.sp,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //             SizedBox(height: 1.h),
  //             TextField(
  //               controller: pointsCtrl,
  //               keyboardType: TextInputType.number,
  //               decoration: InputDecoration(
  //                 hintText: "50",
  //                 contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 suffixText: "XP",
  //               ),
  //             ),
  //             SizedBox(height: 2.h),
  //
  //             Text(
  //               "Feedback",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 13.sp,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //             SizedBox(height: 1.h),
  //             TextField(
  //               controller: feedbackCtrl,
  //               maxLines: 2,
  //               decoration: InputDecoration(
  //                 hintText: "Great job! / Try again...",
  //                 contentPadding: EdgeInsets.all(4.w),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 filled: true,
  //                 fillColor: const Color(0xFFF5F7FA),
  //               ),
  //             ),
  //           ] else ...[
  //             Container(
  //               padding: EdgeInsets.all(3.w),
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: status == 'approved'
  //                     ? _green.withOpacity(0.1)
  //                     : _red.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(
  //                   color: status == 'approved' ? _green : _red,
  //                 ),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Text(
  //                     "Status: ${status.toUpperCase()}",
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: status == 'approved' ? _green : _red,
  //                     ),
  //                   ),
  //                   if (status == 'approved')
  //                     Text(
  //                       "+${submissionData['points_awarded']} XP Awarded",
  //                       style: TextStyle(color: _green),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text("Close", style: TextStyle(color: Colors.grey)),
  //         ),
  //         if (status == 'pending') ...[
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: _red,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             onPressed: () {
  //               ref
  //                   .read(teacherStudentDetailViewModelProvider.notifier)
  //                   .markStemSubmission(
  //                     studentId: widget.studentData['uid'],
  //                     challengeId: submissionData['challenge_id'].toString(),
  //                     approved: false,
  //                     points: 0,
  //                     feedback: feedbackCtrl.text.isEmpty
  //                         ? "Try again."
  //                         : feedbackCtrl.text,
  //                   );
  //               Navigator.pop(ctx);
  //             },
  //             child: const Text(
  //               "Reject",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: _green,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             onPressed: () {
  //               int pts = int.tryParse(pointsCtrl.text) ?? 50;
  //               ref
  //                   .read(teacherStudentDetailViewModelProvider.notifier)
  //                   .markStemSubmission(
  //                     studentId: widget.studentData['uid'],
  //                     challengeId: submissionData['challenge_id'].toString(),
  //                     approved: true,
  //                     points: pts,
  //                     feedback: feedbackCtrl.text.isEmpty
  //                         ? "Great work!"
  //                         : feedbackCtrl.text,
  //                   );
  //               Navigator.pop(ctx);
  //             },
  //             child: const Text(
  //               "Approve",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherStudentDetailViewModelProvider);
    final student = state.student;

    if (state.isLoading || student == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Student Profile",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            _buildProfileBanner(
              student.name,
              student.email,
              student.currentLevel,
            ),
            SizedBox(height: 3.h),
            _buildStatsGrid(
              student.totalXP,
              student.quizzesPassed,
              student.stemApproved,
              student.qrHuntsCompleted,
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Activity History",
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            if (student.recentActivity.isEmpty)
              Container(
                padding: EdgeInsets.all(5.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "No activity recorded yet.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: student.recentActivity.length,
                itemBuilder: (context, index) {
                  final item = student.recentActivity[index];
                  return _buildActivityTile(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildProfileBanner(String name, String email, int level) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.sp,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Level $level",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int xp, int quiz, int stem, int qr) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("XP", "$xp", Icons.star, _amber)),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            "Quiz",
            "$quiz",
            Icons.quiz,
            Colors.purpleAccent,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(child: _buildStatCard("STEM", "$stem", Icons.science, _blue)),
      ],
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(
            val,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: _textDark,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final String title = activity['title'].toString();
    final bool isSubmission = activity['type'] == 'STEM';

    // Extract status safely
    final String status =
        activity['subtitle']?.toString().toLowerCase() ?? '';

    final bool isPendingOrRejected =
        status.contains('pending') || status.contains('rejected');

    // Status UI logic (UNCHANGED)
    bool isPositive = activity['isPositive'] == true;
    Color statusColor = isPositive ? _green : _red;
    IconData icon =
    isPositive ? Icons.check_circle_rounded : Icons.cancel_rounded;

    if (isSubmission) {
      if (status.contains('pending')) {
        statusColor = _amber;
        icon = Icons.hourglass_bottom_rounded;
      } else if (status.contains('approved')) {
        statusColor = _green;
        icon = Icons.check_circle_rounded;
      } else {
        statusColor = _blue;
        icon = Icons.assignment_ind_rounded;
      }
    }

    String subtitle = activity['subtitle'] ?? '';
    if (subtitle.isEmpty && activity['score'] != null) {
      subtitle = activity['score'];
    }

    return GestureDetector(
      onTap: (isSubmission && isPendingOrRejected)
          ? () {
        context.goNamed(
          'teacherStemApprovedScreen',
          extra: {
            'studentId': widget.studentData['uid'],
            'activity': activity,
          },
        );
      }
          : null,

      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor, size: 18.sp),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12.sp, color: Colors.grey),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          "${timeago.format(DateTime.parse(activity['time']))}"
                              "${subtitle.isNotEmpty ? ' • $subtitle' : ''}",
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSubmission)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}
