import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';


class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color color2;
  CategoryModel(this.id, this.title, this.icon, this.color, this.color2);
}

class InteractiveQuizScreen extends ConsumerStatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  ConsumerState<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _headerController;
  late final ScrollController _scrollController;

  double _scrollOffset = 0.0;
  int _pressedIndex = -1;

  final List<AnimationController> _cardControllers = [];
  String _selectedCategoryId = ''; // Empty until data loads

  // --- STYLE DEFINITIONS (To map dynamic names to your beautiful UI) ---
  final Map<String, CategoryModel> _styleMap = {
    'Animals': CategoryModel('Animals', 'Animals', Icons.pets_rounded, Color(0xFFFA8B74), Color(0xFFF04A27)),
    'Plants': CategoryModel('Plants', 'Plants', Icons.eco_rounded, Color(0xFF74FAB6), Color(0xFF27F086)),
    'Ecosystem': CategoryModel('Ecosystem', 'Ecosystem', Icons.public_rounded, Color(0xFF74D4FA), Color(0xFF279AF0)),
    'Science': CategoryModel('Science', 'Science', Icons.science_rounded, Color(0xFFB974FA), Color(0xFF7327F0)),
    'Maths': CategoryModel('Maths', 'Maths', Icons.calculate_rounded, Color(0xFF74FACD), Color(0xFF27F0A8)),
    'Space': CategoryModel('Space', 'Space', Icons.rocket_launch_rounded, Color(0xFFFA74E8), Color(0xFFF027C6)),
    'Recycling': CategoryModel('Recycling', 'Recycling', Icons.recycling_rounded, Color(0xFF81C784), Color(0xFF43A047)),
    'Climate': CategoryModel('Climate', 'Climate', Icons.thermostat_rounded, Color(0xFFFFCC80), Color(0xFFFB8C00)),
  };

  // Fallback style for unknown categories
  final CategoryModel _fallbackStyle = CategoryModel('Unknown', 'General', Icons.quiz_rounded, Colors.blueGrey, Colors.blue);

  // Random Gradients for Quiz Cards
  final List<List<Color>> _randomGradients = [
    [const Color(0xFFFA8B74), const Color(0xFFF04A27)],
    [const Color(0xFF74FAB6), const Color(0xFF27F086)],
    [const Color(0xFF74D4FA), const Color(0xFF279AF0)],
    [const Color(0xFFB974FA), const Color(0xFF7327F0)],
    [const Color(0xFF74FACD), const Color(0xFF27F0A8)],
    [const Color(0xFFFA74E8), const Color(0xFFF027C6)],
    [const Color(0xFFFFCC80), const Color(0xFFFB8C00)],
    [const Color(0xFF81C784), const Color(0xFF43A047)],
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

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
        duration: const Duration(milliseconds: 650),
      );
      _cardControllers.add(ctrl);
      Future.delayed(Duration(milliseconds: 300 + i * 120), () {
        if (mounted && i < _cardControllers.length) _cardControllers[i].forward();
      });
    }
  }

  void _onCategoryChanged(String? newId) {
    if (newId == null || newId == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = newId;
      _pressedIndex = -1;
    });
    ref.read(childQuizViewModelProvider.notifier).loadQuizzes(newId);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- BUILDERS ---

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final alignment1 = Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, _bgController.value)!;
        final alignment2 = Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, _bgController.value)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF0F3460), Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: alignment1,
              end: alignment2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrostedButton({required IconData icon, required VoidCallback onTap}) {
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
            child: Center(child: Icon(icon, color: Colors.white, size: 6.w)),
          ),
        ),
      ),
    );
  }

  // --- DYNAMIC DROPDOWN ---
  Widget _buildCategoryDropdown(List<String> dynamicCategories) {
    if (dynamicCategories.isEmpty) {
      return Text("Loading Categories...", style: GoogleFonts.poppins(color: Colors.white54));
    }

    // Ensure we have a valid selection. If selected is empty or not in list, defaults to first.
    if (_selectedCategoryId.isEmpty || !dynamicCategories.contains(_selectedCategoryId)) {
      // We schedule a state update to sync the selected ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) _onCategoryChanged(dynamicCategories.first);
      });
    }

    // Get style for currently selected
    final currentStyle = _styleMap[_selectedCategoryId] ??
        CategoryModel(_selectedCategoryId, _selectedCategoryId, Icons.category, Colors.blueGrey, Colors.blue);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dynamicCategories.contains(_selectedCategoryId) ? _selectedCategoryId : null,
              dropdownColor: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: currentStyle.color2),
              isExpanded: true,
              hint: Text("Select Category", style: TextStyle(color: Colors.white)),
              items: dynamicCategories.map((catName) {
                final style = _styleMap[catName] ??
                    CategoryModel(catName, catName, Icons.category, Colors.teal, Colors.tealAccent);

                return DropdownMenuItem(
                  value: catName,
                  child: Row(
                    children: [
                      Icon(style.icon, size: 5.w, color: style.color),
                      SizedBox(width: 3.w),
                      Text(
                        style.title,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp
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
    );
  }

  Widget _buildParallaxHeader(List<String> dynamicCategories) {
    final parallaxOffset = _scrollOffset * 0.5;
    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: FadeTransition(
        opacity: _headerController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Quiz',
              style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
            ),
            SizedBox(height: 1.5.h),

            _buildCategoryDropdown(dynamicCategories),

            SizedBox(height: 1.h),
            Text(
              _selectedCategoryId.isEmpty ? "Please select a category" : 'Showing quizzes for ${_selectedCategoryId.toUpperCase()}',
              style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childQuizState = ref.watch(childQuizViewModelProvider);
    final quizzes = childQuizState.quizzes;
    final progressMap = childQuizState.progress;
    final dynamicCategories = childQuizState.categoryNames; // From Firebase

    _initCardAnimations(quizzes.length);

    final activeCategoryStyle = _styleMap[_selectedCategoryId] ?? _fallbackStyle;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('bottomNavChild');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Row
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFrostedButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => context.goNamed('bottomNavChild'),
                          ),
                          Text('Quizzes', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18.sp, color: Colors.white)),
                          _buildFrostedButton(icon: Icons.person_outline_rounded, onTap: () {
                            context.goNamed('childProfile');
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Parallax Title & Dropdown
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    sliver: SliverToBoxAdapter(child: _buildParallaxHeader(dynamicCategories)),
                  ),

                  // Content Grid
                  if (childQuizState.isLoading)
                    SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: activeCategoryStyle.color)),
                    )
                  else if (childQuizState.errorMessage != null)
                    SliverFillRemaining(
                      child: Center(child: Text("Error: ${childQuizState.errorMessage}", style: TextStyle(color: Colors.red))),
                    )
                  else if (quizzes.isEmpty)
                      SliverFillRemaining(
                        child: Center(child: Text("No quizzes found.", style: GoogleFonts.poppins(color: Colors.white54))),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w).copyWith(bottom: 10.h),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 2.5.h,
                            crossAxisSpacing: 4.w,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final quiz = quizzes[index];
                              bool isLocked = false;
                              if (quiz.order > 1) {
                                try {
                                  final prevQuiz = quizzes.firstWhere((q) => q.order == quiz.order - 1);
                                  final prevProgress = progressMap[prevQuiz.id];
                                  if (prevProgress == null || !prevProgress.isPassed) {
                                    isLocked = true;
                                  }
                                } catch (e) {
                                  isLocked = true;
                                }
                              }
                              return _buildAnimatedQuizCard(index, quiz, activeCategoryStyle, isLocked);
                            },
                            childCount: quizzes.length,
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

  Widget _buildAnimatedQuizCard(int index, QuizModel quiz, CategoryModel theme, bool isLocked) {
    if (index >= _cardControllers.length) return const SizedBox.shrink();

    final ctrl = _cardControllers[index];
    final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack);
    final isPressed = _pressedIndex == index;
    final scale = isPressed ? 0.92 : 1.0;

    List<Color> cardGradient;
    if (isLocked) {
      cardGradient = [Colors.grey.shade800, Colors.grey.shade900];
    } else {
      final int colorIndex = (quiz.id?.hashCode ?? index).abs() % _randomGradients.length;
      cardGradient = _randomGradients[colorIndex];
    }

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex = index),
          onTapUp: (_) {
            setState(() => _pressedIndex = -1);
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Pass Level ${quiz.order - 1} to unlock this!", style: GoogleFonts.poppins(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(seconds: 2),
                  )
              );
            } else {
              Future.delayed(const Duration(milliseconds: 100), () {
                context.goNamed('quizQuestionScreen', extra: quiz);
              });
            }
          },
          onTapCancel: () => setState(() => _pressedIndex = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isLocked ? Colors.black26 : cardGradient[0].withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -40, right: -40,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  ),
                ),
                if (quiz.imageUrl != null && !isLocked)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.network(
                          quiz.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => const SizedBox(),
                        ),
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
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "LVL ${quiz.order}",
                              style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          Icon(
                              isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                              color: isLocked ? Colors.white54 : Colors.white,
                              size: 5.w
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isLocked ? Colors.white54 : Colors.white,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: isLocked ? Colors.white10 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLocked ? 'Locked' : 'Start',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isLocked ? Colors.white54 : cardGradient[1],
                                  ),
                                ),
                                if (!isLocked) ...[
                                  SizedBox(width: 1.w),
                                  Icon(Icons.play_arrow_rounded, color: cardGradient[1], size: 4.w),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}