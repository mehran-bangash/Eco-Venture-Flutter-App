import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ClickableInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ClickableInfoCard({
    super.key, required this.icon, required this.title, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      width: 35.w,
      decoration: BoxDecoration(
          color: Colors.lightBlue.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon,size: 8.w,color: color,),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),

        ],
      ),
    );
  }
}