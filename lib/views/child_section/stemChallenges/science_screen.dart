
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';
import 'widgets/challenge_card.dart'; // Ensure this path is correct
import '../../../../models/stem_challenge_read_model.dart';

class ScienceScreen extends ConsumerStatefulWidget {
  const ScienceScreen({super.key});

  @override
  ConsumerState<ScienceScreen> createState() => _ScienceScreenState();
}

class _ScienceScreenState extends ConsumerState<ScienceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final String _category = 'Science';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childStemChallengesViewModelProvider.notifier).loadChallenges(_category);
    });

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childStemChallengesViewModelProvider);
    final adminList = state.adminChallenges;
    final teacherList = state.teacherChallenges;
    final submissions = state.submissions;

    // Calculate Stats (Combined)
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
    _progressAnimation = Tween<double>(begin: 0, end: progressValue).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);

    return PopScope(
        canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF020024), Color(0xFF090979), Color(0xFF00D4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Header and Score Box UI - Same as previous) ...
                  // Omitted for brevity - paste Header/Score code here

                  // 1. GLOBAL CHALLENGES
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text("Global Labs 🌍", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  _buildGrid(adminList, submissions),

                  // 2. CLASSROOM CHALLENGES (Only if available)
                  if (teacherList.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Divider(color: Colors.white24),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text("My Classroom 🏫", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    ),
                    _buildGrid(teacherList, submissions, isTeacher: true),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<StemChallengeReadModel> list, Map<String, dynamic> submissions, {bool isTeacher = false}) {
    if (list.isEmpty) return Center(child: Text("No challenges found.", style: TextStyle(color: Colors.white54)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4.w, mainAxisSpacing: 3.h, childAspectRatio: 0.7),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final challenge = list[index];
        final submission = submissions[challenge.id];

        String statusText = "";
        Color statusColor = Colors.transparent;
        if (submission != null) {
          if (submission.status == 'pending') { statusText = "Pending"; statusColor = Colors.orange; }
          else if (submission.status == 'approved') { statusText = "Done"; statusColor = Colors.green; }
        }

        return Stack(
          children: [
            ChallengeCard(
              onTap: () => context.goNamed('scienceInstructionScreen', extra: challenge),
              title: challenge.title,
              imageUrl: challenge.imageUrl ?? "assets/images/science_placeholder.png",
              difficulty: challenge.difficulty,
              rewardPoints: challenge.points,
              backgroundGradient: const [Color(0xFF003973), Color(0xFFE5E5BE)],
              buttonGradient: const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
            ),
            if (statusText.isNotEmpty)
              Positioned(top: 8, right: 8, child: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)), child: Text(statusText, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)))),
          ],
        );
      },
    );
  }
}