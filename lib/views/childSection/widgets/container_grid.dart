import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ContainerGrid extends StatelessWidget {
  final List<Map<String, String>> items = [
    {"title": "QR Based Treasure hunt", "image": "assets/images/QR-Based.jpeg"},
    {"title": "STEM Challenges", "image": "assets/images/STEM.jpeg"},
    {"title": "Interactive Quiz  Module", "image": "assets/images/quiz.jpeg"},
    {"title": "Nature Photo journal", "image": "assets/images/photo-journal.jpeg"},
    {"title": "Multimedia Content", "image": "assets/images/multimedia.jpeg"},
  ];

   ContainerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3.w,right: 3.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 containers per row
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 1, // adjust height/width ratio
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: SizedBox(
                        width: 20.w,
                        child: Image.asset(
                          item["image"]!,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Text(
                        item["title"]!,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
