import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../models/child/child_progress_model.dart';

class QuizCompletionScreen extends StatelessWidget {
  final String correctStr;
  final String totalStr;
  final ChildQuizProgressModel? progress;

  const QuizCompletionScreen({
    super.key,
    required this.correctStr,
    required this.totalStr,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final int correctAnswers = int.tryParse(correctStr) ?? 0;
    final int totalQuestions = int.tryParse(totalStr) ?? 1;
    final double accuracy = (correctAnswers / totalQuestions) * 100;
    final bool isPassed = progress?.isPassed ?? false;

    final String title = isPassed ? "WOOHOO! 🎉" : "SO CLOSE! 💪";
    final String subtitle = isPassed
        ? "You did an amazing job! You're a superstar."
        : "Don't give up! Practice makes perfect.";
    final Color primaryColor = isPassed
        ? Colors.deepPurpleAccent
        : Colors.orangeAccent;

    // Updated stable Lottie URLs
    const String successAnim =
        'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json'; // Stable fallback
    const String failAnim =
        'https://assets10.lottiefiles.com/packages/lf20_0yfs998p.json';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('interactiveQuiz');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            if (isPassed)
              Align(
                alignment: Alignment.topCenter,
                child: Lottie.network(
                  'https://lottie.host/7905156a-1e65-4f4a-8d19-497746401625/6Q7LpQ484Z.json', // Stable Confetti
                  height: 50.h,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Center(
                      child: Column(
                        children: [
                          if (!isPassed)
                            Lottie.network(
                              'https://lottie.host/86f56c70-6537-4d00-a92c-566089d7990d/67D3v18eI5.json', // Stable Support Anim
                              height: 20.h,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 15.h,
                                    color: primaryColor,
                                  ),
                            ),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Result Card
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 35.w,
                                width: 35.w,
                                child: CircularProgressIndicator(
                                  value: accuracy / 100,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey[100],
                                  color: primaryColor,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${accuracy.toStringAsFixed(0)}%",
                                    style: GoogleFonts.poppins(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    "Accuracy",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(
                                Icons.check_circle,
                                "$correctAnswers",
                                "Correct",
                                Colors.green,
                              ),
                              _buildMiniStat(
                                Icons.cancel,
                                "${totalQuestions - correctAnswers}",
                                "Wrong",
                                Colors.redAccent,
                              ),
                              _buildMiniStat(
                                Icons.emoji_events,
                                "${progress?.levelOrder ?? 1}",
                                "Level",
                                Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    _buildActionButton(
                      text: isPassed ? "CONTINUE" : "TRY AGAIN",
                      color: primaryColor,
                      icon: isPassed ? Icons.arrow_forward : Icons.refresh,
                      onPressed: () => context.goNamed('interactiveQuiz'),
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(height: 0.5.h),
        Text(
          val,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 16.sp,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
