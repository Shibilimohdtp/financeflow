import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/shared/widgets/ff_amount_text.dart';
import 'package:financeflow/shared/widgets/ff_account_preview_card.dart';
import 'package:financeflow/shared/widgets/ff_account_type_tiles.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  Widget buildApp(Widget child, {bool dark = false}) {
    return MaterialApp(
      theme: dark ? StillwaterTheme.deepWater : StillwaterTheme.daylight,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  group('FfAccountPreviewCard', () {
    testWidgets('renders placeholder when name is empty', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FfAccountPreviewCard(accountType: AccountType.bank, balance: 0),
        ),
      );

      expect(find.text('Your account name'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.byType(FfAmountText), findsOneWidget);
    });

    testWidgets('renders filled values and masked pill', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FfAccountPreviewCard(
            accountType: AccountType.bank,
            name: 'Emergency Fund',
            institutionName: 'HDFC Bank',
            maskedIdentifier: '4321',
            balance: 54000,
          ),
        ),
      );

      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('•••• 4321'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('credit card displays Balance label', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FfAccountPreviewCard(
            accountType: AccountType.creditCard,
            name: 'Amazon ICICI',
            balance: -12500,
          ),
        ),
      );

      expect(find.text('Amazon ICICI'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('renders in dark theme without crash', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FfAccountPreviewCard(
            accountType: AccountType.cash,
            name: 'Pocket Money',
            balance: 1500,
          ),
          dark: true,
        ),
      );

      expect(find.text('Pocket Money'), findsOneWidget);
    });
  });

  group('FfAccountTypeTiles', () {
    testWidgets('renders all 6 types and handles selection', (tester) async {
      AccountType selected = AccountType.bank;

      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder:
                (context, setState) => FfAccountTypeTiles(
                  selectedType: selected,
                  onChanged: (newType) {
                    setState(() => selected = newType);
                  },
                ),
          ),
        ),
      );

      // Verify labels
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Invest'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);

      // Checkmark only for selected
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Tap Card
      await tester.tap(find.text('Card'));
      await tester.pumpAndSettle();

      expect(selected, AccountType.creditCard);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('touch targets meet minimum 48 dp height', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FfAccountTypeTiles(selectedType: AccountType.bank, onChanged: (_) {}),
        ),
      );

      final tiles = find.byType(InkWell);
      expect(tiles, findsNWidgets(6));

      for (var i = 0; i < 6; i++) {
        final size = tester.getSize(tiles.at(i));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });
  });
}
