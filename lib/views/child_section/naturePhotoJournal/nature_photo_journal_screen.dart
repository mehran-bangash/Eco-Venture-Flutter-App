import 'dart:ui';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NaturePhotoJournalScreen extends StatefulWidget {
  const NaturePhotoJournalScreen({super.key});

  @override
  State<NaturePhotoJournalScreen> createState() =>
      _NaturePhotoJournalScreenState();
}

class _NaturePhotoJournalScreenState extends State<NaturePhotoJournalScreen> {
  final List<Map<String, dynamic>> _journalEntries = [
    {
      "title": "A Butterfly on a Flower",
      "date": "20 Aug",
      "image": "assets/images/rabbit.jpeg",
    },
    {
      "title": "Sunset in the Valley",
      "date": "21 Aug",
      "image": "assets/images/rabbit.jpeg",
    },
    {
      "title": "Morning Dew on Leaves",
      "date": "22 Aug",
      "image": "assets/images/rabbit.jpeg",
    },
  ];

  void _deleteEntry(int index) {
    setState(() {
      _journalEntries.removeAt(index);
    });

    Utils.showDelightToast(
      context,
      "Entry deleted successfully!",
      duration: const Duration(seconds: 2),
      iconColor: Colors.white,
      bgColor: Colors.redAccent,
      icon: Icons.delete_outline,
      position: DelightSnackbarPosition.bottom,
      textColor: Colors.white,
      autoDismiss: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  Glassy dark-teal theme background (matches VideoScreen)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Nature Photo Journal",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => context.goNamed('bottomNavChild'),
          child: Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D324D),
              Color(0xFF2F5755),
              Color(0xFF1E3C40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.h),
            itemCount: _journalEntries.length + 1, // +1 for Add button
            itemBuilder: (context, index) {
              if (index == _journalEntries.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.goNamed("addEntryScreen"),
                      child: Container(
                        height: 7.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2F8F83)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "➕ Add New Entry",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final entry = _journalEntries[index];

              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                  const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                onDismissed: (_) => _deleteEntry(index),
                child: GestureDetector(
                  onTap: () => context.goNamed('natureDescriptionScreen'),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              //  Image Section
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  entry["image"],
                                  height: 22.h,
                                  width: 35.w,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              //  Text Section
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.5.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        entry["title"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        entry["date"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: const [
                                          Icon(Icons.star_rounded,
                                              color: Colors.amberAccent,
                                              size: 20),
                                          Icon(Icons.star_rounded,
                                              color: Colors.amberAccent,
                                              size: 20),
                                          Icon(Icons.star_rounded,
                                              color: Colors.amberAccent,
                                              size: 20),
                                          Icon(Icons.star_half_rounded,
                                              color: Colors.amberAccent,
                                              size: 20),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
