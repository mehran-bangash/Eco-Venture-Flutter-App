
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InteractiveQuizScreen extends StatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  State<InteractiveQuizScreen> createState() =>
      _InteractiveQuizPremiumScreenState();
}

class _InteractiveQuizPremiumScreenState extends State<InteractiveQuizScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  // staggered card controllers
  final List<AnimationController> _cardControllers = [];
  final List<CategoryModel> categories = [
    CategoryModel(
      'animals',
      'Animals',
      'Test your knowledge of animals',
      Icons.pets_rounded,
      Colors.orangeAccent,
    ),
    CategoryModel(
      'plants',
      'Plants',
      'From tiny seeds to giant trees',
      Icons.eco_rounded,
      Colors.green,
    ),
    CategoryModel(
      'ecosystem',
      'Ecosystem',
      'Explore the balance of nature',
      Icons.public_rounded,
      Colors.blueAccent,
    ),
    CategoryModel(
      'science',
      'Science',
      'Discover the wonders of science',
      Icons.science_rounded,
      Colors.purple,
    ),
    CategoryModel(
      'maths',
      'Maths',
      'Challenge your numerical skills',
      Icons.calculate_rounded,
      Colors.teal,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.linear);

    // create controllers for each card (used for staggered entrance)
    for (var i = 0; i < categories.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 650),
      );
      _cardControllers.add(ctrl);

      // staggered start
      Future.delayed(Duration(milliseconds: 200 + i * 120), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // small helper to compute moving alignment for gradients
  Alignment _movingAlignment(double t, double phase) {
    final dx = 0.5 + 0.45 * math.sin(2 * math.pi * (t + phase));
    final dy = 0.5 + 0.35 * math.cos(2 * math.pi * (t + phase) * 0.7);
    return Alignment(dx * 2 - 1, dy * 2 - 1);
  }

  void _onTapCategory(CategoryModel cat) {
    // temporary action — later replace with navigation to quiz screen
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          cat.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Open ${cat.title} quiz (connect backend later).',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: cat.color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFEEF6FB),
      body: Stack(
        children: [
          // 1) animated layered gradient background
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, child) {
              final t = _bgAnim.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: _movingAlignment(t, 0.0),
                    radius: 1.2,
                    colors: const [
                      Color(0xFFB2F5EA),
                      Color(0xFF9EE7FF),
                      Color(0xFFD6C6FF),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // 2) subtle floating translucent bubbles (built with pure widgets)
          ...List.generate(6, (i) {
            // each bubble moves differently
            return AnimatedBuilder(
              animation: _bgAnim,
              builder: (context, _) {
                final t = _bgAnim.value;
                final speed = 0.9 + (i * 0.12);
                final x =
                    (50.0 +
                        (i * 120) +
                        math.sin((t * speed + i) * 2 * math.pi) * 40) %
                    (100.w);
                final y =
                    (10.h +
                        (i * 8).h +
                        math.cos((t * speed + i) * 2 * math.pi) * 8.h) %
                    100.h;
                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: (6 + i * 1.5).w,
                    height: (6 + i * 1.5).w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06 + i * 0.02),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.02 + i * 0.02),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // safe content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header row - badge, title, avatar
                  Row(
                    children: [
                      // rounded badge
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            context.goNamed('bottomNavChild');
                          },
                          child: Center(
                            child: Icon(Icons.arrow_back_ios,color: Colors.blue,)
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Interactive Quizzes',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                      const Spacer(),
                      // avatar placeholder
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: Colors.grey.shade700),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Title
                  Text(
                    'Choose Your Challenge',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Select a category to start the quiz',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Grid — two columns responsive
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth =
                            (constraints.maxWidth - 6.w) /
                            2; // spacing accommodation
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Wrap(
                            spacing: 4.w,
                            runSpacing: 3.h,
                            children: List.generate(categories.length, (i) {
                              final cat = categories[i];
                              // Alternate two styles for variety
                              final isTall = i % 3 == 0; // some variation
                              return SizedBox(
                                width: itemWidth,
                                child: _buildAnimatedCard(i, cat, isTall),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, CategoryModel cat, bool tall) {
    final ctrl = _cardControllers[index];
    final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack);

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: GestureDetector(
          onTap: () {
            context.goNamed('quizQuestionScreen');
          },
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // glowing circular icon area
                Container(
                  width: tall ? 18.w : 14.w,
                  height: tall ? 18.w : 14.w,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.2, -0.2),
                      colors: [
                        cat.color.withValues(alpha: 0.95),
                        cat.color.withValues(alpha: 0.65),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cat.color.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      cat.icon,
                      color: Colors.white,
                      size: tall ? 8.w : 6.w,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  cat.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  cat.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 1.h),
                // rating stars row (playful)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final active = i < 5;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: active ? Colors.amber : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// small pulsing wrapper used for CTA
class AnimatedPulse extends StatefulWidget {
  final Widget child;
  const AnimatedPulse({required this.child, super.key});

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.98,
        end: 1.03,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// simple model
class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  CategoryModel(this.id, this.title, this.subtitle, this.icon, this.color);
}
