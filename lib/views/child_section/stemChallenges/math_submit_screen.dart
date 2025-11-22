import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../models/stem_challenge_read_model.dart';
import '../../../../models/stem_submission_model.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';

class MathSubmitScreen extends ConsumerStatefulWidget {
  final StemChallengeReadModel challenge;

  const MathSubmitScreen({super.key, required this.challenge});

  @override
  ConsumerState<MathSubmitScreen> createState() => _MathSubmitScreenState();
}

class _MathSubmitScreenState extends ConsumerState<MathSubmitScreen> {
  // CHANGE: List of files
  final List<File> _proofImages = [];
  final TextEditingController _daysController = TextEditingController();

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      setState(() {
        _proofImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }



  Future<void> _submitTask() async {
    // 1. Validation (Images & Days)
    if (_proofImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload photos!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_daysController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter time taken"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Get User Details (Name & Pic)
    String studentName =
        await SharedPreferencesHelper.instance.getUserName() ?? "Student";
    String? studentPic = await SharedPreferencesHelper.instance.getImageUrl();

    // 3. Create Model with ALL DATA (Snapshots)
    final submission = StemSubmissionModel(
      challengeId: widget.challenge.id,
      studentId: "", // Service fills this
      studentName: studentName,
      studentProfilePic: studentPic, // NEW
      challengeTitle: widget.challenge.title,
      category: widget.challenge.category, // NEW: From Challenge Model
      difficulty: widget.challenge.difficulty, // NEW: From Challenge Model
      proofImageUrls: [],
      daysTaken: int.tryParse(_daysController.text.trim()) ?? 1,
      submittedAt: DateTime.now(),
      status: 'pending',
    );

    // 4. Send to ViewModel
    await ref
        .read(childStemChallengesViewModelProvider.notifier)
        .submitChallengeWithProof(
      submission: submission,
      proofImages: _proofImages,
    );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childStemChallengesViewModelProvider);

    ref.listen(childStemChallengesViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Math Challenge Submitted! 🧮"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(childStemChallengesViewModelProvider.notifier).resetSuccess();
        context.goNamed('mathScreen');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${next.errorMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('stemChallenges');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDE7F6), // Light Deep Purple
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 3.h,
                        horizontal: 3.w,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF311B92), Color(0xFF7C4DFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Submit Solution",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // --- Info Card ---
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.challenge.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            "${widget.challenge.points} Points",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // --- Multi-Upload Section ---
                    Text(
                      "Your Work (${_proofImages.length} photos)",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildMathMultiUpload(),

                    SizedBox(height: 3.h),

                    // --- Days Input ---
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepPurple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Time Taken (e.g. 1 hour)",
                          icon: const Icon(
                            Icons.timer,
                            color: Colors.deepPurple,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // --- Submit Button ---
                    SizedBox(
                      width: 100.w,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submitTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF512DA8),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Submit",
                                style: GoogleFonts.poppins(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
              if (state.isLoading)
                const ModalBarrier(dismissible: false, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMathMultiUpload() {
    if (_proofImages.isEmpty) {
      return InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo, size: 40, color: Colors.deepPurple),
              SizedBox(height: 1.h),
              Text(
                "Upload Solution",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 20.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _proofImages.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          if (index == _proofImages.length) {
            return InkWell(
              onTap: _pickImages,
              child: Container(
                width: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.deepPurple),
                ),
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _proofImages[index],
                  width: 20.h,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () => setState(() => _proofImages.removeAt(index)),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 12,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
