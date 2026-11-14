// DS-B20b: the loan sheet on the shared skeleton (archetype A, amount
// first) and the payment account picker (archetype C, choice).
import 'package:financeflow/features/loans/add_edit_loan_sheet.dart';
import 'package:financeflow/features/loans/payment_account_picker.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/shared/widgets/ff_amount_field.dart';
import 'package:financeflow/shared/widgets/ff_amount_hero.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

Future<FakeLoanRepository> _openLoanSheet(
  WidgetTester tester, {
  ThemeData? theme,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeLoanRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(repo),
        allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        theme: theme ?? FfTheme.light(),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showFfSheet<void>(
                        context,
                        builder: (_) => const AddEditLoanSheet(),
                      ),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repo;
}

Finder get _body =>
    find
        .descendant(
          of: find.byType(AddEditLoanSheet),
          matching: find.byType(Scrollable),
        )
        .first;

void main() {
  testWidgets('amount groups as typed and the EMI follows', (tester) async {
    await _openLoanSheet(tester);
    expect(find.text('New loan'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);

    await tester.enterText(find.byType(FfAmountHero), '100000');
    await tester.pumpAndSettle();
    expect(find.text('1,00,000'), findsOneWidget);
    expect(find.textContaining('About ₹'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Monthly EMI'),
      200,
      scrollable: _body,
    );
    final emi = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(FfAmountField, 'Monthly EMI'),
        matching: find.byType(TextField),
      ),
    );
    expect(emi.controller!.text, contains(','));
  });

  testWidgets('creates the loan with the parsed amount', (tester) async {
    final repo = await _openLoanSheet(tester);
    await tester.enterText(find.byType(FfAmountHero), '250000');
    await tester.enterText(
      find.widgetWithText(FfTextField, 'Loan name'),
      'Car loan',
    );
    await tester.enterText(find.widgetWithText(FfTextField, 'Lender'), 'SBI');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create loan'));
    await tester.tap(find.text('Create loan'));
    await tester.pumpAndSettle();

    final loans = await repo.getAllLoans();
    expect(loans, hasLength(1));
    expect(loans.single.principalAmount, 250000);
    expect(loans.single.emiAmount, greaterThan(0));
  });

  testWidgets('shows inline errors instead of saving an empty loan', (
    tester,
  ) async {
    final repo = await _openLoanSheet(tester);
    await tester.tap(find.text('Create loan'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid principal amount.'), findsOneWidget);
    expect(await repo.getAllLoans(), isEmpty);
  });

  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    testWidgets('no overflow at 360 dp and 2x text ($mode)', (tester) async {
      await _openLoanSheet(tester, theme: theme, textScale: 2);
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 6; i++) {
        await tester.drag(_body, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('payment account picker marks the current account', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 1);
    final accounts = [
      Account(
        id: 'a1',
        name: 'Axis',
        type: AccountType.bank,
        createdAt: now,
        updatedAt: now,
      ),
      Account(
        id: 'a2',
        name: 'Cash',
        type: AccountType.cash,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    Account? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: FfTheme.light(),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    picked = await showPaymentAccountPicker(
                      context: context,
                      accounts: accounts,
                      selectedAccountId: 'a1',
                    );
                  },
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Paying account'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'a2');
  });
}
