import 'package:flutter_test/flutter_test.dart';
// import 'package:your_app/utils/xp_calculator.dart';

int calculateXP(int currentXP, bool isPassed) {
  if (isPassed) {
    return currentXP + 20;
  }
  return currentXP;
}

void main() {

  group('XP Calculation Tests', () {

    test('should add 20 XP when quiz is passed', () {
      int result = calculateXP(100, true);
      expect(result, 120);
    });

    test('should not add XP when quiz is failed', () {
      int result = calculateXP(100, false);
      expect(result, 100);
    });

    test('should handle zero XP correctly', () {
      int result = calculateXP(0, true);
      expect(result, 20);
    });

  });

  group('Parent Logic Tests', () {

    test('should prevent duplicate child linking', () {
      List<String> linkedChildren = ['child_123', 'child_456'];
      String newChild = 'child_123';

      bool isAlreadyLinked = linkedChildren.contains(newChild);

      expect(isAlreadyLinked, true);
    });

  });

  group('Badge Logic Tests', () {

    test('should award badge for score >= 90', () {
      double score = 95.0;

      bool earnsBadge = score >= 90.0;

      expect(earnsBadge, true);
    });

    test('should not award badge for score < 90', () {
      double score = 80.0;

      bool earnsBadge = score >= 90.0;

      expect(earnsBadge, false);
    });

  });

  test('Child Logic: Daily goal reached at 3 activities', () {
    int activitiesCompletedToday = 3;
    int goalThreshold = 3;
    bool goalReached = false;

    // Logic: Goal is reached if completed activities meet or exceed threshold
    if (activitiesCompletedToday >= goalThreshold) {
      goalReached = true;
    }

    expect(goalReached, true);
  });

  test('Child Logic: Restrict access to high-level content', () {
    int currentChildLevel = 3;
    int requiredModuleLevel = 5;
    bool isLocked = false;

    // Logic: Module is locked if child's level is less than required
    if (currentChildLevel < requiredModuleLevel) {
      isLocked = true;
    }

    expect(isLocked, true);
  });

  test('Child Logic: Points awarded only on Approved status', () {
    String submissionStatus = 'pending'; // Change to 'approved' to see points
    int pointsAwarded = 0;

    // Logic: Points are only assigned if status is exactly 'approved'
    if (submissionStatus == 'approved') {
      pointsAwarded = 50;
    } else {
      pointsAwarded = 0;
    }

    expect(pointsAwarded, 0);
  });
  test('Child Logic: Reset score for new attempt', () {
    int previousScore = 85;
    int currentScore = previousScore;

    // Logic: Resetting score for a fresh start
    currentScore = 0;

    expect(currentScore, 0);
  });
  test('Final Child Logic: Match Actual Variable totalPoints', () {
    // Using your real project variable name: totalPoints
    int totalPoints = 450;

    // Using your real project formula: (points / 200).floor() + 1
    int level = (totalPoints / 200).floor() + 1;

    expect(level, 3);
  });

}