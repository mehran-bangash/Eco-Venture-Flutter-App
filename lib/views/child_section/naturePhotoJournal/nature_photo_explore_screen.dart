import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/nature_photo_view_model/nature_photo_provider.dart'; // Ensure this points to your Helper

class NaturePhotoExplorerScreen extends ConsumerStatefulWidget {
  const NaturePhotoExplorerScreen({super.key});

  @override
  ConsumerState<NaturePhotoExplorerScreen> createState() =>
      _NaturePhotoExplorerScreenState();
}

class _NaturePhotoExplorerScreenState
    extends ConsumerState<NaturePhotoExplorerScreen>
    with SingleTickerProviderStateMixin {
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // 1. SHOW DIALOG: User chooses Camera or Gallery
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image Source",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: Text("Camera", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: Text("Gallery", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. PICK & SCAN: The Logic
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Resize width to 800px (Fast for AI)
        imageQuality: 50, // Compress quality to 50% (Fast for Upload)
      );

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });

        // A. Get Real User ID from SharedPreferences
        final userId = await SharedPreferencesHelper.instance.getUserId();

        // B. Check if User is Logged In
        if (userId != null && userId.isNotEmpty) {
          // Reset previous result
          ref.read(natureProvider.notifier).reset();

          // Start AI Scan with the REAL User ID
          ref.read(natureProvider.notifier).scanNature(selectedImage!, userId);
        } else {
          // Show error if ID is missing
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error: User not logged in. Please sign in."),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void saveEntry() {
    // Logic: The entry is already saved to Firebase by the scanNature method.
    // This button just confirms and navigates back.
    if (selectedImage == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Text(
          "Discovery saved to your journal!",
          style: GoogleFonts.poppins(fontSize: 16.sp),
        ),
      ),
    );

    // Navigate back to Journal
    Future.delayed(const Duration(milliseconds: 500), () {
      context.goNamed(
        "naturePhotoJournalScreen",
      ); // Ensure this matches your router name
    });
  }

  @override
  Widget build(BuildContext context) {
    // WATCH: Listen to the ViewModel state
    final natureState = ref.watch(natureProvider);

    // Trigger animation when data arrives
    if (natureState.entry != null && !_fadeController.isCompleted) {
      _fadeController.forward();
    }

    // Validation: Only allow "Done" if confidence is good and not unknown
    bool canSave = false;
    if (natureState.entry != null) {
      final label = natureState.entry!.prediction.label.toLowerCase();
      final confidence = natureState.entry!.prediction.confidence;
      if (label != 'unknown' && confidence > 0.4) {
        canSave = true;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed("naturePhotoJournalScreen");
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF4E7),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),

                  // 🔙 Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.goNamed("naturePhotoJournal"),
                        child: Container(
                          padding: EdgeInsets.all(1.5.h),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: Colors.brown,
                          ),
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
                    onTap: natureState.isLoading ? null : _showImageSourceDialog,
                    child: Container(
                      // 🌿 OUTER BORDER
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        // 🌿 INNER BORDER
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 1.2,
                          ),
                        ),
                        child: Container(
                          // 🌿 YOUR ORIGINAL CONTAINER
                          height: 28.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4F7EE),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: Stack(
                            children: [
                              // 📸 MAIN CONTENT
                              Center(
                                child: selectedImage == null
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 10.h,
                                      color: Colors.green.shade600,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Text(
                                      "Tap to Scan Nature",
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

                              // 🧠 AWARENESS / TIP BANNER (KEPT)
                              if (selectedImage == null)
                                Positioned(
                                  top: 1.2.h,
                                  left: 3.w,
                                  right: 3.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: Colors.green.shade700, size: 18),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Text(
                                            "Tip: Take a clear photo, move closer, and avoid blur",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),



                  // ✨ Change Image Button
                  if (selectedImage != null && !natureState.isLoading)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        // FIX: Call _showImageSourceDialog
                        onPressed: _showImageSourceDialog,
                        child: Text(
                          "Retake Photo",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 2.h),

                  // 🤖 AI Output Area
                  if (natureState.isLoading)
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: Colors.green),
                          SizedBox(height: 2.h),
                          Text(
                            "Analyzing Nature...",
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                  if (natureState.error != null)
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Error: ${natureState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // SUCCESS CARD
                  if (natureState.entry != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 100.w,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: canSave
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                natureState.entry!.fact.category.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: canSave ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            // Title
                            Text(
                              natureState.entry!.prediction.label,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            // Description
                            Text(
                              canSave
                                  ? natureState.entry!.fact.description
                                  : "I'm not sure what this is. Try getting closer or taking a clearer picture!",
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

                  SizedBox(height: 5.h),

                  // 💾 Save Button (CONDITIONAL)
                  if (canSave)
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
                            "Done & Save",
                            style: GoogleFonts.poppins(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (natureState.entry != null)
                    // Retry Button if Unknown
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 100.w,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Try Again",
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
      ),
    );
  }
}
