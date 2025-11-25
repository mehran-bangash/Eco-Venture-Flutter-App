import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class TeacherStoryDashboard extends StatefulWidget {
  const TeacherStoryDashboard({super.key});

  @override
  State<TeacherStoryDashboard> createState() => _TeacherStoryDashboardState();
}

class _TeacherStoryDashboardState extends State<TeacherStoryDashboard> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFF8E2DE2); // Deep Purple Theme
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  // Mock Data (Replace with Firebase Stream)
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'The Brave Little Rabbit',
      'pages': 5,
      'created_at': '2 days ago',
      'cover': null // Add asset path or url here if available
    },
    {
      'title': 'Journey to Mars',
      'pages': 8,
      'created_at': '1 week ago',
      'cover': null
    },
    {
      'title': 'The Water Cycle Adventure',
      'pages': 6,
      'created_at': 'Yesterday',
      'cover': null
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.filter_list_rounded, color: _primary, size: 22.sp)
          ),
          SizedBox(width: 3.w),
        ],
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
            child: _stories.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 40.sp, color: Colors.grey.shade300),
                  SizedBox(height: 1.h),
                  Text("No Stories Yet", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)),
                ],
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              itemCount: _stories.length,
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final story = _stories[index];
                return _buildStoryCard(story);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('teacherAddStoryScreen'),
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

  Widget _buildStoryCard(Map<String, dynamic> story) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Icon Container / Cover Preview
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              image: story['cover'] != null ? DecorationImage(image: AssetImage(story['cover']), fit: BoxFit.cover) : null,
            ),
            child: story['cover'] == null ? Icon(Icons.auto_stories, color: _primary, size: 24.sp) : null,
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['title'],
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildTag("${story['pages']} Pages", Colors.orange),
                    SizedBox(width: 2.w),
                    Text(
                      story['created_at'],
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: _textGrey),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              InkWell(
                  onTap: () {
                    // Navigate to Edit Screen (Pass Mock Data for now)
                    context.goNamed('teacherEditStoryScreen', extra: story);
                  },
                  child: Icon(Icons.edit, color: _textGrey, size: 18.sp)
              ),
              SizedBox(height: 1.5.h),
              InkWell(
                  onTap: () {}, // Delete Logic
                  child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 18.sp)
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
        style: GoogleFonts.poppins(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}