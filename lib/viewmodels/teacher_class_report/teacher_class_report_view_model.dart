import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/teacher/teacher_class_report_model.dart';
import '../../repositories/teacher/teacher_class_report_repository.dart';
import 'teacher_class_report_state.dart';

class TeacherClassReportViewModel extends StateNotifier<TeacherClassReportState> {
  final TeacherClassReportRepository _repository;
  StreamSubscription? _sub;
  TeacherClassReportModel? _fullReport;

  TeacherClassReportViewModel(this._repository) : super(TeacherClassReportState()) {
    _loadReport();
  }

  void _loadReport() {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();
    _sub = _repository.getClassReport().listen(
            (data) {
          _fullReport = data;
          _applyFilter();
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  void setAgeCategory(String category) {
    state = state.copyWith(selectedAgeCategory: category);
    _applyFilter();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilter();
  }

  void _applyFilter() {
    if (_fullReport == null) return;

    final category = state.selectedAgeCategory ?? "All";
    final query = state.searchQuery?.toLowerCase() ?? "";

    // 1. Filter by Age
    List<StudentRankItem> filteredRankings = _fullReport!.studentRankings;
    if (category != "All") {
      final range = _parseRange(category);
      filteredRankings = filteredRankings.where((s) => s.age >= range['min']! && s.age <= range['max']!).toList();
    }

    // 2. Filter by Search Query
    if (query.isNotEmpty) {
      filteredRankings = filteredRankings.where((s) => s.name.toLowerCase().contains(query)).toList();
    }

    // 3. Recalculate Stats for the filtered group
    int totalPoints = 0;
    int quizzes = 0;
    int stem = 0;
    int qr = 0;

    for (var s in filteredRankings) {
      totalPoints += s.totalPoints;
      quizzes += s.quizCount;
      stem += s.stemCount;
      qr += s.qrCount;
    }

    final filteredReport = TeacherClassReportModel(
      totalStudents: filteredRankings.length,
      classAverageScore: filteredRankings.isEmpty ? 0 : totalPoints / filteredRankings.length,
      totalQuizzesPassed: quizzes,
      totalStemSubmissions: stem,
      totalQrHuntsSolved: qr,
      studentRankings: filteredRankings,
    );

    state = state.copyWith(isLoading: false, report: filteredReport);
  }

  Map<String, int> _parseRange(String category) {
    if (category == "6-8") return {"min": 6, "max": 8};
    if (category == "9-10") return {"min": 9, "max": 10};
    if (category == "11-12") return {"min": 11, "max": 12};
    return {"min": 0, "max": 99};
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}