import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/qr_hunt_read_model.dart';
import '../../../viewmodels/child_view_model/qr_hunt/child_qr_hunt_provider.dart';

class QrHuntPlayScreen extends ConsumerStatefulWidget {
  // We need the static hunt data to know what clues to show
  final QrHuntReadModel hunt;

  const QrHuntPlayScreen({super.key, required this.hunt});

  @override
  ConsumerState<QrHuntPlayScreen> createState() => _QrHuntPlayScreenState();
}

class _QrHuntPlayScreenState extends ConsumerState<QrHuntPlayScreen> {
  // --- COLORS ---
  final Color _bgDark = const Color(0xFF0F2027); // Deep background

  @override
  Widget build(BuildContext context) {
    // 1. Watch Real-Time Progress
    final state = ref.watch(childQrHuntViewModelProvider);

    // Find progress for THIS specific hunt
    final QrHuntProgressModel? progress = state.progressMap[widget.hunt.id];

    // Default to 0 if not started yet
    final int currentStep = progress?.currentClueIndex ?? 0;
    final bool isComplete = progress?.isCompleted ?? false;

    return PopScope(
       canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('treasureHunt');
        }
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // --- HEADER ---
                  _buildHeader(isComplete, currentStep, widget.hunt.clues.length),

                  // --- CLUES LIST ---
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      itemCount: widget.hunt.clues.length,
                      itemBuilder: (context, index) {
                        // Determine State of this specific clue
                        bool isFound = index < currentStep;
                        bool isActive = index == currentStep && !isComplete;
                        bool isLocked = index > currentStep;

                        return _buildClueTile(
                          index: index,
                          clueText: widget.hunt.clues[index],
                          isFound: isFound,
                          isActive: isActive,
                          isLocked: isLocked,
                        );
                      },
                    ),
                  ),

                  // --- ACTION BUTTON (Only if active) ---
                  if (!isComplete)
                    Padding(
                      padding: EdgeInsets.all(5.w),
                      child: _buildScanButton(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(bool isComplete, int current, int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                isComplete ? "Quest Complete!" : "Find Clue ${current + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                isComplete
                    ? "All treasures found"
                    : "$current / $total Clues Solved",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          // Progress Circle
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: total == 0 ? 0 : current / total,
                backgroundColor: Colors.white10,
                color: isComplete ? Colors.green : Colors.orange,
              ),
              Text(
                "${((current / total) * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClueTile({
    required int index,
    required String clueText,
    required bool isFound,
    required bool isActive,
    required bool isLocked,
  }) {
    Color cardColor = Colors.white.withValues(alpha: 0.05);
    Color borderColor = Colors.transparent;
    IconData statusIcon = Icons.lock;
    Color iconColor = Colors.grey;

    if (isFound) {
      cardColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green.withValues(alpha: 0.3);
      statusIcon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isActive) {
      cardColor = Colors.deepPurple.withValues(alpha: 0.2);
      borderColor = Colors.amber; // Highlight active
      statusIcon = Icons.location_on;
      iconColor = Colors.amber;
    } else if (isLocked) {
// Blur text for locked clues
    }

    return GestureDetector(
      onTap: () {
        if (isActive) {
          // If clicked active card, go to scanner
          _goToScanner();
        } else if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Solve previous clues first!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isActive ? 1.5 : 0.5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 15,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Step Number
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Clue Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFound
                              ? "Solved"
                              : (isActive ? "Current Clue" : "Locked"),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        isLocked
                            ? ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 4,
                                  sigmaY: 4,
                                ),
                                child: Text(
                                  "Hidden clue text...",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              )
                            : Text(
                                clueText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ],
                    ),
                  ),

                  // Status Icon
                  Icon(statusIcon, color: iconColor, size: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton.icon(
        onPressed: _goToScanner,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
        label: Text(
          "Scan to Solve",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676), // Neon Green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          shadowColor: Colors.greenAccent.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  void _goToScanner() {
    // Navigate to QR Scanner Screen
    // Pass the Hunt Model so the scanner knows what to validate against
    context.pushNamed('qrScannerScreen', extra: widget.hunt);
  }
}
