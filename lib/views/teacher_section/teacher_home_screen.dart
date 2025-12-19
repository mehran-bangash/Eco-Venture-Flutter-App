import 'dart:ui'; // Required for BackdropFilter
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture/models/user_model.dart';
import 'package:eco_venture/viewmodels/auth/auth_provider.dart';
import 'package:eco_venture/viewmodels/teacher_home/teacher_home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../core/utils/utils.dart';
import '../../viewmodels/teacher_student_detail/teacher_student_detail_provider.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State to track Teacher Status
  String _teacherStatus =
      'loading'; // 'loading', 'active', 'pending', 'suspended'
  String _teacherName = "Teacher";

  @override
  void initState() {
    super.initState();
    // 1. Check Status immediately
    _checkTeacherStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      Map<String, dynamic> student,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Student?"),
        content: Text(
          "Are you sure you want to remove ${student['name']} from your class?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              // Call Service directly or via ViewModel
              await ref
                  .read(teacherStudentServiceProvider)
                  .removeStudentFromClass(student['uid']);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Student Removed")));
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NEW LOGIC: CHECK STATUS ---
  Future<void> _checkTeacherStatus() async {
    try {
      // Check FirebaseAuth first, then fallback to SharedPreferences
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      uid ??= await SharedPreferencesHelper.instance.getUserId();

      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            // Default to 'active' if field is missing to avoid blocking legacy users
            _teacherStatus = data['status'] ?? 'active';
            _teacherName = data['name'] ?? "Teacher";
          });
        }
      }
    } catch (e) {
      print("Error fetching status: $e");
      // Optional: Handle error state
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(teacherStudentsStreamProvider);
    // 2. BLOCKING LOGIC
    if (_teacherStatus == 'loading') {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_teacherStatus == 'pending') {
      return _buildBlockingScreen(
        title: "Approval Pending",
        message:
        "Your account is currently under review by the Admin.\nYou will be notified once approved.",
        icon: Icons.hourglass_top_rounded,
        color: Colors.orange,
      );
    }

    if (_teacherStatus == 'suspended') {
      return _buildBlockingScreen(
        title: "Account Suspended",
        message:
        "Your access has been revoked. Please contact the administrator for more details.",
        icon: Icons.block_rounded,
        color: Colors.red,
      );
    }

    // 3. IF ACTIVE -> SHOW DASHBOARD
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
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
                      // --- CLASSROOM MANAGEMENT ---
                      SizedBox(height: 3.h),
                      _buildSectionTitle("My Classroom", Icons.groups_rounded),
                      SizedBox(height: 2.h),
                      _buildStudentList(),

                      // --- QUICK STATS / REPORT ---
                      SizedBox(height: 4.h),
                      _buildClassReportCard(),

                      // --- ACTIVITY CENTER ---
                      SizedBox(height: 4.h),
                      _buildSectionTitle(
                        "Activity Center",
                        Icons.dashboard_rounded,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Manage class learning materials",
                        style: GoogleFonts.poppins(
                          color: Colors.blueGrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
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

  // --- NEW: BLOCKING SCREEN WIDGET ---
  Widget _buildBlockingScreen({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final authVM = ref.watch(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.sp, color: color),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 6.h),
            ElevatedButton.icon(
              onPressed: () async {
                await authVM.signOut();

                // Step 3: Show feedback to user
                context.goNamed('login');
                Utils.showDelightToast(
                  context,
                  "User successfully logged out",
                  duration: Duration(seconds: 3),
                  textColor: Colors.white,
                  bgColor: Colors.green,
                  position: DelightSnackbarPosition.bottom,
                  icon: Icons.check,
                  iconColor: Colors.white,
                );
                // Replace with your route
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXISTING WIDGET BUILDERS (Unchanged logic, just using _teacherName) ---

  Widget _buildHeader() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.fromLTRB(5.w, 7.h, 5.w, 5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E54C8).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28.sp,
              backgroundColor: Colors.white,
              // Ideally load real image here
              child: const Icon(
                Icons.person,
                color: Color(0xFF4E54C8),
                size: 30,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $_teacherName! 👋", // Used dynamic name
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.toString() == "TeacherHomeScreen"
                        ? "Class Teacher"
                        : "Teacher", // Just a label
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
          GestureDetector(
            onTap: () {
              context.goNamed('teacherNotificationScreen');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ),
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
            color: const Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return Consumer(
      builder: (context, ref, child) {
        final teacherHomeState = ref.watch(teacherHomeViewModelProvider);

        if (teacherHomeState.isLoading) {
          return _buildStudentListShimmer();
        }

        if (teacherHomeState.errorMessage != null) {
          return Center(child: Text(teacherHomeState.errorMessage!));
        }

        return SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: teacherHomeState.students.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              if (index == teacherHomeState.students.length) {
                return _buildAddStudentButton();
              }
              final student = teacherHomeState.students[index];
              return _buildStudentItem(student);
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentItem(UserModel student) {
    return SingleChildScrollView(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.pushNamed('studentDetailScreen', extra: student.toMap());
            },
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage:
                  student.imgUrl != null && student.imgUrl!.isNotEmpty
                      ? NetworkImage(student.imgUrl!)
                      : const AssetImage('assets/images/boy_1.png')
                  as ImageProvider,
                  onBackgroundImageError: (_, __) =>
                      Icon(Icons.person, size: 20.sp),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            student.displayName,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref, student as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStudentButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            context.pushNamed('addStudentScreen');
          },
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4E54C8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 24.sp),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Add New',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentListShimmer() {
    return SizedBox(
      height: 16.h,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: 4.w),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Container(height: 12, width: 60, color: Colors.white),
              ],
            );
          },
        ),
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
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998e).withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
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
                    decorationColor: Colors.white,
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
      childAspectRatio: 1.0,
      children: [
        _buildGradientActionCard(
          "Quizzes",
          "Create Levels",
          Icons.quiz_rounded,
          const [Color(0xFFFF9966), Color(0xFFFF5E62)],
              () => context.goNamed('teacherQuizDashBoard'),
        ),
        _buildGradientActionCard(
          "STEM",
          "Build & Learn",
          Icons.science_rounded,
          const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              () => context.goNamed('teacherStemChallengeDashboard'),
        ),
        _buildGradientActionCard(
          "Multimedia",
          "Videos & Stories",
          Icons.play_circle_filled_rounded,
          const [Color(0xFFEB3349), Color(0xFFF45C43)],
              () {
            context.goNamed('teacherMultimediaDashboard');
          },
        ),
        _buildGradientActionCard(
          "QR Hunt",
          "Scavenger Hunt",
          Icons.qr_code_scanner_rounded,
          const [Color(0xFF00B4DB), Color(0xFF0083B0)],
              () {
            context.goNamed('teacherTreasureHuntDashboard');
          },
        ),
      ],
    );
  }

  Widget _buildGradientActionCard(
      String title,
      String subtitle,
      IconData icon,
      List<Color> gradient,
      VoidCallback onTap,
      ) {
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
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.white.withValues(alpha: 0.9),
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
