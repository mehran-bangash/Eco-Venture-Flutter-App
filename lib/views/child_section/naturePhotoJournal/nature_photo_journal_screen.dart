import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Ensure this is imported
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Ensure this is imported

// Dummy extension for .withValues since it's not standard Flutter
extension ColorExtensions on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return this.withValues(alpha: alpha);
    }
    return this;
  }
}
// Assume context.goNamed and .w/.h/.sp are defined elsewhere for simplicity

class NaturePhotoJournalScreen extends StatefulWidget {
  const NaturePhotoJournalScreen({super.key});

  @override
  State<NaturePhotoJournalScreen> createState() =>
      _NaturePhotoJournalScreenState();
}

class _NaturePhotoJournalScreenState extends State<NaturePhotoJournalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fabController;
  late final AnimationController _headerController;
  late final AnimationController _particleController;
  late final AnimationController _floatingController; // NEW: Controller for gentle float

  final List<AnimationController> _cardControllers = [];

  double _gyroX = 0.0;
  double _gyroY = 0.0;
  int _pressedIndex = -1;

  final List<Map<String, dynamic>> _journalEntries = [
    {
      "title": "Met a new friend in the woods!",
      "date": "Aug 20",
      "image":
      "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=800&q=80",
      "stars": 4,
    },
    {
      "title": "The most beautiful sunset ever.",
      "date": "Aug 21",
      "image":
      "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=800&q=80",
      "stars": 5,
    },
    {
      "title": "A butterfly on a flower",
      "date": "Aug 24",
      "image":
      "https://images.unsplash.com/photo-1502759683299-cdcd6974244f?auto=format&fit=crop&w=800&q=80",
      "stars": 4,
    },
    {
      "title": "Look at these tiny frogs!",
      "date": "Aug 25",
      "image":
      "https://images.unsplash.com/photo-1496568816309-51d7c20e3b21?auto=format&fit=crop&w=800&q=80",
      "stars": 5,
    },
  ];

  @override
  void initState() {
    super.initState();

    // KEEP: Gyroscope remains for background particle effect
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!mounted) return;
      setState(() {
        _gyroX = (_gyroX + (event.y * 0.02)).clamp(-0.1, 0.1);
        _gyroY = (_gyroY + (event.x * 0.02)).clamp(-0.1, 0.1);
      });
    });

    _fabController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _headerController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _particleController =
    AnimationController(vsync: this, duration: const Duration(seconds: 15))
      ..repeat();

    // NEW: Floating animation controller for the cards
    _floatingController =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true); // Gentle back and forth repeat

    for (var i = 0; i < _journalEntries.length; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600));
      _cardControllers.add(ctrl);
      Future.delayed(Duration(milliseconds: 300 + (i * 100)), () {
        if (mounted) ctrl.forward();
      });
    }

    _headerController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    _particleController.dispose();
    _floatingController.dispose(); // Dispose the new controller
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

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
                Colors.black.withValues(alpha: 0.4),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {

        if (!didPop) {
          context.goNamed('bottomNavChild');
        } //
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
              context.goNamed("learnWithAiScreen");
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
                .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut)),
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
                .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut)),
            child: FadeTransition(
              opacity: _headerController,
              child: _buildCrystalButton(
                onTap: () => {
                  context.goNamed('bottomNavChild')
                },
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
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w)
                    .copyWith(bottom: 15.h, top: 12.h),
                itemCount: _journalEntries.length,
                itemBuilder: (context, index) {
                  final entry = _journalEntries[index];
                  final ctrl = _cardControllers[index];
                  final depth = (index % 3 + 1) * 5.0;

                  return _buildAnimatedFloatingCard(
                    index: index,
                    controller: ctrl,
                    entry: entry,
                    depth: depth,
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
    final buttonSize = size ?? 13.w;      // Use .w at runtime
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: iconButtonSize),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFloatingCard({
    required int index,
    required AnimationController controller,
    required Map<String, dynamic> entry,
    required double depth,
  }) {
    final animation = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    final isPressed = _pressedIndex == index;
    // REMOVED TILT: final tiltX = _gyroX * depth;
    // REMOVED TILT: final tiltY = _gyroY * depth;

    // NEW: Create a gentle vertical translation animation
    final floatAnimation = Tween<double>(begin: 0.0, end: 5.0) // Moves 5 pixels up/down
        .animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Interval(
          (index * 0.15) % 1.0, // Staggered delay for each card
          1.0,
          curve: Curves.easeInOut,
        ),
      ),
    );

    return AnimatedBuilder( // NEW: Use AnimatedBuilder to listen to the float controller
      animation: _floatingController,
      builder: (context, child) {
        return ScaleTransition(
          scale: animation,
          child: Transform.translate( // Apply the gentle vertical float
            offset: Offset(0, floatAnimation.value * math.sin((index + 1) * 0.5)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              // REMOVED TILT TRANSFORM: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(tiltY)..rotateY(tiltX)..scale(isPressed ? 0.92 : 1.0)
              transform: Matrix4.identity() // Cards remain fixed, only scale on press
                ..scale(isPressed ? 0.92 : 1.0),
              alignment: Alignment.center,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressedIndex = index),
                onTapUp: (_) {
                  setState(() => _pressedIndex = -1);
                   context.goNamed('natureDescriptionScreen');
                },
                onTapCancel: () => setState(() => _pressedIndex = -1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            entry["image"],
                            fit: BoxFit.cover,
                            height: 15.h + (entry['title'].length % 3) * 2.h,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 15.h + (entry['title'].length % 3) * 2.h,
                                color: Colors.white.withValues(alpha: 0.1),
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry["title"],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < entry['stars']
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
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
          ),
        );
      },
    );
  }
}

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
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 2);
      canvas.drawCircle(Offset(parallaxX, parallaxY), particleSize * 4, glowPaint);

      final corePaint = Paint()..color = color;
      canvas.drawCircle(Offset(parallaxX, parallaxY), particleSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant FireflyPainter oldDelegate) => true;
}