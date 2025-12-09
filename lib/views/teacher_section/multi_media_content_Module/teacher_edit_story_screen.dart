import 'dart:io';
import 'dart:ui'; // Required for PathMetrics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/story_model.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';

class TeacherEditStoryScreen extends ConsumerStatefulWidget {
  final StoryModel storyData;
  const TeacherEditStoryScreen({super.key, required this.storyData});

  @override
  ConsumerState<TeacherEditStoryScreen> createState() =>
      _TeacherEditStoryScreenState();
}

class _TeacherEditStoryScreenState
    extends ConsumerState<TeacherEditStoryScreen> {
  // --- PRO COLORS ---
  final Color _primaryPurple = const Color(0xFF8E2DE2);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  File? _coverImage; // New local file
  String? _existingCoverUrl; // Old network URL
  late List<StoryPage> _pages;
  bool _isSensitive = false; // NEW
  final List<String> _storyCategories = [
    "Adventure",
    "Animals",
    "Fantasy",
    "Moral",
    "Science",
    "Family",
    "Funny",
    "Education",
  ];

  late String _selectedCategory;


  @override
  void initState() {
    super.initState();

    _titleController.text = widget.storyData.title;
    _descController.text = widget.storyData.description;
    _existingCoverUrl = widget.storyData.thumbnailUrl;



    // FIX HERE
    _pages = List.from(widget.storyData.pages);

    _tagsController.text = widget.storyData.tags.join(', ');
    _isSensitive = widget.storyData.tags.contains('scary');
    _selectedCategory = widget.storyData.category;
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updateStory() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title is required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Process Tags
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (_isSensitive && !tagsList.contains('scary')) tagsList.add('scary');
    if (!_isSensitive) tagsList.remove('scary');

    final updatedStory = widget.storyData.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailUrl: _coverImage?.path ?? _existingCoverUrl,
      pages: _pages,
      tags: tagsList, // Save tags
      isSensitive: _isSensitive,
      category: _selectedCategory,
    );

    await ref
        .read(teacherMultimediaViewModelProvider.notifier)
        .updateStory(updatedStory);
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _coverImage = File(img.path);
        _existingCoverUrl = null; // Clear existing if new picked
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    ref.listen(teacherMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Story Updated Successfully!"),
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
          "Edit Story",
          style: GoogleFonts.poppins(
            color: _textDark,
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
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Story Details"),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Story Title"),
                      _buildTextField(
                        controller: _titleController,
                        hint: "e.g. The Brave Little Rabbit",
                      ),
                      SizedBox(height: 2.h),
                      _buildLabel("Description"),
                      _buildTextField(
                        controller: _descController,
                        hint: "Short summary...",
                        maxLines: 3,
                      ),
                      SizedBox(height: 2.h),
                      _buildLabel("Category"),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _storyCategories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: GoogleFonts.poppins(fontSize: 15.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      SizedBox(height: 3.h),
                      _buildLabel("Cover Illustration"),
                      _buildCoverUpload(),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Content Safety",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          hintText: "Tags",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      SwitchListTile(
                        title: Text(
                          "Contains Sensitive Content?",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: _isSensitive,
                        onChanged: (val) => setState(() => _isSensitive = val),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 1.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Pages (${_pages.length})"),
                    InkWell(
                      onTap: () => _showPageEditor(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16.sp, color: _primaryPurple),
                            SizedBox(width: 1.w),
                            Text(
                              "Add Page",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (_pages.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        "No pages yet.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pages.length,
                    separatorBuilder: (c, i) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) => _buildPageCard(index),
                  ),

                SizedBox(height: 5.h),

                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Update Story",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ... (Reused Widgets from Add Screen: _buildSectionHeader, _buildLabel, _buildTextField) ...
  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: _textDark,
    ),
  );
  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryPurple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCoverUpload() {
    ImageProvider? imgProvider;
    if (_coverImage != null) {
      imgProvider = FileImage(_coverImage!);
    } else if (_existingCoverUrl != null && _existingCoverUrl!.isNotEmpty) {
      imgProvider = NetworkImage(_existingCoverUrl!);
    }

    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 6,
        radius: 12,
      ),
      child: InkWell(
        onTap: _pickCoverImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 20.h,
          width: double.infinity,
          decoration: imgProvider == null
              ? BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: imgProvider != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: imgProvider,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, size: 32.sp, color: Colors.grey),
                    SizedBox(height: 1.h),
                    Text(
                      "Upload Cover Art",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPageCard(int index) {
    final page = _pages[index];

    ImageProvider? pageImgProvider;
    // Smart check: Is it a URL (http) or Local Path?
    if (page.imageUrl.isNotEmpty) {
      if (page.imageUrl.startsWith('http')) {
        pageImgProvider = NetworkImage(page.imageUrl);
      } else {
        pageImgProvider = FileImage(File(page.imageUrl));
      }
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14.sp,
            backgroundColor: _primaryPurple.withOpacity(0.1),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: _textDark),
                ),
                if (pageImgProvider != null) ...[
                  SizedBox(height: 1.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: pageImgProvider,
                      height: 8.h,
                      width: 15.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showPageEditor(existingIndex: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _pages.removeAt(index)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- PAGE EDITOR MODAL ---
  void _showPageEditor({int? existingIndex}) {
    final textCtrl = TextEditingController(
      text: existingIndex != null ? _pages[existingIndex].text : "",
    );

    File? pageImageFile;
    String? pageImageUrl;

    // Initialize image state from existing data
    if (existingIndex != null && _pages[existingIndex].imageUrl.isNotEmpty) {
      if (_pages[existingIndex].imageUrl.startsWith('http')) {
        pageImageUrl = _pages[existingIndex].imageUrl;
      } else {
        pageImageFile = File(_pages[existingIndex].imageUrl);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          ImageProvider? editorImgProvider;
          if (pageImageFile != null) {
            editorImgProvider = FileImage(pageImageFile!);
          } else if (pageImageUrl != null)
            editorImgProvider = NetworkImage(pageImageUrl!);

          return Container(
            height: 85.h,
            padding: EdgeInsets.fromLTRB(
              5.w,
              2.h,
              5.w,
              MediaQuery.of(context).viewInsets.bottom + 2.h,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Container(
                  width: 15.w,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  existingIndex == null
                      ? "Add New Page"
                      : "Edit Page ${existingIndex + 1}",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 3.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Story Text"),
                        TextField(
                          controller: textCtrl,
                          maxLines: 5,
                          style: TextStyle(fontSize: 15.sp),
                          decoration: InputDecoration(
                            hintText: "Once upon a time...",
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        _buildLabel("Illustration (Optional)"),
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? img = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (img != null) {
                              setModalState(() {
                                pageImageFile = File(img.path);
                                pageImageUrl = null; // Override existing URL
                              });
                            }
                          },
                          child: Container(
                            height: 20.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              image: editorImgProvider != null
                                  ? DecorationImage(
                                      image: editorImgProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: editorImgProvider == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          color: _primaryPurple,
                                          size: 24.sp,
                                        ),
                                        Text(
                                          "Add Image",
                                          style: TextStyle(
                                            color: _primaryPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (editorImgProvider != null)
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setModalState(() {
                                  pageImageFile = null;
                                  pageImageUrl = null;
                                }),
                                child: Text(
                                  "Remove Image",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (textCtrl.text.trim().isEmpty &&
                          pageImageFile == null &&
                          pageImageUrl == null)
                        return;

                      // If we have a local file, save its path. If we have a URL, keep it.
                      final String newPath =
                          pageImageFile?.path ?? pageImageUrl ?? "";

                      final newPage = StoryPage(
                        text: textCtrl.text,
                        imageUrl: newPath,
                      );

                      setState(() {
                        if (existingIndex != null)
                          _pages[existingIndex] = newPage;
                        else
                          _pages.add(newPage);
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Save Page",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
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
