import 'dart:math' as math;
import 'package:eco_venture/views/child_section/multimedia/story_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChildMultimediaScreen extends StatefulWidget {
  const ChildMultimediaScreen({super.key});

  @override
  State<ChildMultimediaScreen> createState() => _ChildMultimediaScreenState();
}

class _ChildMultimediaScreenState extends State<ChildMultimediaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final AnimationController _masterController;

  // Professional Theme Palette
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _slate200 = const Color(0xFFE2E8F0);
  final Color _bgSurface = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _tabController = TabController(length: 2, vsync: this);
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
                // 1. Premium Animated Background
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
                Positioned(
                  top: -5.h,
                  right: -15.w,
                  child: _buildGlowBlob(const Color(0xFF06B6D4).withOpacity(0.12), 70.w, t, 0),
                ),
                Positioned(
                  bottom: 5.h,
                  left: -20.w,
                  child: _buildGlowBlob(const Color(0xFFF59E0B).withOpacity(0.08), 80.w, t, 2),
                ),

                // 2. Main Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildCustomHeader(context),
                      SizedBox(height: 1.h),
                      _buildCustomTabBar(context),

                      // 3. Tab Content with Premium Transitions
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
                          child: _tabController.index == 0
                              ? const VideoScreen(key: ValueKey('videos'))
                              : const StoryScreen(key: ValueKey('stories')),
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

  Widget _buildCustomHeader(BuildContext context) {
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
              child: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 17.sp),
            ),
          ),
          Expanded(
            child: Text(
              "Multimedia Content",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 19.sp,
                color: _primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: _slate200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _tabController.index == 0 ? const Color(0xFF06B6D4) : const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: (_tabController.index == 0 ? const Color(0xFF06B6D4) : const Color(0xFFF59E0B)).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: _subText,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 15.sp),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_rounded, size: 20),
                  SizedBox(width: 8),
                  Text("Videos"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 20),
                  SizedBox(width: 8),
                  Text("Stories"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}