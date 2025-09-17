import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class RowCircleLabelText extends StatelessWidget {
  final String labelText;
  final IconData icon;
  const RowCircleLabelText({
    super.key, required this.labelText, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w / 2),
          ),
          child: Center(
            child: Icon(icon, size: 5.w, color: Colors.black),
          ),
        ),
        SizedBox(width: 2.w),
        SizedBox(
          width: 22.w,
          child: Text(
            labelText,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
