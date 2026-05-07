import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/stem_challenge_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../core/config/app_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_stem_challenge/teacher_stem_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherAddStemChallengeScreen extends ConsumerStatefulWidget {
  const TeacherAddStemChallengeScreen({super.key});

  @override
  ConsumerState<TeacherAddStemChallengeScreen> createState() =>
      _TeacherAddStemChallengeScreenState();
}

class _TeacherAddStemChallengeScreenState
    extends ConsumerState<TeacherAddStemChallengeScreen> {
  // --- COLORS ---
  final Color _primaryBlue = const Color(0xFF1565C0);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);
  final Color _borderGrey = const Color(0xFFE0E0E0);

  // --- CONTROLLERS & STATE ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController(
    text: "50",
  );
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedCategory = 'Science';
  final List<String> _categories = [
    'Science',
    'Technology',
    'Engineering',
    'Mathematics',
  ];
  String _selectedDifficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  String? _selectedAgeGroup;

  // Media State
  File? _challengeImage; // Cover Image
  final List<File> _extraImages = [];
  final List<File> _selectedVideos = [];

  List<String> _materials = ['Baking Soda', 'Vinegar'];
  List<String> _steps = [
    "Mix baking soda and vinegar",
    "Observe the chemical reaction",
  ];

  bool _isSensitive = false;
  bool _shouldPopAfterSave = false;

  // --- MEDIA PICKING ---
  Future<void> _pickExtraImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _extraImages.addAll(images.map((e) => File(e.path))));
    }
  }

  Future<void> _pickVideo() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _selectedVideos.add(File(video.path)));
    }
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendClassNotification(
    String teacherId,
    String title,
    String ageGroup,
  ) async {
    try {
      await http.post(
        Uri.parse(ApiConstants.notifyChildClassEndPoints),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "STEM Challenge",
          "title": "New STEM Challenge: $title 🔬",
          "body": "A new STEM challenge for Group $ageGroup is ready!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("Notification error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(teacherStemViewModelProvider);

    ref.listen(teacherStemViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: TextStyle(fontSize: 15.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSensitive
                  ? "Challenge Saved!"
                  : "Challenge Saved & Class Notified!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(teacherStemViewModelProvider.notifier).resetSuccess();
        if (_shouldPopAfterSave)
          Navigator.pop(context);
        else
          _clearForm();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CARD 1: Basics
                      _buildSectionCard(
                        title: "Challenge Basics",
                        children: [
                          _buildLabel("Challenge Title"),
                          _buildTextField(
                            controller: _titleController,
                            hint: "e.g. Bridge Building",
                          ),
                          SizedBox(height: 2.5.h),
                          _buildLabel("Target Class / Age Group"),
                          _buildAgeDropdown(),
                          SizedBox(height: 2.5.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Category"),
                                    _buildDropdown(
                                      _categories,
                                      _selectedCategory,
                                      (v) => setState(
                                        () => _selectedCategory = v!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Difficulty"),
                                    _buildDropdown(
                                      _difficultyLevels,
                                      _selectedDifficulty,
                                      (v) => setState(
                                        () => _selectedDifficulty = v!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.5.h),
                          _buildLabel("Points Reward"),
                          _buildTextField(
                            controller: _pointsController,
                            hint: "50",
                            isNumber: true,
                          ),
                          SizedBox(height: 2.5.h),
                          _buildLabel("Tags (comma-separated)"),
                          _buildTextField(
                            controller: _tagsController,
                            hint: "e.g. chemicals, outdoor",
                          ),
                          SizedBox(height: 2.5.h),
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
                            value: _isSensitive,
                            onChanged: (v) => setState(() => _isSensitive = v),
                            activeThumbColor: Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // CARD 2: Visuals & Media
                      _buildSectionCard(
                        title: "Media (Photos & Videos)",
                        children: [
                          _buildLabel("Cover Image"),
                          _buildImageUpload(),
                          SizedBox(height: 3.h),
                          _buildLabel("Additional Images"),
                          _buildMediaPickerButton(
                            "Add Photos",
                            Icons.add_a_photo,
                            _pickExtraImages,
                          ),
                          if (_extraImages.isNotEmpty) _buildImagePreviewGrid(),
                          SizedBox(height: 3.h),
                          _buildLabel("Videos"),
                          _buildMediaPickerButton(
                            "Add Videos",
                            Icons.video_call,
                            _pickVideo,
                          ),
                          if (_selectedVideos.isNotEmpty)
                            _buildVideoPreviewList(),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // CARD 3: Materials
                      _buildSectionCard(
                        title: "Materials",
                        trailing: _buildAddButton(
                          "Add Item",
                          () => _showAddItemDialog(
                            "Material",
                            (val) => setState(() => _materials.add(val)),
                          ),
                        ),
                        children: [
                          Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: _materials
                                .map(
                                  (m) => _buildChip(
                                    m,
                                    () => setState(() => _materials.remove(m)),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // CARD 4: Instructions
                      _buildSectionCard(
                        title: "Instructions",
                        trailing: _buildAddButton(
                          "Add Step",
                          () => _showAddItemDialog(
                            "Step Description",
                            (val) => setState(() => _steps.add(val)),
                          ),
                        ),
                        children: [
                          ..._steps.asMap().entries.map(
                            (e) => _buildStepItem(e.key + 1, e.value),
                          ),
                        ],
                      ),

                      SizedBox(height: 5.h),
                      _buildFooterButtons(viewModelState.isLoading),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (viewModelState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- SAVE LOGIC ---
  Future<void> _saveChallenge() async {
    if (_titleController.text.trim().isEmpty || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Class Group are required")),
      );
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newChallenge = StemChallengeModel(
      adminId: teacherId,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      imageUrl: _challengeImage?.path,
      imageUrls: _extraImages.map((e) => e.path).toList(),
      videoUrls: _selectedVideos.map((e) => e.path).toList(),
      materials: _materials,
      steps: _steps,
      tags: tagsList,
      isSensitive: _isSensitive,
      ageGroup: _selectedAgeGroup!,
    );

    await ref
        .read(teacherStemViewModelProvider.notifier)
        .addChallenge(newChallenge);

    if (!_isSensitive && teacherId != null) {
      await _sendClassNotification(
        teacherId,
        newChallenge.title,
        _selectedAgeGroup!,
      );
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _pointsController.text = "50";
      _tagsController.clear();
      _challengeImage = null;
      _extraImages.clear();
      _selectedVideos.clear();
      _materials = [];
      _steps = [];
      _selectedAgeGroup = null;
    });
  }

  // --- RESTORED UI HELPERS ---

  Widget _buildSectionCard({
    required String title,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(title),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 2.5.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMediaPickerButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _primaryBlue),
            SizedBox(width: 2.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: _primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewGrid() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _extraImages
            .map(
              (file) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file,
                      width: 22.w,
                      height: 22.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _extraImages.remove(file)),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildVideoPreviewList() {
    return Column(
      children: _selectedVideos
          .map(
            (file) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.movie, color: Colors.blue),
              title: Text(
                file.path.split('/').last,
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _selectedVideos.remove(file)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 6.h, bottom: 3.h, left: 5.w, right: 5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            "New Challenge",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 15.sp,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          hint: const Text("Select Class Group"),
          items: AppConstants.teacherClassRanges
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    "Group $r",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedAgeGroup = v),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return CustomPaint(
      painter: DashedRectPainter(
        color: _primaryBlue,
        strokeWidth: 2,
        gap: 6,
        radius: 16,
      ),
      child: InkWell(
        onTap: () async {
          final img = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );
          if (img != null) setState(() => _challengeImage = File(img.path));
        },
        child: Container(
          height: 20.h,
          width: double.infinity,
          alignment: Alignment.center,
          child: _challengeImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _challengeImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 30.sp, color: _primaryBlue),
                    Text(
                      "Upload Cover Photo",
                      style: GoogleFonts.poppins(color: _primaryBlue),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: _primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white,
      deleteIcon: Icon(Icons.close, size: 18.sp, color: Colors.redAccent),
      onDeleted: onDelete,
      side: BorderSide(color: _primaryBlue.withOpacity(0.2)),
    );
  }

  Widget _buildStepItem(int index, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.sp,
            backgroundColor: _primaryBlue,
            child: Text(
              "$index",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => setState(() => _steps.remove(text)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons(bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    setState(() => _shouldPopAfterSave = true);
                    _saveChallenge();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Publish Challenge",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () {
                    setState(() => _shouldPopAfterSave = false);
                    _saveChallenge();
                  },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Save & Add Another",
              style: TextStyle(color: _primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(String title, Function(String) onAdd) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add $title"),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) onAdd(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 17.sp,
      fontWeight: FontWeight.w800,
      color: _textDark,
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
  Widget _buildAddButton(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(Icons.add, color: _primaryBlue, size: 16.sp),
        Text(
          label,
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
  Widget _buildDropdown(
    List<String> items,
    String selected,
    Function(String?) onChanged,
  ) => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(14),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
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
    for (PathMetric pathMetric in path.computeMetrics()) {
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
