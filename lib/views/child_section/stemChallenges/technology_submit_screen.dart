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

class TechnologySubmitScreen extends ConsumerStatefulWidget {
  final StemChallengeReadModel challenge;

  const TechnologySubmitScreen({super.key, required this.challenge});

  @override
  ConsumerState<TechnologySubmitScreen> createState() =>
      _TechnologySubmitScreenState();
}

class _TechnologySubmitScreenState
    extends ConsumerState<TechnologySubmitScreen> {
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
            content: Text("Project Deployed! 💻"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(childStemChallengesViewModelProvider.notifier).resetSuccess();
        context.goNamed('technologyScreen');
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
        backgroundColor: const Color(0xFF121212),
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
                          colors: [Color(0xFF6200EA), Color(0xFF304FFE)],
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
                            "Submit Code/Build",
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
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.challenge.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.cyanAccent,
                            ),
                          ),
                          Text(
                            "${widget.challenge.points} Points",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // --- Upload ---
                    Text(
                      "Screenshots (${_proofImages.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildTechMultiUpload(),

                    SizedBox(height: 3.h),

                    // --- Time ---
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.purpleAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Time spent (e.g. 2 days)",
                          icon: const Icon(
                            Icons.code,
                            color: Colors.purpleAccent,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
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
                          backgroundColor: const Color(0xFF6200EA),
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
                                "Deploy Submission",
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

  Widget _buildTechMultiUpload() {
    if (_proofImages.isEmpty) {
      return InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purpleAccent, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_file,
                size: 40,
                color: Colors.purpleAccent,
              ),
              SizedBox(height: 1.h),
              Text(
                "Upload Files",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: Colors.purpleAccent,
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
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.purpleAccent),
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
