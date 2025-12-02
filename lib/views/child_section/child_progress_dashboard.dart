import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class ChildProgressDashboard extends StatefulWidget {
  const ChildProgressDashboard({super.key});

  @override
  State<ChildProgressDashboard> createState() => _ChildProgressDashboardState();
}

class _ChildProgressDashboardState extends State<ChildProgressDashboard>
    with TickerProviderStateMixin {

  late final AnimationController _masterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<Color?> _bgAnimation;
  late final AnimationController _shimmerController; // NEW: For shimmer effect

  // Mock Data
  final List<Map<String, dynamic>> _recentActivities = [
    {'title': 'Solar System Quiz', 'type': 'Quiz', 'score': '100%', 'time': '2 hrs ago', 'color': const Color(0xFF9C27B0)},
    {'title': 'Water Filter Build', 'type': 'STEM', 'score': 'Approved', 'time': 'Yesterday', 'color': const Color(0xFF2196F3)},
    {'title': 'Math Level 2', 'type': 'Quiz', 'score': '80%', 'time': '2 days ago', 'color': const Color(0xFF009688)},
    {'title': 'Garden Hunt', 'type': 'QR', 'score': 'Completed', 'time': '3 days ago', 'color': const Color(0xFFFF9800)},
  ];

  final Map<String, double> _skills = {
    'Science': 0.85,
    'Math': 0.60,
    'Logic': 0.75,
    'Creativity': 0.92
  };

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeAnimation = CurvedAnimation(parent: _masterController, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.2, curve: Curves.easeOut)),
    );

    _bgAnimation = ColorTween(
      begin: const Color(0xFF1A237E),
      end: const Color(0xFF311B92),
    ).animate(_masterController);
  }

  @override
  void dispose() {
    _masterController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('bottomNavChild');
        }
      },
      child: AnimatedBuilder(
          animation: Listenable.merge([_masterController, _shimmerController]),
          builder: (context, child) {
            return Scaffold(
              backgroundColor: _bgAnimation.value,
              body: Stack(
                children: [
                  // 1. Animated Background Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(const Color(0xFF0F2027), const Color(0xFF203A43), _masterController.value)!,
                          const Color(0xFF2C5364),
                          const Color(0xFF24243E),
                        ],
                      ),
                    ),
                  ),

                  // 2. Background Patterns
                  const _AnimatedBackground(),

                  // 3. Main Content
                  SafeArea(
                    child: FadeTransition(
                      opacity: const AlwaysStoppedAnimation(1.0),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              SizedBox(height: 4.h),

                              _buildWeeklyStreak(),
                              SizedBox(height: 4.h),

                              _buildSkillRadar(),
                              SizedBox(height: 4.h),

                              Text(
                                  "Your Journey",
                                  style: GoogleFonts.poppins(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [const Shadow(color: Colors.black45, blurRadius: 5)]
                                  )
                              ),
                              SizedBox(height: 2.h),
                              _buildTimelineList(),

                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // --- HEADER (FIXED OVERFLOW) ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () =>context.goNamed('bottomNavChild'),
          icon: Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
          ),
        ),
        // Wrapped in Expanded to prevent overflow
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, Explorer!",
                  style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Level Up!",
                  style: GoogleFonts.poppins(fontSize: 25.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        // Level Indicator with Shimmer
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 20.w, height: 20.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF2979FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2979FF).withOpacity(0.6), blurRadius: 20, spreadRadius: 2),
                    BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 5, offset: const Offset(-2, -2))
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)
              ),
            ),
            // Shimmer Effect Overlay
            IgnorePointer(
              child: Container(
                width: 20.w, height: 20.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerController.value * 2, -0.5),
                        end: Alignment(0.0 + _shimmerController.value * 2, 0.5),
                        colors: [Colors.transparent, Colors.white.withOpacity(0.4), Colors.transparent],
                        stops: const [0.4, 0.5, 0.6]
                    )
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("LVL", style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("3", style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
              ],
            ),
          ],
        )
      ],
    );
  }

  // --- WEEKLY STREAK ---
  Widget _buildWeeklyStreak() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better spacing handling
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 24.sp),
                      SizedBox(width: 2.w),
                      Text("4 Day Streak!", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                  Text("+50 XP", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.orangeAccent))
                ],
              ),
              SizedBox(height: 2.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  bool isActive = index < 4;
                  // Add staggered animation for streak items
                  double offset = math.sin((_masterController.value * 2 * math.pi) + (index * 0.5)) * 2;

                  return Transform.translate(
                    offset: Offset(0, isActive ? offset : 0),
                    child: Column(
                      children: [
                        Container(
                          width: 11.w, height: 11.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isActive
                                  ? const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent])
                                  : null,
                              color: isActive ? null : Colors.white.withOpacity(0.1),
                              boxShadow: isActive ? [BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)] : [],
                              border: Border.all(color: isActive ? Colors.white.withOpacity(0.6) : Colors.white24)
                          ),
                          child: Center(
                            child: isActive
                                ? Icon(Icons.check_rounded, color: Colors.white, size: 20.sp)
                                : Text(["M", "T", "W", "T", "F", "S", "S"][index], style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- SKILL MASTERY (Floating Animation Added) ---
  Widget _buildSkillRadar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Skill Power",
            style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [const Shadow(color: Colors.black45, blurRadius: 5)]
            )
        ),
        SizedBox(height: 2.5.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 2.5.h,
          childAspectRatio: 1.4,
          children: _skills.entries.map((entry) {
            Color skillColor = _getSkillColor(entry.key);
            // Add gentle floating animation to cards
            double float = math.sin((_masterController.value * 2 * math.pi) + entry.key.length) * 3;

            return Transform.translate(
              offset: Offset(0, float),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.08)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 16.w, width: 16.w,
                          child: CircularProgressIndicator(
                            value: entry.value,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(skillColor),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text("${(entry.value * 100).toInt()}%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.sp), // Adjusted size
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text("Mastery", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)), // Adjusted size
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Color _getSkillColor(String skill) {
    switch (skill) {
      case 'Science': return Colors.cyanAccent;
      case 'Math': return Colors.greenAccent;
      case 'Logic': return Colors.purpleAccent;
      default: return Colors.amberAccent;
    }
  }

  // --- TIMELINE LIST ---
  Widget _buildTimelineList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        final bool isLast = index == _recentActivities.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 6.w, height: 6.w,
                    decoration: BoxDecoration(
                        color: activity['color'],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: (activity['color'] as Color).withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: Colors.white30)),
                ],
              ),
              SizedBox(width: 4.w),

              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 2.5.h),
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrapped in Expanded to prevent overflow inside card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'],
                              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: Colors.white60, size: 14.sp),
                                SizedBox(width: 1.w),
                                Text("${activity['time']}", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white60)),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                        decoration: BoxDecoration(color: (activity['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(activity['score'], style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w800, color: activity['color'])),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// --- BACKGROUND PAINTER ---
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06)..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 8; i++) {
      final dx = (random.nextDouble() * size.width + progress * 30) % size.width;
      final dy = (random.nextDouble() * size.height + progress * 15) % size.height;
      final radius = 30 + random.nextDouble() * 80;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}