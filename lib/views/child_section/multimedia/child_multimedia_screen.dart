
import 'package:eco_venture/core/constants/app_colors.dart';
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
    return PopScope(
      canPop: false, // prevents auto pop
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // This runs when system back button is pressed
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBar,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Multimedia Content",
            style: GoogleFonts.poppins(fontSize: 18.sp, color: Colors.white),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              // Handle in-app back arrow
              context.goNamed('bottomNavChild');
            },
            child: Padding(
              padding: EdgeInsets.only(left: 1.w),
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.movie), text: "Video"),
              Tab(icon: Icon(Icons.menu_book), text: "Story"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [VideoScreen(), StoryScreen()],
        ),
      ),
    );
  }


}
