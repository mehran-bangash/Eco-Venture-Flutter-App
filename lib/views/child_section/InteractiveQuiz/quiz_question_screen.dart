import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {

  // Hardcoded quiz data for now
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Which animal is known as the King of the Jungle?",
      "options": ["Elephant", "Lion", "Tiger", "Cheetah"],
      "answer": "Lion",
      "image": "https://cdn-icons-png.flaticon.com/512/616/616408.png"
    },
    {
      "question": "Which planet is known as the Red Planet?",
      "options": ["Earth", "Venus", "Mars", "Jupiter"],
      "answer": "Mars",
      "image": "https://cdn-icons-png.flaticon.com/512/616/616408.png"
    },
    {
      "question": "What do plants need to make food?",
      "options": ["Oxygen", "Water", "Sunlight", "Wind"],
      "answer": "Sunlight",
      "image": "https://cdn-icons-png.flaticon.com/512/2909/2909761.png"
    },
  ];

  int currentIndex = 0;
  String? selectedOption;
  int correctAnswers = 0;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    selectedOption = null;
    correctAnswers = 0;
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextQuestion() {
    if (selectedOption == null) return;

    if (selectedOption == questions[currentIndex]["answer"]) {
      correctAnswers++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
      _controller.forward(from: 0);
    } else {
      // Navigate to completion screen
      context.goNamed(
        'quizCompletionScreen',
        pathParameters: {
          'correct': correctAnswers.toString(),
          'total': questions.length.toString(),
        },
      );



    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text(
          "Quiz Time 🧠",
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
              // Progress Indicator
              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.deepPurpleAccent),
              ),
              SizedBox(height: 2.h),
              Center(
                child: Text(
                  "Question ${currentIndex + 1} of ${questions.length}",
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
                    Image.network(
                      currentQuestion["image"],
                      height: 20.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currentQuestion["question"],
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

              // Options
              ...currentQuestion["options"].map<Widget>((option) {
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
                    padding: EdgeInsets.all(3.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurpleAccent
                            : Colors.grey.shade300,
                        width: 2,
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

              const Spacer(),

              // Next Button
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
                  onPressed: nextQuestion,
                  child: Text(
                    currentIndex == questions.length - 1
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
