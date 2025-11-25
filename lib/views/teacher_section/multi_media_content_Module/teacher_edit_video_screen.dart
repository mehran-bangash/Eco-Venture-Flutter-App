import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TeacherEditVideoScreen extends StatefulWidget {
  final dynamic videoData;
  const TeacherEditVideoScreen({super.key, required this.videoData});

  @override
  State<TeacherEditVideoScreen> createState() => _TeacherEditVideoScreenState();
}

class _TeacherEditVideoScreenState extends State<TeacherEditVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(); // NEW

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem'];

  // Video & Thumbnail State
  File? _newVideoFile;
  bool _hasExistingVideo = true;

  File? _newThumbnail; // NEW
  String? _existingThumbnailUrl; // NEW

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    _titleController.text = widget.videoData['title'] ?? '';
    _descController.text = widget.videoData['description'] ?? '';
    _durationController.text = widget.videoData['duration'] ?? ''; // Pre-fill Duration
    _existingThumbnailUrl = widget.videoData['thumbnail']; // Pre-fill Thumbnail URL

    if (widget.videoData['category'] != null && _categories.contains(widget.videoData['category'])) {
      _selectedCategory = widget.videoData['category'];
    }
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newThumbnail = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic to show thumbnail: New File -> Existing URL -> Placeholder
    ImageProvider? thumbnailProvider;
    if (_newThumbnail != null) {
      thumbnailProvider = FileImage(_newThumbnail!);
    } else if (_existingThumbnailUrl != null && _existingThumbnailUrl!.isNotEmpty) {
      thumbnailProvider = NetworkImage(_existingThumbnailUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Edit Video", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Video Title"),
            _buildTextField(_titleController, "Enter title"),
            SizedBox(height: 2.h),
            _buildLabel("Description"),
            _buildTextField(_descController, "Enter description", maxLines: 3),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Category"),
                      _buildDropdown(),
                    ],
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
            SizedBox(height: 2.h),

            // NEW: Thumbnail Edit Section
            _buildLabel("Thumbnail Image"),
            InkWell(
              onTap: _pickThumbnail,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 18.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  image: thumbnailProvider != null ? DecorationImage(image: thumbnailProvider, fit: BoxFit.cover) : null,
                ),
                child: thumbnailProvider == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_rounded, size: 32.sp, color: Colors.grey.shade400),
                    SizedBox(height: 1.h),
                    Text("Tap to add thumbnail", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                  ],
                )
                    : Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    margin: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Video Upload Box
            _buildLabel("Video Content"),
            InkWell(
              onTap: _pickVideo,
              child: Container(
                height: 20.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: _newVideoFile != null || _hasExistingVideo
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 40.sp, color: Colors.green),
                    SizedBox(height: 1.h),
                    Text(_newVideoFile != null ? "New Video Selected" : "Existing Video Loaded",
                        style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                      child: Text("Tap to Change", style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.blueGrey)),
                    )
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_rounded, size: 40.sp, color: Colors.blue),
                    SizedBox(height: 1.h),
                    Text("Tap to upload MP4", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: () {
                  // Mock Update Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Video Updated Successfully!"), backgroundColor: Colors.green)
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("Update Video", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _newVideoFile = File(video.path);
      });
    }
  }

  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }
}