import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Provider
import '../../../viewmodels/child_view_model/rewards/child_rewards_provider.dart';
import '../../../viewmodels/child_view_model/rewards/child_rewards_view_model.dart';
import '../../viewmodels/child_view_model/rewards/child_rewards_state.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with TickerProviderStateMixin {

  late final AnimationController _masterController;
  late final Animation<Color?> _gradientAnimation;
  late final Animation<double> _shineAnimation;

  final List<AnimationController> _badgeControllers = [];

  @override
  void initState() {
    super.initState();

    // REMOVED: Manual call to loadRealRewardsData() to fix undefined method error.
    // The ViewModel should handle initialization internally or via the provider creation.
    // If you need to refresh, ensure the method exists in ViewModel or use ref.refresh(provider).

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

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

    for (int i = 0; i < 6; i++) {
      final badgeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _badgeControllers.add(badgeController);
      Future.delayed(Duration(milliseconds: 200 + i * 100), () {
        if (mounted) badgeController.forward();
      });
    }
  }
  void _showBadgeDialog(BuildContext context, String badgeName) {
    showDialog(
      context: context,
      barrierDismissible: false, // Must tap button
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.5),
                  boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 50, spreadRadius: 10)]
              ),
            ),
            // Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 3)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 60),
                  SizedBox(height: 10),
                  Text("CONGRATULATIONS!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.orange)),
                  SizedBox(height: 10),
                  Text("You earned the badge:", style: GoogleFonts.poppins(color: Colors.black54)),
                  Text(badgeName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.purple)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Awesome!", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _masterController.dispose();
    for (var c in _badgeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childRewardsViewModelProvider);
    ref.listen(childRewardsViewModelProvider, (previous, next) {
      if (next.newEarnedBadge != null) {
        // Show Celebration Dialog
        _showBadgeDialog(context, next.newEarnedBadge!);
        // Clear state so it doesn't show again on rebuild
        ref.read(childRewardsViewModelProvider.notifier).clearNotification();
      }
    });

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
                        _gradientAnimation.value!.withOpacity(0.7),
                        const Color(0xFF0f172a),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                CustomPaint(
                  painter: GeometricPatternPainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildPremiumAppBar(),
                          SizedBox(height: 3.h),

                          _buildAchievementHero(t, state),
                          SizedBox(height: 4.h),

                          _buildStatsDashboard(t, state),
                          SizedBox(height: 4.h),

                          _buildLevelProgression(t, state),
                          SizedBox(height: 4.h),

                          // Passes REAL state to the builder
                          _buildRewardCategories(t, state),
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
        GestureDetector(
          onTap: () => context.goNamed('bottomNavChild'),
          child: Container(
            width: 12.w, height: 12.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.2)]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade300, size: 20.sp),
              SizedBox(width: 2.w),
              Text("Achievements", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ],
          ),
        ),
        const Spacer(),
        Container(
          width: 12.w, height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Colors.cyan.shade400, Colors.blue.shade600]),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAchievementHero(double t, ChildRewardsState state) {
    return Transform.translate(
      offset: Offset(0, 10 * math.sin(t * 2 * math.pi)),
      child: Column(
        children: [
          Container(
            width: 25.w, height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 30, spreadRadius: 8)],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _shineAnimation.value * 2 * math.pi,
                  child: Container(
                    width: 25.w, height: 25.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Colors.white.withOpacity(0.4), Colors.transparent], stops: const [0.0, 0.7]),
                    ),
                  ),
                ),
                Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32.sp),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text("Level ${state.currentLevel} Explorer!", style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0)),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Text("Keep exploring to unlock more amazing rewards!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(double t, ChildRewardsState state) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          Text("Your Progress", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(icon: Icons.monetization_on_rounded, value: "${state.totalPoints}", label: "Coins", color: Colors.yellow.shade400, t: t, delay: 0.0),
              _buildDashboardStat(icon: Icons.workspace_premium_rounded, value: "${state.badgesEarned}", label: "Badges", color: Colors.cyan.shade400, t: t, delay: 0.3),
              _buildDashboardStat(icon: Icons.trending_up_rounded, value: "${state.currentLevel}", label: "Level", color: Colors.green.shade400, t: t, delay: 0.6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat({required IconData icon, required String value, required String label, required Color color, required double t, required double delay}) {
    final pulse = 1.0 + 0.05 * math.sin((t + delay) * 4 * math.pi);
    return Transform.scale(
      scale: pulse,
      child: Column(
        children: [
          Container(
            width: 16.w, height: 16.w,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.4)]), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))]),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(height: 1.h),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLevelProgression(double t, ChildRewardsState state) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("XP Progress", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
              Text("${(state.xpProgress * 100).toInt()}%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: [
              Container(height: 2.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 2.h,
                width: 85.w * state.xpProgress,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.cyan.shade400, Colors.blue.shade400]), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.6), blurRadius: 10)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UPDATED: NOW USES REAL DATA ---
  Widget _buildRewardCategories(double t, ChildRewardsState state) {
    // Logic: Check if badge exists in recentAchievements
    bool hasQuizBadge = state.recentAchievements.any((a) => a['title'] == 'Quiz Novice');
    bool hasStemBadge = state.recentAchievements.any((a) => a['title'] == 'STEM Explorer');
    bool hasQrBadge = state.recentAchievements.any((a) => a['title'] == 'Treasure Hunter');
    // If we don't have a specific badge string yet, fallback to point check or similar logic from ViewModel
    // Or if the user has > 0 points, give 'In Progress' credit visually

    // FIX: Ensure visual progress is shown even if badge not fully earned
    // If not earned but points exist, show some progress
    double quizProg = hasQuizBadge ? 1.0 : (state.totalPoints > 0 ? 0.4 : 0.0);
    double stemProg = hasStemBadge ? 1.0 : (state.totalPoints > 50 ? 0.3 : 0.0);

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Quiz Master',
        'icon': Icons.quiz_rounded,
        'progress': quizProg,
        'color': Colors.purple,
        'stars': hasQuizBadge ? 'Earned!' : 'In Progress'
      },
      {
        'title': 'STEM Star',
        'icon': Icons.science_rounded,
        'progress': stemProg,
        'color': Colors.blue,
        'stars': hasStemBadge ? 'Earned!' : 'In Progress'
      },
      {
        'title': 'Media Whiz',
        'icon': Icons.play_circle_filled_rounded,
        'progress': 0.6, // Mock progress for video as example
        'color': Colors.redAccent,
        'stars': 'In Progress'
      },
      {
        'title': 'Treasure Hunter',
        'icon': Icons.qr_code_scanner_rounded,
        'progress': hasQrBadge ? 1.0 : 0.2,
        'color': Colors.green,
        'stars': hasQrBadge ? 'Earned!' : 'In Progress'
      },
      {'title': 'Nature Explorer', 'icon': Icons.forest_rounded, 'progress': 0.0, 'color': Colors.orange, 'stars': 'Soon', 'locked': true},
      {'title': 'Game Pro', 'icon': Icons.sports_esports_rounded, 'progress': 0.0, 'color': Colors.pink, 'stars': 'Soon', 'locked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text("Your Badges", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 2.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4.w, mainAxisSpacing: 3.h, childAspectRatio: 1.1),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final bool isLocked = cat['locked'] ?? false;
            final color = isLocked ? Colors.grey : cat['color'] as Color;
            final controller = (index < _badgeControllers.length) ? _badgeControllers[index] : _badgeControllers.last;

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + 0.1 * controller.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.4)]),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(isLocked ? Icons.lock : cat['icon'], color: Colors.white, size: 20.sp),
                              ),
                              const Spacer(),
                              Text(cat['title'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                              Text(
                                  isLocked ? "Coming Soon" : cat['stars'],
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10.sp)
                              ),
                            ],
                          ),
                        ),
                        if (isLocked)
                          Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(25))),

                        // Progress Bar Visual
                        if (!isLocked)
                          Positioned(
                            bottom: 2.h, left: 4.w, right: 4.w,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: cat['progress'],
                                child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
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
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 10; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final radius = 20 + random.nextDouble() * 30;
      final dx = math.sin(time + i) * 20;
      final dy = math.cos(time + i) * 20;

      canvas.drawCircle(Offset(x + dx, y + dy), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) => true;
}