
class ChildRewardsState {
  final int totalPoints;
  final int badgesEarned;
  final int currentLevel;
  final double xpProgress;
  final List<Map<String, dynamic>> recentAchievements;
  final bool isLoading;

  final int quizCount;
  final int stemCount;
  final int videoCount;
  final int qrCount;

  // NEW: Stores the name of a badge if JUST earned (null otherwise)
  final String? newEarnedBadge;

  ChildRewardsState({
    this.totalPoints = 0,
    this.badgesEarned = 0,
    this.currentLevel = 1,
    this.xpProgress = 0.0,
    this.recentAchievements = const [],
    this.isLoading = true,
    this.quizCount = 0,
    this.stemCount = 0,
    this.videoCount = 0,
    this.qrCount = 0,
    this.newEarnedBadge,
  });

  // Add copyWith for cleaner updates
  ChildRewardsState copyWith({
    int? totalPoints, int? badgesEarned, int? currentLevel, double? xpProgress,
    List<Map<String, dynamic>>? recentAchievements, bool? isLoading,
    int? quizCount, int? stemCount, int? videoCount, int? qrCount,
    String? newEarnedBadge,
  }) {
    return ChildRewardsState(
      totalPoints: totalPoints ?? this.totalPoints,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      currentLevel: currentLevel ?? this.currentLevel,
      xpProgress: xpProgress ?? this.xpProgress,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      isLoading: isLoading ?? this.isLoading,
      quizCount: quizCount ?? this.quizCount,
      stemCount: stemCount ?? this.stemCount,
      videoCount: videoCount ?? this.videoCount,
      qrCount: qrCount ?? this.qrCount,
      newEarnedBadge: newEarnedBadge, // Nullable update
    );
  }
}
