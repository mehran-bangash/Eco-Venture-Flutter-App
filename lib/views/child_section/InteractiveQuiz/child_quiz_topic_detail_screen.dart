import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';
import 'quiz_question_screen.dart';

class ChildQuizTopicDetailScreen extends ConsumerStatefulWidget {
  final QuizTopicModel topic;

  const ChildQuizTopicDetailScreen({super.key, required this.topic});

  @override
  ConsumerState<ChildQuizTopicDetailScreen> createState() =>
      _ChildQuizTopicDetailScreenState();
}

class _ChildQuizTopicDetailScreenState
    extends ConsumerState<ChildQuizTopicDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerAnimController;
  late final Animation<double> _headerScaleAnimation;
  late final AnimationController _masterController;

  // Professional Theme Palette
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _bgSurface = const Color(0xFFF8FAFC);
  final Color _slate200 = const Color(0xFFE2E8F0);

  // Home Screen Accent Colors
  final List<Color> _accentColors = [
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF43F5E), // Rose
  ];

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _headerScaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeInOut),
    );

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _masterController.dispose();
    super.dispose();
  }

  void _refreshProgress() {
    ref.refresh(childQuizViewModelProvider);
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (context, _) {
        final t = _masterController.value;
        return Stack(
          children: [
            Container(
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
              child: _buildGlowBlob(Colors.pink.withOpacity(0.08), 80.w, t, 2),
            ),
            Positioned(
              top: 30.h,
              left: 10.w,
              child: _buildGlowBlob(Colors.amber.withOpacity(0.08), 50.w, t, 4),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(
        30 * math.sin(t * 2 * math.pi + phase),
        30 * math.cos(t * 2 * math.pi + phase),
      ),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQuizViewModelProvider);
    final progressMap = state.progress;
    final topicId = widget.topic.id;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('interactiveQuiz');
      },
      child: Scaffold(
        backgroundColor: _bgSurface,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),
                          Text(
                            "Tap a level to start your adventure!",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: _subText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Expanded(
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 5.h),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 4.w,
                                    mainAxisSpacing: 2.5.h,
                                    childAspectRatio: 0.82,
                                  ),
                              itemCount: widget.topic.levels.length,
                              itemBuilder: (context, index) {
                                final level = widget.topic.levels[index];
                                bool isLocked =
                                    level.order > 1 &&
                                    (progressMap["${topicId}_${level.order - 1}"]
                                            ?.isPassed !=
                                        true);

                                // Pass progressMap as the 5th argument
                                return _buildProLevelCard(
                                  level,
                                  isLocked,
                                  widget.topic,
                                  index,
                                  progressMap,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: _primaryDark,
                size: 17.sp,
              ),
            ),
          ),
          Expanded(
            child: ScaleTransition(
              scale: _headerScaleAnimation,
              child: Text(
                widget.topic.topicName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: _primaryDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _refreshProgress,
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _slate200),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: _primaryDark,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProLevelCard(
    QuizLevelModel level,
    bool isLocked,
    QuizTopicModel topic,
    int index,
    Map<String, dynamic> progressMap,
  ) {
    final accentColor = _accentColors[index % _accentColors.length];
    final String key = "${topic.id}_${level.order}";
    final bool isPassed =
        progressMap[key]?.isPassed ?? false; // Check if already passed

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showLockedMessage(level.order - 1);
        } else {
          context.goNamed(
            'quizQuestionScreen',
            extra: QuizQuestionArgs(
              level: level,
              topicId: topic.id!,
              topicName: widget.topic.topicName,
              category: topic.category,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isPassed
                ? Colors.green.shade300
                : (isLocked ? _slate200 : accentColor.withOpacity(0.3)),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPassed
                  ? Colors.green.withOpacity(0.1)
                  : (isLocked
                        ? Colors.black.withOpacity(0.03)
                        : accentColor.withOpacity(0.15)),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // SUCCESS RIBBON (Top Right)
            if (isPassed)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 14.sp),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(4.5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HEADER ROW: Level Badge & Lock Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? Colors.green.withOpacity(0.1)
                              : (isLocked
                                    ? _slate200
                                    : accentColor.withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "LVL ${level.order}",
                          style: GoogleFonts.poppins(
                            color: isPassed
                                ? Colors.green
                                : (isLocked ? _subText : accentColor),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Icon(
                        isLocked
                            ? Icons.lock_rounded
                            : (isPassed
                                  ? Icons.stars_rounded
                                  : Icons.lock_open_rounded),
                        color: isPassed
                            ? Colors.amber
                            : (isLocked
                                  ? _subText.withOpacity(0.4)
                                  : accentColor),
                        size: 16.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),

                  // CENTER ICON: Matches Home Screen "Progress/Rewards" cards
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPassed
                          ? Colors.green.withOpacity(0.1)
                          : (isLocked
                                ? _bgSurface
                                : accentColor.withOpacity(0.1)),
                    ),
                    child: Icon(
                      isLocked
                          ? Icons.lock_outline_rounded
                          : (isPassed
                                ? Icons.replay_rounded
                                : Icons.play_arrow_rounded),
                      color: isPassed
                          ? Colors.green
                          : (isLocked ? _subText : accentColor),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // FOOTER BUTTON: Professional call-to-action
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? _bgSurface
                          : (isPassed ? Colors.green : accentColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        isLocked
                            ? "Locked"
                            : (isPassed ? "Review" : "Start Now"),
                        style: GoogleFonts.poppins(
                          color: isLocked ? _subText : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5.sp,
                        ),
                      ),
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

  void _showLockedMessage(int prevLevel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Complete Level $prevLevel first! 🔒",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class DetailFloatingObjectsPainter extends CustomPainter {
  final double animationValue;
  DetailFloatingObjectsPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Color slate = const Color(0xFF94A3B8).withOpacity(0.1);
    _drawCircle(canvas, size, 0.1, 0.2, 15, slate, 0.8, paint);
    _drawCircle(canvas, size, 0.7, 0.5, 25, slate, -0.5, paint);
  }

  void _drawCircle(
    Canvas canvas,
    Size size,
    double x,
    double y,
    double r,
    Color c,
    double s,
    Paint p,
  ) {
    double dx = (x + (animationValue * s * 0.1)) % 1.0;
    double dy = (y + (math.sin(animationValue * 2 * math.pi * s) * 0.05)) % 1.0;
    canvas.drawCircle(
      Offset(dx * size.width, dy * size.height),
      r,
      p..color = c,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
