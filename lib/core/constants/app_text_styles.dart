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
  static TextStyle body16RegularPureBlack = GoogleFonts.poppins(
    fontSize: 16.sp,
    color: AppColors.pureBlack,
    fontWeight: FontWeight.normal,
  );

  static TextStyle body16RegularForestGreen = GoogleFonts.poppins(
      color: AppColors.forestGreen,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic
  );

  static TextStyle subtitle14Medium = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
}
