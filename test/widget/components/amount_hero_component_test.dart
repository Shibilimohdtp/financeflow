import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/ff_amount_hero.dart';
import 'package:financeflow/shared/widgets/ff_suggestion_chips.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  Widget buildApp(Widget child, {bool dark = false, double textScale = 1.0}) {
    return MaterialApp(
      theme: dark ? StillwaterTheme.deepWater : StillwaterTheme.daylight,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  group('FfAmountHero', () {
    testWidgets('renders label, initial text and currency symbol', (
      tester,
    ) async {
      final controller = TextEditingController(text: '450');
      await tester.pumpWidget(
        buildApp(
          FfAmountHero(
            controller: controller,
            label: 'Amount spent',
            tone: FfTone.expense,
          ),
        ),
      );

      expect(find.text('Amount spent'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      expect(find.text('₹ '), findsOneWidget);
    });

    testWidgets('renders consequence line when provided', (tester) async {
      final controller = TextEditingController(text: '1200');
      await tester.pumpWidget(
        buildApp(
          FfAmountHero(
            controller: controller,
            label: 'Amount spent',
            consequence: 'Cash balance after: ₹3,800',
            consequenceIcon: Icons.payments_outlined,
          ),
        ),
      );

      expect(find.text('Cash balance after: ₹3,800'), findsOneWidget);
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('renders error text in place of consequence', (tester) async {
      final controller = TextEditingController(text: '0');
      await tester.pumpWidget(
        buildApp(
          FfAmountHero(
            controller: controller,
            label: 'Amount spent',
            consequence: 'Cash balance after: ₹3,800',
            errorText: 'Please enter an amount greater than zero.',
          ),
        ),
      );

      expect(
        find.text('Please enter an amount greater than zero.'),
        findsOneWidget,
      );
      expect(find.text('Cash balance after: ₹3,800'), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping clear button triggers onClear callback', (
      tester,
    ) async {
      final controller = TextEditingController(text: '999');
      var cleared = false;
      await tester.pumpWidget(
        buildApp(
          FfAmountHero(
            controller: controller,
            onClear: () {
              cleared = true;
              controller.clear();
            },
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });

    testWidgets('renders without overflow in dark mode at 2x text scale', (
      tester,
    ) async {
      final controller = TextEditingController(text: '12345.67');
      await tester.pumpWidget(
        buildApp(
          FfAmountHero(
            controller: controller,
            label: 'Amount received',
            tone: FfTone.income,
            consequence: 'Savings balance after: ₹1,50,000',
          ),
          dark: true,
          textScale: 2.0,
        ),
      );

      expect(find.text('Amount received'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FfSuggestionChips', () {
    testWidgets('renders items and handles tap selection', (tester) async {
      String? selected;
      await tester.pumpWidget(
        buildApp(
          FfSuggestionChips<String>(
            items: const [
              FfSuggestionChipItem(
                value: 'swiggy',
                label: 'Swiggy',
                icon: Icons.restaurant,
              ),
              FfSuggestionChipItem(value: 'zomato', label: 'Zomato'),
              FfSuggestionChipItem(value: 'lulu', label: 'Lulu Hypermarket'),
            ],
            onSelected: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Swiggy'), findsOneWidget);
      expect(find.text('Zomato'), findsOneWidget);
      expect(find.text('Lulu Hypermarket'), findsOneWidget);

      await tester.tap(find.text('Swiggy'));
      await tester.pumpAndSettle();

      expect(selected, 'swiggy');
    });
  });
}
