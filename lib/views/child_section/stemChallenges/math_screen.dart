import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:eco_venture/views/child_section/stemChallenges/widgets/challenge_card.dart';

class MathScreen extends StatefulWidget {
  const MathScreen({super.key});

  @override
  State<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends State<MathScreen> with SingleTickerProviderStateMixin {
  double progress = 0.72;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get primaryMathBlue => const Color(0xFF283CFF);
  Color get vibrantCyan => const Color(0xFF03E9F4);
  Color get softPurple => const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        //  Gradient background — energetic and intelligent
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryMathBlue,
              softPurple,
              vibrantCyan,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            physics: const BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Header Section
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calculate_rounded,
                                  color: Colors.white, size: 35),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  "Math Missions",
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
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${(progress * 100).toInt()}% Completed",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  //  Score Box with glow
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amberAccent, size: 28),
                        SizedBox(width: 2.w),
                        Text(
                          "Total Score: 1420",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  //  Challenge Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 3.h,
                    childAspectRatio: 0.065.h,
                    children: [
                      ChallengeCard(
                        onTap: () {
                          context.goNamed('mathInstructionScreen');
                        },
                        title: "Number Ninja",
                        imageUrl: "assets/images/rabbit.jpeg",
                        difficulty: "Medium",
                        rewardPoints: 20,
                        backgroundGradient: const [
                          Color(0xFF4A00E0), // royal violet
                          Color(0xFF8E2DE2), // bright purple-pink
                        ],
                        buttonGradient: const [
                          Color(0xFF00DBDE),
                          Color(0xFFFC00FF),
                        ],
                      ),

                      ChallengeCard(
                        onTap: () {
                          context.goNamed('mathInstructionScreen');
                        },
                        title: "Shape Quest",
                        imageUrl: "assets/images/rabbit.jpeg",
                        difficulty: "Easy",
                        rewardPoints: 15,
                        backgroundGradient: const [
                          Color(0xFF2193B0), // teal blue
                          Color(0xFF6DD5ED), // light aqua
                        ],
                        buttonGradient: const [
                          Color(0xFF00C9FF),
                          Color(0xFF92FE9D),
                        ],
                      ),

                       ChallengeCard(
                         onTap: () {
                           context.goNamed('mathInstructionScreen');
                         },
                        title: "Fraction Frenzy",
                        imageUrl: "assets/images/rabbit.jpeg",
                        difficulty: "Hard",
                        rewardPoints: 40,
                        backgroundGradient: const [
                          Color(0xFF8360C3), // deep lavender
                          Color(0xFF2EBF91), // mint-teal gradient
                        ],
                        buttonGradient: const [
                          Color(0xFFFF6CAB),
                          Color(0xFF7366FF),
                        ],
                      ),

                       ChallengeCard(
                         onTap: () {
                           context.goNamed('mathInstructionScreen');
                         },
                        title: "Math Maze",
                        imageUrl: "assets/images/rabbit.jpeg",
                        difficulty: "Medium",
                        rewardPoints: 30,
                        backgroundGradient: const [
                          Color(0xFF4776E6), // electric blue
                          Color(0xFF8E54E9), // violet end
                        ],
                        buttonGradient: const [
                          Color(0xFF00F5A0),
                          Color(0xFF00D9F5),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
