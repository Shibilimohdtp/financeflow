/// Generates deterministic 31-bit integer IDs for notifications.
///
/// Android notification IDs must be 32-bit signed integers. Using a 31-bit
/// positive integer guarantees non-negative, collision-resistant, and
/// persistent IDs across app restarts and device reboots.
class NotificationId {
  NotificationId._();

  static const int needsReviewBatch = 10001;
  static const int backupReminder = 10002;

  /// Generate a stable 31-bit positive integer from an arbitrary string key
  /// using the 32-bit FNV-1a hashing algorithm.
  static int fromKey(String key) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < key.length; i++) {
      hash ^= key.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    final positive = hash & 0x7FFFFFFF;
    return positive == 0 ? 1 : positive;
  }

  static int forBudgetApproaching(String budgetId, {required int year, required int month}) {
    return fromKey('budget:$budgetId:approaching:$year-$month');
  }

  static int forBudgetExceeded(String budgetId, {required int year, required int month}) {
    return fromKey('budget:$budgetId:exceeded:$year-$month');
  }

  static int forSubscriptionRenewal(String subscriptionId, DateTime renewalDate) {
    final y = renewalDate.year;
    final m = renewalDate.month.toString().padLeft(2, '0');
    final d = renewalDate.day.toString().padLeft(2, '0');
    return fromKey('subscription:$subscriptionId:renewal:$y-$m-$d');
  }

  static int forLoanEmi(String loanId, DateTime dueDate) {
    final y = dueDate.year;
    final m = dueDate.month.toString().padLeft(2, '0');
    final d = dueDate.day.toString().padLeft(2, '0');
    return fromKey('loan:$loanId:emi:$y-$m-$d');
  }

  static int forAlertItem(String alertId) {
    return fromKey('alert:$alertId');
  }
}
