import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/stem_challenge_read_model.dart';

class MathInstructionScreen extends StatefulWidget {
  final StemChallengeReadModel challenge;
  const MathInstructionScreen({super.key, required this.challenge});

  @override
  State<MathInstructionScreen> createState() => _MathInstructionScreenState();
}

class _MathInstructionScreenState extends State<MathInstructionScreen> with TickerProviderStateMixin {
  final Set<int> _completedSteps = {};
  late final AnimationController _masterController;

  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('stemChallenges');
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
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
                Positioned(top: -5.h, right: -15.w, child: _buildGlowBlob(Colors.cyan.withOpacity(0.1), 70.w, t, 0)),
                Positioned(bottom: 5.h, left: -20.w, child: _buildGlowBlob(Colors.amber.withOpacity(0.1), 80.w, t, 2)),

                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(challenge.title),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroCard(challenge),
                              SizedBox(height: 4.h),
                              _buildSectionTitle("📦 Materials Needed"),
                              ...challenge.materials.asMap().entries.map((entry) => _buildMaterialItem("${entry.key + 1}. ${entry.value}")),
                              SizedBox(height: 4.h),
                              _buildSectionTitle("📝 Step-by-Step Guide"),
                              Text("Tap a step to mark it as done!", style: GoogleFonts.poppins(color: _subText, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                              SizedBox(height: 2.h),
                              ...challenge.steps.asMap().entries.map((entry) {
                                final index = entry.key;
                                final isDone = _completedSteps.contains(index);
                                return _buildStepItem(index + 1, entry.value, isDone, () {
                                  setState(() {
                                    if (isDone) _completedSteps.remove(index);
                                    else _completedSteps.add(index);
                                  });
                                });
                              }),
                              SizedBox(height: 4.h),
                              _buildSubmitButton(challenge),
                              SizedBox(height: 6.h),
                            ],
                          ),
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
      offset: Offset(30 * math.sin(t * 2 * math.pi + phase), 30 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
      ),
    );
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.goNamed('stemChallenges'),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark, size: 17.sp),
            ),
          ),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: _primaryDark, fontSize: 17.sp, fontWeight: FontWeight.w900)),
          ),
          IconButton(
            onPressed: () => context.pushNamed('childReportIssueScreen', extra: {'id': widget.challenge.id, 'title': widget.challenge.title, 'type': 'STEM Challenge'}),
            icon: Icon(Icons.flag_rounded, color: Colors.red.shade400, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(StemChallengeReadModel challenge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _themeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: _themeColor.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15), spreadRadius: -5),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 25.w,
            height: 12.h,
            decoration: BoxDecoration(color: _themeColor.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty
                  ? Image.network(challenge.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.calculate_rounded, color: _themeColor.withOpacity(0.3), size: 30.sp),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmallBadge("★ ${challenge.difficulty}", _themeColor.withOpacity(0.1), _themeColor),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade600, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text("${challenge.points} XP", style: GoogleFonts.poppins(color: _primaryDark, fontSize: 17.sp, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _primaryDark)),
    );
  }

  Widget _buildMaterialItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: _themeColor, size: 18.sp),
          SizedBox(width: 3.w),
          Expanded(child: Text(text, style: GoogleFonts.poppins(color: _primaryDark, fontSize: 15.sp, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String text, bool isDone, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isDone ? _themeColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDone ? _themeColor.withOpacity(0.5) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? _themeColor : _themeColor.withOpacity(0.1)),
              child: Center(
                child: isDone ? Icon(Icons.check, color: Colors.white, size: 16.sp) : Text("$step", style: GoogleFonts.poppins(color: _themeColor, fontWeight: FontWeight.w800, fontSize: 14.sp)),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(text, style: GoogleFonts.poppins(color: isDone ? _subText : _primaryDark, fontSize: 15.sp, fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : null)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(StemChallengeReadModel challenge) {
    return GestureDetector(
      onTap: () => context.goNamed('mathSubmitScreen', extra: challenge),
      child: Container(
        width: 100.w,
        height: 7.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_themeColor, _themeColor.withBlue(200)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 3.w),
              Text("Upload Creation", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.poppins(color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w800)),
    );
  }
}
