import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';
import 'widgets/challenge_card.dart';


class ScienceScreen extends ConsumerStatefulWidget {
  const ScienceScreen({super.key});

  @override
  ConsumerState<ScienceScreen> createState() => _ScienceScreenState();
}

class _ScienceScreenState extends ConsumerState<ScienceScreen>
    with SingleTickerProviderStateMixin {

  // Animation variables
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  // Constant for the category we are fetching
  final String _category = 'Science';

  @override
  void initState() {
    super.initState();

    // 1. Fetch Data on Init
    Future.microtask(() {
      ref.read(childStemChallengesViewModelProvider.notifier).loadChallenges(_category);
    });

    // Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    // Initial empty animation, will update when data arrives
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
    // 2. Watch the ViewModel State
    final stemState = ref.watch(childStemChallengesViewModelProvider);
    final challenges = stemState.challenges;
    final submissions = stemState.submissions;

    // 3. Calculate Real-Time Stats
    // Calculate Total Score from approved submissions
    int totalScore = 0;
    int completedCount = 0;

    // We filter submissions to check only those relevant to these challenges
    // (Simple way: if submission.challengeId exists in our fetched challenges list)
    for (var challenge in challenges) {
      final sub = submissions[challenge.id];
      if (sub != null && sub.status == 'approved') {
        totalScore += sub.pointsAwarded;
        completedCount++;
      }
    }

    // Calculate Progress %
    double progressValue = challenges.isEmpty ? 0.0 : (completedCount / challenges.length);

    // Update Animation with new value
    _progressAnimation = Tween<double>(begin: 0, end: progressValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0); // Restart animation on data change

    return PopScope(
        canPop: false,
       onPopInvokedWithResult: (didPop, result) {
         if(!didPop){
           context.goNamed('bottomNavChild');
         }
       },
      child: Scaffold(
        body: Container(
          // Science Lab Gradient
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF020024),
                Color(0xFF090979),
                Color(0xFF00D4FF),
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

                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 1,
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
                            const Icon(Icons.science_rounded, color: Colors.white, size: 34),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                "Science Adventures",
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

                        // Progress Bar
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
                                  Color(0xFF00FFDD),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 1.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${(progressValue * 100).toInt()}% Completed",
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

                  // --- Total Score Box ---
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 28),
                        SizedBox(width: 2.w),
                        Text(
                          "Total Score: $totalScore", // Real Data
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

                  // --- Challenge Grid (Real Data) ---
                  if (stemState.isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  else if (challenges.isEmpty)
                    Center(
                      child: Text(
                        "No Science challenges yet!",
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16.sp),
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
                        childAspectRatio: 0.7, // Adjusted for better fit
                      ),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        final submission = submissions[challenge.id];

                        String? statusText;
                        Color? statusColor;

                        if (submission != null) {
                          if (submission.status == 'pending') {
                            statusText = "Pending";
                            statusColor = Colors.orange.shade800;
                          } else if (submission.status == 'approved') {
                            statusText = "Done";
                            statusColor = Colors.green.shade700;
                          }
                        }

                        return ChallengeCard(
                          onTap: () => context.goNamed('scienceInstructionScreen', extra: challenge),
                          title: challenge.title,
                          imageUrl: challenge.imageUrl ?? "assets/images/science_placeholder.png",
                          difficulty: challenge.difficulty,
                          rewardPoints: challenge.points,
                          backgroundGradient: const [Color(0xFF003973), Color(0xFFE5E5BE)],
                          buttonGradient: const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
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