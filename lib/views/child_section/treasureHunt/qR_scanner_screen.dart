
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart'; //  important

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isScanned = true);
    await _controller.stop();

    //  Show success dialog safely
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "QR Scanned Successfully!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Code: ${barcode.rawValue}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    //  Use GoRouter navigation (safe, no crash)
    if (confirmed == true && mounted) {
      context.goNamed('qrSuccessScreen',extra: 5); // rewardCoins = 5
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E15),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Live Camera Preview
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              fit: BoxFit.cover,
            ),

            // Dark Overlay
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black45,
                BlendMode.darken,
              ),
              child: Container(),
            ),

            // Scan Frame Glow
            Container(
              width: 70.w,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.8),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            // Title
            Positioned(
              top: 4.h,
              child: Text(
                "Scan the Treasure Clue",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Flash Toggle
            Positioned(
              bottom: 4.h,
              child: ElevatedButton.icon(
                onPressed: () => _controller.toggleTorch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 1.2.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: Text(
                  "Toggle Flash",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
