import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../widgets/profile_info_tile.dart';
import '../../widgets/settings_tile.dart';

class ChildProfile extends StatefulWidget {
  const ChildProfile({super.key});

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  String username = "Guest";
  String userEmail= "";
  String userDOB="unknown";
  String userPhone="";

 @override
  void initState() {
    // TODO: implement initState
   _loadSharedPreferences();
    super.initState();
  }

  Future<void> _loadSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    final email= await SharedPreferencesHelper.instance.getUserEmail();
    final dob=await SharedPreferencesHelper.instance.getUserDOB();
    final phone=await SharedPreferencesHelper.instance.getUserPhoneNumber();

    setState(() {
      username = name ?? "Guest";
      userEmail= email ?? "";
      userDOB=dob ?? "unknown";
      userPhone=phone ?? "";

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 28.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.backgroundGradient,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(left: 4.w,top: 2.5.h,right: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.goNamed('bottomNavChild');
                                },
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    height: 4.h,
                                    width: 8.w,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.all(Radius.circular(10))
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
                                      color: Colors.white70.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
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
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(10.h),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.h),
                              child: SizedBox(
                                height: 15.h,
                                width: 15.h,
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.blueAccent,
                                    size: 20.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 0.5.h),
                        Text(
                          username,
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          userEmail,
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
              children: [
                SizedBox(height: 2.h),
                _buildPersonalInfoCard(),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () {
                    context.goNamed('editProfile');
                  },
                  child: SettingsTile(
                    title: "Edit Profile",
                    subtitle: "Update your personal \ninformation",
                    circleColor: Colors.blue,
                    leadingIcon: Icons.edit,
                    trailing: Container(
                      height: 5.h,
                      width: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SettingsTile(
                  title: "Delete Account",
                  titleColor: Colors.redAccent,
                  subtitle: "Permanently remove your \naccount",
                  circleColor: Colors.redAccent.withValues(alpha: 0.4),
                  leadingIcon: Icons.delete,
                  trailing: Container(
                    height: 5.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Container(
          height: 38.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 4.h, left: 3.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 6.h,
                        width: 14.w,
                        decoration: BoxDecoration(
                          gradient: AppGradients.buttonGradient,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 8.w,
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 2.5.w),
                            child: Text(
                              'Personal information',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.5.h),
                  ProfileInfoTile(
                    icon: Icons.email,
                    iconColor: Colors.blue,
                    title: "Email Address",
                    secondTitle: userEmail,
                  ),
                  SizedBox(height: 2.5.h),
                  ProfileInfoTile(
                    icon: Icons.calendar_today,
                    iconColor: Colors.purpleAccent,
                    rectangleColor: Colors.purpleAccent.withValues(alpha: 0.1),
                    title: "Date of Birth",
                    secondTitle: userDOB,
                  ),
                  SizedBox(height: 2.5.h),
                  ProfileInfoTile(
                    icon: Icons.call,
                    iconColor: Colors.green,
                    title: "Phone Number",
                    secondTitle:userPhone,
                    rectangleColor: Colors.green.shade50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
