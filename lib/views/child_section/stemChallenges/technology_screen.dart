import 'package:eco_venture/views/child_section/stemChallenges/widgets/challenge_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:math';


class TechnologyScreen extends StatefulWidget {
  const TechnologyScreen({super.key});

  @override
  State<TechnologyScreen> createState() => _TechnologyScreenState();
}

class _TechnologyScreenState extends State<TechnologyScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.83;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Container(
            //  Futuristic Child-Friendly Gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ].map((c) => Color.lerp(c, Colors.blueAccent, 0.4)!).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                //  Subtle Moving Circles in Background
                CustomPaint(
                  painter: _BackgroundPainter(_bgController.value),
                  size: MediaQuery.of(context).size,
                ),

                //  Main UI Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⚙ Header Section
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4A00E0),
                                Color(0xFF8E2DE2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurpleAccent.withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.devices_rounded,
                                      color: Colors.white, size: 34),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      "Tech Playground",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white70, width: 1),
                                    ),
                                    child: Text(
                                      "Level 4",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 1.2.h,
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF76FF7A),
                                  ),
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

                        SizedBox(height: 3.h),

                        // Total Score
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lightbulb_rounded,
                                  color: Colors.amberAccent, size: 28),
                              SizedBox(width: 2.w),
                              Text(
                                "Total Tech Score: 1980",
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

                        //  Challenges Grid
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
                                context.goNamed('technologyInstructionScreen');
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
                                context.goNamed('technologyInstructionScreen');
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
                                context.goNamed('technologyInstructionScreen');
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
              ],
            ),
          );
        },
      ),
    );
  }
}

//  Custom Painter for background glowing orbs
class _BackgroundPainter extends CustomPainter {
  final double progress;
  final Paint glowPaint = Paint()..style = PaintingStyle.fill;

  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(3);
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.1 + 0.8 * random.nextDouble()),
        size.height * (0.1 + 0.8 * random.nextDouble()),
      );

      glowPaint.color = Colors
          .primaries[(i * 4) % Colors.primaries.length]
          .withValues(alpha: 0.05 + 0.05 * sin(progress * 2 * pi));
      canvas.drawCircle(offset, 80 + 40 * sin(progress * 2 * pi), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
