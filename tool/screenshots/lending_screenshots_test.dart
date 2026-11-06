// Screenshot capture for Lending & Borrowing (DS-B18), not part of the test suite.
// Captures overview, detail, and sheets across light and dark modes.
//
//   flutter test tool/screenshots/lending_screenshots_test.dart --update-goldens
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/personal_debts/add_advance_sheet.dart';
import 'package:financeflow/features/personal_debts/add_edit_money_record_sheet.dart';
import 'package:financeflow/features/personal_debts/add_repayment_sheet.dart';
import 'package:financeflow/features/personal_debts/lending_borrowing_screen.dart';
import 'package:financeflow/features/personal_debts/money_record_detail_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/money_advance.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/repositories/money_record_repository.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

final _refDate = DateTime(2026, 11, 6);

final _accountHdfc = Account(
  id: 'acc_hdfc',
  name: 'HDFC Salary',
  type: AccountType.bank,
  currency: 'INR',
  currentBalance: 85400,
  createdAt: _refDate,
  updatedAt: _refDate,
);

final _accountCash = Account(
  id: 'acc_cash',
  name: 'Cash in Wallet',
  type: AccountType.cash,
  currency: 'INR',
  currentBalance: 4200,
  createdAt: _refDate,
  updatedAt: _refDate,
);

// Ahmed: Lent ₹10,000 in two advances (₹7,500 + ₹2,500), repaid ₹3,000, remaining ₹7,000. Overdue.
final _recordAhmed = MoneyRecord(
  id: 'rec_ahmed',
  type: MoneyRecordType.lent,
  personName: 'Ahmed Khan',
  normalizedPersonName: 'ahmed khan',
  originalAmount: 10000.0,
  transactionDate: DateTime(2026, 10, 1),
  dueDate: DateTime(2026, 10, 25), // Overdue
  notes: 'Emergency car repair loan',
  isReminderEnabled: true,
  reminderDaysBefore: 3,
  createdAt: DateTime(2026, 10, 1),
  updatedAt: DateTime(2026, 10, 15),
);

final _advanceAhmed1 = MoneyAdvance(
  id: 'adv_ahmed_1',
  moneyRecordId: 'rec_ahmed',
  amount: 7500.0,
  date: DateTime(2026, 10, 1),
  dueDate: DateTime(2026, 10, 25),
  notes: 'First part via UPI',
  accountId: 'acc_hdfc',
  createdAt: DateTime(2026, 10, 1),
  updatedAt: DateTime(2026, 10, 1),
);

final _advanceAhmed2 = MoneyAdvance(
  id: 'adv_ahmed_2',
  moneyRecordId: 'rec_ahmed',
  amount: 2500.0,
  date: DateTime(2026, 10, 5),
  dueDate: DateTime(2026, 11, 2),
  notes: 'Additional spare parts cost',
  accountId: 'acc_cash',
  createdAt: DateTime(2026, 10, 5),
  updatedAt: DateTime(2026, 10, 5),
);

final _repaymentAhmed1 = MoneyRepayment(
  id: 'rep_ahmed_1',
  moneyRecordId: 'rec_ahmed',
  amount: 3000.0,
  repaymentDate: DateTime(2026, 10, 20),
  notes: 'Partial payback after salary',
  createdAt: DateTime(2026, 10, 20),
);

// Sarah: Borrowed ₹5,000, due in 5 days (Due soon).
final _recordSarah = MoneyRecord(
  id: 'rec_sarah',
  type: MoneyRecordType.borrowed,
  personName: 'Sarah Jenkins',
  normalizedPersonName: 'sarah jenkins',
  originalAmount: 5000.0,
  transactionDate: DateTime(2026, 10, 20),
  dueDate: DateTime(2026, 11, 11), // Due soon (5 days from Nov 6)
  notes: 'Weekend trip split payment',
  isReminderEnabled: true,
  reminderDaysBefore: 1,
  createdAt: DateTime(2026, 10, 20),
  updatedAt: DateTime(2026, 10, 20),
);

final _advanceSarah1 = MoneyAdvance(
  id: 'adv_sarah_1',
  moneyRecordId: 'rec_sarah',
  amount: 5000.0,
  date: DateTime(2026, 10, 20),
  dueDate: DateTime(2026, 11, 11),
  notes: 'Hotel booking share',
  accountId: 'acc_hdfc',
  createdAt: DateTime(2026, 10, 20),
  updatedAt: DateTime(2026, 10, 20),
);

// Uncle John: Lent ₹4,000, fully repaid and settled.
final _recordJohn = MoneyRecord(
  id: 'rec_john',
  type: MoneyRecordType.lent,
  personName: 'Uncle John',
  normalizedPersonName: 'uncle john',
  originalAmount: 4000.0,
  transactionDate: DateTime(2026, 9, 1),
  dueDate: DateTime(2026, 10, 1),
  notes: 'Festival advance',
  settledAt: DateTime(2026, 9, 28),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 28),
);

