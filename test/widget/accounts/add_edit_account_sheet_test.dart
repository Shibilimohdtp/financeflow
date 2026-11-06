import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/add_edit_account_sheet.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  group('AddEditAccountSheet widget tests', () {
    late FakeAccountRepository fakeAccountRepo;
    late FakeTransactionRepository fakeTxRepo;
    late FakeSettingsRepository fakeSettingsRepo;

    setUp(() {
      fakeSettingsRepo = FakeSettingsRepository();
      fakeAccountRepo = FakeAccountRepository();
      fakeTxRepo = FakeTransactionRepository();
    });

    Widget createSheetWidget({
      Account? account,
      TextScaler? textScaler,
      EdgeInsets? viewInsets,
    }) {
      return ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
          accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
          transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          builder: (context, child) {
            var media = MediaQuery.of(context);
            if (textScaler != null) {
              media = media.copyWith(textScaler: textScaler);
            }
            if (viewInsets != null) {
              media = media.copyWith(viewInsets: viewInsets);
            }
            return MediaQuery(data: media, child: child!);
          },
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showAddEditAccountSheet(context, account: account);
                      },
                      child: const Text('Open Sheet'),
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders add mode by default with empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Add Financial Account'), findsOneWidget);
      expect(find.text('Enter account name'), findsOneWidget);
      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Opening Balance'), findsOneWidget);
    });

    testWidgets('validates required fields on submit', (tester) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter name so button switches from guidance to Add Account
      final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
      await tester.enterText(nameFinder, 'My Bank');

      // Clear the default '0' in opening balance
      final balanceFinder = find.widgetWithText(
        TextFormField,
        'Opening Balance',
      );
      await tester.enterText(balanceFinder, '');

      // Tap save
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter opening balance.'), findsOneWidget);
    });

    testWidgets('creates and saves new account', (tester) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
      final balanceFinder = find.widgetWithText(
        TextFormField,
        'Opening Balance',
      );

      await tester.enterText(nameFinder, 'Primary Savings');
      await tester.enterText(balanceFinder, '12500');

      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      final saved = await fakeAccountRepo.getAllAccounts();
      expect(saved.length, 1);
      expect(saved.first.name, 'Primary Savings');
      expect(saved.first.openingBalance, 12500.0);
      expect(saved.first.currentBalance, 12500.0);
      expect(saved.first.type, AccountType.bank);
    });

    testWidgets('edits existing account and saves changes', (tester) async {
      final existing = Account(
        id: 'acc_edit_1',
        name: 'ICICI Savings',
        type: AccountType.bank,
        openingBalance: 5000.0,
        currentBalance: 8500.0,
        currency: 'INR',
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      fakeAccountRepo = FakeAccountRepository([existing]);

      await tester.pumpWidget(createSheetWidget(account: existing));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Account'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'ICICI Savings'),
        findsOneWidget,
      );

      final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
      await tester.enterText(nameFinder, 'ICICI Salary Account');

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      final updated = await fakeAccountRepo.getAccountById('acc_edit_1');
      expect(updated, isNotNull);
      expect(updated!.name, 'ICICI Salary Account');
      expect(updated.currentBalance, 8500.0);
    });

    testWidgets('switching type adapts labels and live preview', (
      tester,
    ) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Card in type tiles
      await tester.tap(find.text('Card'));
      await tester.pumpAndSettle();

      expect(find.text('Current balance owed'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget); // preview label

      // Tap Invest
      await tester.tap(find.text('Invest'));
      await tester.pumpAndSettle();

      expect(find.text('Opening portfolio value'), findsOneWidget);
    });

    testWidgets(
      'shows duplicate-name warning when name matches active account',
      (tester) async {
        final existing = Account(
          id: 'acc_dup_1',
          name: 'HDFC Salary',
          type: AccountType.bank,
          currency: 'INR',
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        fakeAccountRepo = FakeAccountRepository([existing]);

        await tester.pumpWidget(createSheetWidget());
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'hdfc salary');
        await tester.pumpAndSettle();

        expect(
          find.text('An active account with this name already exists'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'institution chip autofills institution and suggests account name',
      (tester) async {
        await tester.pumpWidget(createSheetWidget());
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Scroll to and expand optional details
        final disclosureFinder = find.text(
          'Bank and identifier details (optional)',
        );
        await tester.ensureVisible(disclosureFinder);
        await tester.tap(disclosureFinder);
        await tester.pumpAndSettle();

        // Tap HDFC chip
        final chipFinder = find.text('HDFC');
        await tester.ensureVisible(chipFinder);
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();

        // Verifies institution field and name auto-suggestion
        expect(find.widgetWithText(TextFormField, 'HDFC'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'HDFC Savings'),
          findsOneWidget,
        );
      },
    );

    testWidgets('credit card saves entered debt as negative balance', (
      tester,
    ) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Select Card
      await tester.tap(find.text('Card'));
      await tester.pumpAndSettle();

      final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
      await tester.enterText(nameFinder, 'ICICI Coral');

      final balanceFinder = find.widgetWithText(
        TextFormField,
        'Current balance owed',
      );
      await tester.enterText(balanceFinder, '8500');

      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      final accounts = await fakeAccountRepo.getAllAccounts();
      expect(accounts.length, 1);
      expect(accounts.first.type, AccountType.creditCard);
      expect(accounts.first.openingBalance, -8500.0);
      expect(accounts.first.currentBalance, -8500.0);
    });

    testWidgets('edit mode shows current balance in preview and baseline note', (
      tester,
    ) async {
      final existing = Account(
        id: 'acc_preview_edit',
        name: 'Salary Account',
        type: AccountType.bank,
        openingBalance: 20000.0,
        currentBalance: 42500.0,
        currency: 'INR',
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      fakeAccountRepo = FakeAccountRepository([existing]);

      await tester.pumpWidget(createSheetWidget(account: existing));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Preview displays 'Current balance'
      expect(find.text('Current balance'), findsOneWidget);

      // Baseline history note
      final noteFinder = find.text(
        'Editing the opening balance shifts your baseline balance without changing past transaction records.',
      );
      await tester.ensureVisible(noteFinder);
      expect(noteFinder, findsOneWidget);

      // Archive and delete buttons visible
      expect(find.text('Archive account'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('archive button archives account from inside sheet', (
      tester,
    ) async {
      final existing = Account(
        id: 'acc_archive_test',
        name: 'Savings',
        type: AccountType.bank,
        currency: 'INR',
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      fakeAccountRepo = FakeAccountRepository([existing]);

      await tester.pumpWidget(createSheetWidget(account: existing));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final archiveBtn = find.text('Archive account');
      await tester.ensureVisible(archiveBtn);
      await tester.tap(archiveBtn);
      await tester.pumpAndSettle();

      final updated = await fakeAccountRepo.getAccountById('acc_archive_test');
      expect(updated!.isArchived, isTrue);
    });

    testWidgets('delete button inside sheet opens dialog and deletes account', (
      tester,
    ) async {
      final existing = Account(
        id: 'acc_delete_test',
        name: 'Obsolete Acc',
        type: AccountType.cash,
        currency: 'INR',
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      fakeAccountRepo = FakeAccountRepository([existing]);

      await tester.pumpWidget(createSheetWidget(account: existing));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final deleteBtn = find.text('Delete account');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Delete Account?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      final updated = await fakeAccountRepo.getAccountById('acc_delete_test');
      expect(updated, isNull);
    });

    testWidgets('renders comfortably under 2x text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSheetWidget(textScaler: const TextScaler.linear(2.0)),
      );
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Add Financial Account'), findsOneWidget);
    });

    testWidgets('handles viewInsets keyboard height without crash or overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSheetWidget(viewInsets: const EdgeInsets.only(bottom: 300)),
      );
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Add Financial Account'), findsOneWidget);
    });
  });
}
