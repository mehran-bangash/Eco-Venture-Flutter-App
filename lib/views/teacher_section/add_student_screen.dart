import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- PRO COLORS ---
  final Color _primary = const Color(0xFF4E54C8); // Matches Home Header
  final Color _accent = const Color(0xFF8F94FB);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);
  final Color _surface = Colors.white;

  Future<void> _registerStudent() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields", style: TextStyle(fontSize: 15.sp)), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Connect to Node.js Backend Logic Later
    await Future.delayed(const Duration(seconds: 2)); // Mock UI delay

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student Added Successfully!", style: TextStyle(fontSize: 15.sp)), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
            "New Student",
            style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp)
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primary, _accent]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 26.sp),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student Registration",
                          style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Add a new learner to your class roster.",
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Form Fields Container
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Full Name"),
                  SizedBox(height: 1.5.h),
                  _buildTextField(controller: _nameController, hint: "e.g. Ali Khan", icon: Icons.badge_outlined),
                  SizedBox(height: 3.h),

                  _buildLabel("Email Address"),
                  SizedBox(height: 1.5.h),
                  _buildTextField(controller: _emailController, hint: "student@school.com", icon: Icons.email_outlined),
                  SizedBox(height: 3.h),

                  _buildLabel("Password"),
                  SizedBox(height: 1.5.h),
                  _buildTextField(controller: _passwordController, hint: "••••••••", icon: Icons.lock_outline, isPassword: true),
                ],
              ),
            ),

            SizedBox(height: 5.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 7.5.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 8,
                  shadowColor: _primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Register Student", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _textDark));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(fontSize: 15.sp, color: _textDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _textGrey, size: 20.sp),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: _textGrey, fontSize: 14.sp),
        filled: true,
        fillColor: _bg,
        contentPadding: EdgeInsets.symmetric(vertical: 2.2.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _primary, width: 1.5)),
      ),
    );
  }
}