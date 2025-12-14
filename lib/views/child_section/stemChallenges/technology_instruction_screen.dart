import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/stem_challenge_read_model.dart';

class TechnologyInstructionScreen extends StatefulWidget {
  final StemChallengeReadModel challenge;

  const TechnologyInstructionScreen({super.key, required this.challenge});

  @override
  State<TechnologyInstructionScreen> createState() =>
      _TechnologyInstructionScreenState();
}

class _TechnologyInstructionScreenState
    extends State<TechnologyInstructionScreen> {
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('stemChallenges');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Almost Black
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: CircleAvatar(
              backgroundColor: Colors.white10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.goNamed('stemChallenges'),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            challenge.title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.flag, color: Colors.redAccent),
              onPressed: () {
                context.pushNamed('childReportIssueScreen', extra: {
                  'id': widget.challenge.id,
                  'title': widget.challenge.title,
                  'type': 'STEM Challenge'
                });
              },
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Card ---
                Container(
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.cyanAccent, width: 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: challenge.imageUrl != null
                            ? Image.network(
                                challenge.imageUrl!,
                                width: 20.w,
                                height: 10.h,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.computer,
                                  color: Colors.white54,
                                  size: 10.w,
                                ),
                              )
                            : Icon(
                                Icons.memory,
                                color: Colors.cyanAccent,
                                size: 10.w,
                              ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "★ ${challenge.difficulty}",
                                style: GoogleFonts.poppins(
                                  color: Colors.cyanAccent,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Reward ⭐ ${challenge.points}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                /// --- Materials ---
                Text(
                  "💻 Hardware & Software",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                if (challenge.materials.isEmpty)
                  Text(
                    "No requirements listed.",
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...challenge.materials.asMap().entries.map(
                    (e) => _buildMaterialItem("${e.key + 1}. ${e.value}"),
                  ),

                SizedBox(height: 3.h),

                /// --- Steps ---
                Text(
                  "🚀 Execution Protocol",
                  style: GoogleFonts.poppins(
                    color: Colors.purpleAccent,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Tap to execute step.",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),

                if (challenge.steps.isEmpty)
                  Text("No instructions.", style: TextStyle(color: Colors.grey))
                else
                  ...challenge.steps.asMap().entries.map((entry) {
                    final isDone = _completedSteps.contains(entry.key);
                    return _buildStepItem(
                      step: "${entry.key + 1}",
                      text: entry.value,
                      isCompleted: isDone,
                      onTap: () => setState(
                        () => isDone
                            ? _completedSteps.remove(entry.key)
                            : _completedSteps.add(entry.key),
                      ),
                    );
                  }),

                SizedBox(height: 4.h),

                /// --- Upload ---
                GestureDetector(
                  onTap: () => context.goNamed(
                    'technologySubmitScreen',
                    extra: challenge,
                  ),
                  child: Container(
                    width: 100.w,
                    height: 6.5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6200EA), Color(0xFF651FFF)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "📸 Upload Code/Result",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(Icons.code, color: Colors.cyanAccent, size: 18.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String text,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.purpleAccent : Colors.transparent,
          ),
        ),
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.purpleAccent
                    : Colors.deepPurple.withValues(alpha: 0.5),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                    : Text(
                        step,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.purpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
