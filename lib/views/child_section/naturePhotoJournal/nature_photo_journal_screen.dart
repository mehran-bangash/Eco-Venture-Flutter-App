import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class NaturePhotoJournalScreen extends StatefulWidget {
  const NaturePhotoJournalScreen({super.key});

  @override
  State<NaturePhotoJournalScreen> createState() => _NaturePhotoJournalScreenState();
}

class _NaturePhotoJournalScreenState extends State<NaturePhotoJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.goNamed('bottomNavChild');
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 1.w),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
        ),
      ),
      body: Center(child: Text("NaturePhotoJournal coming soon"),),
    );
  }
}
