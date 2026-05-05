import 'package:eco_venture/core/config/app_constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../models/quiz_topic_model.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/teacher_quiz/teacher_quiz_provider.dart';

class TeacherEditQuizScreen extends ConsumerStatefulWidget {
  final dynamic quizData;

  const TeacherEditQuizScreen({super.key, required this.quizData});

  @override
  ConsumerState<TeacherEditQuizScreen> createState() =>
      _TeacherEditQuizScreenState();
}

class _TeacherEditQuizScreenState extends ConsumerState<TeacherEditQuizScreen> {
  final Color _primary = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _surface = Colors.white;
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);
  final Color _border = const Color(0xFFE0E0E0);

  late TextEditingController _topicNameController;
  late TextEditingController _tagsController;

  late QuizTopicModel _topic;
  late String _selectedCategory;
  final List<String> _categories = ['Science', 'Maths', 'Animals', 'Ecosystem'];
  late List<QuizLevelModel> _levels;
  late bool _isSensitive;
  String? _selectedAgeGroup;

  @override
  void initState() {
    super.initState();

    if (widget.quizData is QuizTopicModel) {
      _topic = widget.quizData as QuizTopicModel;
    } else {
      final map = Map<String, dynamic>.from(widget.quizData as Map);
      _topic = QuizTopicModel.fromMap(
        map['id'] ?? '',
        map['category'] ?? 'Science',
        map,
      );
    }

    _topicNameController = TextEditingController(text: _topic.topicName);
    _tagsController = TextEditingController(text: _topic.tags.join(', '));
    _selectedCategory = _categories.contains(_topic.category)
        ? _topic.category
        : _categories.first;
    _levels = List<QuizLevelModel>.from(_topic.levels);
    _isSensitive = _topic.isSensitive;
    _selectedAgeGroup = _topic.ageGroup;
  }

  @override
  void dispose() {
    _topicNameController.dispose();
    _tagsController.dispose();
    super.dispose();
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
          "title": "Quiz Updated: $topicName 📝",
          "body": "The quiz '$topicName' for Group $ageGroup has been updated!",
          "ageGroup": ageGroup,
        }),
      );
    } catch (e) {
      debugPrint("❌ Notification error: $e");
    }
  }

  Future<void> _updateTopic() async {
    if (_topicNameController.text.trim().isEmpty || _selectedAgeGroup == null) {
      _showError("Please enter a Topic Name and select Target Age");
      return;
    }
    if (_levels.isEmpty) {
      _showError("Please ensure there is at least one Level");
      return;
    }

    String? teacherId = SharedPreferencesHelper.instance.getUserId();
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) tagsList.add('scary');
    if (!_isSensitive) tagsList.remove('scary');

    final updatedTopic = _topic.copyWith(
      category: _selectedCategory,
      topicName: _topicNameController.text.trim(),
      levels: _levels,
      tags: tagsList,
      isSensitive: _isSensitive,
      ageGroup: _selectedAgeGroup!,
    );

    await ref
        .read(teacherQuizViewModelProvider.notifier)
        .updateQuiz(updatedTopic);
    if (!_isSensitive && teacherId != null) {
      _sendClassNotification(
        teacherId,
        updatedTopic.topicName,
        _selectedAgeGroup!,
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
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
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Quiz",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProLabel("General Info"),
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProLabel("Category"),
                      _buildCategoryDropdown(),
                      SizedBox(height: 3.h),
                      _buildProLabel("Topic Name"),
                      _buildProTextField(
                        controller: _topicNameController,
                        hint: "e.g. Solar System",
                        icon: Icons.title_rounded,
                      ),
                      SizedBox(height: 3.h),
                      _buildProLabel("Target Age (Years)"),
                      _buildAgeDropdown(),
                      SizedBox(height: 3.h),
                      _buildProLabel("Tags"),
                      _buildProTextField(
                        controller: _tagsController,
                        hint: "e.g. history, fun",
                        icon: Icons.tag,
                      ),
                      SizedBox(height: 3.h),
                      _buildSensitiveSwitch(),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                _buildLevelsHeader(),
                SizedBox(height: 2.h),
                _buildLevelsList(),
                SizedBox(height: 5.h),
                _buildUpdateButton(quizState.isLoading),
                SizedBox(height: 5.h),
              ],
            ),
          ),
          if (quizState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildCategoryDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          isExpanded: true,
          items: AppConstants.teacherClassRanges
              .map(
                (range) => DropdownMenuItem(
                  value: range,
                  child: Text(
                    "Group $range",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedAgeGroup = val!),
        ),
      ),
    );
  }

  Widget _buildLevelsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProLabel("Levels Config"),
        TextButton.icon(
          onPressed: () => _showLevelEditor(),
          icon: const Icon(Icons.add_rounded),
          label: const Text("Add Level"),
        ),
      ],
    );
  }

  Widget _buildLevelsList() {
    if (_levels.isEmpty) return _buildEmptyState();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _levels.length,
      separatorBuilder: (_, __) => SizedBox(height: 2.h),
      itemBuilder: (ctx, i) => _buildProLevelCard(i, _levels[i]),
    );
  }

  Widget _buildUpdateButton(bool loading) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: loading ? null : _updateTopic,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "UPDATE QUIZ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // --- LEVEL EDITOR (TIMER ADDED) ---
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
    // TIMER CONTROLLER ADDED
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
          height: 90.h,
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
                height: 0.6.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                existingLevel == null ? "Add Level" : "Edit Level",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  children: [
                    _buildProLabel("Level Title"),
                    _buildProTextField(
                      controller: titleCtrl,
                      hint: "e.g. Basics",
                      icon: Icons.text_fields_rounded,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProLabel("Order"),
                              _buildProTextField(
                                controller: orderCtrl,
                                hint: "1",
                                icon: Icons.format_list_numbered,
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
                              _buildProLabel("Points"),
                              _buildProTextField(
                                controller: pointsCtrl,
                                hint: "10",
                                icon: Icons.star_border,
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
                              _buildProLabel("Pass %"),
                              _buildProTextField(
                                controller: passCtrl,
                                hint: "60",
                                icon: Icons.percent,
                                isNumber: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // TIMER UI FIELD ADDED
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProLabel("Timer (Sec)"),
                              _buildProTextField(
                                controller: timerCtrl,
                                hint: "30",
                                icon: Icons.timer_outlined,
                                isNumber: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Questions (${tempQuestions.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showQuestionEditor(
                            context,
                            (q) => setModalState(() => tempQuestions.add(q)),
                          ),
                          icon: const Icon(Icons.add_circle),
                          label: const Text("Add New"),
                        ),
                      ],
                    ),
                    ...tempQuestions.asMap().entries.map(
                      (e) => ListTile(
                        title: Text(
                          "Q${e.key + 1}: ${e.value.question}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showQuestionEditor(
                                context,
                                (up) => setModalState(
                                  () => tempQuestions[e.key] = up,
                                ),
                                existingQuestion: e.value,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setModalState(
                                () => tempQuestions.removeAt(e.key),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || tempQuestions.isEmpty) return;
                    final newLevel = QuizLevelModel(
                      title: titleCtrl.text,
                      order: int.tryParse(orderCtrl.text) ?? 1,
                      passingPercentage: int.tryParse(passCtrl.text) ?? 60,
                      points: int.tryParse(pointsCtrl.text) ?? 10,
                      timerSeconds:
                          int.tryParse(timerCtrl.text) ?? 30, // TIMER SAVED
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
                  style: ElevatedButton.styleFrom(backgroundColor: _textDark),
                  child: Text(
                    index == null ? "ADD LEVEL" : "UPDATE LEVEL",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionEditor(
    BuildContext ctx,
    Function(QuestionModel) onSave, {
    QuestionModel? existingQuestion,
  }) {
    final qTextCtrl = TextEditingController(
      text: existingQuestion?.question ?? "",
    );
    final opCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text: (existingQuestion?.options.length == 4)
            ? existingQuestion!.options[i]
            : "",
      ),
    );
    int correctIdx = (existingQuestion != null)
        ? existingQuestion.options.indexOf(existingQuestion.answer)
        : 0;
    File? newImg;
    String? oldUrl = existingQuestion?.imageUrl;

    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(5.w),
            height: 80.h,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    existingQuestion == null ? "New Question" : "Edit Question",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildProTextField(
                    controller: qTextCtrl,
                    hint: "Question text",
                    icon: Icons.help_outline,
                  ),
                  SizedBox(height: 2.h),
                  _buildImageEditor(
                    newImg,
                    oldUrl,
                    (f) => setState(() => newImg = f),
                  ),
                  ...List.generate(
                    4,
                    (i) => Row(
                      children: [
                        Radio(
                          value: i,
                          groupValue: correctIdx,
                          onChanged: (v) => setState(() => correctIdx = v!),
                          activeColor: _primary,
                        ),
                        Expanded(
                          child: _buildProTextField(
                            controller: opCtrls[i],
                            hint: "Option ${i + 1}",
                            icon: Icons.abc,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (qTextCtrl.text.isEmpty) return;
                        onSave(
                          QuestionModel(
                            question: qTextCtrl.text,
                            options: opCtrls.map((c) => c.text).toList(),
                            answer: opCtrls[correctIdx].text,
                            imageUrl: newImg?.path ?? oldUrl,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                      ),
                      child: const Text(
                        "SAVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildProLevelCard(int i, QuizLevelModel level) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _primary.withOpacity(0.1),
          child: Text(
            "${level.order}",
            style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          level.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${level.questions.length} Qs • ${level.timerSeconds}s Timer",
        ), // TIMER SHOWN ON CARD
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

  Widget _buildImageEditor(File? newF, String? url, Function(File) onPick) {
    return InkWell(
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) onPick(File(img.path));
      },
      child: Container(
        height: 12.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          image: newF != null
              ? DecorationImage(image: FileImage(newF), fit: BoxFit.cover)
              : (url != null
                    ? DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      )
                    : null),
        ),
        child: (newF == null && url == null)
            ? const Center(child: Icon(Icons.camera_alt))
            : null,
      ),
    );
  }

  Widget _buildProTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) => Container(
    margin: EdgeInsets.only(top: 1.h),
    child: TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border),
        ),
      ),
    ),
  );
  Widget _buildProLabel(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: _textGrey,
    ),
  );
  Widget _buildSensitiveSwitch() => SwitchListTile(
    title: const Text("Sensitive Content", style: TextStyle(color: Colors.red)),
    value: _isSensitive,
    onChanged: (v) => setState(() => _isSensitive = v),
  );
  Widget _buildEmptyState() => Container(
    padding: EdgeInsets.all(5.w),
    child: const Center(child: Text("No levels added yet.")),
  );
}
