import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NaturePhotoExplorerScreen extends StatefulWidget {
  const NaturePhotoExplorerScreen({super.key});

  @override
  State<NaturePhotoExplorerScreen> createState() =>
      _NaturePhotoExplorerScreenState();
}

class _NaturePhotoExplorerScreenState extends State<NaturePhotoExplorerScreen>
    with SingleTickerProviderStateMixin {
  File? selectedImage;
  String? aiTitle;
  String? aiDescription;

  final ImagePicker _picker = ImagePicker();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        aiTitle = null;
        aiDescription = null;
      });

      // Simulated AI response — replace with your API
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          aiTitle = "Butterfly";
          aiDescription =
          "Butterflies are colorful insects with delicate wings that help pollinate flowers.";
        });
        _fadeController.forward();
      });
    }
  }

  void saveEntry() {
    if (selectedImage == null || aiTitle == null) return;

    // TODO: Add Firebase save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Text(
          "Photo entry saved!",
          style: GoogleFonts.poppins(fontSize: 16.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed("learnWithAiScreen");
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF4E7),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1.h),

                // 🔙 Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(1.5.h),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 20.sp, color: Colors.brown),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Nature Photo Explorer",
                      style: GoogleFonts.poppins(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // 📸 Upload Section
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 28.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F7EE),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.green.shade300, width: 2),
                    ),
                    child: selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded,
                            size: 10.h, color: Colors.green.shade600),
                        SizedBox(height: 1.5.h),
                        Text(
                          "Tap to Upload a Picture",
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.file(
                        selectedImage!,
                        width: 100.w,
                        height: 28.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // ✨ Change Image Button
                if (selectedImage != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: pickImage,
                      child: Text(
                        "Change Image",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 2.h),

                // 🤖 AI Output
                if (aiTitle != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 100.w,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aiTitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            aiDescription!,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // 💾 Save Button
                if (aiTitle != null)
                  GestureDetector(
                    onTap: saveEntry,
                    child: Container(
                      width: 100.w,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade300,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Save This Photo Entry",
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
