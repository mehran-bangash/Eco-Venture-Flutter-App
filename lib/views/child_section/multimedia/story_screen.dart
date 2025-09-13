import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  // For now, hardcoded data. Later, this can be fetched from API.
  final List<Map<String, dynamic>> videos = [
    {
      "title": "The Rabbit and Tortoise",
      "pages": "3 Pages",
      "image": "assets/images/rabbit.jpeg",
      "rating": 4.5,
    },
    {
      "title": "Life of a Butterfly",
      "pages": "4 Pages",
      "image": "assets/images/butterfly.jpg",
      "rating": 4.2,
    },
    {
      "title": "Jungle Sounds",
      "pages": "3 Pages",
      "image": "assets/images/jungle.jpg",
      "rating": 4.7,
    },
    {
      "title": "Plant Life",
      "pages": "3 Pages",
      "image": "assets/images/plant.jpg",
      "rating": 4.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 per row
            crossAxisSpacing: 2.h,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.8, // Controls card height
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFFB5EFFF).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        video["image"],
                        height: 13.h,
                        width: 100.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 13.h,
                            width: 100.w,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                size: 40, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      video["title"],
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  // Duration + Rating
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration
                        Text(
                          video["pages"],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A2540).withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                        ),

                        // Rating Star
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
