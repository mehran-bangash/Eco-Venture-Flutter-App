import 'package:eco_venture/core/constants/app_gradients.dart';
import 'package:eco_venture/views/child_section/widgets/click_able_info_card.dart';
import 'package:eco_venture/views/child_section/widgets/container_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/shared_preferences_helper.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with TickerProviderStateMixin {
  String username = "unknown";

  late AnimationController _controller; // For entrance animations
  late AnimationController _bgController; // For background gradient
  late AnimationController _floatController; // For continuous floating

  @override
  void initState() {
    super.initState();
    _loadUsername();

    // Entrance animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Background gradient controller (looping)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Floating cards animation (looping)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    setState(() {
      username = name ?? "unknown";
    });
  }

  //  Floating wrapper
  Widget _floatingWrapper({required Widget child}) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, childWidget) {
        final dy = Tween<double>(begin: 0, end: -10).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: Curves.easeInOut,
          ),
        );
        return Transform.translate(
          offset: Offset(0, dy.value),
          child: childWidget,
        );
      },
      child: child,
    );
  }

  // ✅ Entrance animation + floating combo
  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return _buildAnimation(
      index: index,
      child: _floatingWrapper(child: child), // add continuous float
    );
  }

  // 🔹 Reusable entrance animation
  Widget _buildAnimation({required int index, required Widget child}) {
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.15 * index,
          0.8,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    final fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.15 * index,
        1.0,
        curve: Curves.easeIn,
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      Colors.deepPurple, Colors.blueAccent, _bgController.value)!,
                  Color.lerp(
                      Colors.pinkAccent, Colors.orange, _bgController.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(),
              SizedBox(height: 1.5.h),

              // Search Box
              _buildAnimation(index: 1, child: _buildSearchBox()),

              SizedBox(height: 2.h),

              // ✅ Cards with continuous smooth float
              _buildAnimatedCard(
                index: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClickableInfoCard(
                        title: "Progress",
                        icon: Icons.bar_chart,
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(width: 14.w),
                      Flexible(
                        child: ClickableInfoCard(
                          title: "Rewards",
                          icon: Icons.emoji_events,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Floating Grid too
              _buildAnimatedCard(index: 3, child: ContainerGrid()),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Search box UI
  Widget _buildSearchBox() {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, right: 2.w),
      child: Container(
        height: 5.8.h,
        width: 90.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 0.9.w),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "What would you like to select?",
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF0A2540).withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Header section
  Widget _buildHeaderSection() {
    return Stack(
      children: [
        // Background image
        Container(
          width: 100.w,
          height: 25.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/child-Back-image.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay
        Container(
          width: double.infinity,
          height: 25.h,
          decoration: BoxDecoration(
            gradient: AppGradients.backgroundGradient.withOpacity(0.6),
          ),
        ),

        // Header content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 4.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimation(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/appLogo.png",
                            height: 50, width: 50),
                        const SizedBox(width: 8),
                        Text(
                          "Hi, $username",
                          style: GoogleFonts.poppins(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications,
                        color: Colors.white, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.5.h, left: 4.w),
                child: _buildAnimation(
                  index: 1,
                  child: Text(
                    "Ready For today's \n adventure",
                    style: GoogleFonts.poppins(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
