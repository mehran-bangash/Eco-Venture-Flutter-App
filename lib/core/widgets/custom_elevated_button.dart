import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../constants/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:backgroundColor?? AppColors.indigo.withValues(alpha: 0.8),
        foregroundColor:foregroundColor?? Colors.white,     //  Text/icon color
        minimumSize: Size(
          (width ?? 38).w,  // 150 → around 40.w
          (height ?? 5).h,   // 50 → around 6.h
        ),
        // Control button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius?? 20), // Rounded corners
        ),
        elevation: 5, //
      ),
      child: Text(text,style: textStyle??TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700
      ),),
    );

  }
}
