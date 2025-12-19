import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LearnWithAi extends StatefulWidget {
  const LearnWithAi({super.key});

  @override
  State<LearnWithAi> createState() => _LearnWithAiState();
}

class _LearnWithAiState extends State<LearnWithAi> with TickerProviderStateMixin {
  late final AnimationController _skyController;
  late final AnimationController _cloudController;
  late final AnimationController _birdController;
  late final AnimationController _leafController;
  late final AnimationController _ctaController;

  @override
  void initState() {
    super.initState();

    // Gentle animated sky gradient (0.0 -> 1.0 -> repeat)
    _skyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Clouds slide from left to right in a loop
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Birds bobbing/flying motion
    _birdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Leaves floating/rotating
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // CTA button press animation (scale)
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _skyController.dispose();
    _cloudController.dispose();
    _birdController.dispose();
    _leafController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  // Helper: animated gradient
  LinearGradient _animatedSkyGradient() {
    final t = _skyController.value;
    // Interpolate between two pleasant kid-friendly palettes
    final topColor = Color.lerp(const Color(0xFFFFF3C4), const Color(0xFFFFF8E1), t)!;
    final midColor = Color.lerp(const Color(0xFFBCE6FF), const Color(0xFFCFFFE5), t)!;
    final bottomColor = Color.lerp(const Color(0xFFBEE7C7), const Color(0xFFBEE7D6), t)!;

    return LinearGradient(
      colors: [topColor, midColor, bottomColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // Cloud widget
  Widget _buildCloud({required double topPct, required double sizePct, required double speedFactor, required double opacity}) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (_, child) {
        final widthFactor = _cloudController.value; // 0..1
        final screenWidth = MediaQuery.of(context).size.width;
        // movement: start -30% off left to +120% off right (so loops offscreen)
        final x = (widthFactor * (screenWidth + screenWidth * 1.5)) - (screenWidth * 0.75) * speedFactor;
        return Positioned(
          top: MediaQuery.of(context).size.height * topPct,
          left: x,
          child: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: screenWidth * sizePct,
              height: (screenWidth * sizePct) * 0.45,
              child: child,
            ),
          ),
        );
      },
      child: const _CloudShape(),
    );
  }

  // Bird widget
  Widget _buildBird({required double startLeftPct, required double startTopPct, required double scale, required double delay}) {
    return AnimatedBuilder(
      animation: _birdController,
      builder: (_, child) {
        final t = (_birdController.value + delay) % 1.0;
        final bob = sin(t * 2 * pi) * 10;
        final wiggle = cos(t * 2 * pi) * 6;
        final left = MediaQuery.of(context).size.width * startLeftPct + wiggle;
        final top = MediaQuery.of(context).size.height * startTopPct + bob;
        return Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: sin(t * 2 * pi) * 0.12,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: const _BirdWidget(),
    );
  }

  // Floating leaf
  Widget _buildLeaf({required double startLeftPct, required double startTopPct, required double size, required double delay}) {
    return AnimatedBuilder(
      animation: _leafController,
      builder: (_, child) {
        final t = (_leafController.value + delay) % 1.0;
        final screenH = MediaQuery.of(context).size.height;
        final y = (startTopPct * screenH) + (t * screenH * 0.35);
        final x = MediaQuery.of(context).size.width * startLeftPct + sin(t * 2 * pi) * 18;
        final rotation = t * 2 * pi;
        return Positioned(
          left: x,
          top: y % (screenH * 0.9),
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(opacity: 0.9 - (t * 0.5), child: child),
          ),
        );
      },
      child: _LeafIcon(size: size),
    );
  }

