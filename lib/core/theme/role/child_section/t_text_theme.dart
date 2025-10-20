// custom Text Theme
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TTextTheme {
  TTextTheme._();

  /// Base reusable style helper
  static TextStyle baseStyle(Color color, double size, FontWeight weight) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  //  LIGHT THEME
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: baseStyle(Colors.black, 25.sp, FontWeight.bold),
    headlineMedium: baseStyle(Colors.black, 22.sp, FontWeight.w600),
    headlineSmall: baseStyle(Colors.black, 20.sp, FontWeight.w600),

    titleLarge: baseStyle(Colors.black, 18.sp, FontWeight.w600),
    titleMedium: baseStyle(Colors.black, 16.sp, FontWeight.bold),
    titleSmall: baseStyle(Colors.black, 14.sp, FontWeight.bold),

    bodyLarge: baseStyle(Colors.black54, 16.sp, FontWeight.w500),
    bodyMedium: baseStyle(Colors.black87, 14.sp, FontWeight.w500),
    bodySmall: baseStyle(Colors.black, 12.sp, FontWeight.w400),

    labelLarge: baseStyle(Colors.black, 16.sp, FontWeight.bold),
    labelMedium: baseStyle(Colors.black, 14.sp, FontWeight.bold),
    labelSmall: baseStyle(Colors.black54, 12.sp, FontWeight.w500),
  );

  //  DARK THEME
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: baseStyle(Colors.white, 25.sp, FontWeight.bold),
    headlineMedium: baseStyle(Colors.white, 22.sp, FontWeight.w600),
    headlineSmall: baseStyle(Colors.white, 20.sp, FontWeight.w600),

    titleLarge: baseStyle(Colors.white, 18.sp, FontWeight.w600),
    titleMedium: baseStyle(Colors.white, 16.sp, FontWeight.bold),
    titleSmall: baseStyle(Colors.white, 14.sp, FontWeight.bold),

    bodyLarge: baseStyle(Colors.white70, 16.sp, FontWeight.w500),
    bodyMedium: baseStyle(Colors.white, 14.sp, FontWeight.w500),
    bodySmall: baseStyle(Colors.white70, 12.sp, FontWeight.w400),

    labelLarge: baseStyle(Colors.white, 16.sp, FontWeight.bold),
    labelMedium: baseStyle(Colors.white, 14.sp, FontWeight.bold),
    labelSmall: baseStyle(Colors.white70, 12.sp, FontWeight.w500),
  );
}
