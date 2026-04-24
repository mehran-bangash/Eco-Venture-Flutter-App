import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../viewmodels/child_view_model/inbox_report/child_safety_provider.dart';


class ChildReportIssueScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? contentContext;

  const ChildReportIssueScreen({super.key, this.contentContext});

  @override
  ConsumerState<ChildReportIssueScreen> createState() =>
      _ChildReportIssueScreenState();
}

class _ChildReportIssueScreenState
    extends ConsumerState<ChildReportIssueScreen> {
  // Logic: Multi-recipient list starts empty
  final List<String> _selectedRecipients = [];
  String _selectedIssueType = 'Other';
  final TextEditingController _detailsController = TextEditingController();

  File? _screenshot;
  final ImagePicker _picker = ImagePicker();

  List<String> _availableRecipients = ['Parent', 'Admin'];
  final List<String> _issueTypes = [
    'Scary Content',
    'Bullying',
    'App Bug',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _checkTeacherLink();
    if (widget.contentContext != null) {
      _selectedIssueType = 'Scary Content';
    }
  }

  Future<void> _checkTeacherLink() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final teacherId = doc.data()?['teacher_id'];

        if (teacherId != null && teacherId.toString().isNotEmpty) {
          setState(() {
            _availableRecipients = ['Parent', 'Teacher', 'Admin'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking teacher link: $e");
    }
  }

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _screenshot = File(image.path));
  }

  // Logic: Professional multi-send execution
  Future<void> _sendReport() async {
    if (_selectedRecipients.isEmpty) return;

    final notifier = ref.read(childReportViewModelProvider.notifier);

    // We loop and await each send. This keeps 'state.isLoading' true
    // until the last one finishes, solving the "stuck" feeling.
    for (String recipient in _selectedRecipients) {
      await notifier.sendReport(
        recipient: recipient,
        issueType: _selectedIssueType,
        details: _detailsController.text.trim(),
        screenshot: _screenshot,
        contextData: widget.contentContext,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childReportViewModelProvider);

    // Navigation Logic: Only pop when 'isSuccess' is triggered after the loop
    ref.listen(childReportViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report Sent Successfully!"), backgroundColor: Colors.green),
        );
        ref.read(childReportViewModelProvider.notifier).resetSuccess();
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red),
        );
      }
    });

    final bool hasContext = widget.contentContext != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text("Submit Report", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasContext) _buildContextCard(),

            Text("Who should see this?", style: _labelStyle),
            SizedBox(height: 1.5.h),
            _buildRecipientSelector(),

            SizedBox(height: 3.h),
            Text("What happened?", style: _labelStyle),
            SizedBox(height: 1.5.h),
            Wrap(
              spacing: 3.w,
              runSpacing: 1.5.h,
              children: _issueTypes.map((type) => _buildTypeChip(type)).toList(),
            ),

            SizedBox(height: 3.h),
            Text("Details (Optional)", style: _labelStyle),
            SizedBox(height: 1.5.h),
            _buildDetailsField(hasContext),

            SizedBox(height: 3.h),
            Text("Attach Screenshot (Optional)", style: _labelStyle),
            SizedBox(height: 1.5.h),
            _buildScreenshotUpload(),

            SizedBox(height: 5.h),
            // Logic: Button disabled if loading OR no recipient selected
            _buildSendButton(state.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSelector() {
    return Wrap(
      spacing: 3.w,
      runSpacing: 1.5.h,
      children: _availableRecipients.map((r) {
        bool isSelected = _selectedRecipients.contains(r);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? _selectedRecipients.remove(r) : _selectedRecipients.add(r);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? Colors.blue : Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? Colors.white : Colors.white30, size: 17.sp),
                SizedBox(width: 2.w),
                Text(r, style: GoogleFonts.poppins(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSendButton(bool isLoading) {
    bool canSend = _selectedRecipients.isNotEmpty && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: canSend ? _sendReport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676),
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text("Send Alert", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: canSend ? Colors.black : Colors.white24)),
      ),
    );
  }

  // --- Helper Widgets to keep code clean ---

  Widget _buildContextCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24.sp),
          SizedBox(width: 3.w),
          Expanded(child: Text(widget.contentContext!['title'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    bool isSelected = _selectedIssueType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedIssueType = type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(type, style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

  Widget _buildDetailsField(bool hasContext) {
    return TextField(
      controller: _detailsController,
      maxLines: 4,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: "Tell us more...",
        hintStyle: GoogleFonts.poppins(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildScreenshotUpload() {
    return GestureDetector(
      onTap: _pickScreenshot,
      child: Container(
        width: double.infinity,
        height: 18.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          image: _screenshot != null ? DecorationImage(image: FileImage(_screenshot!), fit: BoxFit.cover) : null,
        ),
        child: _screenshot == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: Colors.white54, size: 24.sp),
            Text("Tap to upload image", style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12.sp)),
          ],
        )
            : Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _screenshot = null))),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white70);
}