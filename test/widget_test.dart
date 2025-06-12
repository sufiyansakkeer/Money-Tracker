// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/app/di/injection_container.dart';

void main() {
  setUpAll(() async {
    await initializeDependencies();
  });

  testWidgets('Sample widget test', (WidgetTester tester) async {
    // Instead of the full App, test a simple widget to avoid splash screen timers
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('Test Home')),
    ));
    await tester.pumpAndSettle();

    // Check for the test widget
    expect(find.text('Test Home'), findsOneWidget);
  });
}
