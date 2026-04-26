import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/qr_hunt_read_model.dart';
import '../../../viewmodels/child_view_model/qr_hunt/child_qr_hunt_provider.dart';

class TreasureHuntScreen extends ConsumerStatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  ConsumerState<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends ConsumerState<TreasureHuntScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;

  // Professional Theme Colors
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _accentCyan = const Color(0xFF06B6D4);
  final Color _bgSurface = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQrHuntViewModelProvider);
    final hunts = state.hunts;
    final progressMap = state.progressMap;

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

    double progressPercent = totalCluesAvailable == 0
        ? 0.0
        : (totalCluesFound / totalCluesAvailable);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: _bgSurface,
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
                // 1. Background Gradient & Blobs
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
                  child: _buildGlowBlob(Colors.cyan.withOpacity(0.12), 70.w, t, 0),
                ),
                Positioned(
                  bottom: 5.h,
                  left: -20.w,
                  child: _buildGlowBlob(Colors.indigo.withOpacity(0.08), 80.w, t, 2),
                ),
                Positioned(
                  top: 30.h,
                  left: 10.w,
                  child: _buildGlowBlob(Colors.amber.withOpacity(0.08), 50.w, t, 4),
                ),

                CustomPaint(
                  painter: ParticlePainter(time: t),
                  size: Size(100.w, 100.h),
                ),

                // 2. Main Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          SizedBox(height: 2.h),
                          _buildHeroSection(t),
                          SizedBox(height: 3.h),
                          _buildStatsRow(t, totalScore, totalHuntsCompleted),
                          SizedBox(height: 3.h),
                          _buildProgressSection(t, totalCluesFound, totalCluesAvailable, progressPercent),
                          SizedBox(height: 4.h),
                          Padding(
                            padding: EdgeInsets.only(left: 1.w),
                            child: Text(
                              "Available Quests",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: _primaryDark,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          if (state.isLoading)
                            const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                          else if (hunts.isEmpty)
                            Center(child: Text("No Hunts Available", style: GoogleFonts.poppins(color: _subText)))
                          else
                            ...hunts.map((hunt) {
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
    return Row(
      children: [
        IconButton(
          onPressed: () => context.goNamed('bottomNavChild'),
          icon: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark, size: 17.sp),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade600, size: 18.sp),
              SizedBox(width: 2.w),
              Text(
                "Treasure Hunt",
                style: GoogleFonts.poppins(color: _primaryDark, fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)]),
            boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.2), blurRadius: 10)],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeroSection(double t) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, 8 * math.sin(t * 2 * math.pi)),
          child: Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade500]),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 25, spreadRadius: 5)],
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28.sp),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          "Adventure Awaits!",
          style: GoogleFonts.poppins(color: _primaryDark, fontSize: 22.sp, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          "Discover hidden treasures and unlock mysteries",
          style: GoogleFonts.poppins(color: _subText, fontSize: 13.sp, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsRow(double t, int score, int huntsDone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(label: "Points", value: "$score", icon: Icons.monetization_on_rounded, color: Colors.amber.shade400, t: t, delay: 0),
        _buildStatCard(label: "Hunts", value: "$huntsDone", icon: Icons.map_rounded, color: Colors.blue.shade400, t: t, delay: 0.2),
        _buildStatCard(label: "Rank", value: "1", icon: Icons.trending_up_rounded, color: Colors.green.shade500, t: t, delay: 0.4),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color, required double t, required double delay}) {
    return Container(
      width: 28.w,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 25,
              spreadRadius: -2,
              offset: const Offset(0, 10)
          ),
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 1.h),
          Text(value, style: GoogleFonts.poppins(color: _primaryDark, fontSize: 17.sp, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.poppins(color: _subText, fontSize: 11.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double t, int found, int total, double progress) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF06B6D4).withOpacity(0.12),
              blurRadius: 35,
              spreadRadius: 2,
              offset: const Offset(0, 15)
          ),
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Progress", style: GoogleFonts.poppins(color: _primaryDark, fontSize: 16.sp, fontWeight: FontWeight.w800)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF3B82F6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("$found/$total Clues", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          Stack(
            children: [
              Container(height: 1.5.h, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 1.5.h,
                width: 80.w * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade500]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8)],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(total, (index) {
                final isFound = index < found;
                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFound ? Colors.orange.shade500 : const Color(0xFFF1F5F9),
                    border: Border.all(color: isFound ? Colors.orange.shade200 : const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(isFound ? Icons.check_rounded : Icons.lock_rounded,
                      color: isFound ? Colors.white : const Color(0xFFCBD5E1), size: 14.sp),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHuntCard(QrHuntReadModel hunt, QrHuntProgressModel? progress) {
    bool isTeacher = hunt.createdBy == 'teacher';
    bool isStarted = progress != null;
    bool isCompleted = progress?.isCompleted ?? false;
    int cluesFound = progress?.currentClueIndex ?? 0;

    return GestureDetector(
      onTap: () => context.goNamed('qrHuntPlayScreen', extra: hunt),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.5.h),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade500, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withOpacity(0.45),
                blurRadius: 25,
                spreadRadius: -2,
                offset: const Offset(0, 12)
            ),
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isTeacher ? "Classroom Task 🏫" : "Global Quest 🌍",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                Icon(isCompleted ? Icons.check_circle : Icons.flash_on_rounded, color: Colors.white, size: 18.sp),
              ],
            ),
            SizedBox(height: 2.h),
            Text(hunt.title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 0.5.h),
            Text(
              isCompleted ? "Mission Complete!" : (isStarted ? "Found: $cluesFound / ${hunt.clues.length} Clues" : "Tap to Start Adventure"),
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 3.h),
            Container(
              width: 100.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.orange.shade500, size: 19.sp),
                  SizedBox(width: 2.w),
                  Text(isCompleted ? "Replay" : "Scan & Play",
                      style: GoogleFonts.poppins(color: Colors.orange.shade500, fontSize: 15.sp, fontWeight: FontWeight.w800)),
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
    final paint = Paint()..color = const Color(0xFFE2E8F0).withOpacity(0.2);
    for (int i = 0; i < 12; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 2 + random.nextDouble() * 3;
      final dx = math.sin(time * 2 + i) * 10;
      final dy = math.cos(time * 3 + i) * 10;
      canvas.drawCircle(Offset(x + dx, y + dy), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}