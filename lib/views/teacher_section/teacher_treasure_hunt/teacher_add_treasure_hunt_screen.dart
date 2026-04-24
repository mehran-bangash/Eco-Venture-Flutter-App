import 'package:eco_venture/core/config/app_constants.dart'; // IMPORTED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../models/qr_hunt_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_qr_treasure/teacher_treasure_hunt_provider.dart';

class TeacherAddTreasureHuntScreen extends ConsumerStatefulWidget {
  const TeacherAddTreasureHuntScreen({super.key});

  @override
  ConsumerState<TeacherAddTreasureHuntScreen> createState() =>
      _TeacherAddTreasureHuntScreenState();
}

class _TeacherAddTreasureHuntScreenState
    extends ConsumerState<TeacherAddTreasureHuntScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  String _difficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  // FIX: Changed from _selectedYear to _selectedAgeGroup
  String? _selectedAgeGroup;

  final List<TextEditingController> _clueControllers = [
    TextEditingController(),
    TextEditingController()
  ];

  final String _tempHuntId = DateTime.now().millisecondsSinceEpoch.toString();
  final TextEditingController _tagsController = TextEditingController();
  bool _isSensitive = false;

  final Color _primary = const Color(0xFF00C853);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _tagsController.dispose();
    for (var controller in _clueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendClassNotification(
      String teacherId,
      String huntTitle,
      String ageGroup,
      ) async {
    const String backendUrl = ApiConstants.notifyChildClassEndPoints;

    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "QR Hunt",
          "title": "New Treasure Hunt: $huntTitle 🗺️",
          "body": "A new treasure hunt for Group $ageGroup is ready!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  // --- SAVE LOGIC ---
  Future<void> _saveHunt() async {
    // FIX: Check for _selectedAgeGroup
    if (_titleController.text.isEmpty || _pointsController.text.isEmpty || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields including Target Class"),
          backgroundColor: Colors.red));
      return;
    }

    List<String> clues = _clueControllers
        .where((c) => c.text.isNotEmpty)
        .map((c) => c.text)
        .toList();
    if (clues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Add at least one clue"),
          backgroundColor: Colors.red));
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    if (teacherId == null) return;

    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    final newHunt = QrHuntModel(
      id: _tempHuntId,
      title: _titleController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 100,
      difficulty: _difficulty,
      clues: clues,
      createdAt: DateTime.now(),
      adminId: teacherId,
      tags: tagsList,
      isSensitive: _isSensitive,
      ageGroup: _selectedAgeGroup!, // Directly use selected group
    );

    await ref
        .read(teacherTreasureHuntViewModelProvider.notifier)
        .addHunt(newHunt, null);

    if (!_isSensitive) {
      await _sendClassNotification(teacherId, newHunt.title, _selectedAgeGroup!);
    }
  }

  // --- GENERATE & PRINT PDF ---
  Future<void> _generateAndPrintPdf() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter a Title first!"),
          backgroundColor: Colors.orange));
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();
          for (int i = 0; i < _clueControllers.length; i++) {
            final qrData = "${_tempHuntId}_$i";
            doc.addPage(
              pw.Page(
                pageFormat: format,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text("Clue #${i + 1}",
                            style: pw.TextStyle(
                                fontSize: 30,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        pw.Text("Hunt: ${_titleController.text}",
                            style: pw.TextStyle(
                                fontSize: 20, color: PdfColors.grey700)),
                        pw.SizedBox(height: 40),
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 300,
                          height: 300,
                        ),
                        pw.SizedBox(height: 40),
                        pw.Text("Hide this QR code at location #${i + 1}",
                            style: pw.TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return doc.save();
        },
      );
    } catch (e) {
      debugPrint("PDF Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherTreasureHuntViewModelProvider);

    ref.listen(teacherTreasureHuntViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ref.read(teacherTreasureHuntViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add QR Hunt",
            style: GoogleFonts.poppins(
                color: _textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Create a task. Each clue generates a unique QR code.",
                style: GoogleFonts.poppins(
                    fontSize: 14.sp, color: Colors.grey[600])),
            SizedBox(height: 3.h),

            _buildLabel("Task Name / Title"),
            _buildTextField(_titleController, "Enter task title"),

            SizedBox(height: 2.h),

            // --- NEW: Dynamic Target Class Selection ---
            _buildLabel("Target Class / Age Group"),
            _buildDynamicAgeDropdown(),
            SizedBox(height: 2.h),

            _buildLabel("Points"),
            _buildTextField(_pointsController, "e.g., 100",
                isNumber: true),

            SizedBox(height: 2.h),
            _buildLabel("Difficulty"),
            _buildDropdown(),
            SizedBox(height: 2.h),
            _buildLabel("Tags (comma-separated)"),
            _buildTextField(
                _tagsController, "e.g. outdoor, mystery, night"),

            SizedBox(height: 2.h),

            SwitchListTile(
              title: Text("Mark as Sensitive Content",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  )),
              subtitle: Text(
                "If enabled, this hunt will be blocked for younger children.",
                style: GoogleFonts.poppins(fontSize: 12.sp),
              ),
              value: _isSensitive,
              onChanged: (v) => setState(() => _isSensitive = v),
              activeThumbColor: Colors.red,
            ),

            SizedBox(height: 4.h),
            _buildSectionHeader("Clues Chain"),

            ...List.generate(_clueControllers.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Clue #${index + 1}",
                              style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _primary)),
                          if (index > 0)
                            InkWell(
                              onTap: () => setState(() =>
                                  _clueControllers.removeAt(index)),
                              child: Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20.sp),
                            )
                        ],
                      ),
                      SizedBox(height: 1.h),
                      _buildTextField(_clueControllers[index],
                          "Hint: 'Look under the big tree'",
                          maxLines: 2),
                    ],
                  ),
                ),
              );
            }),

            InkWell(
              onTap: () => setState(
                      () => _clueControllers.add(TextEditingController())),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _primary,
                        width: 1.5,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: _primary, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text("Add Next Clue",
                        style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: _primary)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),

            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text("Ready to hide clues?",
                      style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1565C0))),
                  SizedBox(height: 1.5.h),
                  SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton.icon(
                      onPressed: _generateAndPrintPdf,
                      icon: const Icon(Icons.print_rounded,
                          color: Colors.white),
                      label: Text("Print All QR Codes (PDF)",
                          style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _saveHunt,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5),
                child: state.isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : Text("Save & Publish Hunt",
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC DROPDOWN FOR QR HUNT ---
  Widget _buildDynamicAgeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedAgeGroup,
            isExpanded: true,
            hint: Text("Select Class Group", style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey)),
            items: AppConstants.teacherClassRanges
                .map((range) => DropdownMenuItem(
              value: range,
              child: Text("Group $range",
                  style: GoogleFonts.poppins(fontSize: 15.sp)),
            ))
                .toList(),
            onChanged: (v) => setState(() => _selectedAgeGroup = v),
          )),
    );
  }

  Widget _buildSectionHeader(String title) => Text(title,
      style: GoogleFonts.poppins(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _textDark));
  Widget _buildLabel(String text) => Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: _textDark)));

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(4.w),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _difficulty,
            isExpanded: true,
            items: _difficultyLevels
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text(c,
                  style: GoogleFonts.poppins(fontSize: 15.sp)),
            ))
                .toList(),
            onChanged: (v) => setState(() => _difficulty = v!),
          )),
    );
  }
}