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
  ConsumerState<InteractiveQuizScreen> createState() =>
      _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _objectsController;
  late final ScrollController _scrollController;

  String _selectedAdminCategory = '';
  String _selectedTeacherCategory = '';

  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _bgSurface = const Color(0xFFF8FAFC);

  final List<Color> _accentColors = [
    const Color(0xFFF43F5E),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF3B82F6),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return Icons.science_rounded;
      case 'maths':
        return Icons.calculate_rounded;
      case 'animals':
        return Icons.pets_rounded;
      case 'ecosystem':
        return Icons.eco_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQuizViewModelProvider);
    final adminTopics = state.adminTopics;
    final teacherTopics = state.teacherTopics;
    final adminCats = state.adminCategories;
    final teacherCats = state.teacherCategories;
    final progressMap = state.progress;

    if (_selectedAdminCategory.isEmpty && adminCats.isNotEmpty) {
      Future.microtask(() {
        setState(() => _selectedAdminCategory = adminCats.first);
        ref
            .read(childQuizViewModelProvider.notifier)
            .loadAdminTopics(adminCats.first);
      });
    }

    if (_selectedTeacherCategory.isEmpty && teacherCats.isNotEmpty) {
      Future.microtask(() {
        setState(() => _selectedTeacherCategory = teacherCats.first);
        ref
            .read(childQuizViewModelProvider.notifier)
            .loadTeacherTopics(teacherCats.first);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: _bgSurface,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 5.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSectionTitle(
                      "Global Quizzes",
                      Icons.public,
                      const Color(0xFF06B6D4),
                    ),
                    if (adminCats.isNotEmpty)
                      _buildDropdown(
                        items: adminCats,
                        value: _selectedAdminCategory,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedAdminCategory = val);
                            ref
                                .read(childQuizViewModelProvider.notifier)
                                .loadAdminTopics(val);
                          }
                        },
                      ),
                    SizedBox(height: 2.h),
                    if (state.isLoading && adminTopics.isEmpty)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF06B6D4),
                        ),
                      )
                    else
                      _buildTopicGrid(
                        adminTopics,
                        "No global quizzes found.",
                        progressMap,
                      ),

                    if (teacherCats.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      _buildSectionTitle(
                        "My Classroom",
                        Icons.school_rounded,
                        const Color(0xFFF59E0B),
                      ),
                      _buildDropdown(
                        items: teacherCats,
                        value: _selectedTeacherCategory,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTeacherCategory = val);
                            ref
                                .read(childQuizViewModelProvider.notifier)
                                .loadTeacherTopics(val);
                          }
                        },
                      ),
                      SizedBox(height: 2.h),
                      _buildTopicGrid(
                        teacherTopics,
                        "No class quizzes assigned yet.",
                        progressMap,
                      ),
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

  Widget _buildTopicGrid(
    List<QuizTopicModel> topics,
    String emptyMsg,
    Map<String, dynamic> progressMap,
  ) {
    if (topics.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(5.w),
        child: Center(
          child: Text(
            emptyMsg,
            style: GoogleFonts.poppins(color: _subText, fontSize: 14.sp),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.5.h,
        childAspectRatio: 0.85,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) =>
          _buildAnimatedTopicCard(topics[index], progressMap),
    );
  }

  Widget _buildAnimatedTopicCard(
    QuizTopicModel topic,
    Map<String, dynamic> progressMap,
  ) {
    final accentColor =
        _accentColors[(topic.id.hashCode).abs() % _accentColors.length];

    // Calculate progress
    int passedCount = 0;
    for (var level in topic.levels) {
      if (progressMap["${topic.id}_${level.order}"]?.isPassed == true)
        passedCount++;
    }
    double progressPercent = (passedCount / topic.levels.length) * 100;
    bool isComplete = progressPercent == 100;

    return GestureDetector(
      onTap: () => context.goNamed('childQuizTopicDetailScreen', extra: topic),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isComplete
                ? Colors.green.withOpacity(0.5)
                : accentColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -5,
              right: -5,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  _getCategoryIcon(topic.category),
                  color: accentColor,
                  size: 35.sp,
                ),
              ),
            ),

            if (isComplete)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      _getCategoryIcon(topic.category),
                      color: accentColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    topic.topicName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _primaryDark,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.3.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isComplete
                          ? "COMPLETED"
                          : "${progressPercent.toInt()}% Done",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w900,
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

  // ... rest of your UI helpers (Background, Header, SectionTitle, Dropdown, etc.) ...
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.goNamed('bottomNavChild'),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
          SizedBox(width: 2.w),
          Text(
            "Quiz Center",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17.sp),
          ),
          SizedBox(width: 3.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String value,
    required Function(String?) onChanged,
  }) {
    final safeValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeValue,
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: _subText),
            isExpanded: true,
            style: GoogleFonts.poppins(
              color: _primaryDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            items: items
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
