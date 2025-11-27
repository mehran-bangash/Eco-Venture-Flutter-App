import '../../models/qr_hunt_model.dart';


class TeacherTreasureHuntState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<QrHuntModel> hunts;

  TeacherTreasureHuntState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.hunts = const [],
  });

  TeacherTreasureHuntState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<QrHuntModel>? hunts,
  }) {
    return TeacherTreasureHuntState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      hunts: hunts ?? this.hunts,
    );
  }
}