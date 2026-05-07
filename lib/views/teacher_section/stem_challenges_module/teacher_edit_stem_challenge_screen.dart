import 'package:eco_venture/core/config/app_constants.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
  final Color _primaryBlue = const Color(0xFF1565C0);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  late TextEditingController _titleController;
  late TextEditingController _pointsController;
  final TextEditingController _materialController = TextEditingController();
  late TextEditingController _tagsController;

  late StemChallengeModel _challenge;
  late String _fixedCategory;
  late String _selectedDifficulty;
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  String? _selectedAgeGroup;

  // Media State
  File? _newCoverImage;
  String? _existingCoverUrl;
  List<String> _existingImageUrls = [];
  List<File> _newExtraImages = [];
  List<String> _existingVideoUrls = [];
  List<File> _newVideos = [];

  late List<String> _materials;
  late List<String> _steps;
  late bool _isSensitive;

  @override
  void initState() {
    super.initState();

    if (widget.challengeData is StemChallengeModel) {
      _challenge = widget.challengeData;
    } else {
      final map = Map<String, dynamic>.from(widget.challengeData);
      _challenge = StemChallengeModel.fromMap(map['id'] ?? '', map);
    }

    _titleController = TextEditingController(text: _challenge.title);
    _pointsController = TextEditingController(
      text: _challenge.points.toString(),
    );
    _tagsController = TextEditingController(text: _challenge.tags.join(', '));

    _fixedCategory = _challenge.category;
    _selectedDifficulty = _challenge.difficulty;
    _materials = List<String>.from(_challenge.materials);
    _steps = List<String>.from(_challenge.steps);

    // Initialize Media
    _existingCoverUrl = _challenge.imageUrl;
    _existingImageUrls = List<String>.from(_challenge.imageUrls);
    _existingVideoUrls = List<String>.from(_challenge.videoUrls);

    _isSensitive = _challenge.isSensitive;
    _selectedAgeGroup = _challenge.ageGroup;
  }

  Future<void> _pickExtraImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _newExtraImages.addAll(images.map((e) => File(e.path))));
    }
  }

  Future<void> _pickVideo() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _newVideos.add(File(video.path)));
    }
  }

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
          "title": "STEM Challenge Updated: $title ✏️",
          "body": "The STEM challenge for Group $ageGroup has been updated!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  Future<void> _updateChallenge() async {
    if (_titleController.text.trim().isEmpty || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Age Group required")),
      );
      return;
    }

    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    String? teacherId = SharedPreferencesHelper.instance.getUserId();

    List<String> finalImages = [
      ..._existingImageUrls,
      ..._newExtraImages.map((e) => e.path),
    ];
    List<String> finalVideos = [
      ..._existingVideoUrls,
      ..._newVideos.map((e) => e.path),
    ];

    final updatedChallenge = _challenge.copyWith(
      title: _titleController.text.trim(),
      category: _fixedCategory,
      difficulty: _selectedDifficulty,
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      imageUrl: _newCoverImage?.path ?? _existingCoverUrl,
      imageUrls: finalImages,
      videoUrls: finalVideos,
      materials: _materials,
      steps: _steps,
      tags: tagsList,
      isSensitive: _isSensitive,
      ageGroup: _selectedAgeGroup!,
    );

    await ref
        .read(teacherStemViewModelProvider.notifier)
        .updateChallenge(updatedChallenge);

    if (!_isSensitive && teacherId != null) {
      _sendClassNotification(
        teacherId,
        updatedChallenge.title,
        _selectedAgeGroup!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(teacherStemViewModelProvider);

    ref.listen(teacherStemViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Challenge Updated!"),
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
                  hint: "Enter title",
                ),
                SizedBox(height: 2.h),
                _buildLabel("Target Age Group"),
                _buildAgeDropdown(),
                SizedBox(height: 2.h),
                _buildLabel("Difficulty Level"),
                _buildDifficultySelector(),
                SizedBox(height: 2.h),
                _buildLabel("Points Reward"),
                _buildTextField(
                  controller: _pointsController,
                  hint: "50",
                  isNumber: true,
                ),
                SizedBox(height: 3.h),

                _buildSectionHeader("Media (Photos & Videos)"),
                SizedBox(height: 2.h),
                _buildLabel("Cover Image"),
                _buildCoverUpload(),
                SizedBox(height: 3.h),
                _buildLabel("Additional Photos"),
                _buildMediaPicker(
                  "Add Photos",
                  Icons.add_photo_alternate,
                  _pickExtraImages,
                ),
                _buildImagesPreview(),
                SizedBox(height: 3.h),
                _buildLabel("Videos"),
                _buildMediaPicker("Add Videos", Icons.video_call, _pickVideo),
                _buildVideosPreview(),
                SizedBox(height: 3.h),

                _buildSectionHeader("Materials"),
                _buildMaterialsWrap(),
                _buildDashedAddButton(
                  label: "Add Material",
                  onTap: _showAddMaterialDialog,
                ),
                SizedBox(height: 3.h),

                _buildSectionHeader("Instructions"),
                _buildStepsList(),
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
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildMediaPicker(String label, IconData icon, VoidCallback onTap) {
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

  Widget _buildImagesPreview() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Wrap(
        spacing: 2.w,
        children: [
          ..._existingImageUrls.map(
            (url) => _buildThumb(
              url: url,
              onRemove: () => setState(() => _existingImageUrls.remove(url)),
            ),
          ),
          ..._newExtraImages.map(
            (file) => _buildThumb(
              file: file,
              onRemove: () => setState(() => _newExtraImages.remove(file)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildVideosPreview() {
    return Column(
      children: [
        // FIXED: Show existing videos so user knows what's on the server
        ..._existingVideoUrls.map((url) => ListTile(
            dense: true,
            leading: const Icon(Icons.video_library, color: Colors.orange),
            title: Text(
                "Current Video: ${url.split('/').last.split('?').first}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp)
            ),
            trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _existingVideoUrls.remove(url))
            )
        )),
        // Show newly picked local videos
        ..._newVideos.map((file) => ListTile(
            dense: true,
            leading: const Icon(Icons.movie, color: Colors.blue),
            title: Text("New Video: ${file.path.split('/').last}", style: TextStyle(fontSize: 14.sp)),
            trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _newVideos.remove(file))
            )
        )),
      ],
    );
  }



  Widget _buildThumb({
    String? url,
    File? file,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 1.h),
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: file != null
                  ? FileImage(file)
                  : NetworkImage(url!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverUpload() {
    ImageProvider? provider;
    if (_newCoverImage != null) {
      provider = FileImage(_newCoverImage!);
    } else if (_existingCoverUrl != null)
      provider = NetworkImage(_existingCoverUrl!);

    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 6,
        radius: 12,
      ),
      child: InkWell(
        onTap: () async {
          final img = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );
          if (img != null) setState(() => _newCoverImage = File(img.path));
        },
        child: Container(
          height: 20.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: provider != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(image: provider, fit: BoxFit.cover),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo),
                      Text("Change Cover", style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    // FIXED: Ensure exactly one item matches the value to prevent the Flutter assertion error.
    final List<String> dropdownItems = List<String>.from(
      AppConstants.teacherClassRanges,
    );
    if (_selectedAgeGroup != null &&
        !dropdownItems.contains(_selectedAgeGroup)) {
      dropdownItems.add(_selectedAgeGroup!);
    }
    // Remove potential duplicates to satisfy the "exactly one" requirement
    final uniqueItems = dropdownItems.toSet().toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          items: uniqueItems
              .map((r) => DropdownMenuItem(value: r, child: Text("Group $r")))
              .toList(),
          onChanged: (val) => setState(() => _selectedAgeGroup = val!),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: _difficultyLevels.map((level) {
        final isSelected = _selectedDifficulty == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = level),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBlue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  level,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Edit STEM Challenge",
        style: GoogleFonts.poppins(
          color: _textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildMaterialsWrap() {
    return Wrap(
      spacing: 2.w,
      children: _materials
          .map(
            (m) => Chip(
              label: Text(m),
              onDeleted: () => setState(() => _materials.remove(m)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStepsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text("${i + 1}")),
        title: Text(_steps[i]),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _steps.removeAt(i)),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _updateChallenge,
        style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
        child: const Text(
          "Update Challenge",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String t) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: Text(
      t,
      style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildLabel(String t) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
  );
  Widget _buildDashedAddButton({
    required String label,
    required VoidCallback onTap,
  }) => OutlinedButton(onPressed: onTap, child: Text(label));

  void _showAddMaterialDialog() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Material"),
        content: TextField(controller: c),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() => _materials.add(c.text));
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Step"),
        content: TextField(controller: c),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() => _steps.add(c.text));
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
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
