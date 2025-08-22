import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:eco_venture/core/constants/app_text_styles.dart';
import 'package:eco_venture/core/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _bgController;
  late final AnimationController _centerController;
  late final AnimationController _pulseController;

  // Slides
  late final Animation<Offset> _bgSlide;
  late final Animation<Offset> _centerSlide;

  // Opacities
  late final Animation<double> _logoOpacity;
  late final Animation<double> _parentOpacity;
  late final Animation<double> _childOpacity;
  late final Animation<double> _teacherOpacity;

  // Pulsing (scale)
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Background (slow)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Foreground entry (faster)
    _centerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Pulse (will start AFTER entry completes)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Slides
    _bgSlide = Tween<Offset>(
      begin: const Offset(0, -0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOut),
    );

    _centerSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _centerController, curve: Curves.easeOut),
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
    _bgController.forward();
    _centerController.forward();

    // When entry finishes, start pulsing
    _centerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _centerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image slide
          SlideTransition(
            position: _bgSlide,
            child: Image.asset(
              "assets/images/landing.jpeg",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),

          // Foreground content slide
          Center(
            child: SlideTransition(
              position: _centerSlide,
              child: Padding(
                padding:  EdgeInsets.only(top: 12.h, left: 5.w, right: 5.w),
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
                        padding:  EdgeInsets.only(
                            top: 8, left: 15.w, bottom: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Adventure into Nature, Learn with Fun!",
                            textAlign: TextAlign.center,
                            style:AppTextStyles.body16RegularForestGreen,
                          ),
                        ),
                      ),
                    ),

                     SizedBox(height: 10.h),

                    // Buttons: Parent + Child
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FadeTransition(
                          opacity: _parentOpacity,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: CustomElevatedButton(
                              text: "Parent",
                              textStyle: AppTextStyles.body16RegularPureWhite,),
                          ),
                        ),
                        FadeTransition(
                          opacity: _childOpacity,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: CustomElevatedButton(
                              text: "Child",
                              textStyle: AppTextStyles.body16RegularPureWhite,),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Button: Teacher
                    FadeTransition(
                      opacity: _teacherOpacity,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: CustomElevatedButton(
                          text: "Teacher",
                          textStyle: AppTextStyles.body16RegularPureWhite,),
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