import '../../../models/parent_alert_model.dart';
import '../../../models/parent_safety_settings_model.dart';


class ParentSafetyState {
  final bool isLoading;
  final String? errorMessage;
  final ParentSafetySettingsModel settings;
  final List<ParentAlertModel> alerts;
  final String? selectedChildId;

  // FIX: Added missing field
  final List<Map<String, dynamic>> linkedChildren;

  ParentSafetyState({
    this.isLoading = false,
    this.errorMessage,
    required this.settings,
    this.alerts = const [],
    this.selectedChildId,
    this.linkedChildren = const [],
  });

  factory ParentSafetyState.initial() {
    return ParentSafetyState(settings: ParentSafetySettingsModel());
  }

  ParentSafetyState copyWith({
    bool? isLoading,
    String? errorMessage,
    ParentSafetySettingsModel? settings,
    List<ParentAlertModel>? alerts,
    String? selectedChildId,
    List<Map<String, dynamic>>? linkedChildren,
  }) {
    return ParentSafetyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      settings: settings ?? this.settings,
      alerts: alerts ?? this.alerts,
      selectedChildId: selectedChildId ?? this.selectedChildId,
      linkedChildren: linkedChildren ?? this.linkedChildren,
    );
  }
}