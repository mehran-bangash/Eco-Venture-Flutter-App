import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/quiz_topic_model.dart';
import '../../../viewmodels/teacher_quiz/teacher_quiz_provider.dart';

class TeacherQuizDashboard extends ConsumerStatefulWidget {
  const TeacherQuizDashboard({super.key});

  @override
  ConsumerState<TeacherQuizDashboard> createState() =>
      _TeacherQuizDashboardState();
}

class _TeacherQuizDashboardState extends ConsumerState<TeacherQuizDashboard> {
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'Animals', 'Ecosystem'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(teacherQuizViewModelProvider.notifier)
          .loadQuizzes(_selectedCategory);
    });
  }

  // --- NEW: Confirmation Dialog before Deleting from Both Cloudinary & Firebase ---
  void _confirmDeletion(QuizTopicModel topic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Delete Quiz?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "This will permanently remove '${topic.topicName}' and all its images from the cloud.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (topic.id != null) {
                ref
                    .read(teacherQuizViewModelProvider.notifier)
                    .deleteQuiz(topic.id!, topic.category);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              "DELETE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Category",
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            ..._categories.map(
              (c) => ListTile(
                title: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)),
                trailing: _selectedCategory == c
                    ? Icon(Icons.check, color: _primary)
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = c);
                  ref
                      .read(teacherQuizViewModelProvider.notifier)
                      .loadQuizzes(c);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(teacherQuizViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed("bottomNavTeacher");
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
            onPressed: () => context.goNamed("bottomNavTeacher"),
          ),
          centerTitle: true,
          title: Text(
            "My Quizzes",
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showFilterDialog,
              icon: Icon(
                Icons.filter_list_rounded,
                color: _primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 3.w),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              child: Row(
                children: [
                  Text(
                    "Showing: $_selectedCategory",
                    style: GoogleFonts.poppins(
                      color: _textGrey,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: quizState.isLoading
                  ? Center(child: CircularProgressIndicator(color: _primary))
                  : quizState.quizzes.isEmpty
                  ? Center(
                      child: Text(
                        "No quizzes found in $_selectedCategory",
                        style: GoogleFonts.poppins(
                          color: _textGrey,
                          fontSize: 15.sp,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      itemCount: quizState.quizzes.length,
                      separatorBuilder: (c, i) => SizedBox(height: 2.h),
                      itemBuilder: (context, index) =>
                          _buildTopicCard(quizState.quizzes[index]),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed('teacherAddQuizScreen'),
          backgroundColor: _primary,
          elevation: 4,
          icon: Icon(Icons.add, size: 18.sp),
          label: Text(
            "Create Quiz",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(QuizTopicModel topic) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.library_books_rounded,
              color: _primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.topicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildTag(topic.category, Colors.purple),
                    SizedBox(width: 2.w),
                    _buildTag("${topic.levels.length} Levels", Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              InkWell(
                onTap: () =>
                    context.pushNamed('teacherEditQuizScreen', extra: topic),
                child: Icon(Icons.edit, color: _textGrey, size: 18.sp),
              ),
              SizedBox(height: 1.5.h),
              // Updated to use the confirmation dialog
              InkWell(
                onTap: () => _confirmDeletion(topic),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18.sp,
                ),
              ),
            ],
          ),
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
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
