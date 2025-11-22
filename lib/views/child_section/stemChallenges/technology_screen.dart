import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';
import 'widgets/challenge_card.dart';


class TechnologyScreen extends ConsumerStatefulWidget {
  const TechnologyScreen({super.key});

  @override
  ConsumerState<TechnologyScreen> createState() => _TechnologyScreenState();
}

class _TechnologyScreenState extends ConsumerState<TechnologyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  // Exact Firebase Key
  final String _category = 'Technology';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(childStemChallengesViewModelProvider.notifier)
          .loadChallenges(_category);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
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
    final stemState = ref.watch(childStemChallengesViewModelProvider);
    final challenges = stemState.challenges;
    final submissions = stemState.submissions;

    // Calculate Stats
    int totalScore = 0;
    int completedCount = 0;

    for (var challenge in challenges) {
      final sub = submissions[challenge.id];
      if (sub != null && sub.status == 'approved') {
        totalScore += sub.pointsAwarded;
        completedCount++;
      }
    }

    double progressValue = challenges.isEmpty
        ? 0.0
        : (completedCount / challenges.length);

    _progressAnimation = Tween<double>(
      begin: 0,
      end: progressValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed("bottomNavChild");
        }
      },
      child: Scaffold(
        body: Container(
          // Tech Gradient (Deep Violet / Cyber Blue)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2D0036), // Deep Violet
                Color(0xFF1A237E), // Indigo
                Color(0xFF000000), // Black
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6200EA), Color(0xFF304FFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 2.w),
                            const Icon(
                              Icons.computer_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                "Tech Lab",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 1.4.h,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00E5FF), // Neon Cyan
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 1.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${(progressValue * 100).toInt()}% Coded",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // --- Score Box ---
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amberAccent,
                          size: 28,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Total Score: $totalScore",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // --- Grid ---
                  if (stemState.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    )
                  else if (challenges.isEmpty)
                    Center(
                      child: Text(
                        "No Tech challenges yet!",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 3.h,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        final submission = submissions[challenge.id];

                        String? statusText;
                        Color? statusColor;

                        if (submission != null) {
                          if (submission.status == 'pending') {
                            statusText = "Compiling";
                            statusColor = Colors.orange.shade900;
                          } else if (submission.status == 'approved') {
                            statusText = "Deployed";
                            statusColor = Colors.green.shade700;
                          }
                        }

                        return ChallengeCard(
                          onTap: () => context.goNamed(
                            'technologyInstructionScreen',
                            extra: challenge,
                          ),
                          title: challenge.title,
                          imageUrl:
                              challenge.imageUrl ??
                              "assets/images/tech_placeholder.png",
                          difficulty: challenge.difficulty,
                          rewardPoints: challenge.points,
                          backgroundGradient: const [
                            Color(0xFF311B92),
                            Color(0xFF006064),
                          ],
                          buttonGradient: const [
                            Color(0xFF7C4DFF),
                            Color(0xFF00E5FF),
                          ],
                          // Pass Status Here
                          statusText: statusText,
                          statusColor: statusColor,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
