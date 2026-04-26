import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';
import 'widgets/challenge_card.dart';
import '../../../../models/stem_challenge_read_model.dart';

class EngineeringScreen extends ConsumerStatefulWidget {
  const EngineeringScreen({super.key});

  @override
  ConsumerState<EngineeringScreen> createState() => _EngineeringScreenState();
}

class _EngineeringScreenState extends ConsumerState<EngineeringScreen> {
  final String _category = 'Engineering';
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _themeColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childStemChallengesViewModelProvider.notifier).loadChallenges(_category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childStemChallengesViewModelProvider);
    final adminList = state.adminChallenges;
    final teacherList = state.teacherChallenges;
    final submissions = state.submissions;

    int totalScore = 0;
    int completedCount = 0;
    final allChallenges = [...adminList, ...teacherList];

    for (var challenge in allChallenges) {
      final sub = submissions[challenge.id];
      if (sub != null && sub.status == 'approved') {
        totalScore += sub.pointsAwarded;
        completedCount++;
      }
    }

    double progressValue = allChallenges.isEmpty ? 0.0 : (completedCount / allChallenges.length);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsHeader(totalScore, completedCount, progressValue),
            SizedBox(height: 3.h),
            
            _buildSectionTitle("Builder Quests 🛠️", subtitle: "Construct amazing things with worldwide engineers"),
            _buildGrid(adminList, submissions, isTeacher: false),

            if (teacherList.isNotEmpty) ...[
              SizedBox(height: 5.h),
              _buildSectionTitle("My Classroom 🏫", 
                subtitle: "Engineering projects assigned by your teacher", 
                color: Colors.orange.shade700,
                icon: Icons.school_rounded,
                iconColor: Colors.amber,
              ),
              _buildGrid(teacherList, submissions, isTeacher: true),
            ],
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int score, int completed, double progress) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _themeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category Score", style: GoogleFonts.poppins(color: _subText, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  Text("$score XP", style: GoogleFonts.poppins(color: _primaryDark, fontSize: 20.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$completed Completed", style: GoogleFonts.poppins(color: _themeColor, fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(_themeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle, Color? color, IconData? icon, Color? iconColor}) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: iconColor ?? color ?? _primaryDark, size: 20.sp),
              if (icon != null) SizedBox(width: 2.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: color ?? _primaryDark,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _subText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<StemChallengeReadModel> list, Map<String, dynamic> submissions, {required bool isTeacher}) {
    if (list.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        width: double.infinity,
        child: Center(child: Text("No challenges found.", style: GoogleFonts.poppins(color: _subText))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.75,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final challenge = list[index];
        final submission = submissions[challenge.id];

        String? statusText;
        Color? statusColor;
        if (submission != null) {
          if (submission.status == 'pending') {
            statusText = "Pending";
            statusColor = Colors.orange;
          } else if (submission.status == 'approved') {
            statusText = "Done";
            statusColor = Colors.green;
          } else if (submission.status == 'rejected') {
            statusText = "Redo";
            statusColor = Colors.red;
          }
        }

        return ChallengeCard(
          onTap: () => context.goNamed('engineeringInstructionScreen', extra: challenge),
          title: challenge.title,
          imageUrl: challenge.imageUrl ?? "",
          difficulty: challenge.difficulty,
          rewardPoints: challenge.points,
          themeColor: _themeColor,
          statusText: statusText,
          statusColor: statusColor,
          isTeacher: isTeacher,
        );
      },
    );
  }
}
