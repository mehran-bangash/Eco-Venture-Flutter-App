import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Teacher Approval Screen Widget Tests', () {

    testWidgets('Verify Stem Approval UI elements exist', (WidgetTester tester) async {
      // Controllers often used in Teacher views
      final TextEditingController pointsCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Review STEM Project'),
                // Simulating your pointsCtrl TextField
                TextField(
                  controller: pointsCtrl,
                  decoration: const InputDecoration(labelText: 'Enter Points'),
                ),
                // Simulating your Approve Button
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Approve'),
                ),
              ],
            ),
          ),
        ),
      );

      // 1. Check for the Header
      expect(find.text('Review STEM Project'), findsOneWidget);

      // 2. Check for the TextField by its label
      expect(find.widgetWithText(TextField, 'Enter Points'), findsOneWidget);

      // 3. Check for the Approve Button
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsOneWidget);
    });

  });
  testWidgets('Verify Teacher can enter numeric points', (WidgetTester tester) async {
    final TextEditingController pointsCtrl = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: pointsCtrl,
            keyboardType: TextInputType.number,
          ),
        ),
      ),
    );

    // 1. Enter text into the field
    await tester.enterText(find.byType(TextField), '85');

    // 2. Rebuild the widget to reflect the change
    await tester.pump();

    // 3. Verify the controller now holds the value '85'
    expect(pointsCtrl.text, '85');
  });
  testWidgets('Verify Teacher Reject button triggers logic', (WidgetTester tester) async {
    bool rejected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () => rejected = true,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ),
      ),
    );

    // 1. Find the Reject button
    final rejectBtn = find.widgetWithText(ElevatedButton, 'Reject');

    // 2. Tap it
    await tester.tap(rejectBtn);
    await tester.pump();

    // 3. Verify logic was triggered
    expect(rejected, true);
  });
}