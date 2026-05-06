import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/quiz_topic_model.dart';
import '../../../../models/child/child_progress_model.dart';
import '../../../../viewmodels/child_view_model/interactive_quiz/child_quiz_provider.dart';

class QuizQuestionArgs {
  final QuizLevelModel level;
  final String topicId;
  final String topicName;
  final String category;

  QuizQuestionArgs({
    required this.level,
    required this.topicId,
    required this.topicName,
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

  Timer? _timer;
  int _remainingTime = 0;
  bool _isAnswered = false;
  late AudioPlayer _audioPlayer;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    level = widget.args.level;
    topicId = widget.args.topicId;
    category = widget.args.category;
    _audioPlayer = AudioPlayer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Start timer ONLY if teacher/admin provided a time > 0
    if (level.timerSeconds > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _isAnswered = false;
    _remainingTime = level.timerSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      wrongAnswersCount++;
      _isAnswered = true;
    });
    _playBuzzer();
    HapticFeedback.vibrate();
    Future.delayed(const Duration(seconds: 1), () => _proceedToNext());
  }

  Future<void> _playDing() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/ding.mp3'));
    } catch (_) {}
  }

  Future<void> _playBuzzer() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/buzzer.mp3'));
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;
    setState(() {
      selectedOption = option;
      _isAnswered = true;
    });
    _timer?.cancel();
    final currentQuestion = level.questions[currentIndex];
    final bool isCorrect = option == currentQuestion.answer;
    if (isCorrect) {
      correctAnswersCount++;
      _playDing();
    } else {
      wrongAnswersCount++;
      _playBuzzer();
      HapticFeedback.vibrate();
    }
    attemptDetails.add({
      'question': currentQuestion.question,
      'selected': option,
      'correct': currentQuestion.answer,
      'is_correct': isCorrect,
    });
    Future.delayed(const Duration(milliseconds: 1500), () => _proceedToNext());
  }

  void _proceedToNext() async {
    if (currentIndex < level.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        _isAnswered = false;
      });
      if (level.timerSeconds > 0) _startTimer();
      _controller.forward(from: 0);
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final totalQuestions = level.questions.length;
    final double percentage = (correctAnswersCount / totalQuestions) * 100;
    final bool isPassed = percentage >= level.passingPercentage;

    // FIX: Passing Model object instead of Map to avoid Red Screen error
    final progress = ChildQuizProgressModel(
      topicId: topicId,
      topicName: widget.args.topicName,
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

    await ref
        .read(childQuizViewModelProvider.notifier)
        .saveLevelResult(progress);
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

  Color _getOptionColor(String option, String correctAnswer) {
    if (!_isAnswered) {
      return selectedOption == option ? Colors.deepPurpleAccent : Colors.white;
    }
    if (option == correctAnswer) return Colors.green.shade400;
    if (selectedOption == option && option != correctAnswer)
      return Colors.red.shade400;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (level.questions.isEmpty)
      return const Scaffold(body: Center(child: Text("No questions.")));
    final currentQuestion = level.questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurpleAccent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Level ${level.order}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
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
              LinearProgressIndicator(
                value: (currentIndex + 1) / level.questions.length,
                backgroundColor: Colors.grey[300],
                minHeight: 1.h,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(height: 2.h),

              // --- TIMER AND COUNTER ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Q ${currentIndex + 1} / ${level.questions.length}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                  if (level.timerSeconds > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _remainingTime <= 5
                            ? Colors.red.withOpacity(0.15)
                            : Colors.deepOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: _remainingTime <= 5
                                ? Colors.red
                                : Colors.deepOrange,
                            size: 16.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "00:${_remainingTime.toString().padLeft(2, '0')}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: _remainingTime <= 5
                                  ? Colors.red
                                  : Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 3.h),
              _buildQuestionCard(currentQuestion),
              SizedBox(height: 3.h),
              _buildOptionsList(currentQuestion),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel currentQuestion) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (currentQuestion.imageUrl != null &&
              currentQuestion.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: currentQuestion.imageUrl!,
                height: 20.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, u) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (c, u, e) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 1.5.h),
          ],
          Text(
            currentQuestion.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(QuestionModel currentQuestion) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: currentQuestion.options.map((opt) {
            final color = _getOptionColor(opt, currentQuestion.answer);
            return GestureDetector(
              onTap: () => _onOptionSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: selectedOption == opt
                        ? Colors.transparent
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: selectedOption == opt
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: color == Colors.white
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                    if (selectedOption == opt)
                      Icon(
                        Icons.check_circle,
                        color: color == Colors.white
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
