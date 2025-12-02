import '../../../models/qr_hunt_read_model.dart';

class ChildQrHuntState {
  final bool isLoading;
  final List<QrHuntReadModel> hunts;
  final Map<String, QrHuntProgressModel> progressMap; // Key: huntId
  final String? errorMessage;
  final bool scanSuccess; // To trigger UI feedback

  ChildQrHuntState({
    this.isLoading = false,
    this.hunts = const [],
    this.progressMap = const {},
    this.errorMessage,
    this.scanSuccess = false,
  });

  ChildQrHuntState copyWith({
    bool? isLoading,
    List<QrHuntReadModel>? hunts,
    Map<String, QrHuntProgressModel>? progressMap,
    String? errorMessage,
    bool? scanSuccess,
  }) {
    return ChildQrHuntState(
      isLoading: isLoading ?? this.isLoading,
      hunts: hunts ?? this.hunts,
      progressMap: progressMap ?? this.progressMap,
      errorMessage: errorMessage,
      scanSuccess: scanSuccess ?? false,
    );
  }
}