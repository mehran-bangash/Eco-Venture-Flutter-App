import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/shared_preferences_helper.dart';
import '../child_section/widgets/container_grid.dart';
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
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 26.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/child-Back-image.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
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
                  color: Colors.white.withValues(alpha: 0.9), size: 22.sp),
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
              onTap: () {},
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
              onTap: () {},
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
                _animatedEntry(
                  index: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: _frostedCard(
                      child: ContainerGrid(),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