final _advanceJohn1 = MoneyAdvance(
  id: 'adv_john_1',
  moneyRecordId: 'rec_john',
  amount: 4000.0,
  date: DateTime(2026, 9, 1),
  dueDate: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
);

final _repaymentJohn1 = MoneyRepayment(
  id: 'rep_john_1',
  moneyRecordId: 'rec_john',
  amount: 4000.0,
  repaymentDate: DateTime(2026, 9, 28),
  notes: 'Repaid in full',
  createdAt: DateTime(2026, 9, 28),
);

final _sampleRecords = [_recordAhmed, _recordSarah, _recordJohn];
final _sampleAdvances = [
  _advanceAhmed1,
  _advanceAhmed2,
  _advanceSarah1,
  _advanceJohn1,
];
final _sampleRepayments = [_repaymentAhmed1, _repaymentJohn1];
final _sampleAccounts = [_accountHdfc, _accountCash];

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home, {
  List<MoneyRecord> records = const [],
  List<MoneyAdvance> advances = const [],
  List<MoneyRepayment> repayments = const [],
  List<Account> accounts = const [],
  double height = 844,
  double width = 390,
  double textScale = 1.0,
  bool isBlurred = false,
}) async {
  tester.view.physicalSize = Size(
    width * tester.view.devicePixelRatio,
    height * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.reset);

  final fakeMoneyRepo = FakeMoneyRecordRepository(
    initialRecords: records,
    initialAdvances: advances,
    initialRepayments: repayments,
  );

  final appSettings = AppSettings(isPrivacyBlurEnabled: isBlurred);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(appSettings)),
        moneyRecordRepositoryProvider.overrideWithValue(fakeMoneyRepo),
        allAccountsStreamProvider.overrideWith((ref) => Stream.value(accounts)),
        accountsWithBalancesProvider.overrideWithValue(
          AsyncValue.data(accounts),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 48, bottom: 34),
          ),
          child: home,
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

Widget _sheetHost(Widget Function(BuildContext) builder) => Scaffold(
  body: Builder(
    builder:
        (context) => Center(
          child: TextButton(
            onPressed: () => showFfSheet(context, builder: builder),
            child: const Text('open'),
          ),
        ),
  ),
);

Future<void> _captureSheet(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget Function(BuildContext) sheetBuilder, {
  List<MoneyRecord> records = const [],
  List<MoneyAdvance> advances = const [],
  List<MoneyRepayment> repayments = const [],
  List<Account> accounts = const [],
  double height = 844,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(
    390 * tester.view.devicePixelRatio,
    height * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.reset);

  final fakeMoneyRepo = FakeMoneyRecordRepository(
    initialRecords: records,
    initialAdvances: advances,
    initialRepayments: repayments,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        moneyRecordRepositoryProvider.overrideWithValue(fakeMoneyRepo),
        allAccountsStreamProvider.overrideWith((ref) => Stream.value(accounts)),
        accountsWithBalancesProvider.overrideWithValue(
          AsyncValue.data(accounts),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, height),
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 48, bottom: 34),
          ),
          child: _sheetHost(sheetBuilder),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('b18_overview_normal, $mode', (tester) async {
      await _capture(
        tester,
        'b18_overview_normal_$mode',
        theme,
        const LendingBorrowingScreen(),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 1000,
      );
    });

    testWidgets('b18_overview_empty, $mode', (tester) async {
      await _capture(
        tester,
        'b18_overview_empty_$mode',
        theme,
        const LendingBorrowingScreen(),
        records: const [],
        advances: const [],
        repayments: const [],
        accounts: _sampleAccounts,
        height: 844,
      );
    });

    testWidgets('b18_detail_open, $mode', (tester) async {
      await _capture(
        tester,
        'b18_detail_open_$mode',
        theme,
        MoneyRecordDetailScreen(record: _recordAhmed),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 1100,
      );
    });

    testWidgets('b18_detail_settled, $mode', (tester) async {
      await _capture(
        tester,
        'b18_detail_settled_$mode',
        theme,
        MoneyRecordDetailScreen(record: _recordJohn),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 900,
      );
    });

    testWidgets('b18_sheet_add, $mode', (tester) async {
      await _captureSheet(
        tester,
        'b18_sheet_add_$mode',
        theme,
        (_) => const AddEditMoneyRecordSheet(),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 844,
      );
    });

    testWidgets('b18_sheet_repayment, $mode', (tester) async {
      await _captureSheet(
        tester,
        'b18_sheet_repayment_$mode',
        theme,
        (_) =>
            AddRepaymentSheet(record: _recordAhmed, remainingBalance: 7000.0),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 844,
      );
    });

    testWidgets('b18_sheet_advance, $mode', (tester) async {
      await _captureSheet(
        tester,
        'b18_sheet_advance_$mode',
        theme,
        (_) => AddAdvanceSheet(record: _recordAhmed),
        records: _sampleRecords,
        advances: _sampleAdvances,
        repayments: _sampleRepayments,
        accounts: _sampleAccounts,
        height: 844,
      );
    });
  }
}
