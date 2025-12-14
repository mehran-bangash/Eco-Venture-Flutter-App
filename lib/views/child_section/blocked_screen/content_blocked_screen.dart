import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class ContentBlockedScreen extends StatelessWidget {
  final String reason; // e.g., "Scary Content", "Not Educational"

  const ContentBlockedScreen({super.key, this.reason = "Restricted Content"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 50.sp),
              SizedBox(height: 4.h),
              Text(
                "Content Hidden",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "This content is not available due to your safety settings ($reason).",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: OutlinedButton(
                  onPressed: () => context.pop(), // Go back
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Go Back",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () {
                  // Navigate to Report Screen if they think this is a mistake
                  context.replaceNamed('childReportIssueScreen');
                },
                child: Text(
                  "Report a mistake",
                  style: GoogleFonts.poppins(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
