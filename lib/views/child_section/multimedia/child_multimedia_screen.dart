
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
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent.withValues(alpha: 0.4),
        title: Text(
          "Multimedia Content",
          style: GoogleFonts.poppins(fontSize: 18.sp, color: Color(0xFF0A2540)),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            context.goNamed('bottomNavChild');
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 1.w),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          splashFactory: InkRipple.splashFactory, // ripple effect style
          overlayColor: WidgetStateProperty.all(
            Colors.red.withValues(alpha: 0.1),
          ), // pressed overlay
          indicatorColor: Colors.deepOrange,
          labelStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
          labelColor: Colors.deepOrange, // Active tab text + icon color
          unselectedLabelColor: Color(
            0xFF0A2540,
          ).withValues(alpha: 0.7), // Inactive tab text + icon color
          tabs: [
            Tab(
              icon: Icon(Icons.movie, size: 6.w),
              text: "Video",
            ),
            Tab(icon: Icon(Icons.menu_book), text: "Story"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [VideoScreen(), StoryScreen()],
      ),
    );
  }
}
