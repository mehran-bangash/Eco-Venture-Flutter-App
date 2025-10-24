import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? selectedOption;
  final TextEditingController _detailsController = TextEditingController();
  bool immediateAttention = false;

  final List<String> reportOptions = [
    "Inappropriate Content",
    "Bullying or Harassment",
    "Technical Problem",
    "Wrong Answer in Quiz",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.goNamed('bottomNavChild'),
        ),
        title: Text(
          "Report an Issue",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Select reason
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What would you like to report?",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  ...reportOptions.map((option) => Padding(
                    padding: EdgeInsets.only(bottom: 0.8.h),
                    child: RadioListTile<String>(
                      value: option,
                      groupValue: selectedOption,
                      onChanged: (value) =>
                          setState(() => selectedOption = value),
                      activeColor: const Color(0xFF1565C0),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 2.w),
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Section 2: Details
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tell us more",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _detailsController,
                    maxLines: 5,
                    maxLength: 500,
                    cursorColor: const Color(0xFF1565C0),
                    style: GoogleFonts.poppins(fontSize: 16.sp),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      hintText: "Provide more details about the issue...",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 16.sp,
                      ),
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1565C0),
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Section 3: Screenshot
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attach Screenshot (optional)",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  const DottedBorderBox(),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),

            // Immediate checkbox
            Row(
              children: [
                Checkbox(
                  value: immediateAttention,
                  activeColor: const Color(0xFF1565C0),
                  onChanged: (val) =>
                      setState(() => immediateAttention = val!),
                ),
                Expanded(
                  child: Text(
                    "This needs immediate attention",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Footer note
            Center(
              child: Text(
                "Your report is anonymous and will be reviewed within 24 hours.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () {
                  // Submit action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedOption == null
                      ? Colors.grey.shade300
                      : const Color(0xFF1565C0),
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Submit Report",
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}

// --- Custom Upload Box ---
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 1.3,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                color: Color(0xFF1565C0)),
            SizedBox(width: 2.w),
            Text(
              "Add Screenshot",
              style: GoogleFonts.poppins(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
