import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock Teacher Data
  final String teacherName = "Mr. Ali";
  final String className = "Adventure Class 4B";

  // Mock Students
  final List<Map<String, String>> _students = [
    {'name': 'Hamza', 'avatar': 'assets/images/boy_1.png'},
    {'name': 'Zain', 'avatar': 'assets/images/boy_2.png'},
    {'name': 'Ali', 'avatar': 'assets/images/boy_3.png'},
    {'name': 'Mavia', 'avatar': 'assets/images/boy_1.png'},
    {'name': 'Add New', 'avatar': 'add_icon'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Premium Light Grey-Blue Background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. VIBRANT HEADER ---
            _buildHeader(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 2. CLASSROOM MANAGEMENT ---
                      SizedBox(height: 3.h),
                      _buildSectionTitle("My Classroom", Icons.groups_rounded),
                      SizedBox(height: 2.h),
                      _buildStudentList(),

                      // --- 3. QUICK STATS / REPORT ---
                      SizedBox(height: 4.h),
                      _buildClassReportCard(),

                      // --- 4. ACTIVITY CENTER (Renamed from Content Studio) ---
                      SizedBox(height: 4.h),
                      _buildSectionTitle("Activity Center", Icons.dashboard_rounded),
                      SizedBox(height: 1.h),
                      Text(
                        "Manage class learning materials",
                        style: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 2.5.h),
                      _buildContentGrid(),

                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.fromLTRB(5.w, 7.h, 5.w, 5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)], // Vibrant Blue-Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E54C8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Pic with Border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28.sp,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage("assets/images/teacher_profile.png"),
              onBackgroundImageError: (_, __) {},
              child: const Icon(Icons.person, color: Color(0xFF4E54C8), size: 30),
            ),
          ),
          SizedBox(width: 4.w),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $teacherName! 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black12, blurRadius: 5)],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    className,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon Glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22.sp),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22.sp, color: const Color(0xFF4E54C8)),
        SizedBox(width: 2.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E), // Deep Navy
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return SizedBox(
      height: 16.h, // Taller container
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _students.length,
        separatorBuilder: (_, __) => SizedBox(width: 4.w),
        itemBuilder: (context, index) {
          final student = _students[index];
          final isAddButton = student['avatar'] == 'add_icon';

          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (isAddButton) {
                    context.pushNamed('addStudentScreen');
                  } else {
                    context.pushNamed('studentDetailScreen', extra: student);
                  }
                },
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAddButton ? const Color(0xFF4E54C8) : Colors.white,
                    border: isAddButton
                        ? null
                        : Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.blueGrey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: isAddButton
                      ? Icon(Icons.add, color: Colors.white, size: 24.sp)
                      : Padding(
                    padding: const EdgeInsets.all(2.0), // Inner gap
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: AssetImage(student['avatar']!),
                      onBackgroundImageError: (_,__) => Icon(Icons.person, size: 20.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                student['name']!,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassReportCard() {
    return InkWell(
       onTap: () {
         context.goNamed('classReportScreen');
       },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)], // Lush Green Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998e).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.insights_rounded, color: Colors.white, size: 26.sp),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Class Performance",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  "View Weekly Stats ➔",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 4.w,
      mainAxisSpacing: 2.5.h,
      childAspectRatio: 1.0, // Square-ish cards
      children: [
        _buildGradientActionCard(
          "Quizzes",
          "Create Levels",
          Icons.quiz_rounded,
          const [Color(0xFFFF9966), Color(0xFFFF5E62)], // Orange-Red
              () => context.goNamed( 'teacherQuizDashBoard'),
        ),
        _buildGradientActionCard(
          "STEM",
          "Build & Learn",
          Icons.science_rounded,
          const [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Deep Purple
              () => context.goNamed('teacherStemChallengeDashboard'),
        ),
        _buildGradientActionCard(
          "Multimedia",
          "Videos & Stories",
          Icons.play_circle_filled_rounded,
          const [Color(0xFFEB3349), Color(0xFFF45C43)], // Red-Orange
              () {
               context.goNamed('teacherMultimediaDashboard');
              },
        ),
        _buildGradientActionCard(
          "QR Hunt",
          "Scavenger Hunt",
          Icons.qr_code_scanner_rounded,
          const [Color(0xFF00B4DB), Color(0xFF0083B0)], // Blue
              () {},
        ),
      ],
    );
  }

  // --- GRADIENT CARD FOR CONTENT ---
  Widget _buildGradientActionCard(String title, String subtitle, IconData icon, List<Color> gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circle
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22.sp),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}