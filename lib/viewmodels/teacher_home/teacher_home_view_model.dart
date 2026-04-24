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

          // FIX: Prioritize 'studentAge' and handle parsing strictly
          final dynamic rawAge = map['studentAge'] ?? map['age'] ?? 0;
          final int age = int.tryParse(rawAge.toString()) ?? 0;

          String group;
          if (age >= 11) {
            group = "10 - 12";
          } else if (age >= 9) {
            group = "9 - 10"; // Age 9 & 10 go here
          } else {
            group = "6 - 8"; // Everything else (6, 7, 8)
          }

          // We inject the correct ageGroup into the map before creating the model
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
        state = state.copyWith(isLoading: false, errorMessage: error.toString());
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}