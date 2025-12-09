import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Riverpod


import '../../../viewmodels/child_view_model/report_safety/child_safety_provider.dart';


class ChildReportIssueScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? contentContext;

  const ChildReportIssueScreen({super.key, this.contentContext});

  @override
  ConsumerState<ChildReportIssueScreen> createState() => _ChildReportIssueScreenState();
}

class _ChildReportIssueScreenState extends ConsumerState<ChildReportIssueScreen> {
  String _selectedRecipient = 'Parent';
  String _selectedIssueType = 'Content';
  final TextEditingController _detailsController = TextEditingController();

  File? _screenshot;
  final ImagePicker _picker = ImagePicker();

  final List<String> _recipients = ['Parent', 'Teacher', 'Admin'];
  final List<String> _issueTypes = ['Scary Content', 'Bullying', 'App Bug', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.contentContext != null) {
      _selectedIssueType = 'Scary Content';
    }
  }

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _screenshot = File(image.path));
  }

  // --- SEND LOGIC ---
  Future<void> _sendReport() async {
    await ref.read(childReportViewModelProvider.notifier).sendReport(
      recipient: _selectedRecipient,
      issueType: _selectedIssueType,
      details: _detailsController.text.trim(),
      screenshot: _screenshot,
      contextData: widget.contentContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childReportViewModelProvider);

    // Listen for Success
    ref.listen(childReportViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report Sent! We will check it soon."), backgroundColor: Colors.green));
        ref.read(childReportViewModelProvider.notifier).resetSuccess();
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red));
      }
    });

    final bool hasContext = widget.contentContext != null;
    final String contentTitle = hasContext ? widget.contentContext!['title'] : '';
    final String contentType = hasContext ? widget.contentContext!['type'] : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
        title: Text("Submit Report", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (hasContext) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24.sp),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reporting $contentType", style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          Text(contentTitle, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],

            Text("Who should see this?", style: _labelStyle),
            SizedBox(height: 1.5.h),
            _buildRecipientSelector(),

            SizedBox(height: 3.h),
            Text("What happened?", style: _labelStyle),
            SizedBox(height: 1.5.h),
            Wrap(spacing: 3.w, runSpacing: 1.5.h, children: _issueTypes.map((type) => _buildTypeChip(type)).toList()),

            SizedBox(height: 3.h),
            Text("Details (Optional)", style: _labelStyle),
            SizedBox(height: 1.5.h),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: hasContext ? "Why is this $contentType bad?" : "Tell us more...",
                hintStyle: GoogleFonts.poppins(color: Colors.white30),
                filled: true, fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),

            SizedBox(height: 3.h),
            Text("Attach Screenshot (Optional)", style: _labelStyle),
            SizedBox(height: 1.5.h),
            _buildScreenshotUpload(),

            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity, height: 7.h,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _sendReport, // Connected
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text("Send Alert", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ... (Helper Widgets: _labelStyle, _buildRecipientSelector, _buildTypeChip, _buildScreenshotUpload - Same as before)
  TextStyle get _labelStyle => GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white70);
  Widget _buildRecipientSelector() { return Row(children: _recipients.map((r) { bool isSelected = _selectedRecipient == r; return GestureDetector(onTap: () => setState(() => _selectedRecipient = r), child: Container(margin: EdgeInsets.only(right: 3.w), padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h), decoration: BoxDecoration(color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.blue : Colors.white10)), child: Text(r, style: GoogleFonts.poppins(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))); }).toList()); }
  Widget _buildTypeChip(String type) { bool isSelected = _selectedIssueType == type; return GestureDetector(onTap: () => setState(() => _selectedIssueType = type), child: Container(padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h), decoration: BoxDecoration(color: isSelected ? Colors.orange : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), child: Text(type, style: GoogleFonts.poppins(color: Colors.white)))); }
  Widget _buildScreenshotUpload() { return GestureDetector(onTap: _pickScreenshot, child: Container(width: double.infinity, height: 18.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24), image: _screenshot != null ? DecorationImage(image: FileImage(_screenshot!), fit: BoxFit.cover) : null), child: _screenshot == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_rounded, color: Colors.white54, size: 24.sp), SizedBox(height: 1.h), Text("Tap to upload image", style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12.sp))]) : Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _screenshot = null))))); }
}