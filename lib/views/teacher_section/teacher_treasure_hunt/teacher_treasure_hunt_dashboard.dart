import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
// Import Backend
import '../../../../models/qr_hunt_model.dart';
import '../../../viewmodels/teacher_qr_treasure/teacher_treasure_hunt_provider.dart';


class TeacherTreasureHuntDashboard extends ConsumerStatefulWidget {
  const TeacherTreasureHuntDashboard({super.key});

  @override
  ConsumerState<TeacherTreasureHuntDashboard> createState() => _TeacherTreasureHuntDashboardState();
}

class _TeacherTreasureHuntDashboardState extends ConsumerState<TeacherTreasureHuntDashboard> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF00C853); // Vibrant Green
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  @override
  void initState() {
    super.initState();
    // Fetch Data
    Future.microtask(() {
      ref.read(teacherTreasureHuntViewModelProvider.notifier).loadHunts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherTreasureHuntViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Treasure Hunts",
          style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                style: GoogleFonts.poppins(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: "Search hunts...",
                  hintStyle: GoogleFonts.poppins(color: _textGrey, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: _primary))
                : state.hunts.isEmpty
                ? Center(child: Text("No Treasure Hunts Found", style: GoogleFonts.poppins(color: _textGrey, fontSize: 15.sp)))
                : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              itemCount: state.hunts.length,
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                return _buildHuntCard(state.hunts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('teacherAddTreasureHuntScreen'),
        backgroundColor: _primary,
        elevation: 4,
        icon: Icon(Icons.qr_code_scanner, size: 20.sp),
        label: Text(
            "Create Hunt",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)
        ),
      ),
    );
  }

  Widget _buildHuntCard(QrHuntModel hunt) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.map_rounded, color: _primary, size: 24.sp),
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hunt.title,
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildTag("${hunt.clues.length} Clues", Colors.blue),
                    SizedBox(width: 2.w),
                    _buildTag(hunt.difficulty, Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              InkWell(
                  onTap: () {
                    // Navigate to Edit Screen
                    context.pushNamed('teacherEditTreasureHuntScreen', extra: hunt);
                  },
                  child: Icon(Icons.edit, color: Colors.blue, size: 18.sp)
              ),
              SizedBox(height: 1.5.h),
              InkWell(
                  onTap: () {
                    if (hunt.id != null) {
                      ref.read(teacherTreasureHuntViewModelProvider.notifier).deleteHunt(hunt.id!);
                    }
                  },
                  child: Icon(Icons.delete, color: Colors.red, size: 18.sp)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}