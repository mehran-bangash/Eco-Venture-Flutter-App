import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/auth/auth_provider.dart';

class TeacherStatusPendingScreen extends ConsumerWidget {
  const TeacherStatusPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8092E9), Color(0xFF4B41DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.hourglass_empty_rounded, color: const Color(0xFF4B41DA), size: 30.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Account Pending",
                  style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Your teacher account is currently under review by our administration. Please check back later.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.white.withOpacity(0.9)),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Logic: Sign out and force navigation to login
                      await ref.read(authViewModelProvider.notifier).signOut();
                      if (context.mounted) {
                        context.goNamed('login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4B41DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("LOGOUT", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}