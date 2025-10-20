import 'package:eco_venture/core/constants/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:animate_do/animate_do.dart';
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
      extendBodyBehindAppBar: true,
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 3.h),

                FadeInDown(
                  child: Text(
                    "Welcome Respected Teacher 👨🏫",
                    style: GoogleFonts.poppins(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // Search bar with Dysmorphic effect
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        const Icon(Icons.search, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search modules, students...",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Features Section
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Quick Access",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                Wrap(
                  spacing: 5.w,
                  runSpacing: 3.h,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildAnimatedFeature(Icons.people, "Students", 0),
                    _buildAnimatedFeature(Icons.event_note, "Activities", 100),
                    _buildAnimatedFeature(Icons.quiz, "Assessments", 200),
                    _buildAnimatedFeature(Icons.play_circle_fill, "Media", 300),
                    _buildAnimatedFeature(Icons.forum, "Communicate", 400),
                  ],
                ),

                SizedBox(height: 5.h),

                // Students Header Section
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFffffff), Color(0xFFe9f1ff)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Students",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A2540),
                              ),
                            ),
                            Text(
                              "Tap to view student profiles",
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                gradient: AppGradients.buttonGradient,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  "Delete Student",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Students Grid Section
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Center(
                    child: Wrap(
                      spacing: 10.w,
                      runSpacing: 3.h,
                      children: const [
                        RowCircleLabelText(icon: Icons.person, labelText: "Mehran Ali"),
                        RowCircleLabelText(icon: Icons.person, labelText: "Ali Afzal"),
                        RowCircleLabelText(icon: Icons.person, labelText: "Mavia"),
                        RowCircleLabelText(icon: Icons.person, labelText: "Khan"),
                        RowCircleLabelText(icon: Icons.person, labelText: "Ahmed"),
                        RowCircleLabelText(icon: Icons.person, labelText: "Zubair"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFeature(IconData icon, String label, int delayMs) {
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      child: CircleIconLabel(icon: icon, labelText: label),
    );
  }

  Widget _buildHeaderSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.only(top: 1.h, left: 3.w, right: 3.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mr. Mehran Ali",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Adventure Class",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 28),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
