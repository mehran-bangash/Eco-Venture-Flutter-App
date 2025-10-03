import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NaturePhotoChatbotScreen extends StatefulWidget {
  const NaturePhotoChatbotScreen({super.key});

  @override
  State<NaturePhotoChatbotScreen> createState() => _NaturePhotoChatbotScreenState();
}

class _NaturePhotoChatbotScreenState extends State<NaturePhotoChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7CC), // Light peach background
      body: SafeArea(
        child: Column(
          children: [

            Container(
              width: 100.w,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF69C5C6), // teal header background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   GestureDetector(
                     onTap: () {
                       Navigator.pop(context);
                     },
                       child: Icon(Icons.arrow_back_ios)),
                  Text(
                    "AI Chatbot",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  // 🤖 Robot Icon
                  Icon(Icons.android, size: 5.h, color: Colors.black),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // 🔹 Chat bubble from AI
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    "Hi Ali ! Want to learn about the Butterfly today ?",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // 🔹 User response button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 1.5.h),
                  ),
                  child: Text(
                    "Yes",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 🔹 Message input field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.black54, size: 3.h),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message ....",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.emoji_emotions_outlined,
                        color: Colors.black54, size: 3.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
