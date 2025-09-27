
import 'package:eco_venture/views/child_section/widgets/edit_profile_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../core/constants/app_gradients.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 14.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.backgroundGradient,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 4.w,
                            top: 3.h,
                            right: 4.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.goNamed('childProfile');
                                },
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    height: 4.h,
                                    width: 8.w,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  height: 4.h,
                                  width: 8.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white70.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Text(
                            "Edit Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(10.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.h),
                        child: SizedBox(height: 15.h, width: 15.h),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, left: 35.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              height: 4.h,
                              width: 8.w,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 13.w),
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              height: 4.h,
                              width: 8.w,
                              decoration: BoxDecoration(
                                gradient: AppGradients.buttonGradient,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Tap to change or delete photo",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.only(left: 2.5.w),
                  child: Text(
                    "First Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                EditProfileTextField(
                  icon: Icons.person,
                  hintText: "Mehran",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(left: 2.5.w),
                  child: Text(
                    "Last Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                EditProfileTextField(
                  icon: Icons.person,
                  hintText: "Ali",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(left: 2.5.w),
                  child: Text(
                    "Email (not Editable)",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                EditProfileTextField(
                  icon: Icons.email,
                  hintText: "mehranbangash@gmail.com",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.blueGrey.withValues(alpha: 0.2),
                ),
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(left: 2.5.w),
                  child: Text(
                    "Phone Number",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                EditProfileTextField(
                  icon: Icons.email,
                  hintText: "03347211033",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(left: 2.5.w),
                  child: Text(
                    "Date of Birth",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                EditProfileTextField(
                  icon: Icons.calendar_today,
                  hintText: "Select Date of Birth",
                  trailing: const Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      // Do something with pickedDate
                      print("Selected Date: $pickedDate");
                    }
                  },
                ),
                SizedBox(height: 5.h),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 7.h,
                    width: 100.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // keep icon + text centered
                        children: [
                          const Icon(Icons.save, color: Colors.white, size: 22),
                          SizedBox(width: 2.w),
                          Text(
                            "Save Changes",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
