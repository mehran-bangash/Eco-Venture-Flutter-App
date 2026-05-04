import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/teacher_safety_report/teacher_safety_provider.dart';

class TeacherContactAdminScreen extends ConsumerStatefulWidget {
  const TeacherContactAdminScreen({super.key});

  @override
  ConsumerState<TeacherContactAdminScreen> createState() =>
      _TeacherContactAdminScreenState();
}

class _TeacherContactAdminScreenState
    extends ConsumerState<TeacherContactAdminScreen> {
  String _selectedType = 'App Crash';
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();

  final List<String> _bugTypes = [
    'App Crash',
    'Feature Request',
    'Content Error',
  ];
  final Color _primaryBlue = const Color(0xFF1565C0);
  final Color _bg = const Color(0xFFF4F7FE);

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await ref
        .read(teacherSafetyViewModelProvider.notifier)
        .sendAdminReport(_titleCtrl.text, _messageCtrl.text, _selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherSafetyViewModelProvider);

    ref.listen(teacherSafetyViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report Submitted Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(teacherSafetyViewModelProvider.notifier).resetSuccess();
        _titleCtrl.clear();
        _messageCtrl.clear();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.goNamed("bottomNavTeacher");
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: Text(
            "Contact Admin",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NEW: HISTORY ACCESS CONTAINER ---
              GestureDetector(
                onTap: () => context.pushNamed('teacherAdminInbox'),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _primaryBlue.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _primaryBlue.withOpacity(0.1),
                        child: Icon(Icons.history, color: _primaryBlue),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Report History",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "Track status of your previous reports",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              _buildLabel("Issue Type"),
              Wrap(
                spacing: 2.w,
                children: _bugTypes
                    .map(
                      (t) => ChoiceChip(
                        label: Text(t),
                        selected: _selectedType == t,
                        onSelected: (s) => setState(() => _selectedType = t),
                        selectedColor: _primaryBlue.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 3.h),
              _buildLabel("Title"),
              _buildField(_titleCtrl, "Short summary...", 1),
              SizedBox(height: 3.h),
              _buildLabel("Description"),
              _buildField(_messageCtrl, "Detailed explanation...", 5),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SUBMIT REPORT",
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
    );
  }

  Widget _buildLabel(String t) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
  );
  Widget _buildField(TextEditingController c, String h, int l) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: TextField(
      controller: c,
      maxLines: l,
      decoration: InputDecoration(
        hintText: h,
        contentPadding: EdgeInsets.all(4.w),
        border: InputBorder.none,
      ),
    ),
  );
}
