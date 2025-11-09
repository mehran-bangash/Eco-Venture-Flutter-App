import 'dart:ui';
import 'dart:math' as math; // Needed for the 3D flip
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/shared_preferences_helper.dart';
import '../child_section/widgets/click_able_info_card.dart';


class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with TickerProviderStateMixin {
  String username = "Explorer";

  late final AnimationController _mainController;
  late final AnimationController _bgController;
  late final AnimationController _floatController;

  // --- MOCK DATA FOR THE 5 MODULES ---
  // We define the module data here. Your RiverPod/MVVM would provide this.
// In _ChildHomeScreenState

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'QR based Treasure',
      'icon': Icons.qr_code_scanner_rounded,
      'color1': const Color(0xFF43A047),
      'color2': const Color(0xFF81C784),
      'route': 'treasureHunt',
      'imageUrl': 'https://images.unsplash.com/photo-1620423855978-e5d74a7bef30?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'STEM challenges',
      'icon': Icons.science_outlined,
      'color1': const Color(0xFF1E88E5),
      'color2': const Color(0xFF64B5F6),
      'route': 'stemChallenges',
      'imageUrl': 'https://images.unsplash.com/photo-1634872583967-6417a8638a59?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Nature Photo journal',
      'icon': Icons.photo_camera_rounded,
      'color1': const Color(0xFFFB8C00),
      'color2': const Color(0xFFFFB74D),
      'route':'naturePhotoJournal',
      'imageUrl': 'https://images.unsplash.com/photo-1579535984712-92fffbbaa266?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Interactive Quiz',
      'icon': Icons.quiz_rounded, // <-- CHANGED icon
      'color1': const Color(0xFF8E24AA),
      'color2': const Color(0xFFBA68C8),
      'route':'interactiveQuiz' , // You may want to change this route name
      'imageUrl': 'https://raw.githubusercontent.com/encharm/Font-Awesome-SVG-PNG/master/black/png/256/question.png',
    },
    {
      'title': 'MultiMedia Content',
      'icon': Icons.play_circle_filled_rounded, // <-- CHANGED icon
      'color1': const Color(0xFFE53935),
      'color2': const Color(0xFFEF9A9A),
      'route': 'multiMediaContent', // You may want to change this route name
      'imageUrl': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80', // <-- CHANGED image
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    if (!mounted) return;
    setState(() => username = name ?? "Explorer");
  }

  // Smooth Floating Wrapper
  Widget _floatingWrapper({required Widget child}) {
    final offset = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) =>
          Transform.translate(offset: Offset(0, offset.value), child: child),
    );
  }

  // Staggered Entry Animation
  Widget _animatedEntry({required int index, required Widget child}) {
    final fade = CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.1 * index, 1, curve: Curves.easeInOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.1 * index, 0.9, curve: Curves.easeOutCubic),
    ));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  // Frosted Glass Container
  Widget _frostedCard({required Widget child, double blur = 10}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12), // Changed from withValues
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)), // Changed from withValues
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), // Changed from withValues
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Animated Gradient Background
  Widget _buildAnimatedBackground({required Widget child}) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final color1 = Color.lerp(
            const Color(0xFF3F51B5), const Color(0xFF2196F3), _bgController.value)!;
        final color2 = Color.lerp(
            const Color(0xFF7C4DFF), const Color(0xFFFF4081), _bgController.value)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }

  // Header Section
