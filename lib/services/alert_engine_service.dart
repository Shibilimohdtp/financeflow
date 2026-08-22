import 'package:uuid/uuid.dart';
import '../core/formatting/currency_formatter.dart';
import '../models/alert_item.dart';
import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/loan.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';
import '../repositories/alert_repository.dart';
import 'budget_calculator.dart';

class AlertEngineService {
  final AlertRepository _alertRepository;
  static const _uuid = Uuid();

  AlertEngineService({required AlertRepository alertRepository})
    : _alertRepository = alertRepository;

  /// Scan on-device state and generate local alerts
  Future<List<AlertItem>> scanAndGenerateAlerts({
    required AppSettings settings,
    required List<Budget> activeBudgets,
    required List<Transaction> monthTransactions,
    required List<Subscription> activeSubscriptions,
    required List<Loan> activeLoans,
    required int pendingReviewCount,
    DateTime? referenceDate,
  }) async {
    if (!settings.isAlertsEnabled) return const [];

    final now = referenceDate ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final List<AlertItem> generatedAlerts = [];

    // 1. Budget Alerts
    if (settings.isBudgetAlertsEnabled) {
      for (final budget in activeBudgets.where((b) => !b.isArchived)) {
        final summary = BudgetCalculator.calculateSummary(
          budget,
          monthTransactions,
          referenceDate: now,
        );

        if (summary.isExceeded) {
          final exists = await _alertRepository.alertExistsForEntity(
            type: AlertType.budgetExceeded,
            relatedEntityId: budget.id,
            sinceDate: todayStart,
          );
          if (!exists) {
            final overAmount = summary.amountOverBudget;
            final formattedOver = CurrencyFormatter.formatINR(overAmount);
            final name = budget.categoryName ?? budget.name;
            final alert = AlertItem(
              id: 'alt_${_uuid.v4()}',
              type: AlertType.budgetExceeded,
              title: '$name budget exceeded',
              message: '$name is $formattedOver over this month’s budget.',
              severity: AlertSeverity.urgent,
              scheduledAt: now,
              createdAt: now,
            );
            await _alertRepository.saveAlert(alert);
            generatedAlerts.add(alert);
          }
        } else if (summary.isApproachingThreshold) {
          final exists = await _alertRepository.alertExistsForEntity(
            type: AlertType.budgetApproachingLimit,
            relatedEntityId: budget.id,
            sinceDate: todayStart,
          );
          if (!exists) {
            final pct = (summary.percentageUsed * 100).toStringAsFixed(0);
            final name = budget.categoryName ?? budget.name;
            final alert = AlertItem(
              id: 'alt_${_uuid.v4()}',
              type: AlertType.budgetApproachingLimit,
              title: '$name nearing budget limit',
              message: '$name has reached $pct% of its planned budget.',
              severity: AlertSeverity.attention,
              scheduledAt: now,
              createdAt: now,
            );
            await _alertRepository.saveAlert(alert);
            generatedAlerts.add(alert);
          }
        }
      }
    }

    // 2. Subscription Renewal Alerts
    if (settings.isSubscriptionAlertsEnabled) {
      for (final sub in activeSubscriptions.where(
        (s) => s.status == SubscriptionStatus.active && s.isReminderEnabled,
      )) {
        final days = sub.daysUntilRenewal(referenceDate: now);
        if (days >= 0 && days <= sub.reminderDaysBefore) {
          final exists = await _alertRepository.alertExistsForEntity(
            type: AlertType.upcomingSubscriptionRenewal,
            relatedEntityId: sub.id,
            sinceDate: todayStart,
          );
          if (!exists) {
            final whenText =
                days == 0
                    ? 'today'
                    : (days == 1 ? 'tomorrow' : 'in $days days');
            final formattedAmount = CurrencyFormatter.formatINR(sub.amount);
            final alert = AlertItem(
              id: 'alt_${_uuid.v4()}',
              type: AlertType.upcomingSubscriptionRenewal,
              title: '${sub.merchant} renewal due',
              message: '${sub.merchant} ($formattedAmount) renews $whenText.',
              severity:
                  days <= 1 ? AlertSeverity.urgent : AlertSeverity.attention,
              relatedEntityType: 'subscription',
              relatedEntityId: sub.id,
              scheduledAt: now,
              createdAt: now,
            );
            await _alertRepository.saveAlert(alert);
            generatedAlerts.add(alert);
          }
        }
      }
    }

    // 3. Upcoming EMI Alerts
    if (settings.isLoanAlertsEnabled) {
      for (final loan in activeLoans.where(
        (l) => l.status == LoanStatus.active,
      )) {
        final days = loan.daysUntilDue(referenceDate: now);
        if (days >= 0 && days <= 3) {
          final exists = await _alertRepository.alertExistsForEntity(
            type: AlertType.upcomingEmi,
            relatedEntityId: loan.id,
            sinceDate: todayStart,
          );
          if (!exists) {
            final whenText =
                days == 0
                    ? 'today'
                    : (days == 1 ? 'tomorrow' : 'in $days days');
            final formattedEmi = CurrencyFormatter.formatINR(loan.emiAmount);
            final alert = AlertItem(
              id: 'alt_${_uuid.v4()}',
              type: AlertType.upcomingEmi,
              title: '${loan.name} EMI due',
              message: 'EMI of $formattedEmi is due $whenText.',
              severity:
                  days <= 1 ? AlertSeverity.urgent : AlertSeverity.attention,
              relatedEntityType: 'loan',
              relatedEntityId: loan.id,
              scheduledAt: now,
              createdAt: now,
            );
            await _alertRepository.saveAlert(alert);
            generatedAlerts.add(alert);
          }
        }
      }
    }

    // 4. Needs Review Alert
    if (settings.isNeedsReviewAlertsEnabled && pendingReviewCount > 0) {
      final exists = await _alertRepository.alertExistsForEntity(
        type: AlertType.needsReviewCount,
        relatedEntityId: 'pending_review_batch',
        sinceDate: todayStart,
      );
      if (!exists) {
        final alert = AlertItem(
          id: 'alt_${_uuid.v4()}',
          type: AlertType.needsReviewCount,
          title: 'Transactions need review',
          message:
              'You have $pendingReviewCount imported transactions waiting for review.',
          severity: AlertSeverity.attention,
          relatedEntityType: 'pending_review',
          relatedEntityId: 'pending_review_batch',
          scheduledAt: now,
          createdAt: now,
        );
        await _alertRepository.saveAlert(alert);
        generatedAlerts.add(alert);
      }
    }

    // 5. Backup Reminder
    if (settings.isBackupReminderEnabled) {
      final lastBackup = settings.lastBackupDate;
      final bool needsBackup =
          lastBackup == null || now.difference(lastBackup).inDays >= 30;
      if (needsBackup) {
        final exists = await _alertRepository.alertExistsForEntity(
          type: AlertType.backupReminder,
          relatedEntityId: 'backup_schedule',
          sinceDate: now.subtract(const Duration(days: 7)),
        );
        if (!exists) {
          final alert = AlertItem(
            id: 'alt_${_uuid.v4()}',
            type: AlertType.backupReminder,
            title: 'Encrypted backup reminder',
            message:
                lastBackup == null
                    ? 'Create a local encrypted backup to protect your financial data.'
                    : 'It has been over 30 days since your last encrypted backup.',
            severity: AlertSeverity.informational,
            relatedEntityType: 'backup',
            relatedEntityId: 'backup_schedule',
            scheduledAt: now,
            createdAt: now,
          );
          await _alertRepository.saveAlert(alert);
          generatedAlerts.add(alert);
        }
      }
    }

    return generatedAlerts;
  }
}
