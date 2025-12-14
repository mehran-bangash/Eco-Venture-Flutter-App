import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // Required for CustomPainter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/video_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';

class TeacherAddVideoScreen extends ConsumerStatefulWidget {
  const TeacherAddVideoScreen({super.key});

  @override
  ConsumerState<TeacherAddVideoScreen> createState() =>
      _TeacherAddVideoScreenState();
}

class _TeacherAddVideoScreenState extends ConsumerState<TeacherAddVideoScreen> {
  // --- CONTROLLERS ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  // NEW: Tags Controller
  final TextEditingController _tagsController = TextEditingController();

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem'];

  // NEW: Safety Toggle
  bool _isSensitive = false;

  File? _thumbnailImage;
  File? _videoFile;

  // --- COLORS ---
  final Color _primary = const Color(0xFFE53935); // Red for Video
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendClassNotification(
    String teacherId,
    String videoTitle,
  ) async {
    const String backendUrl = ApiConstants.notifyChildClassEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "Video",
          "title": "New Video: $videoTitle 🎬",
          "body":
              "Your teacher uploaded a new video: $videoTitle. Watch it now!",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Video Notification sent successfully");
      } else {
        print("❌ Notification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error calling notification backend: $e");
    }
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _thumbnailImage = File(image.path));
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => _videoFile = File(video.path));
  }

  Future<void> _uploadVideo() async {
    if (_titleController.text.isEmpty || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title and Video file are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Get teacher ID for notification
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

    // Process Tags
    // Process Tags
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    final newVideo = VideoModel(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      videoUrl: _videoFile!.path,
      thumbnailUrl: _thumbnailImage?.path,
      duration: _durationController.text.isNotEmpty
          ? _durationController.text
          : "00:00",
      uploadedAt: DateTime.now(),
      tags: tagsList, // NEW: Save Tags
      // Defaults
      isSensitive: _isSensitive,
      likes: 0,
      dislikes: 0,
      views: 0,
      status: 'published',
      adminId: '',
      id: '',
    );

    await ref
        .read(teacherMultimediaViewModelProvider.notifier)
        .addVideo(newVideo);
    // Send notification only if not sensitive
    if (!_isSensitive) {
      await _sendClassNotification(teacherId, newVideo.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    ref.listen(teacherMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSensitive
                  ? "Video Uploaded! (No notification - marked sensitive)"
                  : "Video Uploaded & Class Notified!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(teacherMultimediaViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
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

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Upload Video",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Video Details"),
                SizedBox(height: 2.h),
                _buildLabel("Video Title"),
                _buildTextField(_titleController, "Enter title"),
                SizedBox(height: 2.h),
                _buildLabel("Description"),
                _buildTextField(
                  _descController,
                  "Enter description",
                  maxLines: 3,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_buildLabel("Category"), _buildDropdown()],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Duration"),
                          _buildTextField(_durationController, "e.g. 05:30"),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
                _buildSectionHeader("Content Safety"),
                SizedBox(height: 1.5.h),

                // --- NEW SAFETY SECTION ---
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tags (comma separated)"),
                      _buildTextField(
                        _tagsController,
                        "e.g. animals, space, fun",
                      ),
                      SizedBox(height: 2.h),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.red,
                        title: Text(
                          "Contains Sensitive Content?",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          "Marks this as 'Scary' or 'Suspenseful' for parent filters.",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        value: _isSensitive,
                        onChanged: (val) => setState(() => _isSensitive = val),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),
                _buildSectionHeader("Media Content"),
                SizedBox(height: 2.h),
                _buildLabel("Thumbnail Image"),
                _buildThumbnailUpload(),
                SizedBox(height: 3.h),
                _buildLabel("Video File"),
                _buildVideoUpload(),

                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _uploadVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Upload Video",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ... (Helper Widgets: _buildTextField, _buildLabel, _buildSectionHeader, etc.)
  // Keeping them concise for the response, assume they are the same standard pro widgets used before.
  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
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
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15.sp),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
    ),
  );
  Widget _buildDropdown() => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCategory,
        isExpanded: true,
        items: _categories
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v!),
      ),
    ),
  );

  Widget _buildThumbnailUpload() {
    return InkWell(
      onTap: _pickThumbnail,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 18.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          image: _thumbnailImage != null
              ? DecorationImage(
                  image: FileImage(_thumbnailImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _thumbnailImage == null
            ? Center(
                child: Icon(Icons.image, color: Colors.orange, size: 30.sp),
              )
            : null,
      ),
    );
  }

  Widget _buildVideoUpload() {
    return InkWell(
      onTap: _pickVideo,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 18.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: _videoFile == null
            ? Center(
                child: Icon(Icons.video_library, color: _primary, size: 30.sp),
              )
            : Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40.sp,
                ),
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
