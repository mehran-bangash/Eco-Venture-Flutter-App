import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/child_progress_model.dart';

class QuizCompletionScreen extends StatelessWidget {
  final String correctStr;
  final String totalStr;
  final ChildQuizProgressModel? progress; // Received from previous screen

  const QuizCompletionScreen({
    super.key,
    required this.correctStr,
    required this.totalStr,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Parse numbers
    final int correctAnswers = int.tryParse(correctStr) ?? 0;
    final int totalQuestions = int.tryParse(totalStr) ?? 1;

    // Calculate metrics
    final int wrongAnswers = totalQuestions - correctAnswers;
    final double accuracy = (correctAnswers / totalQuestions) * 100;

    // Determine status from the Progress Model (if available)
    final bool isPassed = progress?.isPassed ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('childQuizTopicDetailScreen');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              children: [
                SizedBox(height: 5.h),
                Text(
                  isPassed ? "Level Complete! 🎉" : "Good Effort! 💪",
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: isPassed ? Colors.deepPurpleAccent : Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 1.h),
                if (isPassed)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      "🔓 Next Level Unlocked",
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),

                SizedBox(height: 4.h),

                // Score Circle
                Container(
                  height: 45.w,
                  width: 45.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPassed ? Colors.deepPurpleAccent : Colors.orangeAccent,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            isPassed ? Icons.emoji_events : Icons.thumb_up,
                            color: isPassed ? Colors.amberAccent : Colors.orangeAccent,
                            size: 10.w
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "$correctAnswers / $totalQuestions",
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${accuracy.toStringAsFixed(0)}%",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Performance Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Summary",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      buildPerformanceRow(
                          Icons.check_circle_outline,
                          "Correct Answers",
                          correctAnswers.toString(),
                          color: Colors.green
                      ),
                      buildPerformanceRow(
                          Icons.cancel_outlined,
                          "Wrong Answers",
                          wrongAnswers.toString(),
                          color: Colors.redAccent
                      ),
                      buildPerformanceRow(
                          Icons.percent,
                          "Accuracy",
                          "${accuracy.toStringAsFixed(0)}%",
                          color: Colors.deepPurpleAccent
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons
                buildGradientButton(
                  text: "Back to Levels",
                  icon: Icons.list_alt_rounded,
                  onPressed: () {
                    context.goNamed('interactiveQuiz');
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gradient Button
  Widget buildGradientButton(
      {required String text, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F00FF).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Performance Row Helper
  Widget buildPerformanceRow(IconData icon, String title, String value, {Color color = Colors.deepPurpleAccent}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 5.w)
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}