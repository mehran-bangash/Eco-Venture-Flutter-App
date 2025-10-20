import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:eco_venture/views/child_section/stemChallenges/widgets/challenge_card.dart';

class EngineeringScreen extends StatefulWidget {
  const EngineeringScreen({super.key});

  @override
  State<EngineeringScreen> createState() => _EngineeringScreenState();
}

class _EngineeringScreenState extends State<EngineeringScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.58;
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _rotationAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get neonOrange => const Color(0xFFFFA726);
  Color get steelBlue => const Color(0xFF1E3C72);
  Color get cyanGlow => const Color(0xFF2A93D5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [steelBlue, cyanGlow, neonOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ⚙️ Floating Gears in Background
            Positioned(
              left: -20,
              top: 40,
              child: AnimatedBuilder(
                animation: _rotationAnim,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationAnim.value,
                  child: Icon(Icons.settings, size: 80, color: Colors.white24),
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: 50,
              child: AnimatedBuilder(
                animation: _rotationAnim,
                builder: (context, child) => Transform.rotate(
                  angle: -_rotationAnim.value,
                  child:
                  Icon(Icons.settings_applications, size: 90, color: Colors.white24),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🛠 Header Section
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: 1 + 0.02 * sin(_controller.value * 2 * pi),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF512F),
                                  Color(0xFFF09819),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.engineering_rounded,
                                        color: Colors.white, size: 35),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        "Engineering Adventures",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 1.3.h,
                                  borderRadius: BorderRadius.circular(20),
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${(progress * 100).toInt()}% Completed",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // 🌟 Score Box with glowing pulse
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border:
                            Border.all(color: Colors.white30, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withValues(alpha:
                                    0.4 + 0.2 * sin(_controller.value * 2 * pi)),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amberAccent, size: 28),
                              SizedBox(width: 2.w),
                              Text(
                                "Total Score: 1320",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // 🚀 Challenge Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 3.h,
                      childAspectRatio: 0.065.h,
                      children:  [
                        ChallengeCard(
                          onTap: () {
                            context.goNamed('engineeringInstructionScreen');
                          },
                          title: "Build a Mini Bridge",
                          imageUrl: "assets/images/rabbit.jpeg",
                          difficulty: "Medium",
                          rewardPoints: 30,
                          backgroundGradient: const [
                            Color(0xFF3A7BD5), // metallic blue
                            Color(0xFF00D2FF), // light electric cyan
                          ],
                          buttonGradient: const [
                            Color(0xFFFFB75E),
                            Color(0xFFED8F03),
                          ],
                        ),

                        ChallengeCard(
                          onTap: () {
                            context.goNamed('engineeringInstructionScreen');
                          },
                          title: "Wind Turbine Project",
                          imageUrl: "assets/images/rabbit.jpeg",
                          difficulty: "Hard",
                          rewardPoints: 45,
                          backgroundGradient: const [
                            Color(0xFF232526), // dark steel grey
                            Color(0xFF414345), // metallic chrome
                          ],
                          buttonGradient: const [
                            Color(0xFF56CCF2),
                            Color(0xFF2F80ED),
                          ],
                        ),

                        ChallengeCard(
                          title: "Robot Arm Challenge",
                          imageUrl: "assets/images/rabbit.jpeg",
                          difficulty: "Medium",
                          rewardPoints: 25,
                          backgroundGradient: const [
                            Color(0xFF283E51), // deep navy
                            Color(0xFF485563), // steel grey
                          ],
                          buttonGradient: const [
                            Color(0xFF00C9FF),
                            Color(0xFF92FE9D),
                          ],
                        ),

                        ChallengeCard(
                          onTap: () {
                            context.goNamed('engineeringInstructionScreen');
                          },
                          title: "Catapult Construction",
                          imageUrl: "assets/images/rabbit.jpeg",
                          difficulty: "Easy",
                          rewardPoints: 20,
                          backgroundGradient: const [
                            Color(0xFFFF512F), // molten orange
                            Color(0xFFF09819), // sunrise yellow
                          ],
                          buttonGradient: const [
                            Color(0xFFf46b45),
                            Color(0xFFeea849),
                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
