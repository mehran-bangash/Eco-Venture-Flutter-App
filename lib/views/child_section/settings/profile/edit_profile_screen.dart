import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_gradients.dart';
import '../../../../viewmodels/child_view_model/profile/user_provider.dart';
import '../../widgets/edit_profile_text_field.dart';
import '../../../../services/shared_preferences_helper.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? _image;
  final picker = ImagePicker();

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
  Future<void> pickImageFromGallery(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload immediately via ViewModel
      final uid = await SharedPreferencesHelper.instance.getUserId();
      if (uid != null && _image != null) {
        await ref
            .read(userProfileProvider.notifier)
            .uploadAndSaveProfileImage(uid: uid, imageFile: _image!);
      }
    } else {
      print("No image selected");
    }
  }


  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Choose Option",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      pickImageFromGallery(ImageSource.gallery);
                    },
                    child: Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo, size: 40, color: Colors.blue),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 40, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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

      final parts = username.split(" ");
      _firstnameController.text = parts.isNotEmpty ? parts.first : "";
      _lastnameController.text = parts.length > 1 ? parts.sublist(1).join(" ") : "";
      _emailController.text = userEmail;
      _phoneController.text = userPhone;
      _dobController.text = userDob;
    });
  }

  Future<void> _refreshProfile() async {
    final uid = await SharedPreferencesHelper.instance.getUserId();
    if (uid != null) {
      await ref.read(userProfileProvider.notifier).fetchUserProfile(uid);
      final state = ref.read(userProfileProvider);
      if (state.userProfile != null) {
        setState(() {
          username = state.userProfile?["displayName"] ?? "Guest";
          userEmail = state.userProfile?["email"] ?? "";
          userPhone = state.userProfile?["phone"] ?? "";
          userDob = state.userProfile?["dob"] ?? "";
          profileImg = state.userProfile?["imgUrl"] ?? "";

          final parts = username.split(" ");
          _firstnameController.text = parts.isNotEmpty ? parts.first : "";
          _lastnameController.text = parts.length > 1 ? parts.sublist(1).join(" ") : "";
          _emailController.text = userEmail;
          _phoneController.text = userPhone;
          _dobController.text = userDob;
        });

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

    final uid = await SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;

    // Upload new image if selected
    if (_image != null) {
      await ref.read(userProfileProvider.notifier)
          .uploadAndSaveProfileImage(uid: uid, imageFile: _image!);
    }

    // Update other fields
    await ref.read(userProfileProvider.notifier).updateUserProfile(
      uid: uid,
      name: fullName,
      dob: dob,
      phone: phone,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider);

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
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, top: 3.h, right: 4.w),
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
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (profileImg.isNotEmpty ? NetworkImage(profileImg) : null)
                        as ImageProvider?,
                        child: (profileImg.isEmpty && _image == null)
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
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
                _buildLabel("First Name"),
                EditProfileTextField(
                  controller: _firstnameController,
                  icon: Icons.person,
                  hintText: "First Name",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
                _buildLabel("Last Name"),
                EditProfileTextField(
                  controller: _lastnameController,
                  icon: Icons.person,
                  hintText: "Last Name",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
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
                _buildLabel("Phone Number"),
                EditProfileTextField(
                  controller: _phoneController,
                  icon: Icons.phone,
                  hintText: "Phone Number",
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.blue,
                  fillColor: Colors.white,
                ),
                _buildLabel("Date of Birth"),
                EditProfileTextField(
                  controller: _dobController,
                  icon: Icons.calendar_today,
                  hintText: "Select Date of Birth",
                  trailing: const Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                  ),
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
                SizedBox(height: 1.h),
                ElevatedButton(
                  onPressed: _testSharedPreferences,
                  child: Text("test"),
                ),
                SizedBox(height: 5.h),
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
                          if (state.isLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
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
