import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parent Role Unit Tests', () {

    test('Parent Logic: Verify linked child email matching', () {
      String parentStoredChildEmail = 'child@example.com';
      String childLoginEmail = 'CHILD@example.com'; // User typed with caps

      // Logic: Email check should be case-insensitive to avoid login errors
      bool isMatch = parentStoredChildEmail.toLowerCase() == childLoginEmail.toLowerCase();

      expect(isMatch, true);
    });

  });
  test('Parent Logic: Weekly progress percentage calculation', () {
    int activitiesDone = 7;
    int weeklyGoal = 10;

    // Logic: (Done / Goal) * 100
    double progressPercentage = (activitiesDone / weeklyGoal) * 100;

    expect(progressPercentage, 70.0);
  });
  test('Parent Logic: Screen time limit alert', () {
    int minutesUsed = 65;
    int dailyLimit = 60;
    bool isLimitExceeded = false;

    // Logic: True if usage is greater than the limit
    if (minutesUsed > dailyLimit) {
      isLimitExceeded = true;
    }

    expect(isLimitExceeded, true);
  });

  test('Parent Logic: Sort activities by date (Newest first)', () {
    List<Map<String, dynamic>> activities = [
      {'name': 'Quiz 1', 'date': 20240101},
      {'name': 'Quiz 2', 'date': 20240105}, // Newer date
    ];

    // Logic: Sort by date descending
    activities.sort((a, b) => b['date'].compareTo(a['date']));

    expect(activities[0]['name'], 'Quiz 2');
  });

  test('Parent Logic: Switch active child view', () {
    String selectedChild = 'Child_A';

    // Action: Parent clicks on Child_B's profile
    selectedChild = 'Child_B';

    expect(selectedChild, 'Child_B');
  });
}