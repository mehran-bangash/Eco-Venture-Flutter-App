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
      "gradient": [Color(0xFFFF5858), Color(0xFFF09819)],
    },
    {
      "title": "A Butterfly on a Flower",
      "date": "20 Aug",
      "image": "assets/images/rabbit.jpeg",
      "gradient": [Color(0xFFFF5858), Color(0xFFF09819)],
    },
    {
      "title": "Sunset in the Valley",
      "date": "21 Aug",
      "image": "assets/images/rabbit.jpeg",
      "gradient": [Color(0xFFC471F5), Color(0xFFFA71CD)],
    },
    {
      "title": "Morning Dew on Leaves",
      "date": "22 Aug",
      "image": "assets/images/rabbit.jpeg",
      "gradient": [Color(0xFF64B3F4), Color(0xFFC2E59C)],
    },
  ];

  void _deleteEntry(int index) {
    setState(() {
      _journalEntries.removeAt(index);
    });
     Utils.showDelightToast(context,
       "Card deleted Successfully!",
       duration: Duration(seconds: 3),
       iconColor: Colors.white,
       bgColor: Colors.green,
       icon: Icons.delete,
       position: DelightSnackbarPosition.bottom,
       textColor: Colors.white,
       autoDismiss: true,
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF50589C),
        centerTitle: true,
        title: Text(
          "Nature Photo Journal",
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            context.goNamed('bottomNavChild');
          },
          child: Padding(
            padding: EdgeInsets.only(left: 1.w),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF0C3483),
              Color(0xFFA2B6DF),
              Color(0xFF6B8CCE),
              Color(0xFFA2B6DF),
            ],
            stops: [0.0, 1.0, 1.0, 1.0],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.only(top: 5.h, bottom: 15.h),
          itemCount: _journalEntries.length + 1, // +1 for button
          itemBuilder: (context, index) {
            if (index == _journalEntries.length) {
              // Add New Entry button (navigates instead of adding locally)
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to new entry screen
                      context.goNamed("addEntryScreen");
                    },
                    child: Container(
                      height: 7.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "➕ Add New Entry",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final entry = _journalEntries[index];

            // Each card wrapped in Dismissible
            return GestureDetector(
                onTap: () {
                  context.goNamed('natureDescriptionScreen');
                },
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                onDismissed: (direction) {
                  _deleteEntry(index);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Container(
                    height: 20.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: entry["gradient"],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(2.w),
                          child: SizedBox(
                            height: 23.h,
                            width: 50.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                entry["image"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 2.w, right: 2.w, top: 2.h),
                                child: Text(
                                  entry["title"],
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 2.w, right: 2.w, top: 0.5.h),
                                child: Text(
                                  entry["date"],
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 2.w, right: 2.w, top: 0.5.h),
                                child: const Icon(Icons.star,
                                    color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
