import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/teacher_class_report_repository.dart';
import 'teacher_class_report_state.dart';

class TeacherClassReportViewModel extends StateNotifier<TeacherClassReportState> {
  final TeacherClassReportRepository _repository;
  StreamSubscription? _sub;

  TeacherClassReportViewModel(this._repository) : super(TeacherClassReportState()) {
    _loadReport();
  }

  void _loadReport() {
    state = state.copyWith(isLoading: true);

    _sub?.cancel();
    _sub = _repository.getClassReport().listen(
            (data) {
          state = state.copyWith(isLoading: false, report: data);
        },
        onError: (e) {
          print("Class Report Error: $e");
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}