import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../services/teacher/teacher_student_service.dart';
import 'teacher_home_state.dart';

class TeacherHomeViewModel extends StateNotifier<TeacherHomeState> {
  final TeacherStudentService _service;
  StreamSubscription? _subscription;

  TeacherHomeViewModel(this._service) : super(TeacherHomeState()) {
    _initStudentStream();
  }
  void _initStudentStream() {
    state = state.copyWith(isLoading: true);
    _subscription?.cancel();

    _subscription = _service.getStudentsStream().listen(
          (studentDataList) {
        final List<UserModel> studentModels = studentDataList.map((map) {

          final dynamic rawAge = map['studentAge'] ?? map['age'];

          int age = 0;

          if (rawAge is int) {
            age = rawAge;
          } else if (rawAge is String) {
            age = int.tryParse(rawAge.trim()) ?? 0;
          }

          print("AGE DEBUG => raw: $rawAge | parsed: $age");

          String group;
          if (age >= 11 && age <= 12) {
            group = "11 - 12";
          } else if (age >= 9 && age <= 10) {
            group = "9 - 10";
          } else if (age >= 6 && age <= 8) {
            group = "6 - 8";
          } else {
            group = "Unknown"; // important for catching bad data
          }

          final updatedMap = Map<String, dynamic>.from(map);
          updatedMap['ageGroup'] = group;

          return UserModel.fromMap(updatedMap);
        }).toList();

        state = state.copyWith(
          students: studentModels,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}