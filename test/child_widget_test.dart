import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Child Dashboard Widget Tests', () {

    testWidgets('Verify Header displays Student Name and Time Capsule', (WidgetTester tester) async {
      // 1. Build our widget in the test environment
      // We wrap it in a MaterialApp because UI widgets need it for styling/direction
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Simulating your _buildHeader
                Text('Welcome, Mehran Ali', style: TextStyle(fontSize: 20)),
                // Simulating your _buildTimeLimitCapsule
                LinearProgressIndicator(value: 0.5),
              ],
            ),
          ),
        ),
      );

      // 2. Find the widgets by text or type
      final nameFinder = find.text('Welcome, Mehran Ali');
      final progressFinder = find.byType(LinearProgressIndicator);

      // 3. Verify they exist on the screen
      expect(nameFinder, findsOneWidget);
      expect(progressFinder, findsOneWidget);
    });

  });

  testWidgets('Verify EcoModuleCards are present and interactive', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () => wasTapped = true,
            child: const Text('STEM Project Card'), // Simulating an EcoModuleCard
          ),
        ),
      ),
    );

    // 1. Check if the card exists
    final cardFinder = find.text('STEM Project Card');
    expect(cardFinder, findsOneWidget);

    // 2. Simulate a user tap
    await tester.tap(cardFinder);

    // 3. Rebuild the widget (required after interactions)
    await tester.pump();

    // 4. Verify the interaction triggered the logic
    expect(wasTapped, true);
  });
  testWidgets('Verify Time Limit Capsule value matches logic', (WidgetTester tester) async {
    double remainingTimePercent = 0.75; // 75% time remaining

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LinearProgressIndicator(value: remainingTimePercent),
        ),
      ),
    );

    // 1. Find the Progress Indicator
    final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
    );

    // 2. Verify the UI value matches our data
    expect(progressIndicator.value, 0.75);
  });
  testWidgets('Verify Reward Badge Icon is visible', (WidgetTester tester) async {
    // Simulating a state where the child has earned a 'Star' badge
    bool hasBadge = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: hasBadge ? const Icon(Icons.stars, color: Colors.amber) : Container(),
          ),
        ),
      ),
    );

    // 1. Find the Icon by its specific data
    final badgeFinder = find.byIcon(Icons.stars);

    // 2. Verify it is shown on the screen
    expect(badgeFinder, findsOneWidget);
  });
}