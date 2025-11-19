import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/child_progress_model.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';


class QuizQuestionScreen extends ConsumerStatefulWidget {
  final QuizModel quiz; // Now accepts the Real Quiz Object

  const QuizQuestionScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {

  int currentIndex = 0;
  String? selectedOption;

  // --- Tracking Variables ---
  int correctAnswersCount = 0;
  int wrongAnswersCount = 0;
  List<Map<String, dynamic>> attemptDetails = []; // To save detailed report

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
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

    final currentQuestion = widget.quiz.questions[currentIndex];
    final bool isCorrect = selectedOption == currentQuestion.answer;

    // 1. Update Counters
    if (isCorrect) {
      correctAnswersCount++;
    } else {
      wrongAnswersCount++;
    }

    // 2. Record Detail for Report
    attemptDetails.add({
      'question': currentQuestion.question,
      'selected': selectedOption,
      'correct': currentQuestion.answer,
      'is_correct': isCorrect,
    });

    // 3. Check if Quiz Ended
    if (currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
      _controller.forward(from: 0);
    } else {
      // --- FINISH QUIZ LOGIC ---
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final totalQuestions = widget.quiz.questions.length;
    final double percentage = (correctAnswersCount / totalQuestions) * 100;
    final bool isPassed = percentage >= widget.quiz.passingPercentage;

    // 1. Create Progress Model
    final progress = ChildQuizProgressModel(
      quizId: widget.quiz.id!,
      category: widget.quiz.category,
      order: widget.quiz.order,
      correctAnswers: correctAnswersCount,
      wrongAnswers: wrongAnswersCount,
      attemptPercentage: percentage,
      attemptDate: DateTime.now(),
      questionDetails: attemptDetails,
      isPassed: isPassed,
      attempts: 1,
    );

    // 2. Save to Firebase
    await ref
        .read(childQuizViewModelProvider.notifier)
        .saveQuizResult(progress);

    // 3. Navigate to Completion Screen
    if (!mounted) return;

    context.goNamed(
      'quizCompletionScreen',
      pathParameters: {
        'correct': correctAnswersCount.toString(),
        'total': totalQuestions.toString(),
      },
      extra: progress, // ✔ passing progress object correctly
    );
  }


  @override
  Widget build(BuildContext context) {
    // Safety check for empty quiz
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(body: Center(child: Text("No questions in this quiz.")));
    }

    final currentQuestion = widget.quiz.questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(), // Allow exit
        ),
        title: Text(
          widget.quiz.title, // Real Title
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (currentIndex + 1) / widget.quiz.questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.deepPurpleAccent),
              ),
              SizedBox(height: 2.h),

              Center(
                child: Text(
                  "Question ${currentIndex + 1} of ${widget.quiz.questions.length}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Question Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // OPTIONAL IMAGE LOGIC
                    if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentQuestion.imageUrl!,
                          height: 25.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink(); // Hide if image fails to load
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Question Text (Compulsory)
                    Text(
                      currentQuestion.question,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Options List (Expanded to fill space if needed, or scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: currentQuestion.options.map((option) {
                      final isSelected = selectedOption == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(bottom: 1.5.h),
                          padding: EdgeInsets.all(3.5.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? Colors.deepPurpleAccent.withValues(alpha: 0.1)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurpleAccent
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                          ),
                          child: Text(
                            option,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: isSelected
                                  ? Colors.deepPurpleAccent
                                  : Colors.black87,
                              fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Next / Finish Button
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: selectedOption == null ? null : nextQuestion,
                  child: Text(
                    currentIndex == widget.quiz.questions.length - 1
                        ? "Finish Quiz"
                        : "Next Question",
                    style: GoogleFonts.poppins(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}