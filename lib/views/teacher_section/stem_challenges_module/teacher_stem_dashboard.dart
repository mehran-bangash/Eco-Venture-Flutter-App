import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class TeacherStemDashboard extends StatefulWidget {
  const TeacherStemDashboard({super.key});

  @override
  State<TeacherStemDashboard> createState() => _TeacherStemDashboardState();
}

class _TeacherStemDashboardState extends State<TeacherStemDashboard> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFF1565C0); // Teacher Blue
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  // Mock Data (Replace with Firebase Stream)
  final List<Map<String, dynamic>> _challenges = [
    {
      'title': 'Build a Water Filter',
      'category': 'Engineering',
      'difficulty': 'Medium',
      'points': 50,
      'materials': ['Bottle', 'Sand', 'Gravel'],
      'steps': ['Cut bottle', 'Layer materials'],
      'imageUrl': null
    },
    {
      'title': 'Paper Bridge Challenge',
      'category': 'Physics',
      'difficulty': 'Hard',
      'points': 80,
      'materials': ['Paper', 'Tape'],
      'steps': ['Fold paper', 'Test weight'],
      'imageUrl': null
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
          "STEM Challenges",
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
                  hintText: "Search challenges...",
                  hintStyle: GoogleFonts.poppins(color: _textGrey, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              itemCount: _challenges.length,
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                return _buildChallengeCard(challenge);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('teacherAddStemChallengeScreen'),
        backgroundColor: _primary,
        elevation: 4,
        icon: Icon(Icons.science_rounded, size: 18.sp),
        label: Text(
            "Create Challenge",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.science, color: _primary, size: 24.sp),
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'],
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "${challenge['points']} Points • ${challenge['difficulty']}",
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: _textGrey),
                ),
                SizedBox(height: 1.5.h),
                _buildTag(challenge['category'], Colors.purple),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              InkWell(
                  onTap: () {
                    // Navigate to Edit (Mock Data passed)
                    context.pushNamed('teacherEditStemChallengeScreen', extra: challenge);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: Colors.blue, size: 16.sp),
                  )
              ),
              InkWell(
                  onTap: () {}, // Delete
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
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
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