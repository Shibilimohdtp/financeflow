import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/features/personal_debts/add_edit_money_record_sheet.dart';
import 'package:financeflow/features/personal_debts/widgets/money_record_account_section.dart';
import 'package:financeflow/features/personal_debts/widgets/money_record_date_chips.dart';
import 'package:financeflow/features/personal_debts/widgets/money_record_direction_tiles.dart';
import 'package:financeflow/features/personal_debts/widgets/money_record_preview_card.dart';
import 'package:financeflow/repositories/money_record_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../helpers/fake_repositories.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: StillwaterTheme.daylight,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('B18b Add / Edit Subwidgets', () {
    testWidgets(
      'MoneyRecordPreviewCard renders preview with person and amount',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            MoneyRecordPreviewCard(
              personName: 'Rohan Sharma',
              type: MoneyRecordType.lent,
              amount: 5000.0,
              dueDate: DateTime(2026, 12, 1),
              isSettled: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Rohan Sharma'), findsOneWidget);
        expect(find.text('Rohan Sharma owes you'), findsOneWidget);
        expect(find.byType(MoneyRecordPreviewCard), findsOneWidget);
      },
    );

    testWidgets('MoneyRecordDirectionTiles toggles direction', (tester) async {
      MoneyRecordType selected = MoneyRecordType.lent;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder:
                (context, setState) => MoneyRecordDirectionTiles(
                  selectedType: selected,
                  onChanged: (val) => setState(() => selected = val),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('I lent money'), findsOneWidget);
      expect(find.text('I borrowed money'), findsOneWidget);

      await tester.tap(find.text('I borrowed money'));
      await tester.pumpAndSettle();

      expect(selected, MoneyRecordType.borrowed);
    });

    testWidgets('MoneyRecordDateChips changes date presets', (tester) async {
      final now = DateTime.now();
      DateTime txDate = DateTime(now.year, now.month, now.day);
      DateTime dueDate = txDate.add(const Duration(days: 14));

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder:
                (context, setState) => MoneyRecordDateChips(
                  transactionDate: txDate,
                  dueDate: dueDate,
                  onTransactionDateChanged: (d) => setState(() => txDate = d),
                  onDueDateChanged: (d) => setState(() => dueDate = d),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('In 1 week'), findsOneWidget);
      expect(find.text('In 2 weeks'), findsOneWidget);
      expect(find.text('End of month'), findsOneWidget);

      await tester.tap(find.text('In 1 week'));
      await tester.pumpAndSettle();

      final expectedWeek = txDate.add(const Duration(days: 7));
      expect(dueDate.year, expectedWeek.year);
      expect(dueDate.month, expectedWeek.month);
      expect(dueDate.day, expectedWeek.day);
    });

    testWidgets('MoneyRecordAccountSection toggles transaction recording', (
      tester,
    ) async {
      final testAccount = Account(
        id: 'acc_hdfc',
        name: 'HDFC Bank',
        type: AccountType.bank,
        currentBalance: 25000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool recordInTx = false;
      String? selectedAcc = 'acc_hdfc';

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder:
                (context, setState) => MoneyRecordAccountSection(
                  recordInTransactions: recordInTx,
                  onRecordInTransactionsChanged:
                      (v) => setState(() => recordInTx = v),
                  accounts: [testAccount],
                  selectedAccountId: selectedAcc,
                  onAccountSelected: (id) => setState(() => selectedAcc = id),
                  type: MoneyRecordType.lent,
                  amount: 1500.0,
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Record in my accounts'), findsOneWidget);
      // Consequence line is hidden when toggle is off
      expect(find.textContaining('Takes ₹1,500 from HDFC Bank'), findsNothing);

      // Toggle switch
      await tester.tap(find.text('Record in my accounts'));
      await tester.pumpAndSettle();

      expect(recordInTx, isTrue);
      expect(
        find.textContaining('Takes ₹1,500 from HDFC Bank'),
        findsOneWidget,
      );
    });
  });

  group('AddEditMoneyRecordSheet Flow', () {
    testWidgets('shows collision banner when existing open record matches', (
      tester,
    ) async {
      final existingRecord = MoneyRecord(
        id: 'rec_existing',
        type: MoneyRecordType.lent,
        personName: 'Vikram',
        normalizedPersonName: 'vikram',
        originalAmount: 3000.0,
        transactionDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [existingRecord],
        initialRepayments: [],
      );

      await tester.pumpWidget(
        _wrap(
          const AddEditMoneyRecordSheet(),
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Enter name Vikram
      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'Vikram',
      );
      await tester.pumpAndSettle();

      // Collision banner should appear
      expect(
        find.textContaining('already has an open lent record'),
        findsOneWidget,
      );
    });
  });
}
