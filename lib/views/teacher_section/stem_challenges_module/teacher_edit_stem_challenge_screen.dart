import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // Required for PathMetrics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Import Backend Model
import '../../../../models/stem_challenge_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_stem_challenge/teacher_stem_provider.dart';

class TeacherEditStemChallengeScreen extends ConsumerStatefulWidget {
  final dynamic challengeData;

  const TeacherEditStemChallengeScreen({
    super.key,
    required this.challengeData,
  });

  @override
  ConsumerState<TeacherEditStemChallengeScreen> createState() =>
      _TeacherEditStemChallengeScreenState();
}

class _TeacherEditStemChallengeScreenState
    extends ConsumerState<TeacherEditStemChallengeScreen> {
  // --- PRO COLORS ---
  final Color _primaryBlue = const Color(0xFF1565C0);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  // --- CONTROLLERS ---
  late TextEditingController _titleController;
  late TextEditingController _pointsController;
  final TextEditingController _materialController = TextEditingController();

  // --- ADDED: Tags Controller ---
  late TextEditingController _tagsController;

  // --- STATE ---
  late StemChallengeModel _challenge;

  // Category is now fixed (Read-Only)
  late String _fixedCategory;

  late String _selectedDifficulty;
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  File? _newImageFile;
  String? _existingImageUrl;

  late List<String> _materials;
  late List<String> _steps;

  // --- ADDED: Sensitivity Flag ---
  late bool _isSensitive;

  @override
  void initState() {
    super.initState();

    // 1. Parse Data
    if (widget.challengeData is StemChallengeModel) {
      _challenge = widget.challengeData;
    } else {
      final map = Map<String, dynamic>.from(widget.challengeData);
      _challenge = StemChallengeModel(
        id: map['id'],
        title: map['title'] ?? '',
        category: map['category'] ?? 'Science',
        difficulty: map['difficulty'] ?? 'Easy',
        points: map['points'] is int
            ? map['points']
            : int.tryParse(map['points'].toString()) ?? 0,
        imageUrl: map['imageUrl'],
        materials: List<String>.from(map['materials'] ?? []),
        steps: List<String>.from(map['steps'] ?? []),
        tags: List<String>.from(map['tags'] ?? []), // ADDED: Load tags
        isSensitive: map['isSensitive'] ?? false, // ADDED: Load sensitivity
      );
    }
    // --- NOTIFICATION LOGIC ---
    _titleController = TextEditingController(text: _challenge.title);
    _pointsController = TextEditingController(
      text: _challenge.points.toString(),
    );

    // --- ADDED: Initialize tags controller ---
    _tagsController = TextEditingController(
      text: _challenge.tags?.join(', ') ?? '',
    );

    // Initialize Fixed Category
    _fixedCategory = _challenge.category;

    _selectedDifficulty = _challenge.difficulty;

    _materials = List<String>.from(_challenge.materials);
    _steps = List<String>.from(_challenge.steps);
    _existingImageUrl = _challenge.imageUrl;

    // --- ADDED: Initialize sensitivity ---
    _isSensitive = _challenge.isSensitive ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _materialController.dispose();
    _tagsController.dispose(); // ADDED: Dispose tags controller
    super.dispose();
  }

  Future<void> _sendClassNotification(
    String teacherId,
    String challengeTitle,
  ) async {
    const String backendUrl = ApiConstants.notifyChildClassEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "STEM Challenge",
          "title": "STEM Challenge Updated: $challengeTitle ✏️",
          "body":
              "Your teacher updated the STEM challenge: $challengeTitle. Check the changes!",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ STEM Challenge Update Notification sent successfully");
      } else {
        print("❌ Notification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error calling notification backend: $e");
    }
  }

  // --- UPDATE LOGIC (Simplified - No Category Change) ---
  Future<void> _updateChallenge() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }
    if (_pointsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter points")));
      return;
    }

    // --- ADDED: Process tags like in Add Screen ---
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // --- ADDED: Sensitivity control logic ---
    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    final String? finalImage = _newImageFile?.path ?? _existingImageUrl;

    String? teacherId = await SharedPreferencesHelper.instance.getUserId();
    if (teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: No Teacher ID. Re-login."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedChallenge = _challenge.copyWith(
      title: _titleController.text.trim(),
      // Category remains unchanged
      category: _fixedCategory,
      difficulty: _selectedDifficulty,
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      imageUrl: finalImage,
      materials: _materials,
      steps: _steps,
      // --- ADDED: Include tags and sensitivity ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );
    // Send notification only if not sensitive
    if (!_isSensitive) {
      await _sendClassNotification(teacherId, updatedChallenge.title);
    }

    // Call update directly (No need for oldCategory since it hasn't changed)
    await ref
        .read(teacherStemViewModelProvider.notifier)
        .updateChallenge(updatedChallenge);

    if (!_isSensitive) {
      await _sendClassNotification(teacherId, updatedChallenge.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(teacherStemViewModelProvider);

    ref.listen(teacherStemViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSensitive
                  ? "Challenge Updated! (No notification - marked sensitive)"
                  : "Challenge Updated & Class Notified!",
            ),
            backgroundColor: Colors.green,
          ),
        );

        ref.read(teacherStemViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Challenge Details"),
                SizedBox(height: 2.h),

                _buildLabel("Challenge Title"),
                _buildTextField(
                  controller: _titleController,
                  hint: "Enter challenge title",
                ),
                SizedBox(height: 2.h),

                _buildLabel("Difficulty Level"),
                _buildDifficultySelector(),
                SizedBox(height: 2.h),

                _buildLabel("Points"),
                SizedBox(
                  width: 30.w,
                  child: _buildTextField(
                    controller: _pointsController,
                    hint: "0",
                    isNumber: true,
                    isCenter: true,
                  ),
                ),
                SizedBox(height: 2.h),

                // --- CATEGORY (READ ONLY) ---
                _buildLabel("Category (Fixed)"),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Greyed out look
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: Text(
                    _fixedCategory,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // --- ADDED: Tags Field ---
                _buildLabel("Tags (comma-separated)"),
                _buildTextField(
                  controller: _tagsController,
                  hint: "e.g. chemicals, outdoor, tools, engineering",
                ),
                SizedBox(height: 2.h),

                // --- ADDED: Sensitivity Switch ---
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Mark as Sensitive Content",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  subtitle: Text(
                    "If enabled, this challenge will be blocked for younger children.",
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  value: _isSensitive,
                  onChanged: (v) => setState(() => _isSensitive = v),
                  activeThumbColor: Colors.red,
                ),

                _buildLabel("Challenge Image"),
                _buildImageUploadBox(),
                SizedBox(height: 4.h),

                _buildSectionHeader("Materials / Apparatus Required"),
                SizedBox(height: 2.h),
                _buildMaterialsWrap(),
                SizedBox(height: 1.5.h),
                _buildDashedAddButton(
                  label: "Add Material",
                  onTap: _showAddMaterialDialog,
                ),
                SizedBox(height: 4.h),

                _buildSectionHeader("Step-by-Step Instructions"),
                SizedBox(height: 2.h),
                _buildStepsList(),
                SizedBox(height: 1.5.h),
                _buildDashedAddButton(
                  label: "Add Step",
                  onTap: _showAddStepDialog,
                ),

                SizedBox(height: 5.h),

                _buildFooterButtons(viewModelState.isLoading),
                SizedBox(height: 5.h),
              ],
            ),
          ),
          if (viewModelState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            "Edit STEM Challenge",
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          // Category Badge in AppBar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _fixedCategory,
              style: GoogleFonts.poppins(
                color: _primaryBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  );

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    bool isCenter = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _difficultyLevels.map((level) {
          final isSelected = _selectedDifficulty == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = level),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    level,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (level == 'Easy'
                                ? Colors.green
                                : (level == 'Medium'
                                      ? Colors.orange
                                      : Colors.red))
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageUploadBox() {
    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_existingImageUrl!);
    }

    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 6,
      ),
      child: Container(
        height: 20.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) setState(() => _newImageFile = File(image.path));
          },
          child: imageProvider != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() {
                          _newImageFile = null;
                          _existingImageUrl = null;
                        }),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.close, size: 20, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 32.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Tap to change image",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMaterialsWrap() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _materials.map((material) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                material,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
              SizedBox(width: 1.w),
              InkWell(
                onTap: () => setState(() => _materials.remove(material)),
                child: Icon(
                  Icons.close,
                  size: 18.sp,
                  color: _primaryBlue.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderGrey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: _primaryBlue,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _steps[index],
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _steps.removeAt(index)),
                child: Icon(
                  Icons.delete_outline,
                  size: 20.sp,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashedAddButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 5,
        radius: 10,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: _primaryBlue, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 7.5.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _updateChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Update Challenge",
                    style: GoogleFonts.poppins(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 2.h),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMaterialDialog() {
    _materialController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Material",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _materialController,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: "e.g. 2 AA Batteries",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(fontSize: 15.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_materialController.text.isNotEmpty) {
                setState(() => _materials.add(_materialController.text));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            child: Text(
              "Add",
              style: TextStyle(fontSize: 15.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog() {
    TextEditingController stepCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Instruction Step",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        content: TextField(
          controller: stepCtrl,
          maxLines: 3,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: "Describe the step...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(fontSize: 15.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              if (stepCtrl.text.isNotEmpty) {
                setState(() => _steps.add(stepCtrl.text));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            child: Text(
              "Add",
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ),
        ],
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
    Path path = Path()
      ..addRRect(
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
