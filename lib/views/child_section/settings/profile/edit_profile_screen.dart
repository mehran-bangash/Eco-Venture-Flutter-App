import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_gradients.dart';
import '../../../../repositories/firestore_repo.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../widgets/edit_profile_text_field.dart';

// your helper imports


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String username = "Guest";
  String userEmail = "";
  String userPhone = "";
  String userDob = "";
  String profileImg = "";

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    final email = await SharedPreferencesHelper.instance.getUserEmail();
    final phone = await SharedPreferencesHelper.instance.getUserPhoneNumber();
    final dob = await SharedPreferencesHelper.instance.getUserDOB();
    final img = await SharedPreferencesHelper.instance.getUserImgUrl();

    setState(() {
      username = name ?? "Guest";
      userEmail = email ?? "";
      userPhone = phone ?? "";
      userDob = dob ?? "";
      profileImg = img ?? "";

      // Split name
      final parts = username.split(" ");
      _firstnameController.text = parts.isNotEmpty ? parts.first : "";
      _lastnameController.text =
      parts.length > 1 ? parts.sublist(1).join(" ") : "";

      _emailController.text = userEmail;
      _phoneController.text = userPhone;
      _dobController.text = userDob;
    });
  }
  Future<void> _refreshProfile() async {
    final uid = await SharedPreferencesHelper.instance.getUserId();
    if (uid != null) {
      final profileData = await FirestoreRepo.instance.getUserProfile(uid);
      if (profileData != null) {
        setState(() {
          username = profileData["displayName"] ?? "Guest";
          userEmail = profileData["email"] ?? "";
          userPhone = profileData["phone"] ?? "";
          userDob = profileData["dob"] ?? "";
          profileImg = profileData["imgUrl"] ?? "";

          //  Correct splitting for name fields
          final parts = username.split(" ");
          _firstnameController.text = parts.isNotEmpty ? parts.first : "";
          _lastnameController.text =
          parts.length > 1 ? parts.sublist(1).join(" ") : "";

          _emailController.text = userEmail;
          _phoneController.text = userPhone;
          _dobController.text = userDob;
        });

        // 🎉 Show banner
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile data refreshed successfully"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  Future<void> _testSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    final email = await SharedPreferencesHelper.instance.getUserEmail();
    final phone = await SharedPreferencesHelper.instance.getUserPhoneNumber();
    final dob = await SharedPreferencesHelper.instance.getUserDOB();
    final img = await SharedPreferencesHelper.instance.getUserImgUrl();

    debugPrint("---- SharedPreferences Data ----");
    debugPrint("Name: $name");
    debugPrint("Email: $email");
    debugPrint("Phone: $phone");
    debugPrint("DOB: $dob");
    debugPrint("Image: $img");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ SharedPreferences checked. See console log."),
        duration: Duration(seconds: 2),
      ),
    );
  }


  Future<void> _saveProfile() async {
    final firstName = _firstnameController.text.trim();
    final lastName = _lastnameController.text.trim();
    final fullName = "$firstName $lastName".trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();

    // Save to SharedPreferences
    await SharedPreferencesHelper.instance.saveUserName(fullName);
    await SharedPreferencesHelper.instance.saveUserPhoneNumber(phone);
    await SharedPreferencesHelper.instance.saveUserDOB(dob);

    // Update Firestore
    final uid = await SharedPreferencesHelper.instance.getUserId();
    if (uid != null) {
      await FirestoreRepo.instance.updateUserProfile(uid: uid, name: fullName, dob: dob, phone: phone, imgUrl: "");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 22.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.backgroundGradient,
                ),
                child: Column(
                  children: [
                    // top row
                    SizedBox(height: 2.h,),
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
                            child: Container(
                              height: 4.h,
                              width: 8.w,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          //refresh icon
                          GestureDetector(
                            onTap: _refreshProfile,
                            child: Container(
                              height: 4.h,
                              width: 8.w,
                              decoration: BoxDecoration(
                                color: Colors.white70.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Profile Picture
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImg.isNotEmpty
                          ? NetworkImage(profileImg)
                          : null,
                      child: profileImg.isEmpty
                          ? const Icon(Icons.person,
                          size: 50, color: Colors.white)
                          : null,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---- Body ----
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // First Name
                _buildLabel("First Name"),
                EditProfileTextField(
                  controller: _firstnameController,
                  icon: Icons.person,
                  hintText: "First Name",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),

                // Last Name
                _buildLabel("Last Name"),
                EditProfileTextField(
                  controller: _lastnameController,
                  icon: Icons.person,
                  hintText: "Last Name",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),

                // Email (Read-only)
                _buildLabel("Email (not Editable)"),
                EditProfileTextField(
                  controller: _emailController,
                  icon: Icons.email,
                  hintText: "Email",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.blueGrey.withValues(alpha: 0.2),
                  readOnly: true,
                ),

                // Phone
                _buildLabel("Phone Number"),
                EditProfileTextField(
                  controller: _phoneController,
                  icon: Icons.phone,
                  hintText: "Phone Number",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),

                // DOB
                _buildLabel("Date of Birth"),
                EditProfileTextField(
                  controller: _dobController,
                  icon: Icons.calendar_today,
                  hintText: "Select Date of Birth",
                  trailing:
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      final dob =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      setState(() => _dobController.text = dob);
                    }
                  },
                ),
                SizedBox(height: 1.h,),
                 ElevatedButton(onPressed: _testSharedPreferences, child: Text("test")),
                SizedBox(height: 5.h),

                // Save button
                GestureDetector(
                  onTap: _saveProfile,
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
                        mainAxisSize: MainAxisSize.min,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.5.w, top: 2.h, bottom: 1.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
