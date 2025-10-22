import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QuizCompletionScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const QuizCompletionScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final int wrongAnswers = totalQuestions - correctAnswers;
    final double accuracy = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Text(
                "Quiz Complete! 🎉",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(height: 5.h),

              // Score Circle
              Container(
                height: 30.w,
                width: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepPurpleAccent,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events,
                          color: Colors.amberAccent, size: 8.w),
                      SizedBox(height: 1.h),
                      Text(
                        "$correctAnswers/$totalQuestions",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${accuracy.toStringAsFixed(0)}%",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Tags Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTag("⭐ Great Job"),
                  SizedBox(width: 3.w),
                  buildTag("⚡ Speed Demon"),
                ],
              ),

              SizedBox(height: 5.h),

              // Performance Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Performance",
                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    buildPerformanceRow(Icons.check_circle_outline,
                        "Correct Answers", correctAnswers.toString()),
                    buildPerformanceRow(Icons.cancel_outlined, "Wrong Answers",
                        wrongAnswers.toString(),
                        color: Colors.redAccent),
                    buildPerformanceRow(Icons.percent, "Accuracy",
                        "${accuracy.toStringAsFixed(0)}%"),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              buildGradientButton(
                text: "New Quiz",
                icon: Icons.quiz_outlined,
                onPressed: () {
                  context.goNamed('interactiveQuiz');
                },
              ),
              SizedBox(height: 1.5.h),
              buildOutlinedButton(
                text: "Try Again",
                icon: Icons.refresh,
                onPressed: () {
                  context.pushReplacementNamed('quizQuestionScreen');
                },

              ),
              SizedBox(height: 2.h),
            ],
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
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Outlined Button
  Widget buildOutlinedButton(
      {required String text, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.deepPurpleAccent),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Tag Chip
  Widget buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Performance Row
  Widget buildPerformanceRow(IconData icon, String title, String value,
      {Color color = Colors.deepPurpleAccent}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 5.w),
            SizedBox(width: 2.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
          ]),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
