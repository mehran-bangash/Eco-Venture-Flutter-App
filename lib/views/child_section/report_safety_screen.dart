
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReportSafetyScreen extends StatefulWidget {
  const ReportSafetyScreen({super.key});

  @override
  State<ReportSafetyScreen> createState() => _ReportSafetyScreenState();
}

class _ReportSafetyScreenState extends State<ReportSafetyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  // background shift anim
  late Animation<double> _shift;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _shift = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // multi-layer background lerp between vibrant colors
  BoxDecoration _bgDecoration(double t) {
    final c1 = Color.lerp(const Color(0xFF0F1724), const Color(0xFF0B2545), t)!;
    final c2 = Color.lerp(const Color(0xFF0B2545), const Color(0xFF3A0F6F), 1 - t)!;
    final c3 = Color.lerp(const Color(0xFF3A0F6F), const Color(0xFF0F1724), t * 0.6)!;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-1 + t, -1),
        end: Alignment(1 - t, 1),
        colors: [c1, c2, c3],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

        return PopScope(
        canPop: false, // prevents auto pop
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // This runs when system back button is pressed
            context.goNamed('bottomNavChild');
          }
        },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                "Safety Center",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            body: AnimatedBuilder(
              animation: _shift,
              builder: (context, child) {
                final t = _shift.value;
                return Stack(
                  children: [
                    // animated gradient background
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      decoration: _bgDecoration(t),
                    ),

                    // big soft glows (parallax)
                    Positioned(
                      top: -12.h + (6.h * sin(2 * pi * t)),
                      left: -18.w,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                            radius: 0.9,
                          ),
                        ),
                        child: SizedBox(width: 42.w, height: 42.w),
                      ),
                    ),
                    Positioned(
                      bottom: -10.h + (5.h * cos(2 * pi * t)),
                      right: -16.w,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.pinkAccent.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            radius: 0.9,
                          ),
                        ),
                        child: SizedBox(width: 36.w, height: 36.w),
                      ),
                    ),

                    // smaller twinkling dots
                    ...List.generate(10, (i) => _tinyDot(i, t)),

                    // content
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(4.w, 14.h, 4.w, 10.h),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _animatedGlassCard(
                            icon: Icons.shield,
                            title: "Your safety is our priority",
                            subtitle: "We’re here to help you stay safe and have fun.",
                            color: const Color(0xFF00F0FF),
                            // subtle accent gradient on left
                          ),
                          SizedBox(height: 3.h),

                          _sectionWithShimmer("Quick Actions"),

                          _shimmerActionCard(
                            color: Colors.redAccent,
                            icon: Icons.report_problem_rounded,
                            title: "Report an Issue",
                            description: "Report inappropriate behavior or content.",
                            buttonText: "Report",
                            onPressed: () {
                              context.goNamed("reportIssueScreen");
                            },
                          ),
                          SizedBox(height: 2.h),
                          _shimmerActionCard(
                            color: Colors.deepOrangeAccent,
                            icon: Icons.call,
                            title: "Get Parent Help",
                            description: "Contact your parent or guardian quickly.",
                            buttonText: "Call ...",
                            onPressed: () {},
                          ),

                          SizedBox(height: 3.h),
                          _sectionWithShimmer("Safety Resources"),

                          _shimmerActionCard(
                            color: Colors.lightBlueAccent,
                            icon: Icons.lightbulb,
                            title: "Safety Tips",
                            description: "Learn how to stay safe online.",
                            buttonText: "Learn",
                            onPressed: () {},
                          ),
                          SizedBox(height: 2.h),
                          _shimmerActionCard(
                            color: Colors.purpleAccent,
                            icon: Icons.rule,
                            title: "Online Rules",
                            description: "Guidelines for a positive community.",
                            buttonText: "Read",
                            onPressed: () {},
                          ),

                          SizedBox(height: 3.h),
                          _sectionWithShimmer("Emergency Contacts"),
                          _contactCard(),

                          SizedBox(height: 10.h),
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

  // small twinkle dots with slight motion
  Widget _tinyDot(int i, double t) {
    final rand = Random(i * 31);
    final baseX = rand.nextDouble();
    final baseY = rand.nextDouble();
    final speed = 0.2 + rand.nextDouble() * 0.6;
    final size = 2 + rand.nextDouble() * 4;
    final x = (baseX + sin((t + i) * speed * pi * 2) * 0.02) % 1;
    final y = (baseY + cos((t + i) * speed * pi * 2) * 0.03) % 1;
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06 + 0.04 * sin((t + i) * pi * 2)),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (i % 2 == 0 ? Colors.cyanAccent : Colors.pinkAccent)
                  .withValues(alpha: 0.06),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  // animated glass card with left accent bar and subtle pulse
  Widget _animatedGlassCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // vertical accent
                Container(
                  height: 6.h,
                  width: 1.2.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  padding: EdgeInsets.all(1.8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                      SizedBox(height: 0.6.h),
                      Text(subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: Colors.white70,
                          )),
                    ],
                  ),
                ),
                // subtle chevron
                Icon(Icons.chevron_right_rounded, color: Colors.white30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // section title with animated underline shimmer
  Widget _sectionWithShimmer(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        // animated underline
        SizedBox(
          height: 2.h,
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final pos = (_ctrl.value * 2) % 1;
                      final left = constraints.maxWidth * pos - constraints.maxWidth * 0.25;
                      return Transform.translate(
                        offset: Offset(left, 0),
                        child: Container(
                          height: 6,
                          width: constraints.maxWidth * 0.4,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyanAccent.withValues(alpha: 0.5),
                                  Colors.purpleAccent.withValues(alpha: 0.5),
                                  Colors.pinkAccent.withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  // action card with shimmer border and glow on button
  Widget _shimmerActionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutQuad,
      builder: (context, s, child) {
        return Transform.scale(scale: s, child: child);
      },
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.6.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15.5.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 0.6.h),
                  Text(description,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      )),
                ],
              ),
            ),
            // glowing button
            _glowButton(color: color, label: buttonText, onPressed: onPressed),
          ],
        ),
      ),
    );
  }

  Widget _glowButton({
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.02),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: 1.0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: onPressed,
              child: Text(label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
        );
      },
    );
  }

  // emergency contact card (glass)
  Widget _contactCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(3.5.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.sp,
                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.16),
                child: Icon(Icons.person, color: Colors.cyanAccent, size: 22.sp),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jane Doe",
                        style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(height: 0.4.h),
                    Text("jane.doe@email.com",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        )),
                    SizedBox(height: 0.2.h),
                    Text("(123) 456-7890",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        )),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text("Edit",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.w600,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
