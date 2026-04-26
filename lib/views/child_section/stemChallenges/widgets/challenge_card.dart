import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String difficulty;
  final int rewardPoints;
  final VoidCallback onTap;
  final Color themeColor;

  // Status Parameters
  final String? statusText;
  final Color? statusColor;
  
  // High-Depth Separation
  final bool isTeacher;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.difficulty,
    required this.rewardPoints,
    required this.onTap,
    required this.themeColor,
    this.statusText,
    this.statusColor,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imageUrl.startsWith('http');
    final Color primaryDark = const Color(0xFF0F172A);
    final Color subText = const Color(0xFF64748B);
    
    // High-Depth Colors
    final Color glowColor = isTeacher ? Colors.amber : Colors.blue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          // 3.B: High-Depth Borders (2.0 width, 30% opacity)
          border: Border.all(
            color: themeColor.withOpacity(0.3),
            width: 2.0,
          ),
          // 3.B: Dual-Shadow System
          boxShadow: [
            // Shadow 1: Deep & Soft
            BoxShadow(
              color: themeColor.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            // Shadow 2: Tight & Dark
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // 3.C: Inner Glow Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomRight,
                      radius: 1.5,
                      colors: [
                        glowColor.withOpacity(0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.05),
                          ),
                          child: isNetworkImage
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(themeColor),
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(themeColor),
                                ),
                        ),
                        
                        // 3.C: Source Badge (Global vs Classroom)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                            decoration: BoxDecoration(
                              color: (isTeacher ? Colors.amber : Colors.blue).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                Icon(isTeacher ? Icons.school_rounded : Icons.public_rounded, 
                                  color: Colors.white, size: 12.sp),
                                SizedBox(width: 1.w),
                                Text(
                                  isTeacher ? "CLASSROOM" : "GLOBAL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Status Badge
                        if (statusText != null && statusText!.isNotEmpty)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: statusColor ?? Colors.orange,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                              ),
                              child: Text(
                                statusText!,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content Section
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: primaryDark,
                              height: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              _buildSmallBadge(difficulty, themeColor.withOpacity(0.1), themeColor),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade600, size: 14.sp),
                                  SizedBox(width: 1.w),
                                  Text(
                                    "$rewardPoints",
                                    style: GoogleFonts.poppins(
                                      color: primaryDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Center(
      child: Icon(Icons.science_rounded, color: color.withOpacity(0.3), size: 30.sp),
    );
  }

  Widget _buildSmallBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
