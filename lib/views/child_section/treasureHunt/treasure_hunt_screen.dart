import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  State<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  // late final Animation<double> _pulseAnimation;
  // late final Animation<double> _floatAnimation;
  late final Animation<Color?> _gradientAnimation;

  final int _clueCount = 4;
  final List<bool> _visibleClues = [];
  final List<AnimationController> _cardControllers = [];

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
    //   CurvedAnimation(
    //     parent: _masterController,
    //     curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    //   ),
    // );
    //
    // _floatAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
    //   CurvedAnimation(
    //     parent: _masterController,
    //     curve: Curves.easeInOutSine,
    //   ),
    // );

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF4361EE), // More vibrant blue
      end: const Color(0xFF3A0CA3),   // Deeper purple
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: Curves.easeInOut,
    ));

    for (int i = 0; i < _clueCount; i++) {
      _visibleClues.add(false);
      final cardController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _cardControllers.add(cardController);

      Future.delayed(Duration(milliseconds: 300 + i * 200), () {
        if (mounted) {
          setState(() => _visibleClues[i] = true);
          cardController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Alignment _bgAlignment(double t) {
    final dx = 0.5 + 0.3 * math.sin(t * 2 * math.pi);
    final dy = 0.3 + 0.2 * math.cos(t * 3 * math.pi);
    return Alignment(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final clues = [
      {"title": "The Ancient Oak", "time": "2 hours ago", "icon": Icons.park},
      {"title": "Crimson Bridge", "time": "1 day ago", "icon": Icons.park},
      {"title": "Sunken Statue", "time": "3 days ago", "icon": Icons.architecture},
      {"title": "Golden Griffin", "time": "5 days ago", "icon": Icons.auto_awesome},
    ];

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
                // Animated Background - More vibrant
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: _bgAlignment(t),
                      radius: 1.8,
                      colors: [
                        _gradientAnimation.value!,
                        _gradientAnimation.value!.withValues(alpha: 0.8), // Less opacity for better contrast
                        const Color(0xFF1a1f35), // Darker background for contrast
                      ],
                      stops: const [0.1, 0.5, 1.0],
                    ),
                  ),
                ),

                // Floating Particles
                CustomPaint(
                  painter: ParticlePainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                // Main Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          SizedBox(height: 3.h),
                          _buildHeroSection(t),
                          SizedBox(height: 4.h),
                          _buildStatsRow(t),
                          SizedBox(height: 4.h),
                          _buildProgressSection(t),
                          SizedBox(height: 4.h),
                          _buildCluesGrid(clues),
                          SizedBox(height: 4.h),
                          _buildCurrentQuestCard(t),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        _buildGlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => context.goNamed('bottomNavChild'),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.25), // More opaque
                Colors.white.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)), // Brighter border
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.yellow.shade400, size: 18.sp), // Brighter yellow
              SizedBox(width: 2.w),
              Text(
                "Treasure Hunt",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildUserAvatar(),
      ],
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2), // More opaque
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)), // Brighter border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade500, Colors.purple.shade500], // More vibrant
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4), // Brighter shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white, size: 16.sp),
        ),
      ),
    );
  }

  Widget _buildHeroSection(double t) {
    return Transform.translate(
      offset: Offset(0, 10 * math.sin(t * 2 * math.pi)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.yellow.shade500, Colors.orange.shade500], // More vibrant
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.6), // Brighter glow
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            "Adventure Awaits!",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Discover hidden treasures and unlock mysteries",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp, // Brighter text
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAnimatedStatCard(
          label: "Coins",
          value: "128",
          icon: Icons.monetization_on_rounded,
          color: Colors.yellow.shade600, // More vibrant
          t: t,
          delay: 0,
        ),
        _buildAnimatedStatCard(
          label: "Badges",
          value: "5",
          icon: Icons.workspace_premium_rounded,
          color: Colors.blue.shade400, // More vibrant
          t: t,
          delay: 0.2,
        ),
        _buildAnimatedStatCard(
          label: "Level",
          value: "12",
          icon: Icons.trending_up_rounded,
          color: Colors.green.shade500, // More vibrant
          t: t,
          delay: 0.4,
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double t,
    required double delay,
  }) {
    final animationValue = (t + delay) % 1.0;
    final scale = 1.0 + 0.05 * math.sin(animationValue * 2 * math.pi);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 28.w,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25), // More opaque
              Colors.white.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)), // Brighter border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3), // Darker shadow for contrast
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.3), // More opaque
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(double t) {
    final found = 4;
    final total = 6;
    final progress = found / total;

    return Container(
      width: 100.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25), // More opaque
            Colors.white.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)), // Brighter border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // Darker shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quest Progress",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.blue.shade500], // More vibrant
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$found/$total",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Stack(
            children: [
              // Background
              Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3), // More opaque
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 2.h,
                width: 90.w * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.shade500, // More vibrant
                      Colors.orange.shade500,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.8), // Brighter glow
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(total, (index) {
              final isFound = index < found;
              final pulse = 1.0 + 0.1 * math.sin(t * 4 * math.pi + index);
              return Transform.scale(
                scale: isFound ? pulse : 1.0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFound ? Colors.orange.shade500 : Colors.white.withValues(alpha: 0.3), // More opaque
                    boxShadow: isFound
                        ? [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.6), // Brighter glow
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                  child: isFound
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 14.sp)
                      : Icon(Icons.lock_rounded, color: Colors.white70, size: 12.sp),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCluesGrid(List<Map<String, Object>> clues) {
    return GridView.builder(
      itemCount: clues.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final data = clues[index];
        final visible = _visibleClues[index];
        final controller = _cardControllers[index];

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: visible ? 1 : 0,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - controller.value) * 50),
                child: Transform.scale(
                  scale: 0.9 + 0.1 * controller.value,
                  child: _buildClueCard(
                    title: data["title"] as String,
                    subtitle: data["time"] as String,
                    icon: data["icon"] as IconData,
                    isFound: true,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildClueCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isFound,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFound
              ? [
            Colors.blue.shade500.withValues(alpha: 0.9), // More vibrant and opaque
            Colors.purple.shade500.withValues(alpha:0.9),
          ]
              : [
            Colors.grey.shade700.withValues(alpha:0.8),
            Colors.grey.shade900.withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4), // Darker shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine Effect
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2), // More opaque
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
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3), // More opaque
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16.sp),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  "Found: $subtitle",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500.withValues(alpha: 0.4), // More vibrant
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade500),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded, color: Colors.white, size: 12.sp),
                          SizedBox(width: 1.w),
                          Text(
                            "Completed",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestCard(double t) {
    final glowIntensity = 0.5 + 0.5 * math.sin(t * 4 * math.pi);

    return Transform.translate(
      offset: Offset(0, 5 * math.sin(t * 2 * math.pi)),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade500.withValues(alpha: 0.95), // More vibrant
              Colors.red.shade500.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.6 * glowIntensity), // Brighter glow
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), // Darker shadow
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3), // More opaque
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Current Quest",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.flash_on_rounded, color: Colors.yellow.shade400, size: 18.sp), // Brighter
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              "The Whispering Fountain",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Discover the ancient secrets hidden beneath the mystical waters",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: () => context.goNamed('clueLockedScreen'),
              child: Container(
                width: 100.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3), // Darker shadow
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: Colors.orange.shade500, size: 20.sp), // More vibrant
                    SizedBox(width: 2.w),
                    Text(
                      "Scan to Discover",
                      style: GoogleFonts.poppins(
                        color: Colors.orange.shade500,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
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

class ParticlePainter extends CustomPainter {
  final double time;

  ParticlePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.15); // Brighter particles

    for (int i = 0; i < 15; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 1 + random.nextDouble() * 3;
      final driftX = math.sin(time * 2 + i) * 10;
      final driftY = math.cos(time * 3 + i) * 10;

      canvas.drawCircle(
        Offset(x + driftX, y + driftY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}