import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../models/qr_hunt_read_model.dart';
import '../../../viewmodels/child_view_model/qr_hunt/child_qr_hunt_provider.dart';

class QrHuntPlayScreen extends ConsumerStatefulWidget {
  final QrHuntReadModel hunt;
  const QrHuntPlayScreen({super.key, required this.hunt});

  @override
  ConsumerState<QrHuntPlayScreen> createState() => _QrHuntPlayScreenState();
}

class _QrHuntPlayScreenState extends ConsumerState<QrHuntPlayScreen> {
  final Color _bgDark = const Color(0xFF0F2027);
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Logic: Connects UI to ViewModel for Bilingual Audio
  Future<void> _handleSpeech(String text, String lang) async {
    final notifier = ref.read(childQrHuntViewModelProvider.notifier);

    // 1. Get audio from ViewModel
    // (Returns bytes for Gemini, or null for Free Service playback)
    final audioBytes = await notifier.getClueAudio(text, lang);

    // 2. Only play if we received bytes (Gemini mode)
    // Removed the 'else' block that showed the "unavailable" message
    if (audioBytes != null) {
      await _audioPlayer.play(BytesSource(audioBytes));
    }
  }

  void _showLanguageSelector(String clueText) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: const BoxDecoration(
          color: Color(0xFF1B2559),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Listen to Clue",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 3.h),
            _buildLangOption("English", Icons.language, Colors.blue, clueText),
            SizedBox(height: 2.h),
            _buildLangOption("Urdu", Icons.translate, Colors.green, clueText),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(
    String label,
    IconData icon,
    Color color,
    String text,
  ) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _handleSpeech(text, label);
      },
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white24),
      tileColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQrHuntViewModelProvider);
    final progress = state.progressMap[widget.hunt.id];
    final int currentStep = progress?.currentClueIndex ?? 0;
    final bool isComplete = progress?.isCompleted ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('treasureHunt');
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(
                    isComplete,
                    currentStep,
                    widget.hunt.clues.length,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      itemCount: widget.hunt.clues.length,
                      itemBuilder: (context, index) {
                        bool isFound = index < currentStep;
                        bool isActive = index == currentStep && !isComplete;
                        return _buildClueTile(
                          state.isSpeaking,
                          index,
                          widget.hunt.clues[index],
                          isFound,
                          isActive,
                          index > currentStep,
                        );
                      },
                    ),
                  ),
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

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isComplete, int current, int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
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
          _buildProgressCircle(current, total, isComplete),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(int current, int total, bool isComplete) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: (total == 0) ? 0 : current / total,
          backgroundColor: Colors.white10,
          color: isComplete ? Colors.green : Colors.orange,
        ),
        Text(
          "${((current / (total == 0 ? 1 : total)) * 100).toInt()}%",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildClueTile(
    bool isGlobalSpeaking,
    int index,
    String clueText,
    bool isFound,
    bool isActive,
    bool isLocked,
  ) {
    Color cardColor = isFound
        ? Colors.green.withOpacity(0.1)
        : (isActive
              ? Colors.deepPurple.withOpacity(0.2)
              : Colors.white.withOpacity(0.05));
    Color borderColor = isFound
        ? Colors.green.withOpacity(0.3)
        : (isActive ? Colors.amber : Colors.transparent);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 0.5),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 15)]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            _buildStepNumber(index),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildClueContent(
                clueText,
                isFound,
                isActive,
                isLocked,
                isFound
                    ? Colors.green
                    : (isActive ? Colors.amber : Colors.grey),
              ),
            ),
            if (isActive)
              isGlobalSpeaking
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.amber,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () => _showLanguageSelector(clueText),
                    )
            else
              Icon(
                isFound ? Icons.check_circle : Icons.lock,
                color: isFound ? Colors.green : Colors.grey,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNumber(int index) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
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
    );
  }

  Widget _buildClueContent(
    String text,
    bool isFound,
    bool isActive,
    bool isLocked,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFound ? "Solved" : (isActive ? "Current Clue" : "Locked"),
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: statusColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 0.5.h),
        isLocked
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Text(
                  "Hidden clue text...",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 14.sp,
                  ),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton.icon(
        onPressed: () =>
            context.pushNamed('qrScannerScreen', extra: widget.hunt),
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
          backgroundColor: const Color(0xFF00E676),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
        ),
      ),
    );
  }
}
