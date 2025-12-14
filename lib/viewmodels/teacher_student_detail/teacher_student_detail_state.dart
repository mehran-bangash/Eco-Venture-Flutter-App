
import '../../models/teacher_student_detail_model.dart';

class TeacherStudentDetailState {
  final bool isLoading;
  final TeacherStudentDetailModel? student;
  final String? errorMessage;

  TeacherStudentDetailState({
    this.isLoading = true,
    this.student,
    this.errorMessage,
  });

  TeacherStudentDetailState copyWith({
    bool? isLoading,
    TeacherStudentDetailModel? student,
    String? errorMessage,
  }) {
    return TeacherStudentDetailState(
      isLoading: isLoading ?? this.isLoading,
      student: student ?? this.student,
      errorMessage: errorMessage,
    );
  }
}