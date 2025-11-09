
import 'dart:ui'; // Needed for BackdropFilter (frosted glass)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart'; // Keep your router import


class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color color2; // Added a second color for richer gradients
  CategoryModel(
      this.id, this.title, this.subtitle, this.icon, this.color, this.color2);
}


class InteractiveQuizScreen extends StatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  State<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends State<InteractiveQuizScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _headerController;
  late final ScrollController _scrollController;

  double _scrollOffset = 0.0;
  int _pressedIndex = -1; // Tracks which card is being pressed

  // Staggered card animation controllers
  final List<AnimationController> _cardControllers = [];

  // --- 🎨 NEW VIBRANT DATA ---
  // I've added a second color to each category for beautiful gradients.
  final List<CategoryModel> categories = [
    CategoryModel(
      'animals', 'Animals', 'Test your animal knowledge',
      Icons.pets_rounded, const Color(0xFFFA8B74), const Color(0xFFF04A27),
    ),
    CategoryModel(
      'plants', 'Plants', 'From seeds to giant trees',
      Icons.eco_rounded, const Color(0xFF74FAB6), const Color(0xFF27F086),
    ),
    CategoryModel(
      'ecosystem', 'Ecosystem', 'Explore nature\'s balance',
      Icons.public_rounded, const Color(0xFF74D4FA), const Color(0xFF279AF0),
    ),
    CategoryModel(
      'science', 'Science', 'Discover amazing wonders',
      Icons.science_rounded, const Color(0xFFB974FA), const Color(0xFF7327F0),
    ),
    CategoryModel(
      'maths', 'Maths', 'Challenge your numbers',
      Icons.calculate_rounded, const Color(0xFF74FACD), const Color(0xFF27F0A8),
    ),
    CategoryModel(
      'space', 'Space', 'Journey to the stars',
      Icons.rocket_launch_rounded, const Color(0xFFFA74E8), const Color(0xFFF027C6),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // 1. Controller for the deep background gradient animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // 2. Controller for the header ("Choose Your Challenge") fade-in
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // 3. Controller to detect scrolling for parallax effect
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    // 4. Staggered card controllers (same as your logic, it's good!)
    for (var i = 0; i < categories.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 650),
      );
      _cardControllers.add(ctrl);

      // Staggered start
      Future.delayed(Duration(milliseconds: 300 + i * 120), () {
        if (mounted) ctrl.forward();
      });
    }
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

  /// 🌟 Builds the new dynamic, dark, animated background
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        // This creates a slow, shifting gradient
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
                Color(0xFF0F3460), // Deep blue
                Color(0xFF1A1A2E), // Dark purple/blue
                Color(0xFF16213E), // Almost black
              ],
              begin: alignment1,
              end: alignment2,
            ),
          ),
        );
      },
    );
  }

  /// 🌟 Builds the new "Frosted Glass" UI buttons
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
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 6.w),
            ),
          ),
        ),
      ),
    );
  }

  /// 🌟 Builds the new Parallax Header
  Widget _buildParallaxHeader() {
    // Parallax effect: Header text moves at half the scroll speed
    final parallaxOffset = _scrollOffset * 0.5;

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: FadeTransition(
        opacity: _headerController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Challenge',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Select a category to start the quiz',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E), // Dark base color
        body: Stack(
          children: [
            // 1) The New Animated Background
            _buildAnimatedBackground(),

            // 2) Main Scrollable Content
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 3) Header Row (Frosted Glass)
                  SliverPadding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
                          _buildFrostedButton(
                            icon: Icons.person_outline_rounded,
                            onTap: () {
                              // TODO: Handle profile tap
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4) Parallax Title
                  SliverPadding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    sliver: SliverToBoxAdapter(
                      child: _buildParallaxHeader(),
                    ),
                  ),

                  // 5) The "Ultra Pro" Card Grid
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w)
                        .copyWith(bottom: 10.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2.5.h,
                        crossAxisSpacing: 4.w,
                        childAspectRatio: 0.75, // Taller cards
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final cat = categories[index];
                          return _buildAnimatedCard(index, cat);
                        },
                        childCount: categories.length,
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

  /// 🌟 THE NEW "ULTRA PRO" CARD 🌟
  Widget _buildAnimatedCard(int index, CategoryModel cat) {
    final ctrl = _cardControllers[index];
    final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack);

    // 3D tilt and scale animation on press
    final isPressed = _pressedIndex == index;
    final scale = isPressed ? 0.92 : 1.0;
    final tilt = isPressed ? 0.1 : 0.0; // 3D tilt effect

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(anim),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex = index),
          onTapUp: (_) {
            setState(() => _pressedIndex = -1);
            // Navigate after a slight delay for the animation
            Future.delayed(const Duration(milliseconds: 100), () {
              context.goNamed('quizQuestionScreen');
            });
          },
          onTapCancel: () => setState(() => _pressedIndex = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D perspective
              ..rotateX(tilt) // Apply tilt
              ..scale(scale), // Apply scale
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [cat.color, cat.color2], // Use model's colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: cat.color.withOpacity(0.4), // Shadow matches color
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // "Glossy" shine effect
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Icon
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child:
                        Icon(cat.icon, color: Colors.white, size: 6.5.w),
                      ),
                      // Text and Play Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            cat.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Play Button
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cat.color2,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: cat.color2,
                                  size: 4.w,
                                )
                              ],
                            ),
                          ),
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