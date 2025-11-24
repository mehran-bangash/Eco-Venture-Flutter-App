import 'dart:ui';
import 'dart:math' as math; // Import math for random positions
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';

// Helper class for UI styling
class CategoryStyle {
  final String id;
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  CategoryStyle(this.id, this.title, this.icon, this.color1, this.color2);
}

class InteractiveQuizScreen extends ConsumerStatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  ConsumerState<InteractiveQuizScreen> createState() =>
      _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen>
    with TickerProviderStateMixin {
  // --- ANIMATION CONTROLLERS ---
  late final AnimationController _bgController;
  late final AnimationController
  _objectsController; // Controller for moving objects
  late final AnimationController _headerController;
  late final ScrollController _scrollController;

  // Staggered animation for list items
  final List<AnimationController> _cardControllers = [];

  double _scrollOffset = 0.0;
  int _pressedIndex = -1;
  String _selectedCategoryId = '';

  // --- STYLES (Vibrant Gradients for Children) ---
  final Map<String, CategoryStyle> _styleMap = {
    'Animals': CategoryStyle(
      'Animals',
      'Animals',
      Icons.pets_rounded,
      const Color(0xFFFA8B74),
      const Color(0xFFF04A27),
    ),
    'Plants': CategoryStyle(
      'Plants',
      'Plants',
      Icons.eco_rounded,
      const Color(0xFF74FAB6),
      const Color(0xFF27F086),
    ),
    'Ecosystem': CategoryStyle(
      'Ecosystem',
      'Ecosystem',
      Icons.public_rounded,
      const Color(0xFF74D4FA),
      const Color(0xFF279AF0),
    ),
    'Science': CategoryStyle(
      'Science',
      'Science',
      Icons.science_rounded,
      const Color(0xFFB974FA),
      const Color(0xFF7327F0),
    ),
    'Mathematics': CategoryStyle(
      'Mathematics',
      'Mathematics',
      Icons.calculate_rounded,
      const Color(0xFF74FACD),
      const Color(0xFF27F0A8),
    ),
    'Space': CategoryStyle(
      'Space',
      'Space',
      Icons.rocket_launch_rounded,
      const Color(0xFFFA74E8),
      const Color(0xFFF027C6),
    ),
    'Recycling': CategoryStyle(
      'Recycling',
      'Recycling',
      Icons.recycling_rounded,
      const Color(0xFF81C784),
      const Color(0xFF43A047),
    ),
    'Climate': CategoryStyle(
      'Climate',
      'Climate',
      Icons.thermostat_rounded,
      const Color(0xFFFFCC80),
      const Color(0xFFFB8C00),
    ),
  };

  // Default fallback style
  final CategoryStyle _fallbackStyle = CategoryStyle(
    'General',
    'General',
    Icons.quiz_rounded,
    Colors.blueAccent,
    Colors.lightBlueAccent,
  );

  // Random Gradients for individual topic cards
  final List<List<Color>> _randomGradients = [
    [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)], // Warm Pink
    [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)], // Soft Purple
    [const Color(0xFF84fab0), const Color(0xFF8fd3f4)], // Aqua
    [const Color(0xFFe0c3fc), const Color(0xFF8ec5fc)], // Lavender
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Emerald
    [const Color(0xFFfa709a), const Color(0xFFfee140)], // Sunset
  ];

  @override
  void initState() {
    super.initState();

    // 1. Background Gradient Animation (Slow shift)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // 2. Floating Objects Animation (Continuous loop)
    _objectsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 3. Header Fade In
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // 4. Parallax Scroll Logic
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  void _initCardAnimations(int count) {
    if (_cardControllers.length == count) return;

    for (var c in _cardControllers) {
      c.dispose();
    }
    _cardControllers.clear();

    for (var i = 0; i < count; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _cardControllers.add(ctrl);
      Future.delayed(Duration(milliseconds: 100 + (i * 100)), () {
        if (mounted && i < _cardControllers.length) ctrl.forward();
      });
    }
  }

  void _onCategoryChanged(String? newId) {
    if (newId == null || newId == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = newId;
      _pressedIndex = -1;
    });
    ref.read(childQuizViewModelProvider.notifier).loadTopics(newId);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _objectsController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- ANIMATED BACKGROUND BUILDER ---
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Layer 1: Shifting Gradient
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            final alignment1 = Alignment.lerp(
              Alignment.topLeft,
              Alignment.bottomRight,
              _bgController.value,
            )!;
            final alignment2 = Alignment.lerp(
              Alignment.topRight,
              Alignment.bottomLeft,
              _bgController.value,
            )!;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF0F2027), // Deep Dark Blue/Black
                    Color(0xFF203A43), // Professional Teal/Dark
                    Color(0xFF2C5364), // Rich Slate Blue
                  ],
                  begin: alignment1,
                  end: alignment2,
                ),
              ),
            );
          },
        ),

        // Layer 2: Floating Objects
        AnimatedBuilder(
          animation: _objectsController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: FloatingObjectsPainter(
                animationValue: _objectsController.value,
              ),
            );
          },
        ),
      ],
    );
  }

  // --- FROSTED GLASS BUTTON ---
  Widget _buildFrostedButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 6.w),
            ),
          ),
        ),
      ),
    );
  }

  // --- PARALLAX HEADER & DROPDOWN ---
  Widget _buildParallaxHeader(List<String> categories) {
    final parallaxOffset = _scrollOffset * 0.5;
    final currentStyle = _styleMap[_selectedCategoryId] ?? _fallbackStyle;

    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onCategoryChanged(categories.first);
      });
    }

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: FadeTransition(
        opacity: _headerController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Topic',
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            SizedBox(height: 1.5.h),

            // --- FROSTED DROPDOWN ---
            if (categories.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: categories.contains(_selectedCategoryId)
                            ? _selectedCategoryId
                            : null,
                        dropdownColor: const Color(
                          0xFF2C5364,
                        ).withValues(alpha: 0.95),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: currentStyle.color2,
                          size: 6.w,
                        ),
                        isExpanded: true,
                        hint: Text(
                          "Select Category",
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                        items: categories.map((cat) {
                          final style = _styleMap[cat] ?? _fallbackStyle;
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(
                                  style.icon,
                                  color: style.color1,
                                  size: 6.w,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  cat,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 1.h),
            Text(
              _selectedCategoryId.isEmpty
                  ? "Loading..."
                  : 'Showing topics for ${_selectedCategoryId.toUpperCase()}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQuizViewModelProvider);
    final topics = state.topics;
    final categories = state.categoryNames;

    _initCardAnimations(topics.length);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        body: Stack(
          children: [
            // 1. Animated Background
            _buildAnimatedBackground(),

            // 2. Main Content
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Row
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFrostedButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => context.goNamed('bottomNavChild'),
                          ),
                          Text(
                            'Quizzes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),

                          // --- 2. REFRESH BUTTON ---
                          _buildFrostedButton(
                            icon: Icons.refresh_rounded,
                            onTap: () {
                              if (_selectedCategoryId.isNotEmpty) {
                                ref
                                    .read(childQuizViewModelProvider.notifier)
                                    .loadTopics(_selectedCategoryId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Refreshing Topics...",
                                      style: GoogleFonts.poppins(),
                                    ),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.white.withValues(alpha:
                                      0.2,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Parallax Title & Dropdown
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildParallaxHeader(categories),
                    ),
                  ),

                  // Content Grid
                  if (state.isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (topics.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "No topics found.",
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                      ).copyWith(bottom: 10.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2.5.h,
                          crossAxisSpacing: 4.w,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildAnimatedTopicCard(index, topics[index]);
                        }, childCount: topics.length),
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

  // --- ANIMATED TOPIC CARD ---
  Widget _buildAnimatedTopicCard(int index, QuizTopicModel topic) {
    if (index >= _cardControllers.length) return const SizedBox.shrink();

    final ctrl = _cardControllers[index];
    final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack);
    final isPressed = _pressedIndex == index;
    final scale = isPressed ? 0.95 : 1.0;

    final gradient =
        _randomGradients[(topic.id.hashCode).abs() % _randomGradients.length];
    final darkColor = gradient[0];

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(anim),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex = index),
          onTapUp: (_) {
            setState(() => _pressedIndex = -1);
            Future.delayed(const Duration(milliseconds: 100), () {
              context.goNamed('childQuizTopicDetailScreen', extra: topic);
            });
          },
          onTapCancel: () => setState(() => _pressedIndex = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    Icons.library_books_rounded,
                    color: Colors.white.withValues(alpha: 0.15),
                    size: 50.sp,
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.category.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                topic.topicName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 1.5.h),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.layers,
                                          size: 12.sp,
                                          color: darkColor,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          "${topic.levels.length} Levels",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: darkColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(1.5.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.2),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR ANIMATED OBJECTS ---
class FloatingObjectsPainter extends CustomPainter {
  final double animationValue;

  FloatingObjectsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // FIX: Instantiate the Paint object here
    final Paint circlePaint = Paint()..style = PaintingStyle.fill;

    _drawCircle(
      canvas,
      size,
      0.2,
      0.3,
      20,
      Colors.white.withValues(alpha: 0.05),
      1.5,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.8,
      0.2,
      40,
      Colors.white.withValues(alpha: 0.03),
      -1.0,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.5,
      0.8,
      30,
      Colors.white.withValues(alpha: 0.04),
      0.8,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.1,
      0.7,
      15,
      Colors.white.withValues(alpha: 0.06),
      -2.0,
      circlePaint,
    );
    _drawCircle(
      canvas,
      size,
      0.9,
      0.6,
      25,
      Colors.white.withValues(alpha: 0.03),
      1.2,
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
    double x = (xSeed + (animationValue * speed * 0.2)) % 1.0;
    double y =
        (ySeed + (math.sin(animationValue * 2 * math.pi * speed) * 0.1)) % 1.0;

    if (x < 0) x += 1.0;
    if (y < 0) y += 1.0;

    canvas.drawCircle(
      Offset(x * size.width, y * size.height),
      radius,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(FloatingObjectsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
