import '../models/account.dart';

/// Returns the account that should be preselected for a new transaction.
///
/// Accounts are user-owned data, so the newest active account is a better
/// default than the seeded Cash Wallet. For imported bank/UPI activity, a
/// non-cash account is preferred when one exists.
Account? defaultTransactionAccount(
  Iterable<Account> accounts, {
  bool preferNonCash = false,
}) {
  var candidates = accounts.where((account) => !account.isArchived).toList();
  if (preferNonCash) {
    final nonCash =
        candidates.where((account) => account.type != AccountType.cash).toList();
    if (nonCash.isNotEmpty) candidates = nonCash;
  }

  candidates.sort((a, b) {
    final created = b.createdAt.compareTo(a.createdAt);
    if (created != 0) return created;
    return b.updatedAt.compareTo(a.updatedAt);
  });
  return candidates.firstOrNull;
}
