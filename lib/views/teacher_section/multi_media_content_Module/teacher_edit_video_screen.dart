import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/video_model.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';

class TeacherEditVideoScreen extends ConsumerStatefulWidget {
  final VideoModel videoData;
  const TeacherEditVideoScreen({super.key, required this.videoData});

  @override
  ConsumerState<TeacherEditVideoScreen> createState() =>
      _TeacherEditVideoScreenState();
}

class _TeacherEditVideoScreenState
    extends ConsumerState<TeacherEditVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController =
      TextEditingController(); // Added
  final TextEditingController _durationController = TextEditingController();

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem'];

  File? _newVideoFile;
  File? _newThumbnail;
  String? _existingThumbnailUrl;
  String? _existingVideoUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.videoData.title;
    _descController.text = widget.videoData.description; // Pre-fill
    _durationController.text = widget.videoData.duration;
    _existingThumbnailUrl = widget.videoData.thumbnailUrl;
    _existingVideoUrl = widget.videoData.videoUrl;

    if (_categories.contains(widget.videoData.category)) {
      _selectedCategory = widget.videoData.category;
    }
  }

  Future<void> _updateVideo() async {
    if (_titleController.text.isEmpty) return;

    final updatedVideo = widget.videoData.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(), // Added
      category: _selectedCategory,
      videoUrl: _newVideoFile?.path ?? _existingVideoUrl,
      thumbnailUrl: _newThumbnail?.path ?? _existingThumbnailUrl,
      duration: _durationController.text,
      uploadedAt: widget.videoData.uploadedAt, // Preserve Original Time
    );

    await ref
        .read(teacherMultimediaViewModelProvider.notifier)
        .updateVideo(updatedVideo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    ref.listen(teacherMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video Updated!"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(teacherMultimediaViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    ImageProvider? thumbnailProvider;
    if (_newThumbnail != null) {
      thumbnailProvider = FileImage(_newThumbnail!);
    } else if (_existingThumbnailUrl != null &&
        _existingThumbnailUrl!.isNotEmpty){
      thumbnailProvider = NetworkImage(_existingThumbnailUrl!);
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(
          "Edit Video",
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
              children: [
                _buildTextField(_titleController, "Title"),
                SizedBox(height: 2.h),
                _buildTextField(
                  _descController,
                  "Description",
                  maxLines: 3,
                ), // Added
                SizedBox(height: 2.h),

                // ... (Keep rest of UI Logic from previous version) ...

                // Thumbnail
                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? img = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) {
                      setState(() => _newThumbnail = File(img.path));
                    }
                  },
                  child: Container(
                    height: 18.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      image: thumbnailProvider != null
                          ? DecorationImage(
                              image: thumbnailProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: thumbnailProvider == null
                        ? Center(child: Icon(Icons.image, color: Colors.grey))
                        : null,
                  ),
                ),
                SizedBox(height: 4.h),

                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                    child: state.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Update",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
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
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
