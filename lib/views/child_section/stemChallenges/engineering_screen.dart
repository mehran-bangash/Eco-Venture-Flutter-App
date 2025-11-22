import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/child_view_model/stem_challgengs/child_stem_challenges_view_model_provider.dart';
import 'widgets/challenge_card.dart';


class EngineeringScreen extends ConsumerStatefulWidget {
  const EngineeringScreen({super.key});

  @override
  ConsumerState<EngineeringScreen> createState() => _EngineeringScreenState();
}

class _EngineeringScreenState extends ConsumerState<EngineeringScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  // Exact Firebase Key
  final String _category = 'Engineering';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(childStemChallengesViewModelProvider.notifier).loadChallenges(_category);
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

    double progressValue = challenges.isEmpty ? 0.0 : (completedCount / challenges.length);

    _progressAnimation = Tween<double>(begin: 0, end: progressValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
          // Engineering Gradient (Teal/Slate/Industrial)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF004D40), // Deep Teal
                Color(0xFF263238), // Slate Grey
                Color(0xFF37474F), // Blue Grey
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
                        colors: [Color(0xFF009688), Color(0xFF00695C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.4),
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
                            const Icon(Icons.engineering, color: Colors.white, size: 34),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                "Engineering Zone",
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
                                  Color(0xFFFFAB91), // Orange Accent
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 1.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${(progressValue * 100).toInt()}% Built",
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
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 28),
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
                    const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                  else if (challenges.isEmpty)
                    Center(
                      child: Text(
                        "No Engineering tasks yet!",
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
                            statusText = "Reviewing";
                            statusColor = Colors.orange.shade900;
                          } else if (submission.status == 'approved') {
                            statusText = "Built";
                            statusColor = Colors.green.shade700;
                          }
                        }

                        return ChallengeCard(
                          onTap: () => context.goNamed('engineeringInstructionScreen', extra: challenge),
                          title: challenge.title,
                          imageUrl: challenge.imageUrl ?? "assets/images/engineering_placeholder.png",
                          difficulty: challenge.difficulty,
                          rewardPoints: challenge.points,
                          backgroundGradient: const [Color(0xFF004D40), Color(0xFF00695C)],
                          buttonGradient: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
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