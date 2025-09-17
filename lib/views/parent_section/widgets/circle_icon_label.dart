import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class CircleIconLabel extends StatelessWidget {
  final IconData icon;
  final String labelText;
  const CircleIconLabel({
    super.key, required this.icon, required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w / 2),
          ),
          child: Center(child: Icon(icon, size: 10.w, color: Colors.black)),
        ),
        SizedBox(height: 1.h),
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
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
