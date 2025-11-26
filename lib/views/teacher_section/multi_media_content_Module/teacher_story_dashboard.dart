import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/story_model.dart';
import '../../../viewmodels/multimedia_content/teacher_multimedia_provider.dart';


class TeacherStoryDashboard extends ConsumerStatefulWidget {
  const TeacherStoryDashboard({super.key});

  @override
  ConsumerState<TeacherStoryDashboard> createState() => _TeacherStoryDashboardState();
}

class _TeacherStoryDashboardState extends ConsumerState<TeacherStoryDashboard> {

  final Color _primary = const Color(0xFF8E2DE2); // Deep Purple Theme
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  @override
  void initState() {
    super.initState();
    // Load Stories on Init
    Future.microtask(() => ref.read(teacherMultimediaViewModelProvider.notifier).loadStories());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherMultimediaViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "My Stories",
          style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                style: GoogleFonts.poppins(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: "Search stories...",
                  hintStyle: GoogleFonts.poppins(color: _textGrey, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),

          // List of Stories
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: _primary))
                : state.stories.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 40.sp, color: Colors.grey.shade300),
                  SizedBox(height: 1.h),
                  Text("No Stories Created", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)),
                ],
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              itemCount: state.stories.length,
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final story = state.stories[index];
                return _buildStoryCard(story);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('teacherAddStoryScreen'),
        backgroundColor: _primary,
        elevation: 4,
        icon: Icon(Icons.add, size: 18.sp),
        label: Text(
            "Create Story",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)
        ),
      ),
    );
  }

  Widget _buildStoryCard(StoryModel story) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Thumbnail / Icon
          Container(
            height: 18.w, width: 18.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              image: story.thumbnailUrl != null && story.thumbnailUrl!.startsWith('http')
                  ? DecorationImage(image: NetworkImage(story.thumbnailUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: story.thumbnailUrl == null ? Icon(Icons.auto_stories, color: _primary, size: 24.sp) : null,
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  story.description.isNotEmpty ? story.description : "No description",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(height: 1.h),
                _buildTag("${story.pages.length} Pages", Colors.orange),
              ],
            ),
          ),

          // --- ACTION BUTTONS (Edit & Delete) ---
          Column(
            children: [
              // Edit Button
              InkWell(
                  onTap: () {
                    // Navigate to Edit Screen passing the Story Model
                    context.pushNamed('teacherEditStoryScreen', extra: story);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: Colors.blue, size: 16.sp),
                  )
              ),
              // Delete Button
              InkWell(
                  onTap: () {
                    if(story.id != null) {
                      ref.read(teacherMultimediaViewModelProvider.notifier).deleteStory(story.id!);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.delete_outline, color: Colors.red, size: 16.sp),
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}