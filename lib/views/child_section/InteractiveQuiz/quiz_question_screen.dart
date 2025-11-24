import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/child_progress_model.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';

// Argument Model
class QuizQuestionArgs {
  final QuizLevelModel level;
  final String topicId;
  final String category;

  QuizQuestionArgs({
    required this.level,
    required this.topicId,
    required this.category,
  });
}

class QuizQuestionScreen extends ConsumerStatefulWidget {
  final QuizQuestionArgs args;

  const QuizQuestionScreen({super.key, required this.args});

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {

  late QuizLevelModel level;
  late String topicId;
  late String category;

  int currentIndex = 0;
  String? selectedOption;
  int correctAnswersCount = 0;
  int wrongAnswersCount = 0;
  List<Map<String, dynamic>> attemptDetails = [];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    level = widget.args.level;
    topicId = widget.args.topicId;
    category = widget.args.category;

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextQuestion() async {
    if (selectedOption == null) return;

    final currentQuestion = level.questions[currentIndex];
    final bool isCorrect = selectedOption == currentQuestion.answer;

    if (isCorrect) {
      correctAnswersCount++;
    } else {
      wrongAnswersCount++;
    }

    attemptDetails.add({
      'question': currentQuestion.question,
      'selected': selectedOption,
      'correct': currentQuestion.answer,
      'is_correct': isCorrect,
    });

    if (currentIndex < level.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
      _controller.forward(from: 0);
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final totalQuestions = level.questions.length;
    final double percentage = (correctAnswersCount / totalQuestions) * 100;

    // Logic: Must equal or exceed passing %
    final bool isPassed = percentage >= level.passingPercentage;

    print("DEBUG: Finishing Quiz. Topic: $topicId, Order: ${level.order}, Pass: $isPassed");

    final progress = ChildQuizProgressModel(
      topicId: topicId,
      category: category,
      levelOrder: level.order,
      correctAnswers: correctAnswersCount,
      wrongAnswers: wrongAnswersCount,
      attemptPercentage: percentage,
      attemptDate: DateTime.now(),
      questionDetails: attemptDetails,
      isPassed: isPassed,
      attempts: 1,
    );

    await ref.read(childQuizViewModelProvider.notifier).saveLevelResult(progress);

    if (!mounted) return;

    context.goNamed(
      'quizCompletionScreen',
      pathParameters: {
        'correct': correctAnswersCount.toString(),
        'total': totalQuestions.toString(),
      },
      extra: progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (level.questions.isEmpty) return const Scaffold(body: Center(child: Text("No questions.")));

    final currentQuestion = level.questions[currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('interactiveQuiz');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.deepPurpleAccent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Level ${level.order}",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17.sp),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. PROGRESS BAR ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / level.questions.length,
                    backgroundColor: Colors.grey[300],
                    minHeight: 1.h,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  ),
                ),
                SizedBox(height: 2.h),

                // --- 2. QUESTION COUNTER (FIXED VISIBILITY) ---
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Question ${currentIndex + 1} / ${level.questions.length}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp, // Larger Font
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // --- 3. QUESTION CARD ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))]
                  ),
                  child: Column(
                    children: [
                      if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            currentQuestion.imageUrl!,
                            height: 22.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      Text(
                          currentQuestion.question,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black87)
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                // --- 4. OPTIONS ---
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: currentQuestion.options.map((opt) {
                        final isSelected = selectedOption == opt;
                        return GestureDetector(
                          onTap: () => setState(() => selectedOption = opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(bottom: 1.5.h),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected ? [BoxShadow(color: Colors.deepPurpleAccent.withValues(alpha: 0.3), blurRadius: 8)] : [],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      opt,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15.sp,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : Colors.black87
                                      )
                                  ),
                                ),
                                if (isSelected) Icon(Icons.check_circle, color: Colors.white, size: 18.sp)
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: selectedOption == null ? null : nextQuestion,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: Text(
                        currentIndex == level.questions.length - 1 ? "FINISH" : "NEXT",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}