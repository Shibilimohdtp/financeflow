import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../helpers/fake_repositories.dart';

void main() {
  group('Accounts Management Widget Tests', () {
    late FakeAccountRepository fakeAccountRepo;
    late FakeTransactionRepository fakeTxRepo;
    late FakeSettingsRepository fakeSettingsRepo;

    setUp(() {
      fakeSettingsRepo = FakeSettingsRepository();
      fakeAccountRepo = FakeAccountRepository([
        Account(
          id: 'acc_bank_1',
          name: 'HDFC Bank',
          type: AccountType.bank,
          openingBalance: 25000.0,
          currentBalance: 25000.0,
          currency: 'INR',
          isArchived: false,
          createdAt: DateTime(2026, 8, 22),
          updatedAt: DateTime(2026, 8, 22),
        ),
        Account(
          id: 'acc_cash_1',
          name: 'Old Cash Wallet',
          type: AccountType.cash,
          openingBalance: 500.0,
          currentBalance: 500.0,
          currency: 'INR',
          isArchived: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ]);
      fakeTxRepo = FakeTransactionRepository();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
          accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
          transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const AccountsScreen(),
        ),
      );
    }

    testWidgets(
      'AccountsScreen renders active accounts and allows tab switching to archived',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify Active tab by default shows HDFC Bank
        expect(find.text('Active (1)'), findsOneWidget);
        expect(find.text('Archived (1)'), findsOneWidget);
        expect(find.text('HDFC Bank'), findsOneWidget);
        expect(find.text('Old Cash Wallet'), findsNothing);

        // Tap Archived Tab
        await tester.tap(find.text('Archived (1)'));
        await tester.pumpAndSettle();

        // Now Old Cash Wallet is shown
        expect(find.text('Old Cash Wallet'), findsOneWidget);
        expect(find.text('Archived'), findsOneWidget);
      },
    );

    testWidgets('Opening Add Account sheet displays input fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Add button in AppBar
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('New account'), findsOneWidget);
      expect(find.text('Account name'), findsOneWidget);
      expect(find.text('Opening balance'), findsOneWidget);
      // UX Goal 7: CTA guides user on what is missing ("Enter account name")
      expect(find.text('Enter account name'), findsOneWidget);
    });
  });
}
