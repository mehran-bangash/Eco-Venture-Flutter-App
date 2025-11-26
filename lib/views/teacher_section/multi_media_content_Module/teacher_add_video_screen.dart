import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/video_model.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';

class TeacherAddVideoScreen extends ConsumerStatefulWidget {
  const TeacherAddVideoScreen({super.key});

  @override
  ConsumerState<TeacherAddVideoScreen> createState() => _TeacherAddVideoScreenState();
}

class _TeacherAddVideoScreenState extends ConsumerState<TeacherAddVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController(); // Added Description
  final TextEditingController _durationController = TextEditingController();

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem'];

  File? _thumbnailImage;
  File? _videoFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
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
    if(_titleController.text.isEmpty || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Video file are required"), backgroundColor: Colors.red));
      return;
    }

    final newVideo = VideoModel(
      title: _titleController.text.trim(),
      description: _descController.text.trim(), // Added
      category: _selectedCategory,
      videoUrl: _videoFile!.path,
      thumbnailUrl: _thumbnailImage?.path,
      duration: _durationController.text.isNotEmpty ? _durationController.text : "00:00",
      uploadedAt: DateTime.now(), // Added
      likes: 0, dislikes: 0, views: 0, status: 'published', adminId: '', id: '',
    );

    await ref.read(teacherMultimediaViewModelProvider.notifier).addVideo(newVideo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    ref.listen(teacherMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video Uploaded Successfully!"), backgroundColor: Colors.green));
        ref.read(teacherMultimediaViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Upload Video", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Video Title"),
                _buildTextField(_titleController, "Enter title"),
                SizedBox(height: 2.h),

                _buildLabel("Description"), // Added UI
                _buildTextField(_descController, "Enter description", maxLines: 3),
                SizedBox(height: 2.h),

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Category"), _buildDropdown()])),
                  SizedBox(width: 4.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Duration"), _buildTextField(_durationController, "e.g. 05:30")])),
                ]),
                SizedBox(height: 2.h),

                _buildLabel("Thumbnail Image"),
                InkWell(
                  onTap: _pickThumbnail,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 18.h, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300), image: _thumbnailImage != null ? DecorationImage(image: FileImage(_thumbnailImage!), fit: BoxFit.cover) : null),
                    child: _thumbnailImage == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_rounded, size: 32.sp, color: Colors.orangeAccent), SizedBox(height: 1.h), Text("Tap to upload thumbnail", style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey))]) : null,
                  ),
                ),
                SizedBox(height: 4.h),

                _buildLabel("Video File"),
                InkWell(
                  onTap: _pickVideo,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 20.h, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                    child: _videoFile == null
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_rounded, size: 40.sp, color: Colors.blue), SizedBox(height: 1.h), Text("Tap to upload MP4", style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey))])
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 40.sp, color: Colors.green), SizedBox(height: 1.h), Text("Video Selected", style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.green, fontWeight: FontWeight.bold))]),
                  ),
                ),

                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity, height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _uploadVideo,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: state.isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Upload Video", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          if (state.isLoading) Container(color: Colors.black26, child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)));
  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(controller: ctrl, maxLines: maxLines, style: GoogleFonts.poppins(fontSize: 15.sp), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  Widget _buildDropdown() => Container(padding: EdgeInsets.symmetric(horizontal: 4.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedCategory, isExpanded: true, items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 15.sp)))).toList(), onChanged: (v) => setState(() => _selectedCategory = v!))));
}