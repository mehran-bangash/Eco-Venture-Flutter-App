import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class TeacherQuizDashboard extends StatefulWidget {
  const TeacherQuizDashboard({super.key});

  @override
  State<TeacherQuizDashboard> createState() => _TeacherQuizDashboardState();
}

class _TeacherQuizDashboardState extends State<TeacherQuizDashboard> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFF1565C0); // Teacher Blue
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  // Mock Data (To be replaced by Firebase Stream)
  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Solar System Basics',
      'category': 'Science',
      'levels': 3,
      'created_at': '2 days ago'
    },
    {
      'title': 'Fractions & Decimals',
      'category': 'Maths',
      'levels': 5,
      'created_at': '1 week ago'
    },
    {
      'title': 'Rainforest Ecosystem',
      'category': 'Ecosystem',
      'levels': 2,
      'created_at': 'Yesterday'
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
          "My Quizzes",
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
                  hintText: "Search topics...",
                  hintStyle: GoogleFonts.poppins(color: _textGrey, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),

          // List of Topics
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              itemCount: _topics.length,
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return _buildTopicCard(topic);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('teacherAddQuizScreen'),
        backgroundColor: _primary,
        elevation: 4,
        icon: Icon(Icons.add, size: 18.sp),
        label: Text(
            "Create Quiz",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.library_books_rounded, color: _primary, size: 24.sp),
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic['title'],
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildTag(topic['category'], Colors.purple),
                    SizedBox(width: 2.w),
                    _buildTag("${topic['levels']} Levels", Colors.orange),
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
                    context.goNamed('teacherEditQuizScreen', extra: topic);
                  },
                  child: Icon(Icons.edit, color: _textGrey, size: 18.sp)
              ),
              SizedBox(height: 1.5.h),
              InkWell(
                  onTap: () {}, // Delete
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