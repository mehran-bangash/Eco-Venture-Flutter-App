import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TechnologyInstructionScreen extends StatefulWidget {
  const TechnologyInstructionScreen({super.key});

  @override
  State<TechnologyInstructionScreen> createState() => _TechnologyInstructionScreenState();
}

class _TechnologyInstructionScreenState extends State<TechnologyInstructionScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0C1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          "Paper Duck Challenge",
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
                      child: Image.asset(
                        'assets/images/rabbit.jpeg', // Replace with your image
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
                              "★ Easy",
                              style: GoogleFonts.poppins(
                                color: Colors.greenAccent,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Reward ⭐ 100 gems",
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

              _buildMaterialItem("1. Square Paper (A4 size)", true),
              _buildMaterialItem("2. Scissors (optional)", false),
              _buildMaterialItem("3. Ruler for precision", false),

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
              SizedBox(height: 2.h),

              _buildStepItem(
                  step: "1",
                  text:
                  "Start by folding the square in half corner to corner to make a triangle.",
                  isCompleted: false),
              _buildStepItem(
                  step: "2",
                  text:
                  "Fold the triangle in half again to make a smaller triangle.",
                  isCompleted: true),

              SizedBox(height: 4.h),

              /// --- Upload Button ---
              GestureDetector(
                onTap: () {
                  context.goNamed('technologySubmitScreen');
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

  Widget _buildStepItem({
    required String step,
    required String text,
    required bool isCompleted,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1828),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.greenAccent : Colors.transparent,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
              isCompleted ? Colors.greenAccent : Colors.blueAccent,
              radius: 13.sp,
              child: Text(
                step,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}