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
  ConsumerState<ChildProgressDashboard> createState() =>
      _ChildProgressDashboardState();
}

class _ChildProgressDashboardState extends ConsumerState<ChildProgressDashboard>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _shimmerController;

  // Professional Theme Colors - Moving to a "Slate/Cool" palette for depth
  final Color _primaryDark = const Color(0xFF0F172A); // Darker slate for premium feel
  final Color _subText = const Color(0xFF64748B);
  final Color _accentCyan = const Color(0xFF06B6D4);
  final Color _bgSurface = const Color(0xFFF8FAFC); // Off-white/Slate-50 for depth

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _masterController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childProgressViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: _bgSurface,
        body: AnimatedBuilder(
          animation: Listenable.merge([_masterController, _shimmerController]),
          builder: (context, child) {
            final t = _masterController.value;
            return Stack(
              children: [
                // 1. Enhanced Background Gradient (Not just pure white)
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF1F5F9), // Slate 100
                        Colors.white,
                        const Color(0xFFF8FAFC), // Slate 50
                      ],
                    ),
                  ),
                ),

                // 2. Animated Glow Blobs (Deeper colors for more "weight")
                Positioned(
                  top: -5.h,
                  right: -15.w,
                  child: _buildGlowBlob(Colors.cyan.withOpacity(0.15), 75.w, t, 0),
                ),
                Positioned(
                  bottom: 5.h,
                  left: -25.w,
                  child: _buildGlowBlob(Colors.indigo.withOpacity(0.08), 85.w, t, 2),
                ),
                Positioned(
                  top: 25.h,
                  left: 15.w,
                  child: _buildGlowBlob(Colors.amber.withOpacity(0.1), 55.w, t, 4),
                ),

                // 3. Main Content
                SafeArea(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(state),
                          SizedBox(height: 3.h),

                          _buildWeeklyStreak(state),
                          SizedBox(height: 3.5.h),

                          _buildSkillRadar(state),
                          SizedBox(height: 3.5.h),

                          Padding(
                            padding: EdgeInsets.only(left: 1.w),
                            child: Text(
                              "Your Journey",
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: _primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          if (state.isLoading)
                            const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                          else if (state.timeline.isEmpty)
                            _buildEmptyState()
                          else
                            _buildTimelineList(state.timeline),

                          SizedBox(height: 8.h),
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

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(40 * math.sin(t * 2 * math.pi + phase),
          40 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ChildProgressState state) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.goNamed('bottomNavChild'),
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)), // slate 200
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4)
                )
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 17.sp),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL XP: ${state.totalPoints}",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: const Color(0xFF0EA5E9),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "Level ${state.currentLevel}",
                style: GoogleFonts.poppins(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w900,
                  color: _primaryDark,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        _buildLevelIndicator(state),
      ],
    );
  }

  Widget _buildLevelIndicator(ChildProgressState state) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 18.w,
          height: 18.w,
          child: CircularProgressIndicator(
            value: state.xpProgress,
            backgroundColor: const Color(0xFFF1F5F9), // slate 100
            valueColor: const AlwaysStoppedAnimation(Color(0xFF06B6D4)),
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
          ),
        ),
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5)
              )
            ],
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              "${state.currentLevel}",
              style: GoogleFonts.poppins(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStreak(ChildProgressState state) {
    final bool hasStreak = state.dayStreak > 0;
    final int currentDayIndex = DateTime.now().weekday - 1;

    return Container(
      padding: EdgeInsets.all(5.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 35,
              spreadRadius: 2,
              offset: const Offset(0, 15)
          ),
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2)
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_fire_department_rounded,
                        color: hasStreak ? Colors.orange : const Color(0xFFCBD5E1), size: 21.sp), // slate 300
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    hasStreak ? "${state.dayStreak} Day Streak!" : "Start a Streak!",
                    style: GoogleFonts.poppins(
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.w800,
                        color: _primaryDark
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("BONUS XP",
                    style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isActive = hasStreak && index <= currentDayIndex;
              bool isToday = index == currentDayIndex;
              return Column(
                children: [
                  Container(
                    width: 10.5.w,
                    height: 10.5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.orange : const Color(0xFFF8FAFC), // slate 50
                      border: Border.all(
                        color: isToday ? Colors.orange : (isActive ? Colors.orange.shade200 : const Color(0xFFE2E8F0)), // slate 200
                        width: isToday ? 2.5 : 1.5,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Center(
                      child: isActive
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                          : Text(["M", "T", "W", "T", "F", "S", "S"][index],
                          style: GoogleFonts.poppins(
                              color: _subText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800
                          )),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRadar(ChildProgressState state) {
    final Map<String, double> mappedSkills = {
      'Science': state.skillStats['Science'] ?? 0.0,
      'Math': state.skillStats['Math'] ?? 0.0,
      'Logic': state.skillStats['Logic'] ?? 0.0,
      'Creativity': state.skillStats['Creativity'] ?? 0.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w),
          child: Text(
            "Module Mastery",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 2.2.h,
          childAspectRatio: 1.25,
          children: mappedSkills.entries.map((entry) {
            Color skillColor = _getSkillColor(entry.key);
            return Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: skillColor.withOpacity(0.25), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: skillColor.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 10)
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 14.5.w,
                        width: 14.5.w,
                        child: CircularProgressIndicator(
                          value: entry.value,
                          backgroundColor: const Color(0xFFF8FAFC), // slate 50
                          valueColor: AlwaysStoppedAnimation(skillColor),
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text("${(entry.value * 100).toInt()}%",
                          style: GoogleFonts.poppins(
                              color: _primaryDark,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800
                          )),
                    ],
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: GoogleFonts.poppins(
                                color: _primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5.sp,
                                height: 1.1
                            ),
                            overflow: TextOverflow.ellipsis),
                        Text("MASTERED",
                            style: GoogleFonts.poppins(
                                color: _subText,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getSkillColor(String skill) {
    switch (skill) {
      case 'Science': return const Color(0xFF06B6D4);
      case 'Math': return const Color(0xFF10B981);
      case 'Logic': return const Color(0xFF8B5CF6);
      default: return const Color(0xFFF59E0B);
    }
  }

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
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      color: itemColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: itemColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1
                        )
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2.5, color: const Color(0xFFF1F5F9))), // slate 100
                ],
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 2.2.h),
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)), // slate 100
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8)
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 15.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryDark
                                )),
                            SizedBox(height: 0.4.h),
                            Row(
                              children: [
                                Icon(Icons.history_rounded, size: 12.sp, color: _subText),
                                SizedBox(width: 1.w),
                                Text("${activity['time']}",
                                    style: GoogleFonts.poppins(fontSize: 12.sp, color: _subText, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.6.h),
                        decoration: BoxDecoration(
                            color: itemColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text(activity['type'].toString().toUpperCase(),
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                color: itemColor,
                                letterSpacing: 0.5
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Opacity(
            opacity: 0.1,
            child: Icon(Icons.auto_awesome_rounded, size: 45.sp, color: _primaryDark),
          ),
          SizedBox(height: 1.5.h),
          Text("No activity yet. Start exploring!",
              style: GoogleFonts.poppins(
                  color: _subText,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600
              )),
        ],
      ),
    );
  }
}