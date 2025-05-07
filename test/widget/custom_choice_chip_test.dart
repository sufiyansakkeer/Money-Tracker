import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/custom_choice_chip.dart';

void main() {
  group('CustomChoiceChip Widget Tests', () {
    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChoiceChip(
              name: 'Test Chip',
              selected: true,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.text('Test Chip'), findsOneWidget);

      // Verify it's a ChoiceChip
      final choiceChip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(choiceChip.selected, isTrue);

      // Verify the selected state styling
      final textWidget = tester.widget<Text>(find.text('Test Chip'));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('renders correctly when not selected',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChoiceChip(
              name: 'Test Chip',
              selected: false,
              onSelected: (value) {},
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.text('Test Chip'), findsOneWidget);

      // Verify it's a ChoiceChip
      final choiceChip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(choiceChip.selected, isFalse);
    });

    testWidgets('calls onSelected when tapped', (WidgetTester tester) async {
      bool wasSelected = false;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomChoiceChip(
              name: 'Test Chip',
              selected: false,
              onSelected: (value) {
                wasSelected = value;
              },
            ),
          ),
        ),
      );

      // Tap the chip
      await tester.tap(find.byType(ChoiceChip));
      await tester.pump();

      // Verify onSelected was called
      expect(wasSelected, isTrue);
    });
  });
}
