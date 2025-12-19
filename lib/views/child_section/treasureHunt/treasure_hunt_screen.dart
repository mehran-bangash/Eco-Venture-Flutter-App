import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Riverpod
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/qr_hunt_read_model.dart';
import '../../../viewmodels/child_view_model/qr_hunt/child_qr_hunt_provider.dart'; // Adjust path if needed

class TreasureHuntScreen extends ConsumerStatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  ConsumerState<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends ConsumerState<TreasureHuntScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    // FIX: Removed 'loadHunts()' call.
    // The ViewModel automatically loads data in its constructor via _initStreams().

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _gradientAnimation =
        ColorTween(
          begin: const Color(0xFF4361EE),
          end: const Color(0xFF3A0CA3),
        ).animate(
          CurvedAnimation(parent: _masterController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  Alignment _bgAlignment(double t) {
    final dx = 0.5 + 0.3 * math.sin(t * 2 * math.pi);
    final dy = 0.3 + 0.2 * math.cos(t * 3 * math.pi);
    return Alignment(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    // 2. Watch State (This triggers the ViewModel init logic automatically)
    final state = ref.watch(childQrHuntViewModelProvider);
    final hunts = state.hunts;
    final progressMap = state.progressMap;

    // 3. Calculate Stats
    int totalScore = 0;
    int totalHuntsCompleted = 0;
    int totalCluesFound = 0;
    int totalCluesAvailable = 0;

    for (var hunt in hunts) {
      totalCluesAvailable += hunt.clues.length;
      final prog = progressMap[hunt.id];
      if (prog != null) {
        totalScore += prog.scoreEarned;
        totalCluesFound += prog.currentClueIndex;
        if (prog.isCompleted) totalHuntsCompleted++;
      }
    }

    // Avoid division by zero
    double progressPercent = totalCluesAvailable == 0
        ? 0.0
        : (totalCluesFound / totalCluesAvailable);

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
                // Animated Background (Preserved)
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: _bgAlignment(t),
                      radius: 1.8,
                      colors: [
                        _gradientAnimation.value!,
                        _gradientAnimation.value!.withValues(alpha: 0.8),
                        const Color(0xFF1a1f35),
                      ],
                      stops: const [0.1, 0.5, 1.0],
                    ),
                  ),
                ),

                // Floating Particles (Preserved)
                CustomPaint(
                  painter: ParticlePainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                // Main Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          SizedBox(height: 3.h),

                          _buildHeroSection(t),
                          SizedBox(height: 4.h),

                          // Stats Row (Real Data)
                          _buildStatsRow(t, totalScore, totalHuntsCompleted),
                          SizedBox(height: 4.h),

                          // Progress (Real Data)
                          _buildProgressSection(
                            t,
                            totalCluesFound,
                            totalCluesAvailable,
                            progressPercent,
                          ),
                          SizedBox(height: 4.h),

                          // Available Hunts List
                          Text(
                            "Available Quests",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          if (state.isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          else if (hunts.isEmpty)
                            Center(
                              child: Text(
                                "No Hunts Available",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          else
                            ...hunts.map((hunt) {
                              // Get progress for this specific hunt
                              final prog = progressMap[hunt.id];
                              return _buildHuntCard(hunt, prog);
                            }),

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

  // --- WIDGETS ---

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
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.yellow.shade400,
                size: 18.sp,
              ),
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
          colors: [Colors.blue.shade500, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
      ), // Placeholder for avatar image
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
                colors: [Colors.yellow.shade500, Colors.orange.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
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
              fontSize: 14.sp,
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

  Widget _buildStatsRow(double t, int score, int huntsDone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAnimatedStatCard(
          label: "Points",
          value: "$score",
          icon: Icons.monetization_on_rounded,
          color: Colors.yellow.shade600,
          t: t,
          delay: 0,
        ),
        _buildAnimatedStatCard(
          label: "Hunts",
          value: "$huntsDone",
          icon: Icons.map_rounded,
          color: Colors.blue.shade400,
          t: t,
          delay: 0.2,
        ),
        _buildAnimatedStatCard(
          label: "Rank",
          value: "1", // Mock rank for now
          icon: Icons.trending_up_rounded,
          color: Colors.green.shade500,
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
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                color: color.withValues(alpha: 0.3),
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
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    double t,
    int found,
    int total,
    double progress,
  ) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
                "Total Progress",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$found/$total Clues",
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
              Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 2.h,
                width: 90.w * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade500, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
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
                      color: isFound
                          ? Colors.orange.shade500
                          : Colors.white.withValues(alpha: 0.3), // More opaque
                      boxShadow: isFound
                          ? [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha:
                                  0.6,
                                ), // Brighter glow
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isFound
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          )
                        : Icon(
                            Icons.lock_rounded,
                            color: Colors.white70,
                            size: 12.sp,
                          ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: HUNT CARD (Replaces old clue card) ---
  Widget _buildHuntCard(QrHuntReadModel hunt, QrHuntProgressModel? progress) {
    bool isTeacher = hunt.createdBy == 'teacher';
    bool isStarted = progress != null;
    bool isCompleted = progress?.isCompleted ?? false;
    int cluesFound = progress?.currentClueIndex ?? 0;

    return GestureDetector(
      onTap: () {
        // Navigate to Play Screen (You will create this next)
        context.goNamed('qrHuntPlayScreen', extra: hunt);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade500.withValues(alpha: 0.9),
              Colors.red.shade500.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge: Global vs Classroom
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isTeacher
                        ? Colors.yellow
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    isTeacher ? "Classroom Task 🏫" : "Global Quest 🌍",
                    style: GoogleFonts.poppins(
                      color: isTeacher ? Colors.black : Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              hunt.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              isCompleted
                  ? "Mission Complete!"
                  : (isStarted
                        ? "Found: $cluesFound / ${hunt.clues.length} Clues"
                        : "Tap to Start Adventure"),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 3.h),
            // Scan Button Visual
            Container(
              width: 100.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.orange.shade500,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    isCompleted ? "Replay" : "Scan & Play",
                    style: GoogleFonts.poppins(
                      color: Colors.orange.shade500,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15); // Brighter particles
    for (int i = 0; i < 15; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 1 + random.nextDouble() * 3;
      final driftX = math.sin(time * 2 + i) * 10;
      final driftY = math.cos(time * 3 + i) * 10;
      canvas.drawCircle(Offset(x + driftX, y + driftY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
