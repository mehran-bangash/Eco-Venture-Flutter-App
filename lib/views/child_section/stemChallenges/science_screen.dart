import 'package:eco_venture/views/child_section/stemChallenges/widgets/challenge_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class ScienceScreen extends StatefulWidget {
  const ScienceScreen({super.key});

  @override
  State<ScienceScreen> createState() => _ScienceScreenState();
}

class _ScienceScreenState extends State<ScienceScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.68;
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //  Science Lab Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020024),
              Color(0xFF090979),
              Color(0xFF00D4FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Header Section
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1CB5E0),
                        Color(0xFF000046),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science_rounded,
                              color: Colors.white, size: 34),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              "Science Adventures",
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
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              minHeight: 1.4.h,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00FFDD),
                              ),
                            ),
                          );
                        },
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

                SizedBox(height: 3.h),

                //  Total Score Box
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
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
                        "Total Score: 1256",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Challenge Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 3.h,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.065.h,
                  children: [
                    ChallengeCard(
                      onTap: () {
                        context.goNamed('scienceInstructionScreen');
                      },
                      title: "Magnetic Field Mystery",
                      imageUrl: "assets/images/rabbit.jpeg",
                      difficulty: "Medium",
                      rewardPoints: 25,
                      backgroundGradient: const [
                        Color(0xFF003973),
                        Color(0xFFE5E5BE),
                      ],
                      buttonGradient: const [
                        Color(0xFF00C9A7),
                        Color(0xFF92FE9D),
                      ],
                    ),
                    ChallengeCard(
                      onTap: () {
                        context.goNamed('scienceInstructionScreen');
                      },
                      title: "Magnetic Field Mystery",
                      imageUrl: "assets/images/rabbit.jpeg",
                      difficulty: "Medium",
                      rewardPoints: 25,
                      backgroundGradient: const [
                        Color(0xFF003973),
                        Color(0xFFE5E5BE),
                      ],
                      buttonGradient: const [
                        Color(0xFF00C9A7),
                        Color(0xFF92FE9D),
                      ],
                    ),
                    ChallengeCard(
                      onTap: () {
                        context.goNamed('scienceInstructionScreen');
                      },
                      title: "Magnetic Field Mystery",
                      imageUrl: "assets/images/rabbit.jpeg",
                      difficulty: "Medium",
                      rewardPoints: 25,
                      backgroundGradient: const [
                        Color(0xFF003973),
                        Color(0xFFE5E5BE),
                      ],
                      buttonGradient: const [
                        Color(0xFF00C9A7),
                        Color(0xFF92FE9D),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
