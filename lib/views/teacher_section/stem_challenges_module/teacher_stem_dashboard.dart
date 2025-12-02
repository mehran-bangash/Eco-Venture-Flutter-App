import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/stem_challenge_model.dart';
import '../../../viewmodels/teacher_stem_challenge/teacher_stem_provider.dart';


class TeacherStemDashboard extends ConsumerStatefulWidget {
  const TeacherStemDashboard({super.key});

  @override
  ConsumerState<TeacherStemDashboard> createState() => _TeacherStemDashboardState();
}

class _TeacherStemDashboardState extends ConsumerState<TeacherStemDashboard> {
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Technology', 'Engineering', 'Mathematics'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.microtask(() {
      ref.read(teacherStemViewModelProvider.notifier).loadChallenges(_selectedCategory);
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Category", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            ..._categories.map((c) => ListTile(
              title: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)),
              trailing: _selectedCategory == c ? Icon(Icons.check, color: _primary) : null,
              onTap: () {
                setState(() => _selectedCategory = c);
                _loadData(); // Reload
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stemState = ref.watch(teacherStemViewModelProvider);

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
            onPressed: _showFilterDialog,
            icon: Icon(Icons.filter_list_rounded, color: _primary, size: 22.sp),
          ),
          SizedBox(width: 3.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(teacherStemViewModelProvider.notifier).loadChallenges(_selectedCategory);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              child: Row(
                children: [
                  Text("Showing: $_selectedCategory", style: GoogleFonts.poppins(color: _textGrey, fontSize: 13.sp)),
                ],
              ),
            ),

            Expanded(
              child: stemState.isLoading
                  ? Center(child: CircularProgressIndicator(color: _primary))
                  : stemState.challenges.isEmpty
                  ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 60.h,
                  alignment: Alignment.center,
                  child: Text("No challenges in $_selectedCategory", style: GoogleFonts.poppins(color: _textGrey, fontSize: 15.sp)),
                ),
              )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(), // Needed for RefreshIndicator
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                itemCount: stemState.challenges.length,
                separatorBuilder: (c, i) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final challenge = stemState.challenges[index];
                  return _buildChallengeCard(challenge);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('teacherAddStemChallengeScreen'),
        backgroundColor: _primary,
        elevation: 4,
        icon: Icon(Icons.science_rounded, size: 18.sp),
        label: Text("Create Challenge", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)),
      ),
    );
  }

  Widget _buildChallengeCard(StemChallengeModel challenge) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                image: challenge.imageUrl != null && challenge.imageUrl!.startsWith('http')
                    ? DecorationImage(image: NetworkImage(challenge.imageUrl!), fit: BoxFit.cover)
                    : null
            ),
            child: challenge.imageUrl == null ? Icon(Icons.science, color: _primary, size: 24.sp) : null,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "${challenge.points} Points • ${challenge.difficulty}",
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: _textGrey),
                ),
                SizedBox(height: 1.5.h),
                _buildTag(challenge.category, Colors.purple),
              ],
            ),
          ),
          Column(
            children: [
              InkWell(
                  onTap: () => context.pushNamed('teacherEditStemChallengeScreen', extra: challenge),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: Colors.blue, size: 16.sp),
                  )
              ),
              SizedBox(height: 1.5.h),
              InkWell(
                  onTap: () {
                    if (challenge.id != null) {
                      ref.read(teacherStemViewModelProvider.notifier).deleteChallenge(challenge.id!, challenge.category);
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
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }
}