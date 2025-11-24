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
  late AnimationController _headerAnimController;
  late Animation<double> _headerScaleAnimation;
  late AnimationController _objectsController; // Controller for moving objects

  // Vibrant Gradients matching your reference image style
  final List<List<Color>> _levelGradients = [
    [const Color(0xFFFF8A65), const Color(0xFFFF5252)], // Orange/Red
    [const Color(0xFF4FC3F7), const Color(0xFF2196F3)], // Light Blue
    [const Color(0xFF66BB6A), const Color(0xFF43A047)], // Green
    [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)], // Purple
    [const Color(0xFFFFCA28), const Color(0xFFFF6F00)], // Amber
  ];

  @override
  void initState() {
    super.initState();

    // Header Bouncing Animation
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _headerScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeInOut),
    );

    // Background Floating Objects Animation
    _objectsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _objectsController.dispose();
    super.dispose();
  }

  void _refreshProgress() {
    ref.refresh(childQuizViewModelProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Refreshing Levels...",
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- ANIMATED BACKGROUND BUILDER ---
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base Dark Background
        Container(color: const Color(0xFF1A1A2E)),

        // Moving Particles
        AnimatedBuilder(
          animation: _objectsController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: DetailFloatingObjectsPainter(
                animationValue: _objectsController.value,
              ),
            );
          },
        ),
      ],
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
        if(!didPop){
          context.goNamed('interactiveQuiz');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Animated Background Layer
            _buildAnimatedBackground(),

            // 2. Main Content Layer
            Column(
              children: [
                // Custom AppBar placed in Column to sit on top of background
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  title: ScaleTransition(
                    scale: _headerScaleAnimation,
                    child: Text(
                      widget.topic.topicName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19.sp,
                        shadows: [
                          Shadow(
                            color: Colors.blueAccent.withValues(alpha: 0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: _refreshProgress,
                      icon: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                  ],
                ),

                // Body Content
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
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),

                        // --- VERTICAL GRID ---
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 5.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 4.w,
                                  mainAxisSpacing: 2.5.h,
                                  childAspectRatio: 0.72,
                                ),
                            itemCount: widget.topic.levels.length,
                            itemBuilder: (context, index) {
                              final level = widget.topic.levels[index];

                              bool isLocked = false;

                              if (level.order > 1) {
                                final prevLevelOrder = level.order - 1;
                                final prevKey = "${topicId}_$prevLevelOrder";
                                final prevProgress = progressMap[prevKey];

                                if (prevProgress == null ||
                                    !prevProgress.isPassed) {
                                  isLocked = true;
                                }
                              }

                              return _buildProLevelCard(
                                level,
                                isLocked,
                                widget.topic,
                                index,
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
          ],
        ),
      ),
    );
  }

  // --- PRO CARD DESIGN ---
  Widget _buildProLevelCard(
    QuizLevelModel level,
    bool isLocked,
    QuizTopicModel topic,
    int index,
  ) {
    final gradientColors = _levelGradients[index % _levelGradients.length];
    final textColor = gradientColors[1];

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Complete Level ${level.order - 1} first! 🔒",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          if (topic.id == null) return;
          context.goNamed(
            'quizQuestionScreen',
            extra: QuizQuestionArgs(
              level: level,
              topicId: topic.id!,
              category: topic.category,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isLocked
              ? LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? Colors.black12
                  : gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "LVL ${level.order}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),

                      Icon(
                        isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 18.sp,
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.8.h,
                      horizontal: 3.w,
                    ),
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.white10 : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isLocked
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLocked ? "Locked" : "Start",
                          style: GoogleFonts.poppins(
                            color: isLocked ? Colors.white54 : textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                          ),
                        ),
                        if (!isLocked) ...[
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.play_arrow_rounded,
                            color: textColor,
                            size: 16.sp,
                          ),
                        ],
                      ],
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

// --- CUSTOM PAINTER FOR FLOATING OBJECTS ---
class DetailFloatingObjectsPainter extends CustomPainter {
  final double animationValue;

  DetailFloatingObjectsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // FIX: Instantiate the Paint object here instead of referencing a method
    final Paint circlePaint = Paint()..style = PaintingStyle.fill;

    _drawCircle(
      canvas,
      size,
      0.1,
      0.2,
      15,
      Colors.white.withValues(alpha: 0.03),
      0.8,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.7,
      0.5,
      25,
      Colors.white.withValues(alpha: 0.02),
      -0.5,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.4,
      0.8,
      10,
      Colors.white.withValues(alpha: 0.04),
      1.2,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.2,
      0.6,
      18,
      Colors.blueAccent.withValues(alpha: 0.05),
      0.6,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.8,
      0.1,
      30,
      Colors.purpleAccent.withValues(alpha: 0.05),
      -0.8,
      circlePaint,
    );
  }

  void _drawCircle(
    Canvas canvas,
    Size size,
    double xSeed,
    double ySeed,
    double radius,
    Color color,
    double speed,
    Paint paint,
  ) {
    double x = (xSeed + (animationValue * speed * 0.1)) % 1.0;
    double y =
        (ySeed + (math.sin(animationValue * 2 * math.pi * speed) * 0.05)) % 1.0;

    if (x < 0) x += 1.0;
    if (y < 0) y += 1.0;

    canvas.drawCircle(
      Offset(x * size.width, y * size.height),
      radius,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(DetailFloatingObjectsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
