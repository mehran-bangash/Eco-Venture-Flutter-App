import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class TeacherVideoDashboard extends StatefulWidget {
  const TeacherVideoDashboard({super.key});

  @override
  State<TeacherVideoDashboard> createState() => _TeacherVideoDashboardState();
}

class _TeacherVideoDashboardState extends State<TeacherVideoDashboard> {
  final Color _primary = const Color(0xFFE53935); // YouTube Red-ish
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);

  // Mock Data
  final List<Map<String, dynamic>> _videos = [
    {'title': 'Introduction to Photosynthesis', 'duration': '5:30', 'category': 'Science'},
    {'title': 'Basic Addition', 'duration': '3:45', 'category': 'Maths'},
    {'title': 'The Water Cycle', 'duration': '6:10', 'category': 'Science'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _textDark), onPressed: () => context.pop()),
        centerTitle: true,
        title: Text("My Videos", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp)),
      ),
      body: _videos.isEmpty
          ? Center(child: Text("No Videos Added", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)))
          : ListView.separated(
        padding: EdgeInsets.all(5.w),
        itemCount: _videos.length,
        separatorBuilder: (c, i) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return _buildVideoCard(_videos[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('teacherAddVideoScreen'),
        backgroundColor: _primary,
        icon: Icon(Icons.video_call_rounded, size: 20.sp),
        label: Text("Add Video", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.play_arrow_rounded, color: _primary, size: 26.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video['title'], style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark)),
                SizedBox(height: 0.5.h),
                Text("${video['category']} • ${video['duration']}", style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp),
                onPressed: () => context.goNamed('teacherEditVideoScreen', extra: video),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                onPressed: () {}, // Delete Logic
              ),
            ],
          )
        ],
      ),
    );
  }
}