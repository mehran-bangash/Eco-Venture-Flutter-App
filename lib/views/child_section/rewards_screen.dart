import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Providers
import '../../../viewmodels/child_view_model/rewards/child_rewards_provider.dart';
import '../../../viewmodels/child_view_model/rewards/child_rewards_state.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final Animation<double> _shineAnimation;
  final List<AnimationController> _badgeControllers = [];

  final Color _primaryDark = const Color(0xFF1E293B);
  final Color _subText = const Color(0xFF64748B);
  final Color _accentCyan = const Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    for (int i = 0; i < 5; i++) {
      final badgeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _badgeControllers.add(badgeController);
      Future.delayed(Duration(milliseconds: 300 + i * 150), () {
        if (mounted) badgeController.forward();
      });
    }
  }

  void _showBadgeDialog(BuildContext context, String badgeName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 60,
                        spreadRadius: 20)
                  ]),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 20)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium,
                      color: Colors.amber, size: 70),
                  const SizedBox(height: 16),
                  Text("CONGRATULATIONS!",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.orange)),
                  const SizedBox(height: 8),
                  Text("You earned the badge:",
                      style: GoogleFonts.poppins(color: _subText)),
                  Text(badgeName,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.sp,
                          color: _primaryDark)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text("Awesome!",
                        style: TextStyle(color: Colors.white)),
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
        _showBadgeDialog(context, next.newEarnedBadge!);
        ref.read(childRewardsViewModelProvider.notifier).clearNotification();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
                Positioned(
                  top: -10.h,
                  right: -10.w,
                  child: _buildGlowBlob(
                      Colors.cyan.withOpacity(0.15), 60.w, t, 0),
                ),
                Positioned(
                  bottom: 10.h,
                  left: -20.w,
                  child: _buildGlowBlob(
                      Colors.pink.withOpacity(0.1), 80.w, t, 2),
                ),
                Positioned(
                  top: 30.h,
                  right: 10.w,
                  child: _buildGlowBlob(
                      Colors.amber.withOpacity(0.1), 40.w, t, 4),
                ),

                CustomPaint(
                  painter: GeometricPatternPainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                SafeArea(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildPremiumAppBar(),
                          SizedBox(height: 2.h),
                          _buildAchievementHero(t, state),
                          SizedBox(height: 3.h),
                          _buildStatsDashboard(t, state),
                          SizedBox(height: 3.h),
                          _buildLevelProgression(t, state),
                          SizedBox(height: 4.h),
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

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(20 * math.sin(t * 2 * math.pi + phase),
          20 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
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
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: _primaryDark, size: 18.sp),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: Colors.amber.shade600, size: 18.sp),
              SizedBox(width: 2.w),
              Text("Achievements",
                  style: GoogleFonts.poppins(
                      color: _primaryDark,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const Spacer(),
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: [Colors.cyan.shade300, Colors.blue.shade500]),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAchievementHero(double t, ChildRewardsState state) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, 8 * math.sin(t * 2 * math.pi)),
          child: Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500]),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 5)
              ],
            ),
            child: Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 30.sp),
          ),
        ),
        SizedBox(height: 2.h),
        Text("Level ${state.currentLevel} Explorer!",
            style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: _primaryDark)),
        SizedBox(height: 0.5.h),
        Text("Keep exploring to unlock more rewards!",
            style: GoogleFonts.poppins(
                color: _subText, fontSize: 12.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatsDashboard(double t, ChildRewardsState state) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Your Progress",
              style: GoogleFonts.poppins(
                  color: _primaryDark,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardStat(
                  icon: Icons.monetization_on_rounded,
                  value: "${state.totalPoints}",
                  label: "Coins",
                  color: Colors.amber.shade400,
                  t: t,
                  delay: 0.0),
              _buildDashboardStat(
                  icon: Icons.workspace_premium_rounded,
                  value: "${state.badgesEarned}",
                  label: "Badges",
                  color: Colors.cyan.shade400,
                  t: t,
                  delay: 0.3),
              _buildDashboardStat(
                  icon: Icons.trending_up_rounded,
                  value: "${state.currentLevel}",
                  label: "Level",
                  color: Colors.green.shade400,
                  t: t,
                  delay: 0.6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(
      {required IconData icon,
        required String value,
        required String label,
        required Color color,
        required double t,
        required double delay}) {
    return Column(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color.withOpacity(0.12)),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 1.2.h),
        Text(value,
            style: GoogleFonts.poppins(
                color: _primaryDark,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: GoogleFonts.poppins(
                color: _subText, fontSize: 11.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLevelProgression(double t, ChildRewardsState state) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: _accentCyan, size: 18.sp),
                  SizedBox(width: 1.5.w),
                  Text("XP Progress",
                      style: GoogleFonts.poppins(
                          color: _primaryDark,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              Text("${(state.xpProgress * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                      color: _accentCyan,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: [
              Container(
                  height: 1.5.h,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 1.5.h,
                width: 80.w * state.xpProgress,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_accentCyan, Colors.cyan.shade600]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: _accentCyan.withOpacity(0.3), blurRadius: 10)
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCategories(double t, ChildRewardsState state) {
    bool hasQuizBadge = state.recentAchievements.any((a) => a['title'] == 'Quiz Master');
    bool hasStemBadge = state.recentAchievements.any((a) => a['title'] == 'STEM Explorer');
    bool hasQrBadge = state.recentAchievements.any((a) => a['title'] == 'Treasure Hunter');
    bool hasGameBadge = state.recentAchievements.any((a) => a['title'] == 'Game Master');

    // Progress Logic
    double quizProg = hasQuizBadge ? 1.0 : (state.quizCount / 50).clamp(0.0, 1.0);
    double stemProg = hasStemBadge ? 1.0 : (state.stemCount / 50).clamp(0.0, 1.0);
    double qrProg = hasQrBadge ? 1.0 : (state.qrCount / 50).clamp(0.0, 1.0);
    double gameProg = hasGameBadge ? 1.0 : (state.gameCount / 50).clamp(0.0, 1.0);

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Quiz Master',
        'icon': Icons.quiz_rounded,
        'progress': quizProg,
        'color': Colors.purple,
        'borderColor': Colors.purple.withOpacity(0.3),
        'status': hasQuizBadge ? 'Earned!' : 'In Progress'
      },
      {
        'title': 'STEM Star',
        'icon': Icons.science_rounded,
        'progress': stemProg,
        'color': Colors.blue,
        'borderColor': Colors.blue.withOpacity(0.3),
        'status': hasStemBadge ? 'Earned!' : 'In Progress'
      },
      {
        'title': 'Media Whiz',
        'icon': Icons.play_circle_filled_rounded,
        'progress': 0.0,
        'color': Colors.redAccent,
        'borderColor': Colors.orange.withOpacity(0.3),
        'status': 'In Progress'
      },
      {
        'title': 'Treasure Hunter',
        'icon': Icons.qr_code_scanner_rounded,
        'progress': qrProg,
        'color': Colors.green,
        'borderColor': Colors.green.withOpacity(0.3),
        'status': hasQrBadge ? 'Earned!' : 'In Progress'
      },
      {
        'title': 'Game Master',
        'icon': Icons.sports_esports_rounded,
        'progress': gameProg,
        'color': Colors.pink,
        'borderColor': Colors.pink.withOpacity(0.2),
        'status': hasGameBadge ? 'Earned!' : 'In Progress',
        'locked': false
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text("Your Badges",
              style: GoogleFonts.poppins(
                  color: _primaryDark,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 3.h,
              childAspectRatio: 0.95),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final bool isLocked = cat['locked'] ?? false;
            final color = isLocked ? Colors.grey : cat['color'] as Color;
            final borderColor = isLocked ? Colors.grey.shade200 : cat['borderColor'] as Color;
            final controller = (index < _badgeControllers.length)
                ? _badgeControllers[index]
                : _badgeControllers.last;

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: controller,
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * controller.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.12),
                              blurRadius: 25,
                              spreadRadius: -2,
                              offset: const Offset(0, 12)),
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    color.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 14.w,
                                  height: 14.w,
                                  decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color.withOpacity(0.1), width: 1.5)
                                  ),
                                  child: Icon(isLocked ? Icons.lock : cat['icon'],
                                      color: color, size: 20.sp),
                                ),
                                SizedBox(height: 1.5.h),
                                Text(cat['title'],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        color: _primaryDark,
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w800)),
                                Text(isLocked ? "Coming Soon" : cat['status'],
                                    style: GoogleFonts.poppins(
                                        color: _subText,
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 1.5.h),
                                if (!isLocked)
                                  Container(
                                    height: 7,
                                    width: 25.w,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10)),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: cat['progress'],
                                      child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                                              borderRadius:
                                              BorderRadius.circular(10))),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          if (isLocked)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                        ],
                      ),
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
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final random = math.Random(42);

    for (int i = 0; i < 8; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final r = 15 + random.nextDouble() * 25;
      final dx = math.sin(time * 2 + i) * 15;
      final dy = math.cos(time * 2 + i) * 15;

      canvas.drawCircle(Offset(x + dx, y + dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) => true;
}