// Header Section
  Widget _buildHeader() {
    return ClipRRect( // <-- ADDED ClipRRect to contain the zoom
      child: Stack(
        children: [
          // --- THIS IS THE NEW ANIMATED PART ---
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              // Animates from 1.0 to 1.1 scale
              final scale = 1.0 + (_bgController.value * 0.1);
              // Animates from 0 to 15 pixels horizontally
              final xOffset = _bgController.value * 15.0;

              return Transform(
                transform: Matrix4.identity()
                  ..scale(scale)
                  ..translate(xOffset, 0.0),
                alignment: Alignment.center,
                child: Container(
                  height: 26.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/child-Back-image.jpeg"),
                      fit: BoxFit.cover,
                      alignment: Alignment.center, // Ensure image stays centered
                    ),
                  ),
                ),
              );
            },
          ),
          // --- END OF NEW PART ---

          // The original gradient overlay
          Container(
            height: 26.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // The original text and icons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _animatedEntry(
                  index: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/images/appLogo.png",
                              height: 45, width: 45),
                          SizedBox(width: 2.w),
                          Text(
                            "Hi, $username ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                _animatedEntry(
                  index: 1,
                  child: Text(
                    "Ready for today’s\nadventure? ",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///  Search Box
  Widget _buildSearchBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: _frostedCard(
        child: Container(
          height: 6.5.h,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 22.sp), // Changed from withValues
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "What would you like to explore?",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///  Info Cards Row
  Widget _buildInfoCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.goNamed("progressDashboardScreen");
              },
              child: _frostedCard(
                child: _floatingWrapper(
                  child: ClickableInfoCard(
                    title: "Progress",
                    icon: Icons.show_chart_rounded,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.goNamed("RewardsScreen");
              },
              child: _frostedCard(
                child: _floatingWrapper(
                  child: ClickableInfoCard(
                    title: "Rewards",
                    icon: Icons.emoji_events_rounded,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- Ultra Pro Module Grid ---
  /// --- Ultra Pro Module Grid ---
  Widget _buildModuleGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _modules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 3.w,
          crossAxisSpacing: 3.w,
          childAspectRatio: 0.85, // Adjust this ratio to fit your design
        ),
        itemBuilder: (context, index) {
          final module = _modules[index];

          // --- THIS IS THE UPGRADE ---
          // I've wrapped your _animatedEntry in the _floatingWrapper
          // so the cards will float just like your "Progress" card.
          return _floatingWrapper(
            child: _animatedEntry(
              index: 4 + index, // Stagger the animation
              child: EcoModuleCard(
                title: module['title'],
                icon: module['icon'],
                color1: module['color1'],
                color2: module['color2'],
                imageUrl: module['imageUrl'],
                floatingWrapper: _floatingWrapper, // This is now used for glow
                onTap: () {
                  context.goNamed(module['route']);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  ///  Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildAnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: 3.h),
                _animatedEntry(index: 2, child: _buildSearchBox()),
                SizedBox(height: 3.h),
                _animatedEntry(index: 3, child: _buildInfoCards()),
                SizedBox(height: 3.h),
                _buildModuleGrid(),
                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EcoModuleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String imageUrl;
  final VoidCallback onTap;
  final Widget Function({required Widget child}) floatingWrapper;

  const EcoModuleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.imageUrl,
    required this.onTap,
    required this.floatingWrapper,
  });

  @override
  EcoModuleCardState createState() => EcoModuleCardState();
}

class EcoModuleCardState extends State<EcoModuleCard> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset the flip when coming back to this screen
    if (_flipController.status == AnimationStatus.completed) {
      _flipController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Start flip animation
    await _flipController.forward();

    // Navigate
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) widget.onTap();

    // Reset flip back to front after short delay
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _flipController.reverse();
      });
    }
  }






  @override
  void didUpdateWidget(covariant EcoModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _flipController.value = 0.0;
  }

  void _onTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _handleTap();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.95 : 1.0;

    // --- THIS IS THE NEW GLOW EFFECT ---
    final glow = _isPressed ? 15.0 : 0.0;
    final glowColor = _isPressed ? widget.color1.withValues(alpha: 0.7) : Colors.transparent;
    // --- END NEW EFFECT ---

    // I've wrapped the AnimatedScale in an AnimatedContainer
    // to animate the new glow shadow.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: glow,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final isFront = _flipAnimation.value < 0.5;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isFront
                    ? _buildFrontDesign()
                    : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _buildBackDesign(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// NEW FRONT DESIGN (Image-based, 3D, Glow Accent)
  Widget _buildFrontDesign() {
    final imageUrl = widget.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(imageUrl, fit: BoxFit.cover),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Icon in top-right
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color1.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 22),
            ),
          ),
          // Title + accent line
          Positioned(
            left: 15,
            bottom: 18,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [widget.color1, widget.color2],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Back side stays same (Let's Go)
  Widget _buildBackDesign() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.color2, widget.color1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 10.w),
            SizedBox(height: 1.h),
            Text(
              "Let's Go!",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}