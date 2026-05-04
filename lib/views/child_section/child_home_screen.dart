import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/shared_preferences_helper.dart';

// Logic: Correct import paths
import '../../viewmodels/child_view_model/inbox_report/child_safety_provider.dart';
import '../../viewmodels/child_view_model/profile/user_provider.dart';


class ChildHomeScreen extends ConsumerStatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen>
    with TickerProviderStateMixin {
  String username = "Explorer";

  late final AnimationController _mainController;
  late final AnimationController _bgController;
  late final AnimationController _floatController;
  late final AnimationController _headerPulseController;
  late final AnimationController _particleController;
  late final AnimationController _shimmerController;
  late final AnimationController _breatheController;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredModules = [];

  // Particle system
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'QR Treasure',
      'icon': Icons.qr_code_scanner_rounded,
      'color1': const Color(0xFF2E7D32),
      'color2': const Color(0xFF81C784),
      'route': 'treasureHunt',
      'imageUrl':
      'https://images.unsplash.com/photo-1620423855978-e5d74a7bef30?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'STEM Tasks',
      'icon': Icons.science_rounded,
      'color1': const Color(0xFF0277BD),
      'color2': const Color(0xFF4FC3F7),
      'route': 'stemChallenges',
      'imageUrl':
      'https://images.unsplash.com/photo-1634872583967-6417a8638a59?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Nature Journal',
      'icon': Icons.camera_alt_rounded,
      'color1': const Color(0xFFEF6C00),
      'color2': const Color(0xFFFFB74D),
      'route': 'naturePhotoJournal',
      'imageUrl':
      'https://images.unsplash.com/photo-1579535984712-92fffbbaa266?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Eco Quiz',
      'icon': Icons.lightbulb_rounded,
      'color1': const Color(0xFF6A1B9A),
      'color2': const Color(0xFFBA68C8),
      'route': 'interactiveQuiz',
      'imageUrl':
      'https://raw.githubusercontent.com/encharm/Font-Awesome-SVG-PNG/master/black/png/256/question.png',
    },
    {
      'title': 'Multimedia',
      'icon': Icons.play_circle_fill_rounded,
      'color1': const Color(0xFFC62828),
      'color2': const Color(0xFFEF9A9A),
      'route': 'multiMediaContent',
      'imageUrl':
      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _initTeacherLookup();

    _mainController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..forward();
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _headerPulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _particleController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _breatheController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _filteredModules = List.from(_modules);
    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 3,
        speed: _random.nextDouble() * 0.4 + 0.1,
        opacity: _random.nextDouble() * 0.25 + 0.06,
        color: [
          const Color(0xFF4CAF50),
          const Color(0xFF03A9F4),
          const Color(0xFFFF9800),
          const Color(0xFF9C27B0),
          const Color(0xFF00BCD4),
        ][_random.nextInt(5)],
        phase: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  Future<void> _initTeacherLookup() async {
    final uid = SharedPreferencesHelper.instance.getUserId();
    if (uid != null) {
      ref.read(userProfileProvider.notifier).fetchUserProfile(uid);
    }
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return "0m";
    int h = minutes ~/ 60;
    int m = minutes % 60;
    return h > 0 ? "${h}h ${m}m" : "${m}m";
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredModules = List.from(_modules);
      } else {
        _filteredModules = _modules
            .where((module) => module['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    _floatController.dispose();
    _headerPulseController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _breatheController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final name = SharedPreferencesHelper.instance.getUserName();
    if (!mounted) return;
    setState(() => username = name ?? "Explorer");
  }

  // --- UI WRAPPERS ---

  Widget _floatingWrapper(
      {required Widget child, double offsetValue = -12.0}) {
    final offset = Tween<double>(begin: 0, end: offsetValue).animate(
        CurvedAnimation(
            parent: _floatController, curve: Curves.easeInOutSine));
    return AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) =>
            Transform.translate(offset: Offset(0, offset.value), child: child));
  }

  Widget _animatedEntry({required int index, required Widget child}) {
    final fade = CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.05 * index, 1, curve: Curves.easeInOut));
    final slide = Tween<Offset>(
        begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.05 * index, 0.8,
            curve: Curves.easeOutCubic)));
    return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child));
  }

  Widget _professionalCard(
      {required Widget child,
        Color? borderColor,
        double borderWidth = 2.0}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFAFBFD),
                const Color(0xFFF0F4F8),
                const Color(0xFFFAFBFD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.9),
                width: borderWidth),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFB8C8D8).withOpacity(0.55),
                  offset: const Offset(4, 8),
                  blurRadius: 20,
                  spreadRadius: 1),
              BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: const Offset(-3, -3),
                  blurRadius: 10),
            ],
          ),
          child:
          ClipRRect(borderRadius: BorderRadius.circular(30), child: child),
        );
      },
    );
  }

  /// Animated background with particles + subtle mesh gradient
  Widget _buildAnimatedBackground({required Widget child}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bgController, _particleController]),
      builder: (context, _) {
        final color1 = Color.lerp(const Color(0xFFEDF4F0),
            const Color(0xFFEFF6FB), _bgController.value)!;
        final color2 = Color.lerp(const Color(0xFFF8FAFB),
            const Color(0xFFFDF8EE), _bgController.value)!;
        final color3 = Color.lerp(const Color(0xFFF4F0FB),
            const Color(0xFFEFF8F4), _bgController.value)!;

        return Stack(
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color1, color2, color3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Subtle mesh blobs
            Positioned(
              top: -60,
              right: -40,
              child: _AnimatedBlob(
                controller: _bgController,
                color: const Color(0xFF4CAF50).withOpacity(0.06),
                size: 220,
              ),
            ),
            Positioned(
              bottom: 200,
              left: -50,
              child: _AnimatedBlob(
                controller: _bgController,
                color: const Color(0xFF03A9F4).withOpacity(0.05),
                size: 180,
                reverse: true,
              ),
            ),
            Positioned(
              bottom: 50,
              right: -30,
              child: _AnimatedBlob(
                controller: _bgController,
                color: const Color(0xFFFF9800).withOpacity(0.05),
                size: 150,
              ),
            ),

            // Floating particles
            CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
              ),
              child: const SizedBox.expand(),
            ),

            // Main content
            child,
          ],
        );
      },
    );
  }

  // --- SCREEN TIME CAPSULE (ADDED FROM FIRST FILE) ---
  Widget _buildTimeLimitCapsule() {
    final settingsAsync = ref.watch(childSafetySettingsProvider);
    final usageAsync = ref.watch(childUsageProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        // If limit is unset (24h), hide capsule
        if (settings.dailyLimitHours >= 24.0) return const SizedBox.shrink();

        return usageAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (usedMinutes) {
            final int totalLimitMinutes =
            (settings.dailyLimitHours * 60).round();
            int remaining = totalLimitMinutes - usedMinutes;
            if (remaining < 0) remaining = 0;
            final double progress = totalLimitMinutes == 0
                ? 0.0
                : (remaining / totalLimitMinutes).clamp(0.0, 1.0);

            Color statusColor = const Color(0xFF00E5FF);
            if (settings.isAppPaused) {
              statusColor = Colors.redAccent;
            } else if (remaining <= 0) statusColor = Colors.orangeAccent;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              child: _floatingWrapper(
                offsetValue: -5,
                child: _professionalCard(
                  borderWidth: 1.5,
                  borderColor: statusColor.withOpacity(0.4),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 1.5.h),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _headerPulseController,
                          builder: (context, _) => Icon(
                            settings.isAppPaused
                                ? Icons.pause_circle_filled
                                : Icons.timer_rounded,
                            color: statusColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    settings.isAppPaused
                                        ? "App Paused"
                                        : "Play Time Remaining",
                                    style: GoogleFonts.fredoka(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF455A64),
                                        fontSize: 14.5.sp),
                                  ),
                                  Text(
                                    settings.isAppPaused
                                        ? "Paused"
                                        : _formatMinutes(remaining),
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                        fontSize: 14.sp),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFECEFF1),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    final profileState = ref.watch(userProfileProvider);
    final String studentDisplayName =
        SharedPreferencesHelper.instance.getUserName() ?? "Explorer";
    final String teacherName =
        profileState.teacherName ?? "Classroom";

    return Container(
      // FIX: use full width with no overflow
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(38),
            bottomRight: Radius.circular(38)),
      ),
      child: Stack(
        children: [
          // Background image — full bleed, no left-edge gap
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(38),
                bottomRight: Radius.circular(38)),
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                final scale = 1.04 + (_bgController.value * 0.03);
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: double.infinity,
                    height: 30.h,
                    child: Image.asset(
                      "assets/images/child-Back-image.jpeg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),

          // Gradient overlay
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(38),
                bottomRight: Radius.circular(38)),
            child: Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.82),
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Subtle shimmer stripe on header
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(38),
                bottomRight: Radius.circular(38)),
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, _) {
                return Container(
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(
                            0.04 * _shimmerController.value),
                        Colors.transparent,
                      ],
                      begin: Alignment(-1 + _shimmerController.value * 2.5,
                          -0.3),
                      end: Alignment(
                          -0.5 + _shimmerController.value * 2.5, 0.3),
                    ),
                  ),
                );
              },
            ),
          ),

          // Header content — safe padding from MediaQuery
          SafeArea(
            bottom: false,
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animatedEntry(
                    index: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _headerPulseController,
                                builder: (context, child) => Transform.scale(
                                  scale: 1.0 +
                                      (_headerPulseController.value * 0.08),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black38,
                                              blurRadius: 10,
                                              offset: Offset(0, 4))
                                        ]),
                                    child: Image.asset(
                                        "assets/images/appLogo.png",
                                        height: 42,
                                        width: 42),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hi, $studentDisplayName 👋",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.fredoka(
                                          color: Colors.white,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          shadows: const [
                                            Shadow(
                                                color: Colors.black54,
                                                offset: Offset(0, 2),
                                                blurRadius: 8)
                                          ]),
                                    ),
                                    Container(
                                      margin:
                                      EdgeInsets.only(top: 0.5.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.5.w,
                                          vertical: 0.3.h),
                                      decoration: BoxDecoration(
                                        color:
                                        Colors.white.withOpacity(0.18),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white24,
                                            width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                              Icons.school_rounded,
                                              color: Colors.white,
                                              size: 14),
                                          SizedBox(width: 1.5.w),
                                          Flexible(
                                            child: Text(
                                              "Teacher: $teacherName",
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight:
                                                  FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.goNamed('childNotificationsScreen'),
                          child: AnimatedBuilder(
                            animation: _headerPulseController,
                            builder: (context, child) => Transform.rotate(
                              angle: (math.sin(
                                  _headerPulseController.value *
                                      math.pi *
                                      2) *
                                  0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white30,
                                        width: 1.5)),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                    Icons.notifications_active_rounded,
                                    color: Colors.white,
                                    size: 24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _animatedEntry(
                      index: 1,
                      child: Text(
                        "Ready for today's\nbig adventure?",
                        style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: 0.2),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: _professionalCard(
        borderWidth: 2.5,
        borderColor: const Color(0xFF455A64).withOpacity(0.15),
        child: Container(
          height: 6.5.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _breatheController,
                builder: (ctx, _) => Icon(
                  Icons.search_rounded,
                  color: Color.lerp(const Color(0xFF455A64),
                      const Color(0xFF00BFA5), _breatheController.value * 0.3)!,
                  size: 25,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF263238),
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search for activities...",
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.blueGrey.withOpacity(0.45),
                        fontSize: 14.5.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Expanded(
            child: _floatingWrapper(
              offsetValue: -10,
              child: GestureDetector(
                onTap: () =>
                    context.goNamed("childProgressDashboardScreen"),
                child: _EnhancedInfoCard(
                  icon: Icons.auto_graph_rounded,
                  iconColor: const Color(0xFF00BFA5),
                  label: "Progress",
                  sublabel: "Level Up!",
                  borderColor: const Color(0xFF00BFA5).withOpacity(0.4),
                  shimmerController: _shimmerController,
                  breatheController: _breatheController,
                  accentColor: const Color(0xFF00BFA5),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.5.w),
          Expanded(
            child: _floatingWrapper(
              offsetValue: -14,
              child: GestureDetector(
                onTap: () => context.goNamed("RewardsScreen"),
                child: _EnhancedInfoCard(
                  icon: Icons.stars_rounded,
                  iconColor: const Color(0xFFFFB300),
                  label: "Rewards",
                  sublabel: "My Trove",
                  borderColor: const Color(0xFFFFB300).withOpacity(0.4),
                  shimmerController: _shimmerController,
                  breatheController: _breatheController,
                  accentColor: const Color(0xFFFFB300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _filteredModules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 4.w,
            crossAxisSpacing: 4.w,
            childAspectRatio: 0.8),
        itemBuilder: (context, index) {
          final module = _filteredModules[index];
          return _floatingWrapper(
            offsetValue: (index % 2 == 0) ? -7 : -10,
            child: _animatedEntry(
              index: 4 + index,
              child: EcoModuleCard(
                title: module['title'],
                icon: module['icon'],
                color1: module['color1'],
                color2: module['color2'],
                imageUrl: module['imageUrl'],
                floatingWrapper: _floatingWrapper,
                onTap: () => context.goNamed(module['route']),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: _buildAnimatedBackground(
        child: SafeArea(
          top: false,
          // FIX: ensure no horizontal overflow on any device
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 2.5.h),
                      _buildSearchBox(),
                      SizedBox(height: 1.5.h),
                      _buildTimeLimitCapsule(), // <-- Playing time indicator added here
                      SizedBox(height: 1.5.h),
                      _buildInfoCards(),
                      SizedBox(height: 2.5.h),
                      _buildModuleGrid(),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Info Card with shimmer + ring animation
// ─────────────────────────────────────────────────────────────────────────────

class _EnhancedInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final Color borderColor;
  final Color accentColor;
  final AnimationController shimmerController;
  final AnimationController breatheController;

  const _EnhancedInfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.borderColor,
    required this.accentColor,
    required this.shimmerController,
    required this.breatheController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([shimmerController, breatheController]),
      builder: (context, _) {
        final glowOpacity = 0.08 + breatheController.value * 0.12;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFAFBFD),
                const Color(0xFFF0F4F8),
                const Color(0xFFFAFBFD),
              ],
              begin: Alignment(-1.0 + shimmerController.value * 2.0, -0.5),
              end: Alignment(-0.5 + shimmerController.value * 2.0, 0.5),
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                  color: accentColor.withOpacity(glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6)),
              BoxShadow(
                  color: const Color(0xFFB8C8D8).withOpacity(0.4),
                  offset: const Offset(3, 6),
                  blurRadius: 14),
              BoxShadow(
                  color: Colors.white.withOpacity(0.85),
                  offset: const Offset(-3, -3),
                  blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  // Animated icon ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing ring
                      Container(
                        width: 62 + breatheController.value * 4,
                        height: 62 + breatheController.value * 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withOpacity(
                                0.15 + breatheController.value * 0.1),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              accentColor.withOpacity(0.18),
                              accentColor.withOpacity(0.06),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(label,
                      style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF455A64),
                          fontSize: 17)),
                  Text(sublabel,
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF78909C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated blob for background depth
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedBlob extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final bool reverse;

  const _AnimatedBlob({
    required this.controller,
    required this.color,
    required this.size,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final v = reverse ? 1.0 - controller.value : controller.value;
        final scale = 0.85 + v * 0.3;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle system
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final animatedY =
          (p.y + progress * p.speed) % 1.0;
      final wobbleX = p.x +
          math.sin(progress * math.pi * 2 + p.phase) * 0.025;

      final paint = Paint()
        ..color = p.color.withOpacity(
            p.opacity * (0.6 + 0.4 * math.sin(progress * math.pi * 2 + p.phase)))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(wobbleX * size.width, animatedY * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// EcoModuleCard — UNCHANGED (backend logic preserved exactly)
// ─────────────────────────────────────────────────────────────────────────────

class EcoModuleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String imageUrl;
  final VoidCallback onTap;
  final Widget Function({required Widget child, double offsetValue})
  floatingWrapper;

  const EcoModuleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.imageUrl,
    required this.onTap,
    required this.floatingWrapper,
  });

  @override
  EcoModuleCardState createState() => EcoModuleCardState();
}

class EcoModuleCardState extends State<EcoModuleCard>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  late final AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _flipController, curve: Curves.easeInOutBack));
    _glowController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _flipController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) widget.onTap();
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _flipController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: Listenable.merge([_flipAnimation, _glowController]),
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final isFront = _flipAnimation.value < 0.5;
            final glowOpacity =
                0.15 + _glowController.value * 0.15;

            return Stack(
              children: [
                // Glow layer behind card
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color1.withOpacity(glowOpacity),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  child: isFront
                      ? _buildFrontDesign()
                      : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildBackDesign()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontDesign() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: widget.color1.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(widget.imageUrl, fit: BoxFit.cover),
          // Richer gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.transparent,
                  widget.color1.withOpacity(0.3),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Subtle top vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: widget.color1.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Icon(widget.icon, color: widget.color1, size: 20),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4),
                ),
                const SizedBox(height: 6),
                Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            widget.color2.withOpacity(0.7)
                          ],
                        )))
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildBackDesign() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.color1, widget.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_rounded, color: Colors.white, size: 44),
            const SizedBox(height: 10),
            Text(
              "LET'S GO!",
              style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5),
            )
          ],
        ),
      ),
    );
  }
}