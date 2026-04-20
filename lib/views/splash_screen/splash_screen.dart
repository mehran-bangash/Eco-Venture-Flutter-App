import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../viewmodels/auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late PageController _pageController;
  double _scrollOffset = 0.0;
  int _currentIndex = 0;

  final List<SplashData> _screens = [
    SplashData(
      title: "DISCOVER NATURE\nWITH QR HUNTS",
      description: "Explore your surroundings, scan QR codes, and unlock secrets of the natural world through interactive treasure hunts.",
      bgColor: const Color(0xFFFFD600),
      accentColor: const Color(0xFFFF4081),
      stickerIcon: Icons.nature_people_rounded,
      secondaryIcon: Icons.location_on_rounded,
      roleTag: "Explorer Hub",
    ),
    SplashData(
      title: "STAY CURIOUS,\nSTAY SMART",
      description: "Interact with our AI guide to get instant facts about plants and animals. STEM learning has never been this fun.",
      bgColor: const Color(0xFFCE93D8),
      accentColor: const Color(0xFFFFD600),
      stickerIcon: Icons.psychology_rounded,
      secondaryIcon: Icons.auto_awesome_rounded,
      roleTag: "AI Mentorship",
    ),
    SplashData(
      title: "CHOOSE YOUR\nUNIQUE ROLE",
      description: "Whether you're learning, guiding, or managing a class, pick your role on the next screen to start your journey.",
      bgColor: const Color(0xFF9CCC65),
      accentColor: const Color(0xFFFFD600),
      stickerIcon: Icons.diversity_3_rounded,
      secondaryIcon: Icons.verified_user_rounded,
      roleTag: "Community",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _scrollOffset = _pageController.page ?? 0.0;
        });
      }
    });

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. ORIGINAL BACKGROUND DESIGN
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: _screens[_currentIndex].bgColor,
            child: Stack(
              children: List.generate(_screens.length, (index) {
                double relativePosition = index - _scrollOffset;
                return Positioned(
                  top: -5.h,
                  left: 15.w + (relativePosition * 40.w),
                  child: Opacity(
                    opacity: (1 - relativePosition.abs()).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: -math.pi / 12,
                      child: Container(
                        width: 55.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: _screens[index].accentColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 2. ORIGINAL CONTENT LAYER
          PageView.builder(
            controller: _pageController,
            onPageChanged: (val) => setState(() => _currentIndex = val),
            itemCount: _screens.length,
            itemBuilder: (context, index) => _buildMovingContent(_screens[index]),
          ),

          // 3. FIXED CONTROLS (ONLY LOGIC UPDATED)
          _buildFixedControls(),
        ],
      ),
    );
  }

  Widget _buildMovingContent(SplashData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          _buildProfessionalSticker(data),
          const Spacer(),
          Text(
            data.title,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            data.description,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.black.withOpacity(0.7),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _buildProfessionalSticker(SplashData data) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 45.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              ),
              child: Center(
                child: Icon(data.stickerIcon, size: 30.w, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: -15,
          right: -15,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(data.secondaryIcon, size: 6.w, color: data.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedControls() {
    return Positioned(
      bottom: 4.h,
      left: 6.w,
      right: 6.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Fixed Skip Button
          TextButton(
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(_screens.length - 1,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic);
              }
            },
            child: Text(
              "Skip",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          // Indicators
          Row(
            children: List.generate(_screens.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 6.w : 2.w,
                height: 0.8.h,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
          // Fixed Start/Next Button
          GestureDetector(
            // FIXED — let the router redirect handle navigation after state change
            onTap: () async {
              if (_currentIndex < _screens.length - 1) {
                if (_pageController.hasClients) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else {
                await ref.read(authViewModelProvider.notifier).completeOnboarding();
                // Directly navigate — don't rely on router redirect for this case
                if (mounted) context.goNamed('landing');
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _currentIndex == _screens.length - 1 ? "Start" : "Next",
                style: GoogleFonts.poppins(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashData {
  final String title, description, roleTag;
  final Color bgColor, accentColor;
  final IconData stickerIcon, secondaryIcon;
  SplashData({required this.title, required this.description, required this.bgColor, required this.accentColor, required this.stickerIcon, required this.secondaryIcon, required this.roleTag});
}