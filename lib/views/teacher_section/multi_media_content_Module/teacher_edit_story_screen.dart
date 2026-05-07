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

// Import Backend Model
import '../../../../models/story_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
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
  // --- COLORS ---
  final Color _primaryPurple = const Color(0xFF8E2DE2);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  File? _coverImage;
  String? _existingCoverUrl;
  late List<StoryPage> _pages;
  bool _isSensitive = false;
  String? _selectedAgeGroup;

  final List<String> _storyCategories = [
    "Adventure",
    "Animals",
    "Fantasy",
    "Moral",
    "Science",
    "Family",
    "Funny",
    "Education",
    "Educational",
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.storyData.title;
    _descController.text = widget.storyData.description;
    _existingCoverUrl = widget.storyData.thumbnailUrl;
    _pages = List.from(widget.storyData.pages);
    _tagsController.text = widget.storyData.tags.join(', ');
    _isSensitive = widget.storyData.isSensitive;

    final String dbCategory = widget.storyData.category;
    if (_storyCategories.contains(dbCategory)) {
      _selectedCategory = dbCategory;
    } else {
      _selectedCategory = _storyCategories.firstWhere(
        (cat) => cat.toLowerCase() == dbCategory.toLowerCase(),
        orElse: () => _storyCategories.first,
      );
    }
    _selectedAgeGroup = widget.storyData.ageGroup;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _sendClassNotification(
    String teacherId,
    String storyTitle,
    String ageGroup,
  ) async {
    try {
      await http.post(
        Uri.parse(ApiConstants.notifyChildClassEndPoints),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "Story",
          "title": "Story Updated: $storyTitle 📖",
          "body": "The story for Group $ageGroup has been updated!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("❌ Notification error: $e");
    }
  }

  Future<void> _updateStory() async {
    if (_titleController.text.isEmpty || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title and Target Age are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updatedStory = widget.storyData.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailUrl: _coverImage?.path ?? _existingCoverUrl,
      pages: _pages,
      tags: tagsList,
      isSensitive: _isSensitive,
      category: _selectedCategory,
      ageGroup: _selectedAgeGroup!,
    );

    // The ViewModel updateStory method now handles comparing old vs new URLs for Cloudinary deletion
    await ref
        .read(teacherMultimediaViewModelProvider.notifier)
        .updateStory(updatedStory);

    if (!_isSensitive && teacherId != null) {
      await _sendClassNotification(
        teacherId,
        updatedStory.title,
        _selectedAgeGroup!,
      );
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (img != null) {
      setState(() {
        _coverImage = File(img.path);
        _existingCoverUrl = null;
      });
    }
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
                _buildCard([
                  _buildLabel("Story Title"),
                  _buildTextField(controller: _titleController, hint: "Title"),
                  SizedBox(height: 2.h),
                  _buildLabel("Target Age Group"),
                  _buildAgeDropdown(),
                  SizedBox(height: 2.h),
                  _buildLabel("Description"),
                  _buildTextField(
                    controller: _descController,
                    hint: "Summary...",
                    maxLines: 3,
                  ),
                  SizedBox(height: 2.h),
                  _buildLabel("Category"),
                  _buildCategoryDropdown(),
                  SizedBox(height: 2.h),
                  _buildLabel("Cover Illustration"),
                  _buildCoverUpload(),
                ]),
                SizedBox(height: 3.h),
                _buildCard([
                  _buildLabel("Tags (comma separated)"),
                  _buildTextField(
                    controller: _tagsController,
                    hint: "animals, nature",
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Contains Sensitive Content?",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                    value: _isSensitive,
                    onChanged: (val) => setState(() => _isSensitive = val),
                    activeThumbColor: Colors.redAccent,
                  ),
                ]),
                SizedBox(height: 3.h),
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
                _buildUpdateBtn(state.isLoading),
                SizedBox(height: 5.h),
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

  Widget _buildAgeDropdown() {
    final List<String> dropdownItems = List<String>.from(
      AppConstants.teacherClassRanges,
    );
    if (_selectedAgeGroup != null &&
        !dropdownItems.contains(_selectedAgeGroup)) {
      dropdownItems.add(_selectedAgeGroup!);
    }
    final uniqueItems = dropdownItems.toSet().toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          items: uniqueItems
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    "Group $r",
                    style: GoogleFonts.poppins(fontSize: 15.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedAgeGroup = v!),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
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
          items: _storyCategories
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
  }

  Widget _buildPagesList() {
    if (_pages.isEmpty)
      return Center(
        child: Text(
          "No pages added.",
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (ctx, i) => _buildPageItem(i),
    );
  }

  Widget _buildPageItem(int index) {
    final page = _pages[index];
    ImageProvider? pageImg;
    if (page.imageUrl.isNotEmpty) {
      pageImg = page.imageUrl.startsWith('http')
          ? NetworkImage(page.imageUrl)
          : FileImage(File(page.imageUrl)) as ImageProvider;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _primaryPurple.withOpacity(0.1),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          if (pageImg != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: pageImg,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              page.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showPageEditor(existingIndex: index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
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
    String? localPath;
    String? netUrl;

    if (existingIndex != null) {
      if (_pages[existingIndex].imageUrl.startsWith('http'))
        netUrl = _pages[existingIndex].imageUrl;
      else
        localPath = _pages[existingIndex].imageUrl;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Padding(
          padding: EdgeInsets.fromLTRB(
            5.w,
            2.h,
            5.w,
            MediaQuery.of(ctx).viewInsets.bottom + 2.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Page Editor",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter story text...",
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              InkWell(
                onTap: () async {
                  final i = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (i != null)
                    setMState(() {
                      localPath = i.path;
                      netUrl = null;
                    });
                },
                child: Container(
                  height: 15.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: (localPath != null || netUrl != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image(
                            image: localPath != null
                                ? FileImage(File(localPath!))
                                : NetworkImage(netUrl!) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.grey,
                        ),
                ),
              ),
              if (localPath != null || netUrl != null)
                TextButton(
                  onPressed: () => setMState(() {
                    localPath = null;
                    netUrl = null;
                  }),
                  child: const Text(
                    "Remove Image",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 3.h),
              _buildUpdateBtn(
                false,
                label: "SAVE PAGE",
                onTap: () {
                  if (textCtrl.text.isEmpty) return;
                  setState(() {
                    final p = StoryPage(
                      text: textCtrl.text,
                      imageUrl: localPath ?? netUrl ?? "",
                    );
                    if (existingIndex != null)
                      _pages[existingIndex] = p;
                    else
                      _pages.add(p);
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverUpload() {
    ImageProvider? img;
    if (_coverImage != null)
      img = FileImage(_coverImage!);
    else if (_existingCoverUrl != null && _existingCoverUrl!.isNotEmpty)
      img = NetworkImage(_existingCoverUrl!);

    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 6,
        radius: 12,
      ),
      child: InkWell(
        onTap: _pickCoverImage,
        child: Container(
          height: 18.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: img != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(image: img, fit: BoxFit.cover),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, color: Colors.grey),
                      Text(
                        "Change Cover",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(4.w),
    margin: EdgeInsets.only(bottom: 2.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderGrey),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
  Widget _buildLabel(String t) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      t,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        color: _textDark,
      ),
    ),
  );
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15.sp),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: _textDark,
    ),
  );
  Widget _buildAddPageBtn() => InkWell(
    onTap: () => _showPageEditor(),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.add, size: 16.sp, color: _primaryPurple),
          Text(
            "Add Page",
            style: TextStyle(
              color: _primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _buildUpdateBtn(
    bool loading, {
    String label = "UPDATE STORY",
    VoidCallback? onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 7.h,
    child: ElevatedButton(
      onPressed: loading ? null : (onTap ?? _updateStory),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
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
