class ParentSafetySettingsModel {
  final double dailyLimitHours;
  final String bedtimeStart; // "21:00"
  final String bedtimeEnd;   // "07:00"
  final bool enableBreakReminders;

  // NEW: App Pause State
  final bool isAppPaused;

  // Content Filters
  final bool blockScaryContent;
  final bool blockSocialInteraction;
  final bool educationalOnlyMode;

  ParentSafetySettingsModel({
    this.dailyLimitHours = 2.5,
    this.bedtimeStart = "21:00",
    this.bedtimeEnd = "07:00",
    this.enableBreakReminders = true,
    this.isAppPaused = false, // Default false
    this.blockScaryContent = true,
    this.blockSocialInteraction = true,
    this.educationalOnlyMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'daily_limit_hours': dailyLimitHours,
      'bedtime_start': bedtimeStart,
      'bedtime_end': bedtimeEnd,
      'enable_break_reminders': enableBreakReminders,
      'is_app_paused': isAppPaused, // Added
      'block_scary_content': blockScaryContent,
      'block_social_interaction': blockSocialInteraction,
      'educational_only_mode': educationalOnlyMode,
    };
  }

  factory ParentSafetySettingsModel.fromMap(Map<String, dynamic> map) {
    return ParentSafetySettingsModel(
      dailyLimitHours: (map['daily_limit_hours'] as num? ?? 2.5).toDouble(),
      bedtimeStart: map['bedtime_start'] ?? "21:00",
      bedtimeEnd: map['bedtime_end'] ?? "07:00",
      enableBreakReminders: map['enable_break_reminders'] ?? true,
      isAppPaused: map['is_app_paused'] ?? false, // Added
      blockScaryContent: map['block_scary_content'] ?? true,
      blockSocialInteraction: map['block_social_interaction'] ?? true,
      educationalOnlyMode: map['educational_only_mode'] ?? false,
    );
  }

  ParentSafetySettingsModel copyWith({
    double? dailyLimitHours,
    String? bedtimeStart,
    String? bedtimeEnd,
    bool? enableBreakReminders,
    bool? isAppPaused, // Added
    bool? blockScaryContent,
    bool? blockSocialInteraction,
    bool? educationalOnlyMode,
  }) {
    return ParentSafetySettingsModel(
      dailyLimitHours: dailyLimitHours ?? this.dailyLimitHours,
      bedtimeStart: bedtimeStart ?? this.bedtimeStart,
      bedtimeEnd: bedtimeEnd ?? this.bedtimeEnd,
      enableBreakReminders: enableBreakReminders ?? this.enableBreakReminders,
      isAppPaused: isAppPaused ?? this.isAppPaused, // Added
      blockScaryContent: blockScaryContent ?? this.blockScaryContent,
      blockSocialInteraction: blockSocialInteraction ?? this.blockSocialInteraction,
      educationalOnlyMode: educationalOnlyMode ?? this.educationalOnlyMode,
    );
  }
}
