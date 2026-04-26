import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
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
  ConsumerState<TechnologySubmitScreen> createState() => _TechnologySubmitScreenState();
}

class _TechnologySubmitScreenState extends ConsumerState<TechnologySubmitScreen> with TickerProviderStateMixin {
  final List<File> _proofImages = [];
  final TextEditingController _daysController = TextEditingController();
  late final AnimationController _masterController;

  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _themeColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _daysController.dispose();
    _masterController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => _proofImages.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _submitTask() async {
    if (_proofImages.isEmpty) {
      _showSnackBar("Please upload photos!", Colors.orange);
      return;
    }
    if (_daysController.text.trim().isEmpty) {
      _showSnackBar("Enter time taken", Colors.orange);
      return;
    }

    String studentName = SharedPreferencesHelper.instance.getUserName() ?? "Student";
    String? studentPic = SharedPreferencesHelper.instance.getUserImgUrl();

    final submission = StemSubmissionModel(
      challengeId: widget.challenge.id,
      studentId: "",
      studentName: studentName,
      studentProfilePic: studentPic,
      challengeTitle: widget.challenge.title,
      category: widget.challenge.category,
      difficulty: widget.challenge.difficulty,
      proofImageUrls: [],
      daysTaken: int.tryParse(_daysController.text.trim()) ?? 1,
      submittedAt: DateTime.now(),
      status: 'pending',
    );

    await ref.read(childStemChallengesViewModelProvider.notifier).submitChallengeWithProof(
          submission: submission,
          proofImages: _proofImages,
        );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childStemChallengesViewModelProvider);

    ref.listen(childStemChallengesViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        _showSnackBar("Challenge Submitted Successfully! 🚀", Colors.green);
        ref.read(childStemChallengesViewModelProvider.notifier).resetSuccess();
        context.goNamed('technologyScreen');
      }
      if (next.errorMessage != null) {
        _showSnackBar("Error: ${next.errorMessage}", Colors.red);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('stemChallenges');
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _masterController,
          builder: (context, _) {
            final t = _masterController.value;
            return Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF1F5F9), Colors.white, Color(0xFFF8FAFC)],
                    ),
                  ),
                ),
                Positioned(top: -5.h, right: -15.w, child: _buildGlowBlob(Colors.indigo.withOpacity(0.12), 70.w, t, 0)),
                Positioned(bottom: 5.h, left: -20.w, child: _buildGlowBlob(Colors.pink.withOpacity(0.08), 80.w, t, 2)),

                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar("Submit Creation"),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoCard(),
                              SizedBox(height: 4.h),
                              _buildSectionTitle("Show Your Work! (${_proofImages.length} photos)"),
                              _buildMultiUploadSection(),
                              SizedBox(height: 4.h),
                              _buildSectionTitle("How long did it take?"),
                              _buildTimeInput(),
                              SizedBox(height: 5.h),
                              _buildSubmitButton(state.isLoading),
                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isLoading) const ModalBarrier(dismissible: false, color: Colors.black12),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(30 * math.sin(t * 2 * math.pi + phase), 30 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
      ),
    );
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.goNamed('stemChallenges'),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark, size: 17.sp),
            ),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.poppins(color: _primaryDark, fontSize: 18.sp, fontWeight: FontWeight.w900)),
          const Spacer(),
          SizedBox(width: 12.w),
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _themeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: _themeColor.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15), spreadRadius: -5),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.challenge.title, style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w800, color: _primaryDark)),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade600, size: 16.sp),
              SizedBox(width: 2.w),
              Text("${widget.challenge.points} Points Reward", style: GoogleFonts.poppins(fontSize: 13.sp, color: _themeColor, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, left: 1.w),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _primaryDark)),
    );
  }

  Widget _buildMultiUploadSection() {
    if (_proofImages.isEmpty) {
      return CustomPaint(
        painter: DashedRectPainter(color: _themeColor, strokeWidth: 2, gap: 6, radius: 25),
        child: InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 100.w,
            height: 20.h,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded, size: 35.sp, color: _themeColor),
                SizedBox(height: 1.5.h),
                Text("Tap to select photos", style: GoogleFonts.poppins(fontSize: 14.sp, color: _subText, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 18.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _proofImages.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 4.w),
        itemBuilder: (context, index) {
          if (index == _proofImages.length) {
            return InkWell(
              onTap: _pickImages,
              child: Container(
                width: 15.h,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
                child: Center(child: Icon(Icons.add_rounded, size: 28.sp, color: _subText)),
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_proofImages[index], width: 15.h, height: 18.h, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _proofImages.removeAt(index)),
                  child: CircleAvatar(backgroundColor: Colors.red.shade400, radius: 12, child: const Icon(Icons.close, size: 16, color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
      child: TextField(
        controller: _daysController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "e.g. 2 days",
          hintStyle: GoogleFonts.poppins(color: _subText),
          icon: Icon(Icons.calendar_today_rounded, color: _themeColor, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _submitTask,
      child: Container(
        width: 100.w,
        height: 7.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_themeColor, _themeColor.withBlue(200)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text("Submit Task", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;
  final double radius;
  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.red, this.gap = 5.0, this.radius = 0});
  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius)));
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 5), dashedPaint);
        distance += 5 + gap;
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
