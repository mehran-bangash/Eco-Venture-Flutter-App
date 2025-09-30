import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:eco_venture/core/constants/app_text_styles.dart';
import 'package:eco_venture/core/utils/validators.dart';
import 'package:eco_venture/core/widgets/auth_text_field.dart';
import 'package:eco_venture/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class LoginScreen extends ConsumerStatefulWidget {
  final String? selectRole;
  const LoginScreen({super.key, this.selectRole});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _cardContentController; //  NEW

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<Offset> _formSlideAnimation;

  //  NEW: list of animations for card contents
  late List<Animation<double>> _cardItemAnimations;
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    //  NEW controller for inside card staggered animation
    _cardContentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _formController, curve: Curves.easeOutBack),
        );

    //  Staggered animations for card children (9 items as example)
    int cardChildrenCount = 10; // update if you add/remove widgets

    _cardItemAnimations = List.generate(cardChildrenCount, (index) {
      final start = index * 0.1;
      final end = (start + 0.4).clamp(
        0.0,
        1.0,
      ); // <-- clamp makes sure end <= 1.0
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _cardContentController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _formController.forward();

    //  When slideController (card) finishes, animate card contents
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cardContentController.forward();
      }
    });
  }

  final _formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _cardContentController.dispose(); //  dispose new controller
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8092E9), Color(0xFF8092E9), Color(0xFF4B41DA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Scrollable Column with logo + card
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // important!
                      children: [
                        _buildLogoSection(),
                        SizedBox(height: 3.h),
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                FadeTransition(
                                  opacity: _cardItemAnimations[1],
                                  child: Center(
                                    child: Text(
                                      'SIGN IN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.color,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                FadeTransition(
                                  opacity: _cardItemAnimations[2],
                                  child: Center(
                                    child: Text(
                                      'Enter your credentials to access your account',
                                      style: AppTextStyles
                                          .subtitle14MediumBlackOpacity1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                FadeTransition(
                                  opacity: _cardItemAnimations[3],
                                  child: AuthTextField(
                                    showPrefixIcon: Icons.email_outlined,
                                    showText: "Email",
                                    hintTitle: "Enter your Email",
                                    controller: _emailController,
                                    validator: Validators.email,
                                    keyBoardType: TextInputType.emailAddress,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                FadeTransition(
                                  opacity: _cardItemAnimations[4],
                                  child: AuthTextField(
                                    showPrefixIcon: Icons.lock,
                                    showText: "Password",
                                    hintTitle: "Enter your Password",
                                    controller: _passwordController,
                                    validator: Validators.password,
                                    keyBoardType: TextInputType.text,
                                    isPassword: true,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                GestureDetector(
                                  onTap: () {
                                    context.goNamed('forgotPassword');
                                  },
                                  child: FadeTransition(
                                    opacity: _cardItemAnimations[5],
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Forgot Password?",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          color: Color(0xFF667EEA),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final signInState = ref.watch(
                                      authViewModelProvider,
                                    );
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            if (_formkey.currentState!
                                                .validate()) {
                                              await ref
                                                  .read(
                                                    authViewModelProvider
                                                        .notifier,
                                                  )
                                                  .signInUser(
                                                    _emailController.text
                                                        .trim(),
                                                    _passwordController.text
                                                        .trim(),
                                                    onSuccess: () {
                                                      final role = ref
                                                          .read(
                                                            authViewModelProvider,
                                                          )
                                                          .user
                                                          ?.role; // role from backend
                                                      switch (role) {
                                                        case 'child':
                                                          context.goNamed('bottomNavChild');
                                                          break;
                                                        case 'teacher':
                                                          context.goNamed('teacherHome');
                                                          break;
                                                        case 'parent':
                                                          context.goNamed('parentHome');
                                                          break;
                                                      }
                                                    },
                                                  );
                                            }
                                          },
                                          child: FadeTransition(
                                            opacity: _cardItemAnimations[6],
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(16),
                                              ),
                                              child: Container(
                                                height: 5.5.h,
                                                width: 68.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(16),
                                                      ),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF8092E9),
                                                      Color(0xFF4B41DA),
                                                    ],
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children:
                                                      signInState.isSignInLoading
                                                      ? [
                                                          SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                          SizedBox(width: 2.w),
                                                          Text(
                                                            "Login In...",
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ]
                                                      : [
                                                          Icon(
                                                            Icons.login_rounded,
                                                            color: Colors.white,
                                                            size: 20.sp,
                                                          ),
                                                          SizedBox(width: 2.w),
                                                          Text(
                                                            'Sign In',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //error message
                                        if (signInState.signInError != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: Text(
                                              signInState.signInError!,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 1.5.h),
                                FadeTransition(
                                  opacity: _cardItemAnimations[7],
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.pureBlack,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final googleState = ref.watch(
                                      authViewModelProvider,
                                    );
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {

                                            await ref
                                                .read(
                                                  authViewModelProvider
                                                      .notifier,
                                                )
                                                .continueWithGoogle(
                                                  widget.selectRole??"",
                                                  onSuccess: () {
                                                    final role = ref
                                                        .read(
                                                          authViewModelProvider,
                                                        )
                                                        .user
                                                        ?.role; // role from backend
                                                    switch (role) {
                                                      case 'child':
                                                        context.goNamed('bottomNavChild');
                                                        break;
                                                      case 'teacher':
                                                        context.goNamed('teacherHome');
                                                        break;
                                                      case 'parent':
                                                        context.goNamed('parentHome');
                                                        break;
                                                    }
                                                  },
                                                );
                                          },
                                          child: FadeTransition(
                                            opacity: _cardItemAnimations[8],
                                            child: Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(16),
                                              ),
                                              child: Container(
                                                height: 5.5.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(16),
                                                      ),
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children:
                                                      googleState
                                                          .isGoogleLoading
                                                      ? [
                                                          Padding(
                                                            padding:  EdgeInsets.only(left: 15.w),
                                                            child: SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    color: Colors
                                                                        .black,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 2.w),
                                                          Text(
                                                            "connecting ...",
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          ),
                                                        ]
                                                      : [
                                                          Flexible(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    left: 6.w,
                                                                  ),
                                                              child: Image.asset(
                                                                'assets/images/logoGoogle.png',
                                                                height: 4.h,
                                                                width: 8.w,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 7.w),
                                                          Text(
                                                            'Continue with Google',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                            ),
                                                          ),
                                                        ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //error message
                                        if (googleState.googleError != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: Text(
                                              googleState.googleError!,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 3.h),
                                GestureDetector(
                                  onTap: () {
                                    context.goNamed('signup');
                                  },
                                  child: FadeTransition(
                                    opacity: _cardItemAnimations[9],
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: "Don't have an account? ",
                                            ),
                                            TextSpan(
                                              text: 'Sign Up',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF667EEA),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        children: [
          //  Animated Logo (scale + rotation)
          ScaleTransition(
            scale: _logoScale,
            child: RotationTransition(
              turns: _logoRotation,
              child: Container(
                margin: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/appLogo.png',
                    width: 27.w,
                    height: 10.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          //  Fade-in Welcome Text
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "WelCome Back",
              style: AppTextStyles.body25RegularPureWhite,
            ),
          ),
          SizedBox(height: 2.h),

          //  Slide-in Subtitle
          SlideTransition(
            position: _slideAnimation,
            child: Text(
              "Sign in to begin your EcoVenture journey",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
