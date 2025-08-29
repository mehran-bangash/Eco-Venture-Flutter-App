import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppTextStyles {
  static TextStyle heading28Bold = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.pureBlack,
  );

  static TextStyle body16RegularPureWhite = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.pureWhite
  );
  static TextStyle body25RegularPureWhite = GoogleFonts.poppins(
    fontSize: 25.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle body22RegularPureWhite = GoogleFonts.poppins(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle body16RegularPureBlack = GoogleFonts.poppins(
    fontSize: 16.sp,
    color: AppColors.pureBlack,
    fontWeight: FontWeight.normal,
  );
  static TextStyle body16RegularW700PureBlack = GoogleFonts.poppins(
    fontSize: 16.sp,
    color: AppColors.pureBlack,
    fontWeight: FontWeight.w700,
  );
  static TextStyle body16RegularIndigo = GoogleFonts.poppins(
    fontSize: 16.sp,
    color: AppColors.indigo,
    fontWeight: FontWeight.w600,
  );
  static TextStyle body15RegularPureBlackW600 = GoogleFonts.poppins(
    fontSize: 15.sp,
    color: AppColors.pureBlack,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body16RegularForestGreen = GoogleFonts.poppins(
      color: AppColors.forestGreen,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic
  );

  static TextStyle subtitle14MediumBlack = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.pureBlack,
  );
  static TextStyle subtitle14MediumBlackOpacity1 = GoogleFonts.poppins(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.pureBlack.withValues(alpha: 1),
  );
}
