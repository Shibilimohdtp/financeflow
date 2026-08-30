import '../../core/formatting/currency_formatter.dart';

class NotificationText {
  final String title;
  final String body;

  const NotificationText({required this.title, required this.body});
}

/// Formats human-friendly notification copy adhering to the Stillwater design system
/// and respecting lock-screen/device privacy settings.
class NotificationFormatter {
  NotificationFormatter._();

  static NotificationText formatNeedsReview({
    required int count,
    String? singleMerchant,
    double? singleAmount,
    required bool hideSensitive,
  }) {
    if (hideSensitive) {
      return NotificationText(
        title:
            count > 1 ? 'Transactions need review' : 'Transaction needs review',
        body:
            count > 1
                ? '$count imported transactions are waiting for your review.'
                : '1 imported transaction is waiting for your review.',
      );
    }

    if (count == 1 && singleMerchant != null && singleMerchant.isNotEmpty) {
      final amountSuffix =
          singleAmount != null
              ? ' · ${CurrencyFormatter.formatINR(singleAmount)}'
              : '';
      return NotificationText(
        title: 'Transaction needs review',
        body: '$singleMerchant$amountSuffix is waiting for review.',
      );
    }

    return NotificationText(
      title: 'Transactions need review',
      body: '$count imported transactions are waiting for your review.',
    );
  }

  static NotificationText formatBudgetApproaching({
    required String categoryName,
    required double percentageUsed,
    required bool hideSensitive,
  }) {
    if (hideSensitive) {
      return const NotificationText(
        title: 'Budget update',
        body: 'A FinanceFlow budget is nearing its limit. Open to view.',
      );
    }

    final pct = (percentageUsed * 100).toStringAsFixed(0);
    return NotificationText(
      title: '$categoryName budget nearing limit',
      body: '$categoryName has reached $pct% of this month’s planned budget.',
    );
  }

  static NotificationText formatBudgetExceeded({
    required String categoryName,
    required double amountOver,
    required bool hideSensitive,
  }) {
    if (hideSensitive) {
      return const NotificationText(
        title: 'Budget update',
        body: 'A FinanceFlow budget has been exceeded. Open to view.',
      );
    }

    final formattedOver = CurrencyFormatter.formatINR(amountOver);
    return NotificationText(
      title: '$categoryName budget exceeded',
      body: '$categoryName is $formattedOver over this month’s budget.',
    );
  }

  static NotificationText formatSubscriptionRenewal({
    required String merchant,
    required double amount,
    required int daysUntil,
    required bool hideSensitive,
  }) {
    final whenText =
        daysUntil <= 0
            ? 'today'
            : (daysUntil == 1 ? 'tomorrow' : 'in $daysUntil days');

    if (hideSensitive) {
      return NotificationText(
        title: 'Subscription reminder',
        body:
            'An upcoming subscription renewal is due $whenText. Open to view.',
      );
    }

    final formatted = CurrencyFormatter.formatINR(amount);
    return NotificationText(
      title: '$merchant renewal due',
      body: '$merchant ($formatted) renews $whenText.',
    );
  }

  static NotificationText formatLoanEmi({
    required String loanName,
    required double emiAmount,
    required int daysUntil,
    required bool hideSensitive,
  }) {
    final whenText =
        daysUntil <= 0
            ? 'today'
            : (daysUntil == 1 ? 'tomorrow' : 'in $daysUntil days');

    if (hideSensitive) {
      return NotificationText(
        title: 'Loan EMI reminder',
        body: 'An upcoming loan EMI payment is due $whenText. Open to view.',
      );
    }

    final formatted = CurrencyFormatter.formatINR(emiAmount);
    return NotificationText(
      title: '$loanName EMI due',
      body: 'EMI of $formatted is due $whenText.',
    );
  }

  static NotificationText formatBackupReminder({
    required int? daysSinceLastBackup,
    required bool hideSensitive,
  }) {
    if (hideSensitive) {
      return const NotificationText(
        title: 'Backup reminder',
        body: 'A local encrypted backup is recommended. Open to view.',
      );
    }

    return NotificationText(
      title: 'Encrypted backup reminder',
      body:
          daysSinceLastBackup == null
              ? 'Create a local encrypted backup to protect your financial data.'
              : 'It has been over $daysSinceLastBackup days since your last encrypted backup.',
    );
  }
}
