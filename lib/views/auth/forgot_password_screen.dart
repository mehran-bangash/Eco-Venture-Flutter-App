import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:eco_venture/core/constants/app_text_styles.dart';
import 'package:eco_venture/core/utils/validators.dart';
import 'package:eco_venture/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _headerAnim;
  late Animation<double> _cardAnim;
  late Animation<double> _cardChildAnim;
  late Animation<double> _fieldAnim;
  late Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Sequence of animations
    _headerAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _cardAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    );

    _cardChildAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.65, curve: Curves.easeIn),
    );

    _fieldAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.8, curve: Curves.easeOut),
    );

    _buttonAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  final _formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              /// 1. Header
              FadeTransition(
                opacity: _headerAnim,
                child: _buildHeaderSection(),
              ),
              SizedBox(height: 3.h),

              /// 2. Card
              FadeTransition(
                opacity: _cardAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_cardAnim),
                  child: _buildCardSectionAnimated(),
                ),
              ),
              SizedBox(height: 2.h),

              /// 3. AuthTextField
              FadeTransition(
                opacity: _fieldAnim,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: AuthTextField(
                    customFieldWidth: 90.w,
                    showPrefixIcon: Icons.email_outlined,
                    showText: "Email",
                    hintTitle: "Enter registered email",
                    controller: _emailController,
                    validator: Validators.email,
                    keyBoardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              Consumer(
                builder: (context, ref, child) {
                  final forgotState = ref.watch(authViewModelProvider);
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_formkey.currentState!.validate()) {
                            await ref.read(authViewModelProvider.notifier).forgotPassword(
                              _emailController.text.trim(),
                              onSuccess: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Reset link successfully sent to your Gmail"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          }
                        },

                        child: FadeTransition(
                          opacity: _buttonAnim,
                          child: _buildResendButton(),
                        ),
                      ),
                      //  Error message here
                      if (forgotState.emailError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            forgotState.emailError!,
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
            ],
          ),
        ),

        /// 4. Resend Link Button
      ),
    );
  }

  // --- Resend Button ---
  Widget _buildResendButton() {
    return Consumer(builder: (context, ref, child) {
      final sendLinkState=ref.watch(authViewModelProvider);
      return Material(
        elevation: 5,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
          height: 5.5.h,
          width: 90.w,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            gradient: LinearGradient(
              colors: [Color(0xFF8092E9), Color(0xFF4B41DA)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:sendLinkState.isEmailLoading? [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              "sending link...",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),)]:[
              Icon(
                Icons.mark_email_unread_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                "Resend Link",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    },);
  }

  // --- Card with child animations ---
  Widget _buildCardSectionAnimated() {
    return Container(
      height: 17.h,
      width: 88.w,
      decoration: BoxDecoration(
        color: AppColors.blueGrey.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon (fast appear)
          FadeTransition(
            opacity: _cardChildAnim,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h, left: 3.5.w),
              child: Container(
                height: 6.h,
                width: 14.w,
                decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.amber.withValues(alpha: 0.9),
                  size: 8.w,
                ),
              ),
            ),
          ),

          /// Texts (appear smoothly one by one)
          Flexible(
            child: FadeTransition(
              opacity: _cardChildAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.8.h, left: 4.w),
                    child: Text(
                      "Check Your Inbox",
                      style: AppTextStyles.body16RegularW700PureBlack,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.1.h, left: 4.w),
                    child: Text(
                      "We have sent you a reset link. Check your inbox first. If it’s not there, peek in spam before trying again.",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.pureBlack.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 22.h,
      width: 100.w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8092E9), Color(0xFF8092E9), Color(0xFF4B41DA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 3.5.w),
            child: Container(
              height: 6.h,
              width: 14.w,
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.pureWhite,
                size: 8.w,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Forgot Password",
                  style: AppTextStyles.body22RegularPureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
