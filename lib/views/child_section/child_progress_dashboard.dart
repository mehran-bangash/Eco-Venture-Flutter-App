import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/child_view_model/child_progress_dashboard/child_progress_provider.dart';
import '../../viewmodels/child_view_model/child_progress_dashboard/child_progress_state.dart';

class ChildProgressDashboard extends ConsumerStatefulWidget {
  const ChildProgressDashboard({super.key});

  @override
  ConsumerState<ChildProgressDashboard> createState() => _ChildProgressDashboardState();
}

class _ChildProgressDashboardState extends ConsumerState<ChildProgressDashboard>
    with TickerProviderStateMixin {

  late final AnimationController _masterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<Color?> _bgAnimation;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
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
    // 1. Watch Real Data
    final state = ref.watch(childProgressViewModelProvider);

    return AnimatedBuilder(
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

                const _AnimatedBackground(),

                // 2. Main Content
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
                            _buildHeader(state),
                            SizedBox(height: 4.h),

                            _buildWeeklyStreak(state),
                            SizedBox(height: 4.h),

                            _buildSkillRadar(state),
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

                            if (state.isLoading)
                              const Center(child: CircularProgressIndicator(color: Colors.white))
                            else if (state.timeline.isEmpty)
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(2.h),
                                    child: Text("No activity yet. Start exploring!", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14.sp)),
                                  )
                              )
                            else
                              _buildTimelineList(state.timeline),

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
    );
  }

  // --- HEADER ---
  Widget _buildHeader(ChildProgressState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => context.pop(),
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total XP: ${state.totalPoints}",
                  style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.cyanAccent, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Level ${state.currentLevel}",
                  style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        // Level Indicator
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 20.w, height: 20.w,
              child: CircularProgressIndicator(
                value: state.xpProgress, // Real Progress
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
                strokeWidth: 6,
              ),
            ),
            Container(
              width: 16.w, height: 16.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF2979FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2979FF).withOpacity(0.6), blurRadius: 20, spreadRadius: 2),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("LVL", style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("${state.currentLevel}", style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- WEEKLY STREAK (FIXED DAY LOGIC) ---
  Widget _buildWeeklyStreak(ChildProgressState state) {
    final bool hasStreak = state.dayStreak > 0;
    // Calculate current day index (Mon=0, Tue=1, ..., Sun=6)
    final int currentDayIndex = DateTime.now().weekday - 1;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: hasStreak ? Colors.orangeAccent : Colors.grey, size: 24.sp),
                      SizedBox(width: 2.w),
                      Text(
                          hasStreak ? "${state.dayStreak} Day Streak!" : "Start a Streak!",
                          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)
                      ),
                    ],
                  ),
                  // Clarified Text
                  Text("Streak Bonus", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.orangeAccent))
                ],
              ),
              SizedBox(height: 2.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  // Highlight: If this day is TODAY or BEFORE today (and streak exists)
                  // Simple logic: If streak > 0, highlight up to today
                  bool isActive = hasStreak && index <= currentDayIndex;
                  bool isToday = index == currentDayIndex;

                  return Column(
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
                            border: Border.all(
                                color: isToday ? Colors.white : (isActive ? Colors.white.withOpacity(0.6) : Colors.white24),
                                width: isToday ? 2 : 1
                            )
                        ),
                        child: Center(
                          child: isActive
                              ? Icon(Icons.check_rounded, color: Colors.white, size: 20.sp)
                              : Text(["M", "T", "W", "T", "F", "S", "S"][index], style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- SKILL MASTERY (RENAMED TO MATCH MODULES) ---
  Widget _buildSkillRadar(ChildProgressState state) {
    // Using exact module names now
    final Map<String, double> mappedSkills = {
      'Science': state.skillStats['Science'] ?? 0.0,
      'Math': state.skillStats['Math'] ?? 0.0,
      'QR Hunt': state.skillStats['Logic'] ?? 0.0, // Replaced 'Logic' label visually
      'STEM': state.skillStats['Creativity'] ?? 0.0 // Replaced 'Creativity' label visually
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Module Mastery",
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
          children: mappedSkills.entries.map((entry) {
            Color skillColor = _getSkillColor(entry.key);
            return Container(
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
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text("Progress", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                      ],
                    ),
                  )
                ],
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
      case 'QR Hunt': return Colors.purpleAccent; // Logic color
      default: return Colors.amberAccent; // STEM/Creativity color
    }
  }

  // --- TIMELINE LIST ---
  Widget _buildTimelineList(List<Map<String, dynamic>> timeline) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final activity = timeline[index];
        final bool isLast = index == timeline.length - 1;

        final Color itemColor = activity['color'] as Color;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 6.w, height: 6.w,
                    decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: itemColor.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
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
                        decoration: BoxDecoration(color: itemColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(activity['type'], style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w800, color: itemColor)),
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

// --- ANIMATED BACKGROUND PAINTER ---
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