import 'dart:convert';
import 'dart:io';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:eco_venture/core/config/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/quiz_topic_model.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_quiz/teacher_quiz_provider.dart';

class TeacherAddQuizScreen extends ConsumerStatefulWidget {
  const TeacherAddQuizScreen({super.key});

  @override
  ConsumerState<TeacherAddQuizScreen> createState() =>
      _TeacherAddQuizScreenState();
}

class _TeacherAddQuizScreenState extends ConsumerState<TeacherAddQuizScreen> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textLabel = const Color(0xFF333333);
  final Color _border = const Color(0xFFE0E0E0);

  // --- TOPIC STATE ---
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'Animals', 'Ecosystem'];
  String? _selectedAgeGroup;

  final List<QuizLevelModel> _levels = [];
  bool _isSensitive = false;

  @override
  void dispose() {
    _topicController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // --- SAVE LOGIC ---
  Future<void> _saveQuiz() async {
    if (_topicController.text.trim().isEmpty || _selectedAgeGroup == null) {
      _showSnackBar(
        "Please enter a Topic Name and select Target Class",
        Colors.red,
      );
      return;
    }

    if (_levels.isEmpty) {
      _showSnackBar("Please add at least one Level", Colors.red);
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    if (teacherId == null) return;

    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) tagsList.add('scary');

    final newTopic = QuizTopicModel(
      category: _selectedCategory,
      topicName: _topicController.text.trim(),
      createdBy: 'teacher',
      creatorId: teacherId,
      levels: _levels,
      tags: tagsList,
      isSensitive: _isSensitive,
      ageGroup: _selectedAgeGroup!,
    );

    await ref.read(teacherQuizViewModelProvider.notifier).addQuiz(newTopic);

    if (!_isSensitive) {
      _sendClassNotification(teacherId, newTopic.topicName, _selectedAgeGroup!);
    }
  }

  Future<void> _sendClassNotification(
    String teacherId,
    String topicName,
    String ageGroup,
  ) async {
    try {
      await http.post(
        Uri.parse(ApiConstants.notifyChildClassEndPoints),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "teacherId": teacherId,
          "type": "Quiz",
          "title": "New Quiz: $topicName 🧠",
          "body": "A new quiz for Group $ageGroup is ready!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(teacherQuizViewModelProvider);

    ref.listen(teacherQuizViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ref.read(teacherQuizViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New Quiz",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Topic Information"),
            SizedBox(height: 2.h),
            _buildLabel("Category"),
            _buildDropdown(
              _selectedCategory,
              _categories,
              (val) => setState(() => _selectedCategory = val!),
            ),
            SizedBox(height: 2.5.h),
            _buildLabel("Quiz Topic Name"),
            _buildTextField(
              controller: _topicController,
              hint: "e.g. Solar System",
            ),
            SizedBox(height: 2.5.h),
            _buildLabel("Target Class / Age Group"),
            _buildAgeDropdown(),
            SizedBox(height: 2.5.h),
            _buildLabel("Tags (comma-separated)"),
            _buildTextField(
              controller: _tagsController,
              hint: "e.g. history, fun",
            ),
            SizedBox(height: 2.5.h),
            _buildSensitiveSwitch(),
            SizedBox(height: 4.h),
            _buildLevelsSection(),
            SizedBox(height: 5.h),
            _buildPublishButton(quizState.isLoading),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  // --- LEVEL EDITOR (With Timer & Question Editing) ---
  void _showLevelEditor({QuizLevelModel? existingLevel, int? index}) {
    final titleCtrl = TextEditingController(text: existingLevel?.title ?? "");
    final orderCtrl = TextEditingController(
      text: existingLevel?.order.toString() ?? "${_levels.length + 1}",
    );
    final pointsCtrl = TextEditingController(
      text: existingLevel?.points.toString() ?? "10",
    );
    final passCtrl = TextEditingController(
      text: existingLevel?.passingPercentage.toString() ?? "60",
    );
    final timerCtrl = TextEditingController(
      text: existingLevel?.timerSeconds.toString() ?? "30",
    );
    List<QuestionModel> tempQuestions = existingLevel != null
        ? List.from(existingLevel.questions)
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 92.h,
          padding: EdgeInsets.fromLTRB(
            5.w,
            2.h,
            5.w,
            MediaQuery.of(context).viewInsets.bottom + 2.h,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 15.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                existingLevel == null ? "Add Level" : "Edit Level",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _buildLabel("Level Title"),
                      _buildTextField(
                        controller: titleCtrl,
                        hint: "e.g. Basics",
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Order"),
                                _buildTextField(
                                  controller: orderCtrl,
                                  hint: "1",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Points"),
                                _buildTextField(
                                  controller: pointsCtrl,
                                  hint: "10",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Pass %"),
                                _buildTextField(
                                  controller: passCtrl,
                                  hint: "60",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Timer (Sec)"),
                                _buildTextField(
                                  controller: timerCtrl,
                                  hint: "30",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Questions (${tempQuestions.length})",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showQuestionEditor(
                              context,
                              null,
                              (q) => setModalState(() => tempQuestions.add(q)),
                            ),
                            icon: const Icon(Icons.add_circle),
                            label: const Text("Add New"),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...List.generate(tempQuestions.length, (i) {
                        final q = tempQuestions[i];
                        return ListTile(
                          title: Text(
                            "${i + 1}. ${q.question}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showQuestionEditor(
                                  context,
                                  q,
                                  (updated) => setModalState(
                                    () => tempQuestions[i] = updated,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => setModalState(
                                  () => tempQuestions.removeAt(i),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              _buildActionBtn(
                existingLevel == null ? "ADD LEVEL" : "UPDATE LEVEL",
                () {
                  if (titleCtrl.text.isEmpty || tempQuestions.isEmpty) return;
                  final newLevel = QuizLevelModel(
                    title: titleCtrl.text,
                    order: int.tryParse(orderCtrl.text) ?? 1,
                    passingPercentage: int.tryParse(passCtrl.text) ?? 60,
                    points: int.tryParse(pointsCtrl.text) ?? 10,
                    timerSeconds: int.tryParse(timerCtrl.text) ?? 30,
                    questions: tempQuestions,
                  );
                  setState(() {
                    if (index != null)
                      _levels[index] = newLevel;
                    else
                      _levels.add(newLevel);
                    _levels.sort((a, b) => a.order.compareTo(b.order));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- QUESTION EDITOR (Visual Interactivity) ---
  void _showQuestionEditor(
    BuildContext ctx,
    QuestionModel? initial,
    Function(QuestionModel) onSave,
  ) {
    final qCtrl = TextEditingController(text: initial?.question ?? "");
    File? qImage =
        (initial?.imageUrl != null && !initial!.imageUrl!.startsWith('http'))
        ? File(initial.imageUrl!)
        : null;
    final opCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text: initial?.options.length == 4 ? initial?.options[i] : "",
      ),
    );
    int selectedIdx = (initial != null)
        ? initial.options.indexOf(initial.answer)
        : -1;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 85.h,
          padding: EdgeInsets.fromLTRB(
            5.w,
            2.h,
            5.w,
            MediaQuery.of(context).viewInsets.bottom + 2.h,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  initial == null ? "New Question" : "Edit Question",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildTextField(controller: qCtrl, hint: "Question..."),
                SizedBox(height: 2.h),
                _buildImagePicker(
                  qImage,
                  (f) => setModalState(() => qImage = f),
                ),
                SizedBox(height: 2.h),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: opCtrls[i],
                            hint: "Option ${i + 1}",
                          ),
                        ),
                        IconButton(
                          onPressed: () => setModalState(() => selectedIdx = i),
                          icon: Icon(
                            selectedIdx == i
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selectedIdx == i
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                _buildActionBtn("SAVE", () {
                  if (qCtrl.text.isEmpty || selectedIdx == -1) return;
                  onSave(
                    QuestionModel(
                      question: qCtrl.text,
                      options: opCtrls.map((c) => c.text).toList(),
                      answer: opCtrls[selectedIdx].text,
                      imageUrl: qImage?.path ?? initial?.imageUrl,
                    ),
                  );
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildAgeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          hint: const Text("Select Age Group"),
          items: AppConstants.teacherClassRanges
              .map((r) => DropdownMenuItem(value: r, child: Text("Group $r")))
              .toList(),
          onChanged: (v) => setState(() => _selectedAgeGroup = v),
        ),
      ),
    );
  }

  Widget _buildLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("Levels (${_levels.length})"),
            TextButton.icon(
              onPressed: () => _showLevelEditor(),
              icon: const Icon(Icons.add),
              label: const Text("Add Level"),
            ),
          ],
        ),
        if (_levels.isEmpty)
          Center(
            child: Text(
              "No levels yet",
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _levels.length,
            separatorBuilder: (_, __) => SizedBox(height: 1.h),
            itemBuilder: (_, i) => _buildLevelCard(i, _levels[i]),
          ),
      ],
    );
  }

  Widget _buildLevelCard(int i, QuizLevelModel level) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _border),
      ),
      child: ListTile(
        title: Text(
          "Lvl ${level.order}: ${level.title}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${level.questions.length} Qs • ${level.timerSeconds}s timer",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showLevelEditor(existingLevel: level, index: i),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _levels.removeAt(i)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(File? current, Function(File) onPick) {
    return InkWell(
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) onPick(File(img.path));
      },
      child: Container(
        height: 10.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: _primary),
          borderRadius: BorderRadius.circular(12),
          image: current != null
              ? DecorationImage(image: FileImage(current), fit: BoxFit.cover)
              : null,
        ),
        child: current == null
            ? Center(child: Icon(Icons.camera_alt, color: _primary))
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String curr,
    List<String> items,
    Function(String?) onC,
  ) => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border, width: 1.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: curr,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onC,
      ),
    ),
  );
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
  }) => TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
  Widget _buildSectionHeader(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w800,
      color: _primary,
    ),
  );
  Widget _buildLabel(String t) => Padding(
    padding: EdgeInsets.only(bottom: 0.5.h),
    child: Text(
      t.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: _textLabel,
      ),
    ),
  );
  Widget _buildActionBtn(String t, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 6.h,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: _textDark),
      child: Text(
        t,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
  Widget _buildPublishButton(bool loading) => SizedBox(
    width: double.infinity,
    height: 7.h,
    child: ElevatedButton(
      onPressed: loading ? null : _saveQuiz,
      style: ElevatedButton.styleFrom(backgroundColor: _primary),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "PUBLISH QUIZ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
  Widget _buildSensitiveSwitch() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: SwitchListTile(
      title: const Text(
        "Sensitive Content",
        style: TextStyle(color: Colors.red),
      ),
      value: _isSensitive,
      onChanged: (v) => setState(() => _isSensitive = v),
    ),
  );
}
