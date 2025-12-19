import '../../../models/nature_photo_upload_model.dart';

// 1. THE STATE: What the UI looks like at any moment
class NatureState {
  final bool isLoading;
  final JournalEntry? entry; // The result (Card Data)
  final String? error;       // Error message if any

  NatureState({
    this.isLoading = false,
    this.entry,
    this.error,
  });

  // Helper to make updates easier
  NatureState copyWith({
    bool? isLoading,
    JournalEntry? entry,
    String? error,
  }) {
    return NatureState(
      isLoading: isLoading ?? this.isLoading,
      entry: entry ?? this.entry,
      error: error ?? this.error,
    );
  }
}