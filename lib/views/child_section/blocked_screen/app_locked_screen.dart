import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppLockedScreen extends StatelessWidget {
  final String message;
  const AppLockedScreen({super.key, this.message = "Time's Up!"});

  @override
  Widget build(BuildContext context) {
    // Intercept Back Button
    return PopScope(
      canPop: false, // Prevent going back
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                color: Colors.white,
                size: 45.sp,
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 17.w),
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Take a break! Come back later.",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
