import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../models/nature_photo_upload_model.dart';

import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/nature_photo_view_model/nature_photo_provider.dart'; // Your SharedPrefs helper

// 1. STREAM PROVIDER: Listens to Firebase using SharedPrefs ID
final journalStreamProvider = StreamProvider<List<JournalEntry>>((ref) async* {
  // A. WAIT: Get the real User ID from local storage
  final userId = await SharedPreferencesHelper.instance.getUserId();

  // B. CHECK: If empty/null, return empty list (stop here)
  if (userId == null || userId.isEmpty) {
    yield [];
    return;
  }

  // C. LISTEN: Connect to Firebase using the REAL ID
  yield* FirebaseDatabase.instance
      .ref('users/$userId/journal')
      .onValue
      .map((event) {
    final map = event.snapshot.value as Map<dynamic, dynamic>?;
    if (map == null) return <JournalEntry>[];

    final entries = map.values.map((e) {
      return JournalEntry.fromMap(Map<String, dynamic>.from(e));
    }).toList();

    // Sort by newest first
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  });
});

// Extension for Color opacity
extension ColorExtensions on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return withOpacity(alpha);
    }
    return this;
  }
}

class NaturePhotoJournalScreen extends ConsumerStatefulWidget {
  const NaturePhotoJournalScreen({super.key});

  @override
  ConsumerState<NaturePhotoJournalScreen> createState() =>
      _NaturePhotoJournalScreenState();
}

class _NaturePhotoJournalScreenState extends ConsumerState<NaturePhotoJournalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fabController;
  late final AnimationController _headerController;
  late final AnimationController _particleController;
  late final AnimationController _floatingController;

  double _gyroX = 0.0;
  double _gyroY = 0.0;
  int _pressedIndex = -1;

  @override
  void initState() {
    super.initState();

    gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!mounted) return;
      setState(() {
        _gyroX = (_gyroX + (event.y * 0.02)).clamp(-0.1, 0.1);
        _gyroY = (_gyroY + (event.x * 0.02)).clamp(-0.1, 0.1);
      });
    });

    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _particleController = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat();

    _floatingController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    _headerController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    _particleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // --- BACKGROUND UI ---
  Widget _buildEnchantedBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E56A0), Color(0xFF163A6C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: FireflyPainter(
                time: _particleController.value,
                gyroX: _gyroX,
                gyroY: _gyroY,
              ),
              child: Container(),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // We removed the _showEditDialog function from here because
  // we will move it to the description screen later.

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalStreamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButton: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Curves.elasticOut,
          ),
          child: _buildCrystalButton(
            onTap: () {
              context.pushNamed("learnWithAiScreen");
            },
            icon: Icons.add_a_photo_rounded,
            size: 16.w,
            iconSize: 8.w,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                .animate(CurvedAnimation(
                parent: _headerController, curve: Curves.easeOut)),
            child: FadeTransition(
              opacity: _headerController,
              child: Text(
                "Nature Forest Journal",
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 10)],
                ),
              ),
            ),
          ),
          leading: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                .animate(CurvedAnimation(
                parent: _headerController, curve: Curves.easeOut)),
            child: FadeTransition(
              opacity: _headerController,
              child: _buildCrystalButton(
                onTap: () => {context.goNamed('bottomNavChild')},
                icon: Icons.arrow_back_rounded,
                size: 13.w,
                iconSize: 5.w,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            _buildEnchantedBackground(),
            SafeArea(
              bottom: false,
              child: journalAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(
                    child: Text("Error: $err",
                        style: const TextStyle(color: Colors.red))),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        "No discoveries yet!\nTap the camera to start.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 16.sp),
                      ),
                    );
                  }

                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w)
                        .copyWith(bottom: 15.h, top: 12.h),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final depth = (index % 3 + 1) * 5.0;

                      return _buildAnimatedFloatingCard(
                        index: index,
                        entry: entry,
                        depth: depth,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrystalButton({
    required VoidCallback onTap,
    required IconData icon,
    double? size,
    double? iconSize,
  }) {
    final buttonSize = size ?? 13.w;
    final iconButtonSize = iconSize ?? 5.w;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: iconButtonSize),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFloatingCard({
    required int index,
    required JournalEntry entry,
    required double depth,
  }) {
    final isPressed = _pressedIndex == index;

    final floatAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Interval(
          (index * 0.15) % 1.0,
          1.0,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // 1. DISMISSIBLE: Enables Swipe-to-Delete
    return Dismissible(
      key: Key(entry.id), // Unique ID is critical
      direction: DismissDirection.endToStart, // Swipe Right to Left
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.only(right: 5.w),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        // Get ID and Delete
        final userId = await SharedPreferencesHelper.instance.getUserId();
        if (userId != null) {
          ref.read(natureProvider.notifier).deleteEntry(userId, entry.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Deleted ${entry.prediction.label}")),
            );
          }
        }
      },
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, floatAnimation.value * math.sin((index + 1) * 0.5)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.identity()..scale(isPressed ? 0.92 : 1.0),
              alignment: Alignment.center,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressedIndex = index),
                onTapUp: (_) {
                  setState(() => _pressedIndex = -1);
                  // 2. Navigate to Description Screen
                  context.pushNamed('natureDescriptionScreen', extra: entry);
                },
                onTapCancel: () => setState(() => _pressedIndex = -1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      // 3. REMOVED STACK & EDIT BUTTON: Just the column now
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            entry.imageUrl,
                            fit: BoxFit.cover,
                            height: 15.h + (entry.prediction.label.length % 3) * 2.h,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 15.h,
                                color: Colors.white.withOpacity(0.1),
                                child: const Center(
                                    child: Icon(Icons.image, color: Colors.white24)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 15.h,
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.prediction.label,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  DateFormat('MMM d').format(entry.timestamp),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade400,
                                      size: 16.sp,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 4. FIREFLY PAINTER CLASS
class FireflyPainter extends CustomPainter {
  final double time;
  final double gyroX;
  final double gyroY;
  final int particleCount = 40;
  final List<Color> colors = [
    const Color(0xFFF0E68C),
    const Color(0xFFB0E0E6),
    const Color(0xFF98FB98),
  ];

  FireflyPainter({required this.time, required this.gyroX, required this.gyroY});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final random = math.Random(10);

    for (int i = 0; i < particleCount; i++) {
      final speed = random.nextDouble() * 0.2 + 0.1;
      final seedX = random.nextDouble() * 2 * math.pi;
      final seedY = random.nextDouble() * 2 * math.pi;
      final seedT = random.nextDouble();
      final t = (time + seedT) * speed;
      final x = (math.sin(t + seedX) + 1) / 2 * canvasSize.width;
      final y = (1.0 - (t * 1.5 + seedY) % 1.0) * canvasSize.height;
      final depth = (i % 5 + 1) * 10.0;
      final parallaxX = x + (gyroX * depth);
      final parallaxY = y + (gyroY * depth);

      final particleSize = random.nextDouble() * 2.0 + 1.0;
      final color = colors[i % colors.length];

      final glowPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 2);
      canvas.drawCircle(Offset(parallaxX, parallaxY), particleSize * 4, glowPaint);

      final corePaint = Paint()..color = color;
      canvas.drawCircle(Offset(parallaxX, parallaxY), particleSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant FireflyPainter oldDelegate) => true;
}