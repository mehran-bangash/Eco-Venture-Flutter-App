import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:lottie/lottie.dart'; // Optional: If you have animations, otherwise use Icon

class QRSuccessScreen extends StatefulWidget {
  final int rewardCoins;
  // Accept extra data passed from Scanner
  const QRSuccessScreen({super.key, required this.rewardCoins});

  @override
  State<QRSuccessScreen> createState() => _QRSuccessScreenState();
}

class _QRSuccessScreenState extends State<QRSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Deep Dark Background
      body: Stack(
        children: [
          // 1. Ambient Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853).withOpacity(0.2), // Green glow
                  const Color(0xFF0F2027),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon with Glow
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade400,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(Icons.lock_open_rounded, color: Colors.white, size: 40.sp),
                      ),
                      SizedBox(height: 3.h),

                      // Text
                      Text(
                        "Clue Unlocked!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Great job! You found the correct spot.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Reward Pill
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 18.sp),
                            SizedBox(width: 2.w),
                            Text(
                              "+${widget.rewardCoins} Points",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 6.5.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // IMPORTANT: Pop back to Play Screen to continue the game
                            // Since Scanner replaced PlayScreen in stack? No, typically Scanner is PUSHED on top.
                            // If Scanner used 'replaceNamed', then this Success screen is now where Scanner was.
                            // So 'pop' goes back to PlayScreen.
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              // Fallback if stack is empty (rare)
                              context.goNamed('treasureHunt');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            elevation: 10,
                            shadowColor: Colors.greenAccent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Next Clue",
                                style: GoogleFonts.poppins(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}