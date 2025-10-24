import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:math' as math;

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _particleController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap:() {
            context.goNamed("bottomNavChild");
          },
          child: Padding(
            padding:  EdgeInsets.all(1.5.w),
            child: Container(
              height: 3.h,
              width: 5.w,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          "🌟 Progress Dashboard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// 🌈 Animated Wavy Gradient Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.sin(t * 2 * math.pi) * 0.8,
                      math.cos(t * 2 * math.pi) * 0.8,
                    ),
                    end: Alignment(
                      -math.sin(t * 2 * math.pi) * 0.8,
                      -math.cos(t * 2 * math.pi) * 0.8,
                    ),
                    colors: [
                      Color.lerp(
                        const Color(0xFFFFC371),
                        const Color(0xFFFF5F6D),
                        t,
                      )!,
                      Color.lerp(
                        const Color(0xFF6A11CB),
                        const Color(0xFF2575FC),
                        1 - t,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          /// 🌟 Floating Glow Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              final size = MediaQuery.of(context).size;
              final particles = List.generate(25, (i) {
                final progress = (_particleController.value + i * 0.04) % 1.0;
                final dx =
                    (math.sin(progress * 6 * math.pi + i) * size.width * 0.4) +
                    size.width / 2;
                final dy = progress * size.height;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Container(
                    width: (3 + math.sin(progress * 2 * math.pi) * 2),
                    height: (3 + math.sin(progress * 2 * math.pi) * 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              });

              return Stack(children: particles);
            },
          ),

          /// 🌈 Main UI (with animated cards)
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _welcomeCard(),
                  SizedBox(height: 3.h),
                  _progressCard(),
                  SizedBox(height: 3.h),
                  Text(
                    "📚 Subject Progress",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _subjectGrid(), // will animate
                  SizedBox(height: 3.h),
                  _performanceBarGraph(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💫 Welcome Card
  Widget _welcomeCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, Alex 👋",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  "You’re on a 5-day learning streak 🔥",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📈 Overall Progress Card
  Widget _progressCard() {
    return _frostedCard(
      "Overall Progress",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Level 5 • 1200 / 2000 XP",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15.sp),
          ),
          SizedBox(height: 1.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 1.4.h,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF80DEEA),
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            "60% Completed 🎯",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎓 Subject Grid
  Widget _subjectGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 4.w,
      mainAxisSpacing: 2.h,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        subjectCard(
          "🔬",
          "Science",
          0.8,
          "Level 3",
          "12 Quizzes",
          _cardController,
        ),
        subjectCard("🔢", "Math", 0.5, "Level 2", "9 Quizzes", _cardController),
        subjectCard(
          "🏗️",
          "Engineering",
          0.7,
          "Level 4",
          "15 Quizzes",
          _cardController,
        ),
        subjectCard(
          "💻",
          "Technology",
          0.4,
          "Level 1",
          "8 Quizzes",
          _cardController,
        ),
      ],
    );
  }

  Widget subjectCard(
    String emoji,
    String title,
    double progress,
    String level,
    String quizzes,
    AnimationController controller,
  ) {
    final gradient = _getVibrantGradient(title, controller);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale = 1 + math.sin(controller.value * 2 * math.pi) * 0.05;
        final rotation = math.sin(controller.value * 2 * math.pi) * 0.02;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, math.sin(controller.value * math.pi * 2) * 4)
            ..scale(scale)
            ..rotateZ(rotation),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.last.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 1.5,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.black.withValues(alpha: 0.15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 24.sp)),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17.sp,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 1.2.h,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFF176),
                      ),
                    ),
                  ),
                  Text(
                    "${(progress * 100).toInt()}% Complete\n$level\n$quizzes",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getVibrantGradient(
    String title,
    AnimationController controller,
  ) {
    final t = (controller.value * 0.3);

    switch (title.toLowerCase()) {
      case 'science':
        return LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFFF5F6D), const Color(0xFFFFC371), t)!,
            Color.lerp(const Color(0xFFFFA17F), const Color(0xFFFF5F6D), t)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'math':
        return LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFFF9A8B), const Color(0xFFFF6A88), t)!,
            Color.lerp(const Color(0xFFFBD786), const Color(0xFFF7797D), t)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'engineering':
        return LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFFBD786), const Color(0xFFC6FFDD), t)!,
            Color.lerp(const Color(0xFFF7797D), const Color(0xFFFBD786), t)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'technology':
        return LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFFF512F), const Color(0xFFF09819), t)!,
            Color.lerp(const Color(0xFFFF9966), const Color(0xFFFF5E62), t)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFA17F), Color(0xFFFF5F6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// 📊 Animated Bar Graph for Performance
  Widget _performanceBarGraph() {
    final subjects = {
      "Math": 0.7,
      "Science": 0.5,
      "Engineering": 0.8,
      "Tech": 0.6,
    };

    return _frostedCard(
      "Performance Insights",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          ...subjects.entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 25.w,
                    child: Text(
                      e.key,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOutCubic,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: e.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${(e.value * 100).toInt()}%",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 🌫 Frosted Glass Card Template
  /// 🌈 Rich Gradient Card (for all frosted cards)
  Widget _frostedCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          child,
        ],
      ),
    );
  }
}
