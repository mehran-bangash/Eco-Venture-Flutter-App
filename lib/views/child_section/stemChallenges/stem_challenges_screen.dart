import 'dart:math' as math;
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:eco_venture/views/child_section/stemChallenges/engineering_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/math_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/science_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/technology_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StemChallengesScreen extends StatefulWidget {
  const StemChallengesScreen({super.key});

  @override
  State<StemChallengesScreen> createState() => _StemChallengesScreenState();
}

class _StemChallengesScreenState extends State<StemChallengesScreen> with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late TabController _tabController;

  // Premium Theme Colors
  final Color _primaryDark = const Color(0xFF0F172A); // Slate 900
  final Color _subText = const Color(0xFF64748B); // Slate 500
  final Color _slate200 = const Color(0xFFE2E8F0);
  final Color _bgSurface = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        backgroundColor: _bgSurface,
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
                // Design System: Slate-tinted gradient background
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF1F5F9), Colors.white, Color(0xFFF8FAFC)],
                    ),
                  ),
                ),
                // Glow Blobs
                Positioned(
                  top: -5.h,
                  right: -15.w,
                  child: _buildGlowBlob(Colors.cyan.withOpacity(0.1), 70.w, t, 0),
                ),
                Positioned(
                  bottom: 5.h,
                  left: -20.w,
                  child: _buildGlowBlob(Colors.amber.withOpacity(0.1), 80.w, t, 2),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      SizedBox(height: 1.h),
                      _buildTabBar(),

                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _buildTabContent(_tabController.index),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0: return const ScienceScreen(key: ValueKey('science'));
      case 1: return const MathScreen(key: ValueKey('math'));
      case 2: return const EngineeringScreen(key: ValueKey('eng'));
      case 3: return const TechnologyScreen(key: ValueKey('tech'));
      default: return const ScienceScreen();
    }
  }

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(30 * math.sin(t * 2 * math.pi + phase),
          30 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.goNamed('bottomNavChild'),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _slate200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark, size: 17.sp),
            ),
          ),
          const Spacer(),
          Text(
            "STEM Challenges",
            style: GoogleFonts.poppins(
              color: _primaryDark,
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ButtonsTabBar(
        controller: _tabController,
        backgroundColor: _getCategoryColor(_tabController.index),
        unselectedBackgroundColor: Colors.white,
        unselectedLabelStyle: GoogleFonts.poppins(color: _subText, fontWeight: FontWeight.w600),
        labelStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        elevation: 8,
        borderColor: _slate200,
        unselectedBorderColor: _slate200,
        borderWidth: 1.5,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
        buttonMargin: EdgeInsets.symmetric(horizontal: 2.w),
        tabs: [
          _buildTab(Icons.science_rounded, 'Science', Colors.cyan),
          _buildTab(Icons.calculate_rounded, 'Math', Colors.green),
          _buildTab(Icons.engineering_rounded, 'Eng.', Colors.orange),
          _buildTab(Icons.computer_rounded, 'Tech.', Colors.indigo),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    switch (index) {
      case 0: return Colors.cyan;
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.indigo;
      default: return Colors.blue;
    }
  }

  Tab _buildTab(IconData icon, String text, Color color) {
    return Tab(
      child: Row(
        children: [
          Icon(icon, size: 18.sp,
              color: _tabController.index == _getTabIndex(text) ? Colors.white : color),
          SizedBox(width: 1.5.w),
          Text(text),
        ],
      ),
    );
  }

  int _getTabIndex(String text) {
    if (text == 'Science') return 0;
    if (text == 'Math') return 1;
    if (text == 'Eng.') return 2;
    if (text == 'Tech.') return 3;
    return 0;
  }
}