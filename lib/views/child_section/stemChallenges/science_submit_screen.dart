import 'dart:io';
import 'dart:ui'; // Required for CustomPainter
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

class ScienceSubmitScreen extends ConsumerStatefulWidget {
  final StemChallengeReadModel challenge;

  const ScienceSubmitScreen({super.key, required this.challenge});

  @override
  ConsumerState<ScienceSubmitScreen> createState() =>
      _ScienceSubmitScreenState();
}

class _ScienceSubmitScreenState extends ConsumerState<ScienceSubmitScreen> {
  // CHANGE 3: List of Files
  final List<File> _proofImages = [];
  final TextEditingController _daysController = TextEditingController();

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  // --- MULTI-IMAGE PICKER ---
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    // Pick multiple
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      setState(() {
        // Add new selections to existing list
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
            content: Text("Challenge Submitted Successfully! 🚀"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(childStemChallengesViewModelProvider.notifier).resetSuccess();
        context.goNamed('scienceScreen');
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
        backgroundColor: const Color(0xFFF8F7FC),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 4.h),
                    _buildInfoCard(),
                    SizedBox(height: 3.h),

                    // --- Upload Section ---
                    Text(
                      "Show Your Work! (${_proofImages.length} photos)",
                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildMultiUploadSection(),

                    SizedBox(height: 3.h),

                    // --- Time Input ---
                    Text(
                      "How long did it take?",
                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "e.g. 2 days",
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    SizedBox(
                      width: 100.w,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submitTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Submit Task",
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

  Widget _buildHeader() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B4EFF), Color(0xFFFFA726)],
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          SizedBox(width: 2.w),
          Text(
            "Submit Creation",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: Colors.black,
            ),
          ),
          Text(
            "${widget.challenge.points} Points Reward",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW MULTI-UPLOAD WIDGET ---
  Widget _buildMultiUploadSection() {
    if (_proofImages.isEmpty) {
      // Empty State
      return CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFF7B4EFF),
          strokeWidth: 2,
          gap: 6,
          radius: 20,
        ),
        child: InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 100.w,
            height: 20.h,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 40,
                  color: Color(0xFF7B4EFF),
                ),
                SizedBox(height: 1.h),
                Text(
                  "Tap to select photos",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // List State
    return SizedBox(
      height: 20.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _proofImages.length + 1, // +1 for Add Button
        separatorBuilder: (_, __) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          // Add Button at the end
          if (index == _proofImages.length) {
            return InkWell(
              onTap: _pickImages,
              child: Container(
                width: 20.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              ),
            );
          }

          // Image Thumbnail
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

class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;
  final double radius;
  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.red,
    this.gap = 5.0,
    this.radius = 0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + 5),
          dashedPaint,
        );
        distance += 5 + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
