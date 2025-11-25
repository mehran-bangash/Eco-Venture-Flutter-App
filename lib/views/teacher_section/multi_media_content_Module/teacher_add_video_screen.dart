import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TeacherAddVideoScreen extends StatefulWidget {
  const TeacherAddVideoScreen({super.key});

  @override
  State<TeacherAddVideoScreen> createState() => _TeacherAddVideoScreenState();
}

class _TeacherAddVideoScreenState extends State<TeacherAddVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(); // NEW: Duration

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History'];

  File? _thumbnailImage; // NEW: Thumbnail

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
    if (image != null) {
      setState(() {
        _thumbnailImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Upload Video", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      _buildLabel("Duration"), // NEW UI
                      _buildTextField(_durationController, "e.g. 05:30"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // NEW: Thumbnail Upload
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
                    image: _thumbnailImage != null
                        ? DecorationImage(image: FileImage(_thumbnailImage!), fit: BoxFit.cover)
                        : null
                ),
                child: _thumbnailImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, size: 32.sp, color: Colors.orangeAccent),
                    SizedBox(height: 1.h),
                    Text("Tap to upload thumbnail", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                  ],
                )
                    : Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.edit, color: Colors.black)),
                    onPressed: _pickThumbnail,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Video Upload Box
            _buildLabel("Video File"),
            Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 40.sp, color: Colors.blue),
                  SizedBox(height: 1.h),
                  Text("Tap to upload MP4", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Mock Save
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("Upload Video", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
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
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }
}