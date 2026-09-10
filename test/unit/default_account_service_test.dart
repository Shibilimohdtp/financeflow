import 'package:financeflow/models/account.dart';
import 'package:financeflow/services/default_account_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final older = DateTime(2026, 8, 1);
  final newer = DateTime(2026, 8, 2);

  test('uses the newest active account for manual transactions', () {
    final account = defaultTransactionAccount([
      Account(
        id: 'cash',
        name: 'Cash Wallet',
        type: AccountType.cash,
        createdAt: older,
        updatedAt: older,
      ),
      Account(
        id: 'bank',
        name: 'Main Bank',
        type: AccountType.bank,
        createdAt: newer,
        updatedAt: newer,
      ),
    ]);

    expect(account?.id, 'bank');
  });

  test('prefers a non-cash account for imported financial events', () {
    final account = defaultTransactionAccount([
      Account(
        id: 'bank',
        name: 'Main Bank',
        type: AccountType.bank,
        createdAt: older,
        updatedAt: older,
      ),
      Account(
        id: 'cash',
        name: 'Cash Wallet',
        type: AccountType.cash,
        createdAt: newer,
        updatedAt: newer,
      ),
    ], preferNonCash: true);

    expect(account?.id, 'bank');
  });

  test('ignores archived accounts', () {
    final account = defaultTransactionAccount([
      Account(
        id: 'archived',
        name: 'Old Bank',
        type: AccountType.bank,
        isArchived: true,
        createdAt: newer,
        updatedAt: newer,
      ),
      Account(
        id: 'cash',
        name: 'Cash Wallet',
        type: AccountType.cash,
        createdAt: older,
        updatedAt: older,
      ),
    ]);

    expect(account?.id, 'cash');
  });
}
