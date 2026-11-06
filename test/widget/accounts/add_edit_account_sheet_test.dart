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

    Widget createSheetWidget({Account? account}) {
      return ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
          accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
          transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
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
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Opening Balance'), findsOneWidget);
    });

    testWidgets('validates required fields on submit', (tester) async {
      await tester.pumpWidget(createSheetWidget());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Clear the default '0' in opening balance
      final balanceFinder = find.widgetWithText(
        TextFormField,
        'Opening Balance',
      );
      await tester.enterText(balanceFinder, '');

      // Tap save
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an account name.'), findsOneWidget);
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
      expect(find.text('ICICI Savings'), findsOneWidget);

      final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
      await tester.enterText(nameFinder, 'ICICI Salary Account');

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      final updated = await fakeAccountRepo.getAccountById('acc_edit_1');
      expect(updated, isNotNull);
      expect(updated!.name, 'ICICI Salary Account');
      expect(updated.currentBalance, 8500.0);
    });
  });
}
