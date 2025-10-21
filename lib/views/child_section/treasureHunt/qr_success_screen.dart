import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QRSuccessScreen extends StatelessWidget {
  final int rewardCoins;
  const QRSuccessScreen({super.key, this.rewardCoins = 5});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const LinearGradient(
        colors: [Color(0xFF00D2A8), Color(0xFF00B2A8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.zero) == null // just to force gradient below
          ? Colors.transparent
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00D2A8), Color(0xFF00B2A8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // White reward card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Yellow circular icon
                  Container(
                    height: 12.h,
                    width: 12.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFF6CC),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_open_rounded ,// or use Icons.lock_open_rounded
                        color: Colors.amber.shade700,
                        size: 45.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Amazing Work!",
                    style: GoogleFonts.poppins(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF14213D),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "You've unlocked a new clue.",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Coin reward
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "+$rewardCoins Coins",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),

            // Continue button
            GestureDetector(
              onTap: () => context.goNamed('treasureHunt'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A7BD5), Color(0xFF00D2A8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.sp),
                ),
                child: Center(
                  child: Text(
                    "Continue →",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
