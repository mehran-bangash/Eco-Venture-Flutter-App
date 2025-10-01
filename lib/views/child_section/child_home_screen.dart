
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

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  String username = "unknown";

  @override
  void initState() {
    // TODO: implement initState
    _loadUsername();
    super.initState();

  }

  Future<void> _loadUsername() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    setState(() {
      username = name ?? "unknown";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient.withOpacity(0.8)
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 1.5.h),
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
                            color: Color(0xFF1565C0).withValues(alpha: 0.9),
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
            gradient: AppGradients.backgroundGradient.withOpacity(0.6)
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
                        "Hi, $username",
                        style: GoogleFonts.poppins(
                          fontStyle: FontStyle.italic,
                          fontSize: 18, // use 18.sp if using sizer
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.notifications,
                    color: Colors.white,
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
                    color: Colors.white,
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


