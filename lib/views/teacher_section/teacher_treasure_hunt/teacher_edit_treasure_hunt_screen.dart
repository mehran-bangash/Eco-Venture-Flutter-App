import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../models/qr_hunt_model.dart';
import '../../../core/config/api_constants.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_qr_treasure/teacher_treasure_hunt_provider.dart';

class TeacherEditTreasureHuntScreen extends ConsumerStatefulWidget {
  final dynamic huntData;
  const TeacherEditTreasureHuntScreen({super.key, required this.huntData});

  @override
  ConsumerState<TeacherEditTreasureHuntScreen> createState() =>
      _TeacherEditTreasureHuntScreenState();
}

class _TeacherEditTreasureHuntScreenState
    extends ConsumerState<TeacherEditTreasureHuntScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  // --- ADDED: Tags Controller ---
  final TextEditingController _tagsController = TextEditingController();

  late QrHuntModel _hunt;
  String _difficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];
  final List<TextEditingController> _clueControllers = [];

  // --- ADDED: Sensitivity Flag ---
  bool _isSensitive = false;

  final Color _primary = const Color(0xFF00C853);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    // Parse Data
    if (widget.huntData is QrHuntModel) {
      _hunt = widget.huntData;
    } else {
      final map = Map<String, dynamic>.from(widget.huntData);
      _hunt = QrHuntModel(
        id: map['id'],
        title: map['title'] ?? '',
        points: map['points'] is int
            ? map['points']
            : int.tryParse(map['points'].toString()) ?? 0,
        difficulty: map['difficulty'] ?? 'Easy',
        clues: List<String>.from(map['clues'] ?? []),
        createdAt: DateTime.now(),
        tags: List<String>.from(map['tags'] ?? []),
        // ADDED: Load tags
        isSensitive: map['isSensitive'] ?? false, // ADDED: Load sensitivity
      );
    }

    _titleController.text = _hunt.title;
    _pointsController.text = _hunt.points.toString();
    _difficulty = _hunt.difficulty;

    // --- ADDED: Initialize tags and sensitivity ---
    _tagsController.text = _hunt.tags?.join(', ') ?? '';
    _isSensitive = _hunt.isSensitive ?? false;

    for (var clue in _hunt.clues) {
      _clueControllers.add(TextEditingController(text: clue));
    }
  }

  Future<void> _updateHunt() async {
    if (_titleController.text.isEmpty) return;

    List<String> clues = _clueControllers
        .where((c) => c.text.isNotEmpty)
        .map((c) => c.text)
        .toList();

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

    // --- GET TEACHER ID FOR NOTIFICATION ---
    String? teacherId = await SharedPreferencesHelper.instance.getUserId();
    if (teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: No Teacher ID. Re-login."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedHunt = _hunt.copyWith(
      title: _titleController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      difficulty: _difficulty,
      clues: clues,
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    // Update in Firebase
    await ref
        .read(teacherTreasureHuntViewModelProvider.notifier)
        .updateHunt(updatedHunt, null);

    // --- SEND NOTIFICATION ONLY IF NOT SENSITIVE ---
    if (!_isSensitive) {
      await _sendClassNotification(teacherId, updatedHunt.title);
    }
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendClassNotification(
    String teacherId,
    String huntTitle,
  ) async {
    const String backendUrl = ApiConstants.notifyChildClassEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "QR Hunt",
          "title": "QR Hunt Updated: $huntTitle ✏️",
          "body":
              "Your teacher updated the treasure hunt: $huntTitle. Check it out!",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ QR Hunt Update Notification sent successfully");
      } else {
        print("❌ Notification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error calling notification backend: $e");
    }
  }

  Future<void> _reprintPdf() async {
    if (_hunt.id == null) return;

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        for (int i = 0; i < _clueControllers.length; i++) {
          // Ensure we use the SAME ID so previous codes don't break if not changed
          final qrData = "${_hunt.id}_$i";

          doc.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Clue #${i + 1}",
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Hunt: ${_titleController.text}",
                        style: pw.TextStyle(
                          fontSize: 20,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrData,
                        width: 300,
                        height: 300,
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        "Location #${i + 1}",
                        style: pw.TextStyle(fontSize: 18),
                      ),
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherTreasureHuntViewModelProvider);

    ref.listen(teacherTreasureHuntViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSensitive
                ? "Hunt Updated! (No notification sent - marked sensitive)"
                : "Hunt Updated & Class Notified!"),
            backgroundColor: Colors.green,
          ),
        );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit QR Hunt",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Edit Details"),
                SizedBox(height: 2.h),
                _buildLabel("Task Name"),
                _buildTextField(_titleController, "Title"),
                SizedBox(height: 2.h),
                _buildLabel("Points"),
                _buildTextField(_pointsController, "100", isNumber: true),
                SizedBox(height: 2.h),
                _buildLabel("Difficulty"),
                _buildDropdown(),

                // --- ADDED: Tags Field (same as Add Screen) ---
                SizedBox(height: 2.h),
                _buildLabel("Tags (comma-separated)"),
                _buildTextField(
                  _tagsController,
                  "e.g. outdoor, mystery, night",
                ),

                // --- ADDED: Sensitivity Switch (same as Add Screen) ---
                SizedBox(height: 2.h),
                SwitchListTile(
                  title: Text(
                    "Mark as Sensitive Content",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  subtitle: Text(
                    "If enabled, this hunt will be blocked for younger children.",
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  value: _isSensitive,
                  onChanged: (v) => setState(() => _isSensitive = v),
                  activeThumbColor: Colors.red,
                ),

                SizedBox(height: 4.h),
                _buildSectionHeader("Edit Clues"),

                ...List.generate(_clueControllers.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Clue ${index + 1}",
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(
                                  () => _clueControllers.removeAt(index),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          _buildTextField(
                            _clueControllers[index],
                            "Edit clue...",
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                InkWell(
                  onTap: () => setState(
                    () => _clueControllers.add(TextEditingController()),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _primary,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18.sp, color: _primary),
                        SizedBox(width: 2.w),
                        Text(
                          "Add Clue",
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Reprint Option
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton.icon(
                    onPressed: _reprintPdf,
                    icon: Icon(Icons.print, color: _primary),
                    label: Text(
                      "Re-Print Codes (PDF)",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateHunt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Update Checkpoint",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: _textDark,
    ),
  );
  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    ),
  );
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15.sp),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
    ),
  );
  Widget _buildDropdown() => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _difficulty,
        isExpanded: true,
        items: _difficultyLevels
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _difficulty = v!),
      ),
    ),
  );
}
