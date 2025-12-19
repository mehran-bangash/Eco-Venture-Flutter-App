import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/nature_photo_upload_model.dart';
import '../../../repositories/nature_repository.dart';
import 'nature_photo_state.dart';


// 2. THE VIEWMODEL
class NatureViewModel extends StateNotifier<NatureState> {
  final NatureRepository _repository;

  NatureViewModel(this._repository) : super(NatureState());

  // METHOD A: Scan & Save (Connects to Repo)
  Future<void> scanNature(File imageFile, String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final JournalEntry result = await _repository.processAndSaveEntry(imageFile, userId);
      state = state.copyWith(
        isLoading: false,
        entry: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Scan failed: ${e.toString()}",
      );
    }
  }

  // METHOD B: Delete (Used by Dismissible)
  Future<void> deleteEntry(String userId, String entryId) async {
    try {
      // We don't set 'isLoading' here because the UI (Dismissible)
      // usually handles the animation instantly.
      await _repository.deleteEntry(userId, entryId);
    } catch (e) {
      state = state.copyWith(error: "Delete failed: ${e.toString()}");
    }
  }

  // METHOD C: Update (For editing notes later)
  Future<void> updateEntry(String userId, JournalEntry updatedEntry) async {
    try {
      await _repository.updateEntry(userId, updatedEntry);
      // Update local state if the currently viewed entry is the one being updated
      if (state.entry?.id == updatedEntry.id) {
        state = state.copyWith(entry: updatedEntry);
      }
    } catch (e) {
      state = state.copyWith(error: "Update failed: ${e.toString()}");
    }
  }

  // METHOD D: Reset (Clears screen for a fresh start)
  void reset() {
    state = NatureState(); // Reverts to initial empty state
  }
}

// 3. THE PROVIDER
final natureProvider = StateNotifierProvider<NatureViewModel, NatureState>((ref) {
  // We return the ViewModel initialized with the Repository
  return NatureViewModel(NatureRepository());
});