import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../services/shared_preferences_helper.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin{
  late AnimationController _floatController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  int? _selectedIndex;
  final prefs = SharedPreferencesHelper.instance;


  @override
  void initState() {
    super.initState();

    _floatController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _cardController =
    AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);

    // New Professional Pulse Animation for Title
    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = null;
          });
        },
        child: Stack(
          children: [
            // 🌿 BACKGROUND
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4FC3F7),
                    Color(0xFF81D4FA),
                    Color(0xFFE1F5FE),
                  ],
                ),
              ),
            ),

            // ☀️ SUN
            Positioned(
              top: 8.h,
              right: 10.w,
              child: CustomPaint(
                size: Size(14.w, 14.w),
                painter: SunPainter(),
              ),
            ),






            // ☁️ CLOUDS
            Positioned(top: 22.h, left: 5.w, child: _buildCloud(28.w)),
            Positioned(top: 28.h, right: 5.w, child: _buildCloud(22.w)),

            // 🌱 HILLS (Layered for Depth)
            AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                return Stack(
                  children: [
                    CustomPaint(
                      painter: HillPainter(
                        offset: _floatController.value * 15,
                        color: const Color(0xFF81C784),
                        heightFactor: 0.75,
                      ),
                      size: Size.infinite,
                    ),
                    CustomPaint(
                      painter: HillPainter(
                        offset: _floatController.value * 25,
                        color: const Color(0xFF66BB6A),
                        heightFactor: 0.7,
                      ),
                      size: Size.infinite,
                    ),
                  ],
                );
              },
            ),

            // 🌑 OVERLAY
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 📱 UI
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    SizedBox(height: 6.h),

                    // 🌿 LOGO + TITLE
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.greenAccent.withOpacity(0.8), Colors.transparent],
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(Icons.eco_rounded, color: Colors.white, size: 26.sp),
                        ),


                        SizedBox(height: 2.h),

                        // 🎬 IMPROVED PULSE ANIMATION
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Text(
                            "ECOVENTURE",
                            style: GoogleFonts.montserrat(
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                                Shadow(
                                  color: Colors.greenAccent.withOpacity(0.7),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 1.h),

                        // 🆕 UPDATED TAGLINE

                        Text(
                          "Adventure into Nature, Learn with Fun!",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 1.h),

                        // 🎯 ADVENTURE INDICATOR
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (_, __) {
                            return Opacity(
                              opacity: 0.9 + (math.sin(_floatController.value * math.pi) * 0.1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Colors.greenAccent,
                                    size: 16.sp,
                                    shadows: [
                                      Shadow(
                                        color: Colors.greenAccent.withOpacity(0.7),
                                        blurRadius: 12,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Start Your Adventure",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                        Shadow(
                                          color: Colors.greenAccent.withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      ],
                    ),

                    const Spacer(),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "CHOOSE YOUR ROLE",
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    GestureDetector(
                      onTap: () async {
                        setState(() => _selectedIndex = 0);
                        context.goNamed('login', extra: "child");
                        await SharedPreferencesHelper.instance.saveUserRole("child");
                      },
                      child: _buildCard("Explorer", "CHILD",
                          "Complete missions, scan QR & explore nature",
                          Icons.explore, Colors.blueAccent, 0),
                    ),

                    GestureDetector(
                      onTap: () async {
                        setState(() => _selectedIndex = 1);
                        context.goNamed('login', extra: "parent");
                        await SharedPreferencesHelper.instance.saveUserRole("parent");

                      },
                      child: _buildCard("Guardian", "PARENT",
                          "Track safety and progress insights",
                          Icons.shield, Colors.orange, 1),
                    ),

                    GestureDetector(
                      onTap: () async {
                        setState(() => _selectedIndex = 2);
                        context.goNamed('login', extra: "teacher");
                        await SharedPreferencesHelper.instance.saveUserRole("teacher");
                      },
                      child: _buildCard("Mentor", "TEACHER",
                          "Guide learning with challenges & quizzes",
                          Icons.school, Colors.greenAccent, 2),
                    ),


                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ☁️ CLOUD
  Widget _buildCloud(double width) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) {
        return Transform.translate(
          offset:
          Offset(math.sin(_floatController.value * math.pi) * 15, 0),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(width, width * 0.5),
        painter: CloudPainter(),
      ),
    );
  }

  // 🎬 CARD
  Widget _buildCard(String title, String label, String desc,
      IconData icon, Color accent, int index) {
    bool isSelected = _selectedIndex == index;

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 2.h),
        height: 11.h,
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.9) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? accent.withOpacity(0.6) : Colors.black26,
              blurRadius: isSelected ? 25 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            CircleAvatar(
              backgroundColor: isSelected ? Colors.white : accent.withOpacity(0.3),
              child: Icon(icon, color: isSelected ? accent : Colors.white),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? accent : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(isSelected ? 1.0 : 0.85),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }

}

class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Sun core
    final corePaint = Paint()..color = const Color(0xFFFFD600); // golden yellow
    canvas.drawCircle(center, size.width * 0.25, corePaint);

    // Rays
    final rayPaint = Paint()..color = const Color(0xFFFFD600);
    const rayCount = 12;
    final radius = size.width * 0.4;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + math.cos(angle - 0.1) * radius,
        center.dy + math.sin(angle - 0.1) * radius,
      );
      path.lineTo(x, y);
      path.lineTo(
        center.dx + math.cos(angle + 0.1) * radius,
        center.dy + math.sin(angle + 0.1) * radius,
      );
      path.close();

      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// ☁️ CLOUD SHAPE
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5),
        size.height * 0.3, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4),
        size.height * 0.35, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5),
        size.height * 0.3, paint);

    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.5,
            size.width * 0.6, size.height * 0.3),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🌱 HILLS
class HillPainter extends CustomPainter {
  final double offset;
  final Color color;
  final double heightFactor;

  HillPainter({required this.offset, required this.color, required this.heightFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * heightFactor);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * heightFactor +
            math.sin((i + offset) * 0.005) * 15,
      );
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HillPainter oldDelegate) => true;
}