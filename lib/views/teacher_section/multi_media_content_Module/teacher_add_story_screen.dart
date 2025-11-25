import 'dart:io';
import 'dart:ui'; // Required for CustomPainter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TeacherAddStoryScreen extends StatefulWidget {
  const TeacherAddStoryScreen({super.key});

  @override
  State<TeacherAddStoryScreen> createState() => _TeacherAddStoryScreenState();
}

class _TeacherAddStoryScreenState extends State<TeacherAddStoryScreen> {
  // --- PRO COLORS ---
  final Color _primaryPurple = const Color(0xFF8E2DE2); // Story Theme Purple
  final Color _accentPurple = const Color(0xFF4A00E0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);
  final Color _dashedColor = const Color(0xFFBDBDBD);

  final TextEditingController _titleController = TextEditingController();
  File? _coverImage;

  // List of Pages: Each page has 'text' (String) and 'image' (File?)
  final List<Map<String, dynamic>> _pages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- MOCK SAVE LOGIC ---
  Future<void> _saveStory() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a story title"), backgroundColor: Colors.red));
      return;
    }
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one page"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Mock Delay

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story Published Successfully!"), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _coverImage = File(img.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Create New Story", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 17.sp)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION 1: STORY INFO ---
                _buildSectionHeader("Story Details"),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Story Title"),
                      _buildTextField(controller: _titleController, hint: "e.g. The Brave Little Rabbit"),
                      SizedBox(height: 3.h),
                      _buildLabel("Cover Illustration"),
                      _buildCoverUpload(),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // --- SECTION 2: PAGES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Pages (${_pages.length})"),
                    InkWell(
                      onTap: () => _showPageEditor(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                        decoration: BoxDecoration(color: _primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [Icon(Icons.add, size: 16.sp, color: _primaryPurple), SizedBox(width: 1.w), Text("Add Page", style: GoogleFonts.poppins(fontSize: 12.sp, color: _primaryPurple, fontWeight: FontWeight.w600))]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (_pages.isEmpty)
                  Center(child: Padding(padding: EdgeInsets.all(4.h), child: Text("Start writing your story...", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp))))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pages.length,
                    separatorBuilder: (c, i) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) => _buildPageCard(index),
                  ),

                SizedBox(height: 5.h),

                // --- SAVE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveStory,
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Publish Story", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark));
  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])));

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryPurple, width: 1.5)),
      ),
    );
  }

  Widget _buildCoverUpload() {
    return CustomPaint(
      painter: DashedRectPainter(color: _dashedColor, strokeWidth: 1.5, gap: 6, radius: 12),
      child: InkWell(
        onTap: _pickCoverImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 20.h, width: double.infinity,
          decoration: _coverImage == null ? BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)) : null,
          child: _coverImage != null
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_coverImage!, fit: BoxFit.cover, width: double.infinity))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_rounded, size: 32.sp, color: Colors.grey), SizedBox(height: 1.h), Text("Upload Cover Art", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey))]),
        ),
      ),
    );
  }

  Widget _buildPageCard(int index) {
    final page = _pages[index];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Number
          CircleAvatar(radius: 14.sp, backgroundColor: _primaryPurple.withOpacity(0.1), child: Text("${index + 1}", style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 14.sp))),
          SizedBox(width: 4.w),

          // Content Preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page['text'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14.sp, color: _textDark)),
                if (page['image'] != null) ...[
                  SizedBox(height: 1.h),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(page['image'], height: 8.h, width: 15.w, fit: BoxFit.cover)),
                ]
              ],
            ),
          ),

          // Edit/Delete
          Column(
            children: [
              InkWell(onTap: () => _showPageEditor(existingIndex: index), child: Icon(Icons.edit, color: Colors.blue, size: 18.sp)),
              SizedBox(height: 1.5.h),
              InkWell(onTap: () => setState(() => _pages.removeAt(index)), child: Icon(Icons.delete, color: Colors.red, size: 18.sp)),
            ],
          )
        ],
      ),
    );
  }

  // --- PAGE EDITOR MODAL ---
  void _showPageEditor({int? existingIndex}) {
    final pageTextCtrl = TextEditingController(text: existingIndex != null ? _pages[existingIndex]['text'] : "");
    File? pageImage = existingIndex != null ? _pages[existingIndex]['image'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 85.h,
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, MediaQuery.of(context).viewInsets.bottom + 2.h),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(
                children: [
                  Container(width: 15.w, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  SizedBox(height: 2.h),
                  Text(existingIndex == null ? "Add New Page" : "Edit Page ${existingIndex + 1}", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _textDark)),
                  SizedBox(height: 3.h),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Story Text"),
                          TextField(
                            controller: pageTextCtrl,
                            maxLines: 5,
                            style: TextStyle(fontSize: 15.sp),
                            decoration: InputDecoration(hintText: "Once upon a time...", filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          ),
                          SizedBox(height: 3.h),

                          _buildLabel("Illustration (Optional)"),
                          InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                              if(img != null) setModalState(() => pageImage = File(img.path));
                            },
                            child: Container(
                              height: 20.h, width: double.infinity,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                  image: pageImage != null ? DecorationImage(image: FileImage(pageImage!), fit: BoxFit.cover) : null
                              ),
                              child: pageImage == null ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: _primaryPurple, size: 24.sp), Text("Add Image", style: TextStyle(color: _primaryPurple))])) : null,
                            ),
                          ),
                          if (pageImage != null)
                            Padding(padding: EdgeInsets.only(top: 1.h), child: Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setModalState(() => pageImage = null), child: Text("Remove Image", style: TextStyle(color: Colors.red))))),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity, height: 7.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (pageTextCtrl.text.trim().isEmpty && pageImage == null) return;

                        final newPage = {'text': pageTextCtrl.text, 'image': pageImage};
                        setState(() {
                          if (existingIndex != null) _pages[existingIndex] = newPage;
                          else _pages.add(newPage);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: Text("Save Page", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class DashedRectPainter extends CustomPainter {
  final double strokeWidth; final Color color; final double gap; final double radius;
  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.red, this.gap = 5.0, this.radius = 0});
  @override void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    Path path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius)));
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) { canvas.drawPath(pathMetric.extractPath(distance, distance + 5), dashedPaint); distance += 5 + gap; }
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}