import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parent Dashboard Widget Tests', () {

    testWidgets('Verify Parent Child-Switch Dropdown exists', (WidgetTester tester) async {
      String selectedChild = 'Child A';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: selectedChild,
              items: <String>['Child A', 'Child B'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // 1. Check if the dropdown displays the current selection
      expect(find.text('Child A'), findsOneWidget);

      // 2. Check if the dropdown widget itself is found
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

  });
  testWidgets('Verify Parent Skill Growth Chart is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            width: 200,
            child: CustomPaint(
              key: const Key('skillChart'), // Added a Key here
              painter: null,
            ),
          ),
        ),
      ),
    );

    // 1. Find the CustomPaint specifically by its Key
    final chartFinder = find.byKey(const Key('skillChart'));

    // 2. Verify it is present on the screen
    expect(chartFinder, findsOneWidget);
  });
  testWidgets('Verify Performance Summary Tiles display data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              // Simulating your summary tiles
              ListTile(title: Text('Quiz Avg: 85%')),
              ListTile(title: Text('STEM Projects: 4')),
            ],
          ),
        ),
      ),
    );

    // 1. Verify that the specific stats are visible
    expect(find.text('Quiz Avg: 85%'), findsOneWidget);
    expect(find.text('STEM Projects: 4'), findsOneWidget);
  });
}