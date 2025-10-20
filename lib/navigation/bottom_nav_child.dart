import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../views/child_section/ai_chat_screen.dart';
import '../views/child_section/child_home_screen.dart';
import '../views/child_section/report_safety_screen.dart';
import '../views/child_section/settings/child_settings.dart';

class BottomNavChild extends StatefulWidget {
  const BottomNavChild({super.key});

  @override
  State<BottomNavChild> createState() => _BottomNavChildState();
}

class _BottomNavChildState extends State<BottomNavChild>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final _screens = [
    const ChildHomeScreen(),
    const AiChatScreen(),
    const ReportSafetyScreen(),
    const ChildSettings(),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF2F5FA),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),


      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.65),
                    Colors.white.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(25),
              ),

              // NAVIGATION ITEMS
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, "Home", 0),
                  _buildNavItem(Icons.smart_toy_rounded, "ChatBot", 1),
                  _buildNavItem(Icons.shield_rounded, "Safety", 2),
                  _buildNavItem(Icons.settings_rounded, "Settings", 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0A2540).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: isActive ? 1.3 : 1.0,
              curve: Curves.easeOut,
              child: Icon(
                icon,
                size: 22.sp,
                color: isActive
                    ? const Color(0xFF0A2540)
                    : Colors.black.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isActive
                    ? const Color(0xFF0A2540)
                    : Colors.black.withValues(alpha: 0.6),
                fontSize: 13.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
