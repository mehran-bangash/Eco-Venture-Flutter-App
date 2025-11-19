
import 'package:eco_venture/views/child_section/multimedia/story_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChildMultimediaScreen extends StatefulWidget {
  const ChildMultimediaScreen({super.key});

  @override
  State<ChildMultimediaScreen> createState() => _ChildMultimediaScreenState();
}

class _ChildMultimediaScreenState extends State<ChildMultimediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState(); // Corrected order
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        // 1. We remove the AppBar to allow a full-screen gradient.
        appBar: null,
        body: Container(
          // 2. Full-screen gradient background for a professional feel.
          // These colors match the ones you used in the Story/Video screens.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D324D), // Deep Ocean Blue
                Color(0xFF2F5755), // Teal Green blend
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 3. A custom, clean header instead of an AppBar.
                _buildCustomHeader(context),

                // 4. A modern, pill-style TabBar.
                _buildCustomTabBar(context),

                // 5. The TabBarView, which takes the remaining space.
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      VideoScreen(),
                      StoryScreen(),
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

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.goNamed('bottomNavChild'),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
          // Title (centered)
          Expanded(
            child: Text(
              "Multimedia Content",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // This SizedBox balances the Row so the title is perfectly centered.
          SizedBox(width: 10.w),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25), // Background of the tab bar
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: TabBar(
          controller: _tabController,
          // 6. This is the new, modern "pill" indicator.
          indicator: BoxDecoration(
            color: Colors.deepOrange, // Your chosen highlight color
            borderRadius: BorderRadius.circular(25.0),
          ),
          indicatorColor: Colors.transparent, // Hide the default underline

          // --- THIS IS THE FIX ---
          dividerColor: Colors.transparent, // Removes any faint divider line
          // --- END FIX ---

          labelColor: Colors.white, // Selected text color
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7), // Unselected text
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_rounded),
                  SizedBox(width: 8),
                  Text("Videos"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded),
                  SizedBox(width: 8),
                  Text("Stories"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}