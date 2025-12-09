import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/parent_safety_repository.dart';
import '../../../services/shared_preferences_helper.dart';
import 'parent_safety_state.dart';


class ParentSafetyViewModel extends StateNotifier<ParentSafetyState> {
  final ParentSafetyRepository _repository;

  StreamSubscription? _settingsSub;
  StreamSubscription? _alertsSub;

  ParentSafetyViewModel(this._repository) : super(ParentSafetyState.initial());

  // --- NEW: FETCH LINKED CHILDREN ---
  Future<void> fetchLinkedChildren() async {
    state = state.copyWith(isLoading: true);
    try {
      final parentId = await SharedPreferencesHelper.instance.getUserId();
      if (parentId == null) {
        state = state.copyWith(isLoading: false); // Or handle error
        return;
      }

      final children = await _repository.getLinkedChildren(parentId);
      state = state.copyWith(isLoading: false, linkedChildren: children);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to load children: $e");
    }
  }

  // --- NEW: LINK CHILD ---
  Future<void> linkChildByEmail(String email, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      final parentId = await SharedPreferencesHelper.instance.getUserId();
      if (parentId == null) throw Exception("Parent not logged in");

      final childUid = await _repository.linkChild(parentId, email, name);

      // Refresh list
      await fetchLinkedChildren();

      // Auto-select and stop loading
      selectChild(childUid);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- EXISTING LOGIC ---
  void selectChild(String childId) {
    state = state.copyWith(selectedChildId: childId, isLoading: true);
    _subscribeToStreams(childId);
  }

  void _subscribeToStreams(String childId) {
    _settingsSub?.cancel();
    _alertsSub?.cancel();

    _settingsSub = _repository.watchSettings(childId).listen(
          (newSettings) {
        state = state.copyWith(settings: newSettings, isLoading: false);
      },
      onError: (e) => state = state.copyWith(errorMessage: "Settings Error: $e", isLoading: false),
    );

    _alertsSub = _repository.watchAlerts(childId).listen(
          (newAlerts) {
        state = state.copyWith(alerts: newAlerts);
      },
      onError: (e) => state = state.copyWith(errorMessage: "Alerts Error: $e"),
    );
  }

  Future<void> updateTimeSettings({double? limit, String? start, String? end, bool? reminders}) async {
    if (state.selectedChildId == null) return;
    final newSettings = state.settings.copyWith(dailyLimitHours: limit, bedtimeStart: start, bedtimeEnd: end, enableBreakReminders: reminders);
    state = state.copyWith(settings: newSettings);
    try { await _repository.saveSettings(state.selectedChildId!, newSettings); }
    catch (e) { state = state.copyWith(errorMessage: "Failed to save settings"); }
  }

  Future<void> updateContentFilters({bool? scary, bool? social, bool? eduOnly}) async {
    if (state.selectedChildId == null) return;
    final newSettings = state.settings.copyWith(blockScaryContent: scary, blockSocialInteraction: social, educationalOnlyMode: eduOnly);
    state = state.copyWith(settings: newSettings);
    try { await _repository.saveSettings(state.selectedChildId!, newSettings); }
    catch (e) { state = state.copyWith(errorMessage: "Failed to save filters"); }
  }

  Future<void> markAlertResolved(String alertId) async {
    if (state.selectedChildId == null) return;
    await _repository.resolveAlert(state.selectedChildId!, alertId);
  }
  Future<void> unlinkChild(String childUid) async {
    // 1. Optimistic Update (Update State Immediately)
    final currentList = [...state.linkedChildren];
    currentList.removeWhere((c) => c['uid'] == childUid);
    state = state.copyWith(linkedChildren: currentList);

    try {
      final parentId = await SharedPreferencesHelper.instance.getUserId();
      if (parentId != null) {
        // 2. Call Backend
        await _repository.unlinkChild(parentId, childUid);
      }
    } catch (e) {
      // Revert on error
      state = state.copyWith(errorMessage: "Failed to unlink: $e");
      fetchLinkedChildren(); // Reload real data
    }
  }
  Future<void> toggleAppPause(bool isPaused) async {
    if (state.selectedChildId == null) return;

    final newSettings = state.settings.copyWith(
      isAppPaused: isPaused,
    );

    // Optimistic Update
    state = state.copyWith(settings: newSettings);

    try {
      await _repository.saveSettings(state.selectedChildId!, newSettings);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pause app");
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _alertsSub?.cancel();
    super.dispose();
  }
}