import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TeacherEditStoryScreen extends StatefulWidget {
  final dynamic storyData;
  const TeacherEditStoryScreen({super.key, required this.storyData});

  @override
  State<TeacherEditStoryScreen> createState() => _TeacherEditStoryScreenState();
}

class _TeacherEditStoryScreenState extends State<TeacherEditStoryScreen> {
  final TextEditingController _titleController = TextEditingController();

  // List of pages: each page has text and image
  List<Map<String, dynamic>> _pages = [];
  File? _coverImage;
  String? _existingCoverUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.storyData['title'] ?? '';

    // Mock loading pages (in real app, parse from widget.storyData)
    // Simulating existing pages
    _pages = [
      {'text': 'Once upon a time...', 'image_url': 'mock_url_1'},
      {'text': 'The bunny jumped high.', 'image_url': 'mock_url_2'},
    ];
    _existingCoverUrl = widget.storyData['imageUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Edit Story", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
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
            // --- STORY METADATA ---
            _buildSectionHeader("Story Info"),
            SizedBox(height: 2.h),
            _buildTextField(_titleController, "Story Title"),
            SizedBox(height: 3.h),

            _buildLabel("Cover Image"),
            _buildImagePickerBox(
                file: _coverImage,
                existingUrl: _existingCoverUrl,
                onTap: () async {
                  final f = await _pickImage();
                  if(f!=null) setState(() => _coverImage = f);
                }
            ),

            SizedBox(height: 4.h),

            // --- PAGES LIST ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Pages (${_pages.length})"),
                ElevatedButton.icon(
                  onPressed: () => _showPageEditor(),
                  icon: const Icon(Icons.add),
                  label: Text("Add Page", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E2DE2), foregroundColor: Colors.white),
                )
              ],
            ),
            SizedBox(height: 2.h),

            if (_pages.isEmpty)
              Center(child: Text("No pages yet", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                separatorBuilder: (c, i) => SizedBox(height: 2.h),
                itemBuilder: (context, index) => _buildPageCard(index),
              ),

            SizedBox(height: 5.h),

            // --- UPDATE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story Updated!"), backgroundColor: Colors.green));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("Update Story", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard(int index) {
    final page = _pages[index];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Number
          CircleAvatar(backgroundColor: const Color(0xFF8E2DE2), radius: 12.sp, child: Text("${index+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          SizedBox(width: 3.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page['text'] ?? "No text", maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14.sp)),
                SizedBox(height: 1.h),
                if (page['image_file'] != null || page['image_url'] != null)
                  Container(
                    height: 8.h, width: 15.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                            image: page['image_file'] != null
                                ? FileImage(page['image_file']) as ImageProvider
                                : AssetImage("assets/images/story_placeholder.png"), // Mock asset fallback
                            fit: BoxFit.cover
                        )
                    ),
                  )
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showPageEditor(index: index)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _pages.removeAt(index))),
            ],
          )
        ],
      ),
    );
  }

  // --- PAGE EDITOR MODAL ---
  void _showPageEditor({int? index}) {
    final textCtrl = TextEditingController(text: index != null ? _pages[index]['text'] : '');
    File? pageImg = index != null ? _pages[index]['image_file'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 80.h,
              padding: EdgeInsets.all(5.w),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(
                children: [
                  Text(index == null ? "Add Page" : "Edit Page ${index + 1}", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.h),
                  TextField(
                    controller: textCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                        hintText: "Story text...",
                        filled: true, fillColor: const Color(0xFFF4F7FE),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                  ),
                  SizedBox(height: 2.h),
                  InkWell(
                    onTap: () async {
                      final f = await _pickImage();
                      if(f != null) setModalState(() => pageImg = f);
                    },
                    child: Container(
                      height: 20.h, width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          image: pageImg != null ? DecorationImage(image: FileImage(pageImg!), fit: BoxFit.cover) : null
                      ),
                      child: pageImg == null ? const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)) : null,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity, height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final newPage = {'text': textCtrl.text, 'image_file': pageImg};
                        setState(() {
                          if(index != null) _pages[index] = newPage;
                          else _pages.add(newPage);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E2DE2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text("Save Page", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.sp)),
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B2559)));
  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)));
  Widget _buildTextField(TextEditingController ctrl, String hint) => TextField(controller: ctrl, style: GoogleFonts.poppins(fontSize: 15.sp), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));

  Widget _buildImagePickerBox({File? file, String? existingUrl, required VoidCallback onTap}) {
    ImageProvider? img;
    if(file != null) img = FileImage(file);
    else if(existingUrl != null) img = AssetImage("assets/images/video_placeholder.png"); // Mock asset

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 20.h, width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), image: img != null ? DecorationImage(image: img, fit: BoxFit.cover) : null),
        child: img == null ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey)) : null,
      ),
    );
  }
}