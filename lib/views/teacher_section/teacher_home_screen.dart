import 'package:eco_venture/core/constants/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../parent_section/widgets/circle_icon_label.dart';
import '../parent_section/widgets/row_circle_label_text.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,//background Color
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.only(left: 6.w, right: 5.w),
                  child: Text(
                    "Welcome Respected Teacher",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // Search bar
                Padding(
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
                               color: Color(0xFF1565C0).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
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
                                color: Color(0xFF0A2540).withValues(alpha: 0.6),
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

                SizedBox(height: 4.h),

                // Features section
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Wrap(
                    spacing: 4.w,
                    runSpacing: 3.h,
                    alignment: WrapAlignment.start,
                    children: [
                      CircleIconLabel(
                        icon: Icons.people,
                        labelText: "Students",
                      ),
                      CircleIconLabel(
                        icon: Icons.event_note,
                        labelText: "Activities",
                      ),
                      CircleIconLabel(
                        icon: Icons.quiz,
                        labelText: "Quizzes and Assessments",
                      ),
                      CircleIconLabel(
                        icon: Icons.play_circle_fill,
                        labelText: "Multimedia Contents",
                      ),
                      CircleIconLabel(
                        icon: Icons.forum,
                        labelText: "Communicate",
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                //  Students header
                Container(
                  height: 12.h,
                  width: 100.w,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h, left: 5.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Students",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 3.w),
                              child: Container(
                                height: 4.h,
                                width: 35.w,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.buttonGradient,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Delete student",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          "Tap to view student profile",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                //  Class report
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: Container(
                      height: 4.h,
                      width: 35.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(
                          "class report",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                //  Students grid
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 2.h,
                    children: [
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Mehran Ali",
                      ),
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Ali Afzal",
                      ),
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Muhammad Mavia",
                      ),
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Ali khan",
                      ),
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Ali khan",
                      ),
                      RowCircleLabelText(
                        icon: Icons.person,
                        labelText: "Ali khan",
                      ),
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

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 6.w),
          child: Column(
            children: [
              Text(
                "Mr, Mehran Ali",
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "Adventure class",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 5.w),
              SizedBox(width: 2.w),
              Icon(Icons.menu, color: Colors.white, size: 7.w),
            ],
          ),
        ),
      ],
    );
  }
}
