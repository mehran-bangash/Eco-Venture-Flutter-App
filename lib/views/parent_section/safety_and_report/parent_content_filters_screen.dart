import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class ParentContentFiltersScreen extends StatefulWidget {
  const ParentContentFiltersScreen({super.key});

  @override
  State<ParentContentFiltersScreen> createState() => _ParentContentFiltersScreenState();
}

class _ParentContentFiltersScreenState extends State<ParentContentFiltersScreen> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF1E88E5);
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF263238);
  final Color _textGrey = const Color(0xFF78909C);

  // --- FILTER STATE ---
  // Default values (Mock)
  bool _blockScaryContent = true;
  bool _blockSocialInteraction = true;
  bool _educationalOnlyMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Content Filters & Moderation",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            // --- FILTERS LIST ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(height: 2.h),

                  // 1. Scary Content
                  _buildFilterTile(
                    title: "Scary Content",
                    subtitle: "Filters out frightening or suspenseful scenes.",
                    icon: Icons.visibility_off_rounded,
                    color: Colors.purple,
                    value: _blockScaryContent,
                    onChanged: (val) => setState(() => _blockScaryContent = val),
                  ),
                  SizedBox(height: 2.5.h),

                  // 2. Social Interaction
                  _buildFilterTile(
                    title: "Social Interaction",
                    subtitle: "Restricts chat or friend requests from others.",
                    // FIX: Replaced undefined icon with a standard alternative
                    icon: Icons.speaker_notes_off_rounded,
                    color: Colors.orange,
                    value: _blockSocialInteraction,
                    onChanged: (val) => setState(() => _blockSocialInteraction = val),
                  ),
                  SizedBox(height: 2.5.h),

                  // 3. Educational-Only Mode
                  _buildFilterTile(
                    title: "Educational-Only Mode",
                    subtitle: "Limits gameplay to core learning modules.",
                    icon: Icons.school_rounded,
                    color: Colors.blue,
                    value: _educationalOnlyMode,
                    onChanged: (val) => setState(() => _educationalOnlyMode = val),
                  ),
                ],
              ),
            ),

            // --- SAVE BUTTON ---
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 7.5.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Connect to ViewModel to save preferences
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Filters Updated!"), backgroundColor: Colors.green)
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 5,
                  shadowColor: _primary.withOpacity(0.4),
                ),
                child: Text(
                  "Save Filters",
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 4.w),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: _textGrey,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade200,
              trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}