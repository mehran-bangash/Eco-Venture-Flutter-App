


class ChildProgressState {
  final bool isLoading;
  final int totalPoints;
  final int currentLevel;
  final double xpProgress; // 0.0 - 1.0
  final Map<String, double> skillStats; // {"Science": 0.8, ...}
  final List<Map<String, dynamic>> timeline; // Formatted for UI
  final int dayStreak;

  ChildProgressState({
    this.isLoading = true,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.xpProgress = 0.0,
    this.skillStats = const {'Science': 0.1, 'Math': 0.1, 'Logic': 0.1, 'Creativity': 0.1},
    this.timeline = const [],
    this.dayStreak = 0,
  });

  ChildProgressState copyWith({
    bool? isLoading,
    int? totalPoints,
    int? currentLevel,
    double? xpProgress,
    Map<String, double>? skillStats,
    List<Map<String, dynamic>>? timeline,
    int? dayStreak,
  }) {
    return ChildProgressState(
      isLoading: isLoading ?? this.isLoading,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      xpProgress: xpProgress ?? this.xpProgress,
      skillStats: skillStats ?? this.skillStats,
      timeline: timeline ?? this.timeline,
      dayStreak: dayStreak ?? this.dayStreak,
    );
  }
}