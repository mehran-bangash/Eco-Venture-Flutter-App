import 'dart:math';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _masterController;
  late final Animation<double> _pulseAnimation;

  // For staggering cards
  final int _clueCount = 4;
  final List<bool> _visibleClues = [];

  @override
  void initState() {
    super.initState();

    // master controller controls background movement + staggered entrance + pulse
    _masterController =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInOutSine),
      ),
    );

    // initialize clue visibility which will be toggled with staggered timers
    for (int i = 0; i < _clueCount; i++) {
      _visibleClues.add(false);
      // stagger each reveal
      Future.delayed(Duration(milliseconds: 450 + i * 140), () {
        if (mounted) setState(() => _visibleClues[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }



// animated shifting gradient builder using controller value
  Alignment _bgAlignment(double t) {
    // moves gradient center in circular-ish way
    final dx = 0.5 + 0.5 * (0.5 * (1 + sin(t * 2)));
    final dy = 0.2 + 0.6 * (0.5 * (1 + cos(t * 3)));
    return Alignment(dx * 2 - 1, dy * 2 - 1);
  }


  @override
  Widget build(BuildContext context) {
    // sample data (replace with backend later)
    final clues = [
      {"title": "The Ancient Oak", "time": "2 hours ago"},
      {"title": "The Crimson Bridge", "time": "1 day ago"},
      {"title": "The Sunken Statue", "time": "3 days ago"},
      {"title": "The Golden Griffin", "time": "5 days ago"},
    ];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _masterController,
        builder: (context, _) {
          final t = _masterController.value;
          return Container(
            width: 100.w,
            height: 100.h,
            // moving layered gradient for playful depth
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: _bgAlignment(t),
                radius: 1.1,
                colors: const [
                  Color(0xFF66F6B7),
                  Color(0xFF4ADEDE),
                  Color(0xFF6C63FF),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      SizedBox(height: 2.h),
                      _buildStatsRow(t),
                      SizedBox(height: 2.h),
                      _buildProgress(t),
                      SizedBox(height: 2.h),
                      _buildCluesGrid(clues),
                      SizedBox(height: 2.h),
                      _buildCurrentQuestCard(),
                      SizedBox(height: 2.h),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Top bar with menu, title and avatar
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.goNamed('bottomNavChild');
          },
            child: _glassButton(icon: Icons.arrow_back_ios, onTap: () {})),
        SizedBox(width: 3.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo + title
              const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
              SizedBox(width: 2.w),
              Text(
                "Treasure Quest",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // small semi-transparent glass button used on top-left
  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 5.5.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  // Stats row: coins, badges, rank — each with bounce animation
  Widget _buildStatsRow(double t) {
    // tiny staggered scale for micro-interaction
    final scales = [
      1.0 + 0.02 * sin(t * 2),
      1.0,
      1.0 - 0.015 * sin(t * 3),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _animatedStatItem(
          label: "Coins",
          value: "45",
          icon: Icons.monetization_on,
          color: const Color(0xFFFFD54F),
          scale: scales[0],
        ),
        _animatedStatItem(
          label: "Badges",
          value: "3",
          icon: Icons.military_tech,
          color: const Color(0xFF6C63FF),
          scale: scales[1],
        ),
      ],
    );
  }

  Widget _animatedStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double scale,
  }) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 29.w,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18.sp),
                SizedBox(width: 2.w),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.6.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress indicator with animated dots and gradient fill
  /// Progress indicator with animated treasure progress style
  Widget _buildProgress(double t) {
    final found = 4;
    final total = 6;

    final progress = found / total;
    final glow = (0.5 + 0.5 * sin(t * 4));

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 2.w),
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [Colors.white, Colors.yellowAccent.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect),
                child: Text(
                  "Progress: $found / $total Clues",
                  style: GoogleFonts.poppins(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Animated progress bar
          Stack(
            children: [
              // background
              Container(
                width: 80.w,
                height: 1.2.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // progress fill with glow
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 80.w * progress,
                height: 1.2.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFFF8A00),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8A00).withValues(alpha:  glow * 0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.8.h),

          // Cute treasure path dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(total, (i) {
              final isFound = i < found;
              final pulse = 1.0 + 0.12 * sin(t * 4 + i);
              return Transform.scale(
                scale: pulse,
                child: Icon(
                  isFound ? Icons.star_rounded : Icons.circle,
                  color: isFound ? Colors.amberAccent : Colors.white54,
                  size: isFound ? 18.sp : 14.sp,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  /// Grid of clue cards with staggered entrance and soft shadows
  Widget _buildCluesGrid(List<Map<String, String>> clues) {
    return GridView.builder(
      itemCount: clues.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final data = clues[index];
        final visible = _visibleClues[index];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 550),
          opacity: visible ? 1 : 0,
          curve: Curves.easeOut,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 550),
            offset: visible ? Offset.zero : const Offset(0, 0.15),
            curve: Curves.easeOutBack,
            child: _buildClueCard(
              title: data["title"] ?? "",
              subtitle: data["time"] ?? "",
              isFound: true,
            ),
          ),
        );
      },
    );
  }

  // single clue card (found)
  Widget _buildClueCard({
    required String title,
    required String subtitle,
    required bool isFound,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFound
              ? [const Color(0xFF3DDC84), const Color(0xFF19C37D)]
              : [Colors.white, Colors.white70],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // check badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.check_circle, color: Colors.white, size: 5.w),
              ),
            ),
          ),
          // content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 0.7.h),
              Text(
                "Found: $subtitle",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // current quest card with action button
  Widget _buildCurrentQuestCard() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A00),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              "Current Quest",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.sp),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "The Whispering Fountain",
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          SizedBox(height: 1.5.h),
          ElevatedButton.icon(
            onPressed: () {
              context.goNamed('clueLockedScreen');
            },
            icon: const Icon(Icons.qr_code_2_outlined),
            label: Text("Scan Clue", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A00),
              padding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 10.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }


}