  // CTA button widget
  Widget _buildCTA() {
    return Positioned(
      bottom: 6.h,
      left: 6.w,
      right: 6.w,
      child: ScaleTransition(
        scale: _ctaController,
        child: GestureDetector(
          onTapDown: (_) => _ctaController.reverse(),
          onTapUp: (_) {
            _ctaController.forward();
            // Go to the Camera / Explorer Screen
            context.goNamed('naturePhotoExploreScreen');
          },
          onTapCancel: () => _ctaController.forward(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.2.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5EEAD4), Color(0xFF06B6D4)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.teal.withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 6.w),
                SizedBox(width: 4.w),
                Text(
                  "Start Exploring!",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Headline
  Widget _buildHeadline() {
    final headlineScale = CurvedAnimation(parent: _skyController, curve: Curves.easeOutBack);
    return Positioned(
      top: 6.h,
      left: 0,
      right: 0,
      child: ScaleTransition(
        scale: headlineScale,
        child: Column(
          children: [
            Text(
              "Nature Adventure 🌿",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: Colors.brown.shade800,
                shadows: [
                  Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Take a picture. Learn amazing facts. Have fun!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hills
  Widget _buildHills() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 32.h,
        child: CustomPaint(
          painter: _HillPainter(),
          child: Container(),
        ),
      ),
    );
  }

  // Back button
  Widget _buildBackButton() {
    return Positioned(
      top: 4.h,
      left: 4.w,
      child: GestureDetector(
        onTap: () {
          // Go back to the Journal List
          context.goNamed('naturePhotoJournal');
        },
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.brown.shade800,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Hardware back button behavior
          context.goNamed("naturePhotoJournalScreen");
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([_skyController, _cloudController, _birdController, _leafController]),
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: _animatedSkyGradient()),
              child: Stack(
                children: [
                  _buildBackButton(),

                  // Sun
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Transform.rotate(
                      angle: _skyController.value * 2 * pi * 0.08,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [Colors.yellow.shade300, Colors.orange.shade300]),
                          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Center(child: Icon(Icons.wb_sunny, color: Colors.white.withOpacity(0.9), size: 8.w)),
                      ),
                    ),
                  ),

                  // Clouds
                  _buildCloud(topPct: 0.08, sizePct: 0.48, speedFactor: 0.9, opacity: 0.95),
                  _buildCloud(topPct: 0.16, sizePct: 0.32, speedFactor: 0.65, opacity: 0.85),
                  _buildCloud(topPct: 0.26, sizePct: 0.42, speedFactor: 1.2, opacity: 0.9),

                  // Birds
                  _buildBird(startLeftPct: 0.08, startTopPct: 0.25, scale: 1.0, delay: 0.0),
                  _buildBird(startLeftPct: 0.45, startTopPct: 0.18, scale: 0.9, delay: 0.25),
                  _buildBird(startLeftPct: 0.65, startTopPct: 0.28, scale: 0.8, delay: 0.55),

                  // Leaves
                  _buildLeaf(startLeftPct: 0.12, startTopPct: 0.02, size: 6.w, delay: 0.05),
                  _buildLeaf(startLeftPct: 0.32, startTopPct: 0.05, size: 7.w, delay: 0.25),
                  _buildLeaf(startLeftPct: 0.72, startTopPct: 0.01, size: 5.w, delay: 0.6),
                  _buildLeaf(startLeftPct: 0.52, startTopPct: 0.12, size: 6.5.w, delay: 0.8),

                  // Sparkles
                  Positioned(
                    left: 10.w,
                    top: 22.h,
                    child: Opacity(
                      opacity: 0.9,
                      child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle)),
                    ),
                  ),
                  Positioned(
                    left: 25.w,
                    top: 24.h,
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle)),
                    ),
                  ),

                  _buildHeadline(),
                  _buildHills(),
                  _buildCTA(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CloudShape extends StatelessWidget {
  const _CloudShape();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 8,
          child: Container(width: 120, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), borderRadius: BorderRadius.circular(40))),
        ),
        Positioned(
          left: 36,
          top: 0,
          child: Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(40))),
        ),
        Positioned(
          left: 86,
          top: 10,
          child: Container(width: 46, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(40))),
        ),
      ],
    );
  }
}

class _BirdWidget extends StatelessWidget {
  const _BirdWidget();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.rotate(
          angle: -0.25,
          child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(3))),
        ),
        const SizedBox(width: 4),
        Container(
          width: 48,
          height: 28,
          decoration: BoxDecoration(color: Colors.teal.shade300, borderRadius: BorderRadius.circular(16)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 22,
              height: 20,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeafIcon extends StatelessWidget {
  final double size;
  const _LeafIcon({required this.size});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.4,
      child: Container(
        width: size,
        height: size * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade300, Colors.green.shade600]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 4))],
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(width: size * 0.18, height: size * 0.18, decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(4))),
        ),
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF9BE7A6);
    final paint2 = Paint()..color = const Color(0xFF6FCF97);
    final paint3 = Paint()..color = const Color(0xFF42B883);

    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.quadraticBezierTo(size.width * 0.2, size.height * 0.45, size.width * 0.4, size.height * 0.6);
    path1.quadraticBezierTo(size.width * 0.6, size.height * 0.75, size.width * 0.9, size.height * 0.6);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    canvas.drawPath(path1, paint1);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.73);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.86, size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint2);

    final path3 = Path();
    path3.moveTo(0, size.height * 0.85);
    path3.quadraticBezierTo(size.width * 0.33, size.height * 0.72, size.width * 0.66, size.height * 0.86);
    path3.quadraticBezierTo(size.width * 0.8, size.height * 0.95, size.width, size.height * 0.9);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}