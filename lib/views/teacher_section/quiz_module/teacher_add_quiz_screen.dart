import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TeacherAddQuizScreen extends StatefulWidget {
  const TeacherAddQuizScreen({super.key});

  @override
  State<TeacherAddQuizScreen> createState() => _TeacherAddQuizScreenState();
}

class _TeacherAddQuizScreenState extends State<TeacherAddQuizScreen> {
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);

  final TextEditingController _topicController = TextEditingController();
  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'Animals', 'Ecosystem'];

  // Mock list for UI demo
  List<Map<String, dynamic>> _levels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Create New Quiz", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.w700, fontSize: 17.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Topic Information"),
            SizedBox(height: 2.h),

            // Category
            _buildLabel("Category"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: _primary),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Topic Name
            _buildLabel("Quiz Topic Name"),
            _buildTextField(controller: _topicController, hint: "e.g. Solar System"),
            SizedBox(height: 4.h),

            // Levels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Levels (${_levels.length})"),
                InkWell(
                  onTap: () => _showLevelEditor(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: _primary, size: 16.sp),
                        SizedBox(width: 1.w),
                        Text("Add Level", style: GoogleFonts.poppins(fontSize: 13.sp, color: _primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 2.h),

            if (_levels.isEmpty)
              Center(child: Padding(padding: EdgeInsets.all(4.h), child: Text("No levels added yet.", style: GoogleFonts.poppins(color: Colors.grey))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _levels.length,
                itemBuilder: (context, index) => _buildLevelCard(_levels[index], index),
              ),

            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save Logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text("Publish Quiz", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark));
  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])));

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.amber.shade100, child: Text("${level['order']}", style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold))),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level['title'], style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                Text("${level['questions'].length} Questions • ${level['points']} Pts", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}), // Add edit logic later
          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _levels.removeAt(index))),
        ],
      ),
    );
  }

  // --- LEVEL EDITOR MODAL ---
  void _showLevelEditor() {
    // Controllers
    final titleCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: "${_levels.length + 1}");
    final pointsCtrl = TextEditingController(text: "10");
    final passCtrl = TextEditingController(text: "60");

    // Local State for Questions
    List<Map<String, dynamic>> tempQuestions = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( // WRAP IN STATEFUL BUILDER
          builder: (context, setModalState) {
            return Container(
              height: 90.h,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  Text("Add Level", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.h),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Level Title"),
                          _buildTextField(controller: titleCtrl, hint: "e.g. Basics"),
                          SizedBox(height: 2.h),
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Order"), _buildTextField(controller: orderCtrl, hint: "Order")])),
                            SizedBox(width: 3.w),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Points"), _buildTextField(controller: pointsCtrl, hint: "Points")])),
                            SizedBox(width: 3.w),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Pass %"), _buildTextField(controller: passCtrl, hint: "%")])),
                          ]),
                          SizedBox(height: 3.h),

                          // Questions Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Questions (${tempQuestions.length})", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showQuestionEditor(context, (newQ) {
                                    setModalState(() {
                                      tempQuestions.add(newQ);
                                    });
                                  });
                                },
                                icon: Icon(Icons.add_circle_outline),
                                label: Text("Add Question"),
                                style: ElevatedButton.styleFrom(backgroundColor: _textDark, foregroundColor: Colors.white),
                              ),
                            ],
                          ),

                          if (tempQuestions.isEmpty)
                            Padding(padding: EdgeInsets.all(2.h), child: Center(child: Text("No questions yet", style: TextStyle(color: Colors.grey))))
                          else
                            ...tempQuestions.map((q) => ListTile(
                              title: Text(q['question'], maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setModalState(() => tempQuestions.remove(q))),
                            )).toList(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity, height: 6.5.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isEmpty) return;

                        final newLevel = {
                          'order': int.tryParse(orderCtrl.text) ?? (_levels.length + 1),
                          'title': titleCtrl.text,
                          'points': int.tryParse(pointsCtrl.text) ?? 10,
                          'passing_percentage': int.tryParse(passCtrl.text) ?? 60,
                          'questions': tempQuestions,
                        };

                        setState(() => _levels.add(newLevel));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text("Save Level", style: TextStyle(fontSize: 15.sp, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  // --- QUESTION EDITOR ---
  void _showQuestionEditor(BuildContext ctx, Function(Map<String, dynamic>) onSave) {
    String qText = "";
    File? qImage;
    final op1 = TextEditingController();
    final op2 = TextEditingController();
    final op3 = TextEditingController();
    final op4 = TextEditingController();
    int correctIdx = 0;

    showDialog(
        context: ctx,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              // FIX: Removed strict padding here to allow banner to touch edges, padding applied to content
              // padding: EdgeInsets.all(5.w),
              height: 75.h,
              child: Column(
                children: [
                  // --- PROFESSIONAL BANNER ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "New Question",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(5.w), // Content Padding
                      child: Column(
                        children: [
                          TextField(
                              onChanged: (v) => qText = v,
                              style: GoogleFonts.poppins(fontSize: 15.sp),
                              decoration: InputDecoration(
                                  hintText: "Question Text",
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FE),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                              )
                          ),
                          SizedBox(height: 2.h),

                          // --- OPTIONAL IMAGE UPLOAD ---
                          InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                              if(img != null) setState(() => qImage = File(img.path));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 15.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FE),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                  image: qImage != null ? DecorationImage(image: FileImage(qImage!), fit: BoxFit.cover) : null
                              ),
                              child: qImage == null
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: _primary, size: 24.sp),
                                  SizedBox(height: 0.5.h),
                                  Text("Add Image (Optional)", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]))
                                ],
                              )
                                  : Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => setState(() => qImage = null),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),

                          ...List.generate(4, (i) => Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              children: [
                                Radio(value: i, groupValue: correctIdx, onChanged: (v) => setState(() => correctIdx = v!), activeColor: _primary),
                                Expanded(child: TextField(
                                    controller: [op1, op2, op3, op4][i],
                                    style: GoogleFonts.poppins(fontSize: 14.sp),
                                    decoration: InputDecoration(
                                        hintText: "Option ${i+1}",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                                        filled: true,
                                        fillColor: const Color(0xFFF4F7FE),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                                    )
                                )),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),

                  // Save Button Container with padding
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 6.5.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (qText.isNotEmpty) {
                            onSave({
                              'question': qText,
                              'options': [op1.text, op2.text, op3.text, op4.text],
                              'answer': [op1.text, op2.text, op3.text, op4.text][correctIdx],
                              'image_url': qImage?.path, // Added image URL field
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text("SAVE QUESTION", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}