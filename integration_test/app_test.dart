import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_track/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts with the splash screen
      expect(find.byType(Image), findsWidgets);
      
      // Wait for navigation to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify we're on the main screen
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Tap on the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Verify we're on the transaction page
      expect(find.text('Add Transaction'), findsOneWidget);
    });
  });
}
