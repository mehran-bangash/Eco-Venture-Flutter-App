import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../models/stem_challenge_read_model.dart';
import '../../../../models/stem_submission_model.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';

class EngineeringSubmitScreen extends ConsumerStatefulWidget {
  final StemChallengeReadModel challenge;

  const EngineeringSubmitScreen({super.key, required this.challenge});

  @override
  ConsumerState<EngineeringSubmitScreen> createState() =>
      _EngineeringSubmitScreenState();
}

class _EngineeringSubmitScreenState
    extends ConsumerState<EngineeringSubmitScreen> {
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
    if (_proofImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload photos of your build!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_daysController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("How long did you build?"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final submission = StemSubmissionModel(
      challengeId: widget.challenge.id,
      studentId: "",
      challengeTitle: widget.challenge.title,
      proofImageUrls: [],
      daysTaken: int.tryParse(_daysController.text.trim()) ?? 1,
      submittedAt: DateTime.now(),
      status: 'pending',
    );

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
            content: Text("Project Submitted for Review! 🛠️"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(childStemChallengesViewModelProvider.notifier).resetSuccess();
        context.goNamed('engineeringScreen');
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
        backgroundColor: const Color(0xFFECEFF1), // Light Blue Grey
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
                          colors: [Color(0xFF009688), Color(0xFF26A69A)],
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
                            "Submit Prototype",
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

                    // --- Info ---
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.1),
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
                              color: Colors.teal,
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

                    // --- Upload ---
                    Text(
                      "Build Photos (${_proofImages.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildEngMultiUpload(),

                    SizedBox(height: 3.h),

                    // --- Time ---
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                      ),
                      child: TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Time spent (e.g. 3 days)",
                          icon: const Icon(Icons.build, color: Colors.teal),
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
                          backgroundColor: const Color(0xFF00796B),
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
                                "Submit Build",
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

  Widget _buildEngMultiUpload() {
    if (_proofImages.isEmpty) {
      return InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 40, color: Colors.teal),
              SizedBox(height: 1.h),
              Text(
                "Add Photos",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: Colors.teal,
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
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.teal),
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
