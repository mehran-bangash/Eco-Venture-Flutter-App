import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:eco_venture/core/config/app_constants.dart'; // IMPORTED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/story_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';

class TeacherAddStoryScreen extends ConsumerStatefulWidget {
  const TeacherAddStoryScreen({super.key});

  @override
  ConsumerState<TeacherAddStoryScreen> createState() =>
      _TeacherAddStoryScreenState();
}

class _TeacherAddStoryScreenState extends ConsumerState<TeacherAddStoryScreen> {
  final Color _primaryPurple = const Color(0xFF8E2DE2);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // FIX: Changed from _selectedYear to _selectedAgeGroup
  String? _selectedAgeGroup;

  File? _coverImage;
  bool _isSensitive = false;
  final List<StoryPage> _pages = [];

  final List<String> _storyCategories = [
    'Moral Stories',
    'Fairy Tales',
    'Adventure',
    'Educational',
    'Science Fiction',
    'Fantasy',
    'Animals',
    'Nature',
    'History',
    'Culture',
    'General',
  ];
  String _selectedCategory = 'General';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // --- SAVE LOGIC ---
  Future<void> _saveStory() async {
    // FIX: Check for _selectedAgeGroup
    if (_titleController.text.trim().isEmpty || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a story title and select target class"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one page"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    if (teacherId == null) return;

    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (_isSensitive) tagsList.add('scary');

    final newStory = StoryModel(
      id: '',
      adminId: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailUrl: _coverImage?.path,
      pages: _pages,
      uploadedAt: DateTime.now(),
      tags: tagsList,
      isSensitive: _isSensitive,
      category: _selectedCategory,
      ageGroup: _selectedAgeGroup!, // Directly use the selected group
    );

    await ref
        .read(teacherMultimediaViewModelProvider.notifier)
        .addStory(newStory);

    if (!_isSensitive) {
      await _sendClassNotification(
        teacherId,
        newStory.title,
        _selectedAgeGroup!,
      );
    }
  }

  Future<void> _sendClassNotification(
    String teacherId,
    String storyTitle,
    String ageGroup,
  ) async {
    const String backendUrl = ApiConstants.notifyChildClassEndPoints;
    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "Story",
          "title": "New Story: $storyTitle 📖",
          "body": "A new story for Group $ageGroup is ready!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _coverImage = File(img.path));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    ref.listen(teacherMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ref.read(teacherMultimediaViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New Story",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
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
                        offset: const Offset(0, 4),
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

                      // REUSABLE DROPDOWN CALL
                      _buildLabel("Target Class / Age Group"),
                      _buildDynamicAgeDropdown(),

                      SizedBox(height: 2.h),
                      _buildLabel("Story Category"),
                      _buildCategoryDropdown(),
                      SizedBox(height: 2.h),
                      _buildLabel("Description"),
                      _buildTextField(
                        controller: _descController,
                        hint: "Short summary...",
                        maxLines: 3,
                      ),
                      SizedBox(height: 3.h),
                      _buildLabel("Cover Illustration"),
                      _buildCoverUpload(),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                _buildSectionHeader("Content Safety"),
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: Column(
                    children: [
                      _buildLabel("Tags (comma separated)"),
                      _buildTextField(
                        controller: _tagsController,
                        hint: "e.g. animals, fun, magic",
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Contains Suspense/Scary Content?",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        value: _isSensitive,
                        onChanged: (val) => setState(() => _isSensitive = val),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Pages (${_pages.length})"),
                    _buildAddPageBtn(),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildPagesList(),
                SizedBox(height: 5.h),
                _buildPublishBtn(state.isLoading),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- THE REUSABLE FUNCTION FOR ALL MODULES ---
  Widget _buildDynamicAgeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          hint: Text(
            "Select Class Group",
            style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: _primaryPurple),
          items: AppConstants.teacherClassRanges
              .map(
                (range) => DropdownMenuItem(
                  value: range,
                  child: Text(
                    "Group $range",
                    style: GoogleFonts.poppins(fontSize: 15.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedAgeGroup = v),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey),
      ),
      child: DropdownButton<String>(
        value: _selectedCategory,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: _primaryPurple, size: 24.sp),
        style: GoogleFonts.poppins(fontSize: 15.sp, color: _textDark),
        onChanged: (String? newValue) =>
            setState(() => _selectedCategory = newValue!),
        items: _storyCategories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }

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
          decoration: _coverImage == null
              ? BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: _coverImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_coverImage!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, size: 30.sp, color: Colors.grey),
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

  Widget _buildAddPageBtn() => InkWell(
    onTap: () => _showPageEditor(),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: _primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.add, size: 16.sp, color: _primaryPurple),
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
  );

  Widget _buildPagesList() {
    if (_pages.isEmpty)
      return Center(
        child: Text(
          "Start writing your story...",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      separatorBuilder: (c, i) => SizedBox(height: 2.h),
      itemBuilder: (context, index) => _buildPageCard(index),
    );
  }

  Widget _buildPublishBtn(bool loading) => SizedBox(
    width: double.infinity,
    height: 7.h,
    child: ElevatedButton(
      onPressed: loading ? null : _saveStory,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              "Publish Story",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    ),
  );

  Widget _buildPageCard(int index) {
    final page = _pages[index];
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
        children: [
          CircleAvatar(
            radius: 14.sp,
            backgroundColor: _primaryPurple.withOpacity(0.1),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              page.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: _textDark),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp),
            onPressed: () => _showPageEditor(existingIndex: index),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
            onPressed: () => setState(() => _pages.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _showPageEditor({int? existingIndex}) {
    final textCtrl = TextEditingController(
      text: existingIndex != null ? _pages[existingIndex].text : "",
    );
    File? pageImage;
    if (existingIndex != null && _pages[existingIndex].imageUrl.isNotEmpty)
      pageImage = File(_pages[existingIndex].imageUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                          final XFile? img = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null)
                            setModalState(() => pageImage = File(img.path));
                        },
                        child: Container(
                          height: 20.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            image: pageImage != null
                                ? DecorationImage(
                                    image: FileImage(pageImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: pageImage == null
                              ? Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    color: _primaryPurple,
                                    size: 24.sp,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (textCtrl.text.trim().isEmpty && pageImage == null)
                      return;
                    setState(() {
                      final newPage = StoryPage(
                        text: textCtrl.text,
                        imageUrl: pageImage?.path ?? "",
                      );
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
                  child: const Text(
                    "Save Page",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
