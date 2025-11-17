import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin{
  late final AnimationController _masterController;
  // late final Animation<double> _floatAnimation;
  late final Animation<Color?> _gradientAnimation;
  late final Animation<double> _shineAnimation;

  final List<AnimationController> _badgeControllers = [];

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // _floatAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
    //   CurvedAnimation(
    //     parent: _masterController,
    //     curve: Curves.easeInOutSine,
    //   ),
    // );

    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF667eea),
      end: const Color(0xFF764ba2),
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: Curves.easeInOut,
    ));

    // Initialize badge animations with cascading delay
    for (int i = 0; i < 12; i++) {
      final badgeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      _badgeControllers.add(badgeController);

      Future.delayed(Duration(milliseconds: 200 + i * 100), () {
        if (mounted) badgeController.forward();
      });
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    for (var controller in _badgeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
                // Premium Gradient Background
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.3 + 0.2 * math.sin(t * 2), 0.4 + 0.1 * math.cos(t * 3)),
                      radius: 2.0,
                      colors: [
                        _gradientAnimation.value!,
                        _gradientAnimation.value!.withValues(alpha:0.7),
                        const Color(0xFF0f172a),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                // Animated Geometric Patterns
                CustomPaint(
                  painter: GeometricPatternPainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                // Main Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildPremiumAppBar(),
                          SizedBox(height: 3.h),
                          _buildAchievementHero(t),
                          SizedBox(height: 4.h),
                          _buildStatsDashboard(t),
                          SizedBox(height: 4.h),
                          _buildLevelProgression(t),
                          SizedBox(height: 4.h),
                          _buildBadgeCollection(),
                          SizedBox(height: 4.h),
                          _buildRewardCategories(t),
                          SizedBox(height: 6.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Row(
      children: [
        // Back Button with Premium Design
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
            onPressed: () => context.goNamed('bottomNavChild'),
          ),
        ),

        const Spacer(),

        // Premium Title
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purpleAccent.withValues(alpha: 0.3),
                Colors.blueAccent.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade300, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                "Achievements",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Premium Profile Avatar
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.cyan.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementHero(double t) {
    return Transform.translate(
      offset: Offset(0, 15 * math.sin(t * 2 * math.pi)),
      child: Column(
        children: [
          // Animated Trophy Container
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shine Effect
                AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _shineAnimation.value * 2 * math.pi,
                      child: Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32.sp),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Premium Title Text
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.amber.shade300, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "Champion Explorer!",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Subtitle with Premium Design
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              "Keep exploring to unlock more amazing rewards!",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(double t) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Your Progress Dashboard",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 3.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(
                icon: Icons.star_rate_rounded,
                value: "1,250",
                label: "Stars",
                color: Colors.amber.shade400,
                t: t,
                delay: 0.0,
              ),
              _buildDashboardStat(
                icon: Icons.monetization_on_rounded,
                value: "8,400",
                label: "Coins",
                color: Colors.yellow.shade400,
                t: t,
                delay: 0.3,
              ),
              _buildDashboardStat(
                icon: Icons.workspace_premium_rounded,
                value: "12",
                label: "Badges",
                color: Colors.cyan.shade400,
                t: t,
                delay: 0.6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double t,
    required double delay,
  }) {
    final pulse = 1.0 + 0.1 * math.sin((t + delay) * 4 * math.pi);

    return Transform.scale(
      scale: pulse,
      child: Column(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgression(double t) {
    final glow = 0.5 + 0.5 * math.sin(t * 6 * math.pi);

    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purpleAccent.withValues(alpha: 0.3),
            Colors.blueAccent.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Explorer Level 3",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "80% Complete",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Premium Progress Bar
          Stack(
            children: [
              // Background Track
              Container(
                height: 2.5.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              // Progress Fill with Glow
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 2.5.h,
                width: 85.w * 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.shade400,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.6 * glow),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),

              // Progress Indicators
              Positioned(
                left: 20.w,
                child: Container(
                  width: 4,
                  height: 2.5.h,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                left: 40.w,
                child: Container(
                  width: 4,
                  height: 2.5.h,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                left: 60.w,
                child: Container(
                  width: 4,
                  height: 2.5.h,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          Text(
            "Only 20% more to reach Level 4!",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            "Badge Collection",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        SizedBox(
          height: 25.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (context, index) {
              final controller = _badgeControllers[index];
              final colors = [
                [Colors.amber, Colors.orange],
                [Colors.blue, Colors.cyan],
                [Colors.green, Colors.lightGreen],
                [Colors.purple, Colors.pink],
                [Colors.red, Colors.orange],
                [Colors.teal, Colors.cyan],
                [Colors.indigo, Colors.purple],
                [Colors.lime, Colors.green],
                [Colors.deepOrange, Colors.red],
                [Colors.blueGrey, Colors.grey],
                [Colors.deepPurple, Colors.purple],
                [Colors.brown, Colors.orange],
              ];

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - controller.value) * 50),
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * controller.value,
                      child: Container(
                        width: 20.w,
                        margin: EdgeInsets.only(right: 3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: colors[index % colors.length],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[index % colors.length][0].withValues(alpha: 0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCategories(double t) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Nature Explorer',
        'icon': Icons.forest_rounded,
        'progress': 0.8,
        'color': Colors.green,
        'stars': '45'
      },
      {
        'title': 'Science Whiz',
        'icon': Icons.science_rounded,
        'progress': 0.6,
        'color': Colors.blue,
        'stars': '32'
      },
      {
        'title': 'Game Master',
        'icon': Icons.sports_esports_rounded,
        'progress': 0.9,
        'color': Colors.orange,
        'stars': '78'
      },
      {
        'title': 'Quiz Champion',
        'icon': Icons.quiz_rounded,
        'progress': 0.7,
        'color': Colors.purple,
        'stars': '56'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            "Reward Categories",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 3.h,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = category['color'] as Color;
            final pulse = 1.0 + 0.05 * math.sin(t * 4 * math.pi + index);

            return Transform.scale(
              scale: pulse,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 14.w,
                            height: 14.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),

                          Text(
                            category['title'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          // Progress
                          Container(
                            height: 0.8.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  width: (100.w - 16.w) * (category['progress'] as double),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 1.h),

                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                              SizedBox(width: 1.w),
                              Text(
                                '${category['stars']} Stars',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final double time;

  GeometricPatternPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    // Draw geometric patterns
    for (int i = 0; i < 8; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final sizeFactor = 20 + random.nextDouble() * 40;
      final rotation = time * 2 + i;

      final path = Path();

      if (i % 3 == 0) {
        // Draw triangles
        path.moveTo(x, y - sizeFactor);
        path.lineTo(x - sizeFactor, y + sizeFactor);
        path.lineTo(x + sizeFactor, y + sizeFactor);
        path.close();
      } else if (i % 3 == 1) {
        // Draw diamonds
        path.moveTo(x, y - sizeFactor);
        path.lineTo(x + sizeFactor, y);
        path.lineTo(x, y + sizeFactor);
        path.lineTo(x - sizeFactor, y);
        path.close();
      } else {
        // Draw circles
        canvas.drawCircle(Offset(x, y), sizeFactor / 2, paint);
        continue;
      }

      // Rotate and draw the shape
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation)
        ..translate(-x, -y);
      path.transform(matrix.storage);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) => true;
}