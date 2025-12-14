import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/stem_challenge_read_model.dart';

class ScienceInstructionScreen extends StatefulWidget {
  final StemChallengeReadModel challenge;

  const ScienceInstructionScreen({super.key, required this.challenge});

  @override
  State<ScienceInstructionScreen> createState() => _ScienceInstructionScreenState();
}

class _ScienceInstructionScreenState extends State<ScienceInstructionScreen> {
  // Track which steps are marked as done by index
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    // Shorten variable for easier usage
    final challenge = widget.challenge;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('stemChallenges');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0C1B),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: CircleAvatar(
              backgroundColor: Colors.white10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: (){
                  context.goNamed('stemChallenges');
                },
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            challenge.title, // Real Title
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Challenge Card ---
                Container(
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1A29),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.greenAccent, width: 0.6),
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty
                            ? Image.network(
                          challenge.imageUrl!, // Real Image
                          width: 20.w,
                          height: 10.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, color: Colors.white54, size: 10.w),
                        )
                            : Image.asset(
                          'assets/images/science_placeholder.png', // Fallback
                          width: 20.w,
                          height: 10.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "★ ${challenge.difficulty}", // Real Difficulty
                                style: GoogleFonts.poppins(
                                  color: Colors.greenAccent,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Reward ⭐ ${challenge.points} gems", // Real Points
                              style: GoogleFonts.poppins(
                                color: Colors.amberAccent,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                /// --- Materials Needed ---
                Text(
                  "📦 Materials Needed",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),

                // Dynamic List of Materials
                if (challenge.materials.isEmpty)
                  Text("No materials listed.", style: TextStyle(color: Colors.grey))
                else
                  ...challenge.materials.asMap().entries.map((entry) {
                    return _buildMaterialItem("${entry.key + 1}. ${entry.value}", false);
                  }),

                SizedBox(height: 3.h),

                /// --- Step by Step Guide ---
                Text(
                  "📝 Step-by-Step Guide",
                  style: GoogleFonts.poppins(
                    color: Colors.blueAccent,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Tap a step to mark it as done!",
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10.sp),
                ),
                SizedBox(height: 2.h),

                // Dynamic Interactive Steps
                if (challenge.steps.isEmpty)
                  Text("No steps listed.", style: TextStyle(color: Colors.grey))
                else
                  ...challenge.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stepText = entry.value;
                    final isDone = _completedSteps.contains(index);

                    return _buildStepItem(
                      step: "${index + 1}",
                      text: stepText,
                      isCompleted: isDone,
                      onTap: () {
                        setState(() {
                          if (isDone) {
                            _completedSteps.remove(index);
                          } else {
                            _completedSteps.add(index);
                          }
                        });
                      },
                    );
                  }),

                SizedBox(height: 4.h),

                /// --- Upload Button ---
                GestureDetector(
                  onTap: () {
                    // Navigate to Submit Screen, passing the challenge model
                    context.goNamed('scienceSubmitScreen', extra: challenge);
                  },
                  child: Container(
                    width: 100.w,
                    height: 6.5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "📸 Upload Your Creation",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                /// --- Save Button ---
                Center(
                  child: Container(
                    width: 35.w,
                    height: 5.5.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        "♡ Save",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// --- Reusable Widgets ---
  Widget _buildMaterialItem(String text, bool checked) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: checked ? Colors.purpleAccent : Colors.white54,
            size: 22.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Updated Interactive Step Item
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
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1828),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.greenAccent : Colors.transparent,
            width: isCompleted ? 1.5 : 1,
          ),
          boxShadow: isCompleted
              ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.15), blurRadius: 8)]
              : [],
        ),
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Circle / Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.greenAccent : Colors.blueAccent.withValues(alpha: 0.2),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.black, size: 18.sp)
                    : Text(
                  step,
                  style: GoogleFonts.poppins(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Text Content
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isCompleted ? 0.6 : 1.0,
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    height: 1.4,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}