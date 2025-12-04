import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class ParentScreenTimeScreen extends StatefulWidget {
  const ParentScreenTimeScreen({super.key});

  @override
  State<ParentScreenTimeScreen> createState() => _ParentScreenTimeScreenState();
}

class _ParentScreenTimeScreenState extends State<ParentScreenTimeScreen> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF2196F3); // Blue
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF263238);
  final Color _textGrey = const Color(0xFF78909C);

  // State Variables
  double _dailyLimit = 2.5; // 2.5 Hours
  TimeOfDay _bedtimeStart = const TimeOfDay(hour: 21, minute: 0); // 9:00 PM
  TimeOfDay _bedtimeEnd = const TimeOfDay(hour: 7, minute: 0);   // 7:00 AM

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _bedtimeStart : _bedtimeEnd,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _bedtimeStart = picked;
        } else {
          _bedtimeEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 22.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Screen Time Control",
          style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 19.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: DAILY LIMIT ---
            Text("Daily Limit", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 1.h),
            Text("Set the maximum playtime per day.", style: GoogleFonts.poppins(fontSize: 15.sp, color: _textGrey)),
            SizedBox(height: 2.h),

            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daily Limit", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: _textDark)),
                      Text(_formatHours(_dailyLimit), style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primary)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _primary,
                      inactiveTrackColor: _primary.withOpacity(0.2),
                      thumbColor: Colors.white,
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
                      overlayColor: _primary.withOpacity(0.1),
                    ),
                    child: Slider(
                      value: _dailyLimit,
                      min: 0,
                      max: 6,
                      divisions: 12, // 30 min increments
                      onChanged: (val) => setState(() => _dailyLimit = val),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("0h", style: GoogleFonts.poppins(fontSize: 14.sp, color: _textGrey)),
                        Text("6h", style: GoogleFonts.poppins(fontSize: 14.sp, color: _textGrey)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // --- SECTION 2: BEDTIME ---
            Text("Bedtime", style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 1.h),
            Text("The app will be unavailable during these hours.", style: GoogleFonts.poppins(fontSize: 15.sp, color: _textGrey)),
            SizedBox(height: 2.h),

            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From", style: GoogleFonts.poppins(fontSize: 14.sp, color: _textGrey)),
                        SizedBox(height: 1.h),
                        _buildTimeSelector(_formatTime(_bedtimeStart), () => _selectTime(true)),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("To", style: GoogleFonts.poppins(fontSize: 14.sp, color: _textGrey)),
                        SizedBox(height: 1.h),
                        _buildTimeSelector(_formatTime(_bedtimeEnd), () => _selectTime(false)),
                      ],
                    ),
                  ),
                  // Moon Icon Decoration
                  Positioned(
                    right: 0, top: 0,
                    child: Icon(Icons.nights_stay_rounded, color: Colors.indigo.shade100, size: 26.sp),
                  )
                ],
              ),
            ),

            const Spacer(),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 7.5.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Connect to ViewModel
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings Saved!"), backgroundColor: Colors.green));
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 5,
                  shadowColor: _primary.withOpacity(0.4),
                ),
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _formatHours(double value) {
    int hours = value.floor();
    int minutes = ((value - hours) * 60).round();
    if (minutes == 0) return "${hours}h";
    return "${hours}h ${minutes}m";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  Widget _buildTimeSelector(String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEEF0F2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: _textDark)),
            Icon(Icons.access_time_rounded, color: _textGrey, size: 20.sp),
          ],
        ),
      ),
    );
  }
}