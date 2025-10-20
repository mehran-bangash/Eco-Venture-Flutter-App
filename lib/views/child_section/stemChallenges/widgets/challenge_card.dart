import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String difficulty;
  final int rewardPoints;
  final VoidCallback? onTap;

  /// Custom gradient to match each screen’s theme (Science, Math, etc.)
  final List<Color> backgroundGradient;

  /// Optional — customize Start button gradient
  final List<Color>? buttonGradient;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.difficulty,
    required this.rewardPoints,
    required this.backgroundGradient,
    this.buttonGradient,
    this.onTap,
  });

  Color _difficultyColor(String level) {
    switch (level.toLowerCase()) {
      case "easy":
        return const Color(0xFF5CE1E6);
      case "medium":
        return const Color(0xFFFFC857);
      case "hard":
        return const Color(0xFFFF6B6B);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(difficulty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: diffColor.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: -3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖼️ IMAGE SECTION
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    imageUrl,
                    height: 12.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 4.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📜 CONTENT SECTION
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.8.h),

                  // 🧠 Difficulty Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: diffColor, width: 1.2),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: diffColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // 💎 Points + Start Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.diamond,
                              color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 1.w),
                          Text(
                            "$rewardPoints",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: buttonGradient ??
                                  const [
                                    Color(0xFF00F5A0),
                                    Color(0xFF00D9F5),
                                  ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            "Start",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
