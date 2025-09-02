
import 'package:eco_venture/views/childSection/widgets/click_able_info_card.dart';
import 'package:eco_venture/views/childSection/widgets/container_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD7D7E0),
              Color(0xFFAEBAF5) // Almost White Aqua
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 1.h),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 3.5.h,
                  width: 26.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF0A2540).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      "Parent Section",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.only(left: 5.w, right: 2.w),
                child: Container(
                  height: 5.8.h,
                  width: 90.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9), // corrected
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
                            color: Color(0xFF1E3A8A).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
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
                              color: Color(0xFF0A2540).withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h,),
              Padding(
                padding: EdgeInsetsGeometry.only(left:8.w,right: 8.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClickableInfoCard(title: "Progress",icon: Icons.bar_chart,color: Colors.orangeAccent,),
                    SizedBox(width: 14.w,),
                    Flexible(child: ClickableInfoCard(title: "Rewards",icon: Icons.emoji_events,color: Colors.yellowAccent,)),
                  ],
                ),
              ),
              ContainerGrid(),
              SizedBox(height: 10.h,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        // 1. Background image
        Container(
          width: 100.w,
          height: 25.h, // adjust height according to your header
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/child-Back-image.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. Gradient overlay
        Container(
          width: double.infinity,
          height: 25.h, // same as image height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF95C8FC).withValues(alpha: 0.6), // Gentle Frost Blue
                Color(0xFFF1FCFF).withValues(alpha: 0.6), // Almost White Aqua
              ],
            ),
          ),
        ),

        // 3. Your header content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 3.5.w,
            vertical: 4.5.h,
          ), // adjust padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/appLogo.png",
                        height: 50,
                        width: 50,
                      ),
                      SizedBox(width: 8), // can use 2.w if using sizer
                      Text(
                        "Hi, Mehran Ali",
                        style: GoogleFonts.poppins(
                          fontStyle: FontStyle.italic,
                          fontSize: 18, // use 18.sp if using sizer
                          color: Color(0xFF0A2540),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.notifications,
                    color: Color(0xFF1E3A8A),
                    size: 24, // use 6.w if using sizer
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.5.h, left: 4.w),
                child: Text(
                  "Ready For today's \n adventure",
                  style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    fontSize: 18.sp,
                    color: Color(0xFF0A2540),
                    fontWeight: FontWeight.w600,
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


