import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/stem_challenge_read_model.dart';

class EngineeringInstructionScreen extends StatefulWidget {
  final StemChallengeReadModel challenge;

  const EngineeringInstructionScreen({super.key, required this.challenge});

  @override
  State<EngineeringInstructionScreen> createState() => _EngineeringInstructionScreenState();
}

class _EngineeringInstructionScreenState extends State<EngineeringInstructionScreen> {
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('stemChallenges');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF263238), // Blue Grey Dark
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: CircleAvatar(
              backgroundColor: Colors.white10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            challenge.title,
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 3.w),
              child: const Icon(Icons.bookmark_border, color: Colors.white),
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
                    color: const Color(0xFF37474F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.tealAccent, width: 0.6),
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: challenge.imageUrl != null
                            ? Image.network(
                          challenge.imageUrl!, width: 20.w, height: 10.h, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => Icon(Icons.construction, color: Colors.white54, size: 10.w),
                        )
                            : Icon(Icons.engineering, color: Colors.tealAccent, size: 10.w),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "★ ${challenge.difficulty}",
                                style: GoogleFonts.poppins(color: Colors.tealAccent, fontSize: 14.sp, fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Reward ⭐ ${challenge.points}",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                /// --- Materials ---
                Text("🛠 Tools & Parts", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                if (challenge.materials.isEmpty)
                  Text("No tools listed.", style: TextStyle(color: Colors.grey))
                else
                  ...challenge.materials.asMap().entries.map((e) => _buildMaterialItem("${e.key + 1}. ${e.value}")),

                SizedBox(height: 3.h),

                /// --- Steps ---
                Text("🏗 Blueprint Guide", style: GoogleFonts.poppins(color: Colors.orangeAccent, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 0.5.h),
                Text("Tap a step to complete it.", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10.sp)),
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
                      onTap: () => setState(() => isDone ? _completedSteps.remove(entry.key) : _completedSteps.add(entry.key)),
                    );
                  }),

                SizedBox(height: 4.h),

                /// --- Upload ---
                GestureDetector(
                  onTap: () => context.goNamed('engineeringSubmitScreen', extra: challenge),
                  child: Container(
                    width: 100.w,
                    height: 6.5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]),
                    ),
                    child: Center(
                      child: Text("📸 Upload Prototype", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.sp)),
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
          Icon(Icons.hexagon_outlined, color: Colors.white54, size: 18.sp),
          SizedBox(width: 3.w),
          Expanded(child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStepItem({required String step, required String text, required bool isCompleted, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF37474F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? Colors.tealAccent : Colors.transparent),
        ),
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            Container(
              width: 10.w, height: 10.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? Colors.tealAccent : Colors.blueGrey),
              child: Center(child: isCompleted ? Icon(Icons.check, color: Colors.black, size: 16.sp) : Text(step, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp, decoration: isCompleted ? TextDecoration.lineThrough : null, decorationColor: Colors.tealAccent)),
            ),
          ],
        ),
      ),
    );
  }
}