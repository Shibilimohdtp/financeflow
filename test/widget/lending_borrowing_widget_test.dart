import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/personal_debts/add_edit_money_record_sheet.dart';
import 'package:financeflow/features/personal_debts/add_repayment_sheet.dart';
import 'package:financeflow/features/personal_debts/lending_borrowing_screen.dart';
import 'package:financeflow/features/personal_debts/money_record_detail_screen.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/repositories/money_record_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../helpers/fake_repositories.dart';

void main() {
  final testRecord1 = MoneyRecord(
    id: 'rec_lent_1',
    type: MoneyRecordType.lent,
    personName: 'Ahmed',
    originalAmount: 10000.0,
    transactionDate: DateTime(2026, 2, 1),
    dueDate: DateTime(2026, 3, 1), // Overdue
    notes: 'Emergency expense',
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 1),
  );

  final testRecord2 = MoneyRecord(
    id: 'rec_borrowed_1',
    type: MoneyRecordType.borrowed,
    personName: 'Sarah',
    originalAmount: 5000.0,
    transactionDate: DateTime(2026, 3, 5),
    dueDate: DateTime(2026, 4, 5),
    createdAt: DateTime(2026, 3, 5),
    updatedAt: DateTime(2026, 3, 5),
  );

  final testRepayment1 = MoneyRepayment(
    id: 'rep_1',
    moneyRecordId: 'rec_lent_1',
    amount: 3000.0,
    repaymentDate: DateTime(2026, 2, 15),
    notes: 'First installment',
    createdAt: DateTime(2026, 2, 15),
  );

  testWidgets(
    'LendingBorrowingScreen renders empty state when no records exist',
    (WidgetTester tester) async {
      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [],
        initialRepayments: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const LendingBorrowingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lending & Borrowing'), findsOneWidget);
      expect(find.text('OWED TO ME'), findsOneWidget);
      expect(find.text('I OWE'), findsOneWidget);
      expect(find.text('No Lending or Borrowing Records'), findsOneWidget);
      expect(find.text('Add Record'), findsWidgets);
    },
  );

  testWidgets(
    'LendingBorrowingScreen renders hero cards, filters, and records list',
    (WidgetTester tester) async {
      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [testRecord1, testRecord2],
        initialRepayments: [testRepayment1],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const LendingBorrowingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header summary cards
      expect(find.text('OWED TO ME'), findsOneWidget);
      expect(find.text('I OWE'), findsOneWidget);
      expect(find.text('₹7,000'), findsWidgets); // Summary card + Ahmed card
      expect(find.text('₹5,000'), findsWidgets); // Summary card + Sarah card

      // Verify list items
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
      expect(find.text('Emergency expense'), findsOneWidget);

      // Test filter chip switching
      await tester.tap(find.text('Owed to Me'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Sarah'), findsNothing);

      await tester.tap(find.text('I Owe'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmed'), findsNothing);
      expect(find.text('Sarah'), findsOneWidget);
    },
  );

  testWidgets(
    'AddEditMoneyRecordSheet validates and allows creating a record',
    (WidgetTester tester) async {
      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [],
        initialRepayments: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const Scaffold(
              body: AddEditMoneyRecordSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('I Lent Money'), findsWidgets);
      expect(find.text('Save Record'), findsOneWidget);

      // Attempt submit without filling
      await tester.tap(find.text('Save Record'));
      await tester.pumpAndSettle();

      expect(find.text("Person's name is required"), findsOneWidget);

      // Enter name and amount
      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'Uncle Robert',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '0.00'),
        '15000',
      );

      await tester.tap(find.text('Save Record'));
      await tester.pumpAndSettle();

      final allRecords = await fakeRepo.getAllRecords();
      expect(allRecords.length, 1);
      expect(allRecords.first.personName, 'Uncle Robert');
      expect(allRecords.first.originalAmount, 15000.0);
    },
  );

  testWidgets(
    'MoneyRecordDetailScreen displays details, allows adding repayment and settling',
    (WidgetTester tester) async {
      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [testRecord1],
        initialRepayments: [testRepayment1],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: MoneyRecordDetailScreen(record: testRecord1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ahmed'), findsWidgets);
      expect(find.text('REMAINING BALANCE'), findsOneWidget);
      expect(find.text('₹7,000'), findsOneWidget);
      expect(find.text('₹10,000'), findsOneWidget); // Original
      expect(find.text('₹3,000 (30%)'), findsOneWidget); // Repaid
      expect(find.text('Record Repayment'), findsOneWidget);
      expect(find.text('Settle'), findsOneWidget);

      // Settle the record
      await tester.tap(find.text('Settle'));
      await tester.pumpAndSettle();

      final updated = await fakeRepo.getRecordById(testRecord1.id);
      expect(updated?.settledAt, isNotNull);
    },
  );

  testWidgets(
    'AddRepaymentSheet validates and records partial repayment',
    (WidgetTester tester) async {
      final fakeRepo = FakeMoneyRecordRepository(
        initialRecords: [testRecord1],
        initialRepayments: [testRepayment1],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moneyRecordRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: Scaffold(
              body: AddRepaymentSheet(
                record: testRecord1,
                remainingBalance: 7000.0,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Record Repayment'), findsOneWidget);
      expect(find.text('Pay Full'), findsOneWidget);

      // Tap Pay Full
      await tester.tap(find.text('Pay Full'));
      await tester.pumpAndSettle();

      expect(find.text('7000'), findsOneWidget);

      await tester.tap(find.text('Save Repayment'));
      await tester.pumpAndSettle();

      final reps = await fakeRepo.getRepaymentsForRecord(testRecord1.id);
      expect(reps.length, 2);
      expect(reps.last.amount, 7000.0);
    },
  );
}
