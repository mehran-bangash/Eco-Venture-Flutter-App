import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../models/qr_hunt_read_model.dart';
import '../../../viewmodels/child_view_model/qr_hunt/child_qr_hunt_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  final QrHuntReadModel hunt;

  const QRScannerScreen({super.key, required this.hunt});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, // Prevents ultra-fast duplicate scans
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isCoolingDown = false; // FIX: Cooldown flag

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // Block if already processing OR in cooldown period (e.g. just showed error)
    if (_isProcessing || _isCoolingDown) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    // Validate
    await ref.read(childQrHuntViewModelProvider.notifier).validateScan(barcode.rawValue!, widget.hunt);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childQrHuntViewModelProvider);

    ref.listen(childQrHuntViewModelProvider, (prev, next) {
      // Success Case
      if (next.scanSuccess) {
        _controller.stop();
        ref.read(childQrHuntViewModelProvider.notifier).resetFlags();
        if (mounted) context.replaceNamed('qrSuccessScreen', extra: 10);
      }

      // Error Case (Wrong Code)
      if (next.errorMessage != null && !_isCoolingDown) {
        // 1. Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2)
            )
        );

        // 2. Start Cooldown
        setState(() {
          _isCoolingDown = true; // Block new scans
          _isProcessing = false; // Reset processing
        });

        // 3. Clear Error from State immediately so we don't loop
        ref.read(childQrHuntViewModelProvider.notifier).resetFlags();

        // 4. Unlock after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _isCoolingDown = false);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E15),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              fit: BoxFit.cover,
            ),

            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
              child: Container(),
            ),

            // Scan Frame
            Container(
              width: 70.w, height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  // Visual Feedback: Turn RED if cooling down (Error state)
                    color: _isCoolingDown ? Colors.red : Colors.deepPurpleAccent.withOpacity(0.8),
                    width: 4
                ),
                boxShadow: [
                  BoxShadow(
                      color: _isCoolingDown ? Colors.red.withOpacity(0.4) : Colors.deepPurpleAccent.withOpacity(0.6),
                      blurRadius: 18
                  )
                ],
              ),
            ),

            Positioned(
              top: 4.h,
              child: Text(
                  _isCoolingDown ? "Wrong Code... Wait" : "Scan the Clue Code",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp)
              ),
            ),

            if (_isProcessing && !_isCoolingDown)
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            Positioned(
              bottom: 4.h,
              child: ElevatedButton.icon(
                onPressed: () => _controller.toggleTorch(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h)),
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: Text("Flash", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.sp)),
              ),
            ),

            Positioned(
              top: 2.h, left: 4.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => context.pop(),
              ),
            )
          ],
        ),
      ),
    );
  }
}