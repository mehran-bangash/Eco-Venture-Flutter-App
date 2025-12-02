import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';

class InteractiveQuizScreen extends ConsumerStatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  ConsumerState<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen>
    with TickerProviderStateMixin {

  // --- ANIMATION CONTROLLERS ---
  late final AnimationController _bgController;
  late final AnimationController _objectsController;
  late final ScrollController _scrollController;

  // --- STATE FOR DROPDOWNS ---
  String _selectedAdminCategory = '';
  String _selectedTeacherCategory = '';

  // Random Gradients for cards
  final List<List<Color>> _randomGradients = [
    [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)], // Pink
    [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)], // Purple
    [const Color(0xFF84fab0), const Color(0xFF8fd3f4)], // Aqua
    [const Color(0xFFe0c3fc), const Color(0xFF8ec5fc)], // Lavender
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green
    [const Color(0xFFfa709a), const Color(0xFFfee140)], // Sunset
  ];

  @override
  void initState() {
    super.initState();
    // Background Gradient Animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // Floating Objects Animation
    _objectsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _objectsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQuizViewModelProvider);

    // Data lists
    final adminTopics = state.adminTopics;
    final teacherTopics = state.teacherTopics;
    final adminCats = state.adminCategories;
    final teacherCats = state.teacherCategories;

    // --- AUTO-SELECT DEFAULTS ---
    if (_selectedAdminCategory.isEmpty && adminCats.isNotEmpty) {
      Future.microtask(() {
        setState(() => _selectedAdminCategory = adminCats.first);
        ref.read(childQuizViewModelProvider.notifier).loadAdminTopics(adminCats.first);
      });
    }

    if (_selectedTeacherCategory.isEmpty && teacherCats.isNotEmpty) {
      Future.microtask(() {
        setState(() => _selectedTeacherCategory = teacherCats.first);
        ref.read(childQuizViewModelProvider.notifier).loadTeacherTopics(teacherCats.first);
      });
    }

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
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 5.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    _buildHeader(),

                    // SECTION 1: GLOBAL CONTENT (Admin)

                    _buildSectionTitle("Global Quizzes", Icons.public),

                    if (adminCats.isNotEmpty)
                      _buildDropdown(
                          items: adminCats,
                          value: _selectedAdminCategory,
                          onChanged: (val) {
                            if(val != null) {
                              setState(() => _selectedAdminCategory = val);
                              ref.read(childQuizViewModelProvider.notifier).loadAdminTopics(val);
                            }
                          }
                      ),

                    SizedBox(height: 2.h),

                    // Show Loading or Grid
                    if (state.isLoading && adminTopics.isEmpty)
                      const Center(child: CircularProgressIndicator(color: Colors.white))
                    else
                      _buildTopicGrid(adminTopics, "No global quizzes found."),
                    // SECTION 2: CLASSROOM CONTENT (Teacher)
                    if (teacherCats.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 2),
                      ),
                      SizedBox(height: 3.h),

                      _buildSectionTitle("My Classroom", Icons.school_rounded),

                      _buildDropdown(
                          items: teacherCats,
                          value: _selectedTeacherCategory,
                          onChanged: (val) {
                            if(val != null) {
                              setState(() => _selectedTeacherCategory = val);
                              ref.read(childQuizViewModelProvider.notifier).loadTeacherTopics(val);
                            }
                          }
                      ),

                      SizedBox(height: 2.h),
                      _buildTopicGrid(teacherTopics, "No class quizzes assigned yet."),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ANIMATED BACKGROUND ---
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Layer 1: Gradient
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            final alignment1 = Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, _bgController.value)!;
            final alignment2 = Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, _bgController.value)!;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
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
              painter: FloatingObjectsPainter(animationValue: _objectsController.value),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.goNamed('bottomNavChild'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text("Quiz Center", style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 10)])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.cyanAccent, size: 18.sp),
          ),
          SizedBox(width: 3.w),
          Text(title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 5)])),
        ],
      ),
    );
  }

  Widget _buildDropdown({required List<String> items, required String value, required Function(String?) onChanged}) {
    final safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), border: Border.all(color: Colors.white24)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeValue,
                dropdownColor: const Color(0xFF203A43).withValues(alpha: 0.95),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                isExpanded: true,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicGrid(List<QuizTopicModel> topics, String emptyMsg) {
    if (topics.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(5.w),
        child: Center(child: Text(emptyMsg, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 15.sp))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.8,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildAnimatedTopicCard(topics[index], index);
      },
    );
  }

  // --- ULTRA PRO TOPIC CARD ---
  Widget _buildAnimatedTopicCard(QuizTopicModel topic, int index) {
    // Random Gradient based on ID
    final gradient = _randomGradients[(topic.id.hashCode).abs() % _randomGradients.length];
    final darkColor = gradient[0];

    return GestureDetector(
      onTap: () => context.goNamed('childQuizTopicDetailScreen', extra: topic),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: gradient[0].withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Stack(
          children: [
            // 1. Background Icon
            Positioned(
              top: -15,
              right: -15,
              child: Icon(Icons.library_books_rounded, color: Colors.white.withValues(alpha: 0.15), size: 60.sp),
            ),

            // 2. Teacher Badge (If Applicable)
            if (topic.createdBy == 'teacher')
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 12.sp, color: Colors.amber),
                      SizedBox(width: 1.w),
                      Text("CLASS", style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: darkColor))
                    ],
                  ),
                ),
              ),

            // 3. Content Overlay (Glass)
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
                        color: Colors.black.withValues(alpha: 0.2), // Darker overlay for readability
                        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            topic.topicName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 4)]
                            ),
                          ),
                          SizedBox(height: 1.5.h),

                          // Levels & Arrow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                    color: Colors.white, // White pill
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                ),
                                child: Text(
                                  "${topic.levels.length} Levels",
                                  style: GoogleFonts.poppins(fontSize: 12.sp, color: darkColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(Icons.play_circle_fill, color: Colors.white, size: 22.sp)
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
    );
  }
}

// --- PAINTER CLASS ---
class FloatingObjectsPainter extends CustomPainter {
  final double animationValue;
  FloatingObjectsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    _drawCircle(canvas, size, 0.2, 0.3, 20, Colors.white.withValues(alpha:0.05), 1.5, paint);
    _drawCircle(canvas, size, 0.8, 0.2, 40, Colors.white.withValues(alpha: 0.03), -1.0, paint);
    _drawCircle(canvas, size, 0.5, 0.8, 30, Colors.white.withValues(alpha: 0.04), 0.8, paint);
    _drawCircle(canvas, size, 0.1, 0.7, 15, Colors.white.withValues(alpha: 0.06), -2.0, paint);
    _drawCircle(canvas, size, 0.9, 0.6, 25, Colors.white.withValues(alpha: 0.03), 1.2, paint);
  }

  void _drawCircle(Canvas canvas, Size size, double xSeed, double ySeed, double radius, Color color, double speed, Paint paint) {
    double x = (xSeed + (animationValue * speed * 0.2)) % 1.0;
    double y = (ySeed + (math.sin(animationValue * 2 * math.pi * speed) * 0.1)) % 1.0;
    if (x < 0) x += 1.0;
    if (y < 0) y += 1.0;
    canvas.drawCircle(Offset(x * size.width, y * size.height), radius, paint..color = color);
  }

  @override
  bool shouldRepaint(FloatingObjectsPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}