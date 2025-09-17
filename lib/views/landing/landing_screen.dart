import 'package:eco_venture/core/constants/app_text_styles.dart';
import 'package:eco_venture/core/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {

  // Controllers
  late final AnimationController _centerController;
  late final AnimationController _pulseController;

  // Opacities
  late final Animation<double> _logoOpacity;
  late final Animation<double> _parentOpacity;
  late final Animation<double> _childOpacity;
  late final Animation<double> _teacherOpacity;

  // Pulsing (scale)
  late final Animation<double> _pulseAnimation;

  // For background animation
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();

    // Foreground entry (faster)
    _centerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Pulse (after entry completes)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Opacities (staggered)
    _logoOpacity = CurvedAnimation(
      parent: _centerController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );
    _parentOpacity = CurvedAnimation(
      parent: _centerController,
      curve: const Interval(0.35, 0.45, curve: Curves.easeIn),
    );
    _childOpacity = CurvedAnimation(
      parent: _centerController,
      curve: const Interval(0.45, 0.55, curve: Curves.easeIn),
    );
    _teacherOpacity = CurvedAnimation(
      parent: _centerController,
      curve: const Interval(0.55, 0.65, curve: Curves.easeIn),
    );

    // Pulse scale (e.g., 0.95 -> 1.05)
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entry animations
    _centerController.forward();

    // When entry finishes, start pulsing
    _centerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // Start ticker for background animation
    _ticker = Ticker((d) {
      setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _centerController.dispose();
    _pulseController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Background animation values
    var time = DateTime.now().millisecondsSinceEpoch / 2000;
    var scaleX = 1.2 + sin(time) * .05;
    var scaleY = 1.2 + cos(time) * .07;
    var offsetY = 20 + cos(time) * 20;

    return Scaffold(
      body: Stack(
        children: [
          //Background fluid animation
          LayoutBuilder(
            builder: (_, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Transform.translate(
                offset: Offset(
                  -(scaleX - 1) / 2 * width,
                  -(scaleY - 1) / 2 * height + offsetY,
                ),
                child: Transform(
                  transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                  child: Image.asset(
                    "assets/images/landing.jpeg",
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),

          // Foreground content
          Center(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.45),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _centerController, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 12.h, left: 5.w, right: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo + title
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/appLogo.png",
                            height: 55,
                            width: 55,
                          ),
                          SizedBox(width: 3.5.w),
                          Text(
                            "ECOVENTURE",
                            style: AppTextStyles.heading28Bold,
                          ),
                        ],
                      ),
                    ),

                    FadeTransition(
                      opacity: _logoOpacity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8, left: 15.w, bottom: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Adventure into Nature, Learn with Fun!",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body16RegularForestGreen,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FadeTransition(
                          opacity: _parentOpacity,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: CustomElevatedButton(
                              onPressed: () {
                                context.goNamed('login', extra: "parent");
                              },
                              text: "Parent",
                              textStyle: AppTextStyles.body16RegularPureWhite,
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _childOpacity,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: CustomElevatedButton(
                              text: "Child",
                              textStyle: AppTextStyles.body16RegularPureWhite,
                              onPressed: () {
                                context.goNamed('login', extra: "child");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    FadeTransition(
                      opacity: _teacherOpacity,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: CustomElevatedButton(
                          text: "Teacher",
                          onPressed: () {
                            context.goNamed('login', extra: "teacher");
                          },
                          textStyle: AppTextStyles.body16RegularPureWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
