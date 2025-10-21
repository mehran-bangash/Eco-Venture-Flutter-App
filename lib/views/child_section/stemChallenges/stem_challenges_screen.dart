import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:eco_venture/views/child_section/stemChallenges/engineering_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/math_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/science_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/technology_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StemChallengesScreen extends StatefulWidget {
  const StemChallengesScreen({super.key});

  @override
  State<StemChallengesScreen> createState() => _StemChallengesScreenState();
}

class _StemChallengesScreenState extends State<StemChallengesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              context.goNamed('bottomNavChild');
            },
            child: Padding(
              padding:  EdgeInsets.only(left: 2.w,top: 1.h),
              child: Container(
                height: 2.h,
                width: 3.w,
                decoration: BoxDecoration(
                  color: Colors.white60.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
          ),
          backgroundColor: Colors.blueAccent,
          title: Text(
            "STEM Challenges",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.h),
            child: ButtonsTabBar(
              backgroundColor: Colors.red,
              unselectedBackgroundColor: Colors.grey[300],
              unselectedLabelStyle: GoogleFonts.poppins(color: Colors.black),
              labelStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              splashColor: Colors.deepPurple,
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
              buttonMargin: EdgeInsets.only(
                left: 2.w,
                right: 2.w,
                bottom: 0.5.h,
              ), // space between tabs
              tabs: const [
                Tab(icon: Icon(Icons.science_outlined), text: 'Science'),
                Tab(icon: Icon(Icons.calculate_outlined), text: 'Math'),
                Tab(
                  icon: Icon(Icons.engineering_outlined),
                  text: 'Engineering',
                ),
                Tab(icon: Icon(Icons.computer_outlined), text: 'Technology'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ScienceScreen(),
            MathScreen(),
            EngineeringScreen(),
            TechnologyScreen(),
          ],
        ),
      ),
    );
  }
}
