import 'package:eco_venture/views/childSection/ai_chat_screen.dart';
import 'package:eco_venture/views/childSection/child_home_screen.dart';
import 'package:eco_venture/views/childSection/profile/child_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/childSection/report_safety_screen.dart';

class BottomNavChild extends StatefulWidget {
  const BottomNavChild({super.key});

  @override
  State<BottomNavChild> createState() => _BottomNavChildState();
}

class _BottomNavChildState extends State<BottomNavChild> {
  int _currentIndex = 0;

  final _screens = [
    ChildHomeScreen(),
    AiChatScreen(),
    ReportSafetyScreen(),
    ChildProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD7D7E0),
              Color(0xFFAEBAF5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF0A2540), // deep navy for contrast
          unselectedItemColor: Colors.black.withValues(alpha: 0.7), // subtle gray
          selectedLabelStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.nunito(),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: 'ChatBot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'Safety',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
