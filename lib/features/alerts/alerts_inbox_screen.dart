import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/alert_item.dart';
import '../../repositories/alert_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../theme/stillwater_tokens.dart';
import 'alert_settings_sheet.dart';
import 'alerts_controller.dart';

class AlertsInboxScreen extends ConsumerStatefulWidget {
  const AlertsInboxScreen({super.key});

  @override
  ConsumerState<AlertsInboxScreen> createState() => _AlertsInboxScreenState();
}

class _AlertsInboxScreenState extends ConsumerState<AlertsInboxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(alertsControllerProvider.notifier).runAlertScan(),
    );
  }

  Color _getSeverityColor(BuildContext context, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.urgent:
        return context.secColors.error;
      case AlertSeverity.attention:
        return context.aiColors.accent;
      case AlertSeverity.informational:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.budgetApproachingLimit:
      case AlertType.budgetExceeded:
        return Icons.pie_chart_rounded;
      case AlertType.upcomingSubscriptionRenewal:
        return Icons.repeat_rounded;
      case AlertType.upcomingEmi:
        return Icons.account_balance_outlined;
      case AlertType.needsReviewCount:
        return Icons.rate_review_outlined;
      case AlertType.backupReminder:
        return Icons.backup_outlined;
      case AlertType.largeExpense:
      case AlertType.unusualSpending:
        return Icons.payments_outlined;
      case AlertType.savingsGoalReminder:
        return Icons.flag_outlined;
      case AlertType.incomeReceived:
        return Icons.south_west_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final alertsAsync = ref.watch(activeAlertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Alert Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertSettingsSheet()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark All Read',
            onPressed:
                () =>
                    ref.read(alertsControllerProvider.notifier).markAllAsRead(),
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                child: FfEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No active alerts',
                  description:
                      'FinanceFlow monitors your local budgets, upcoming EMIs, and subscription renewals calmly in the background.',
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            itemCount: alerts.length,
            separatorBuilder:
                (_, __) => const SizedBox(height: StillwaterTokens.spaceSm),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final iconColor = _getSeverityColor(context, alert.severity);

              return Dismissible(
                key: Key(alert.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(
                    right: StillwaterTokens.spaceLg,
                  ),
                  color: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.archive_outlined,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) {
                  ref
                      .read(alertsControllerProvider.notifier)
                      .dismissAlert(alert.id);
                },
                child: FfCard(
                  onTap: () {
                    ref
                        .read(alertsControllerProvider.notifier)
                        .markAsRead(alert.id);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getAlertIcon(alert.type),
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight:
                                              alert.isRead
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (!alert.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: iconColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: StillwaterTokens.space2Xs),
                            Text(
                              alert.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    alert.isRead
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceXs),
                            Text(
                              DateFormatter.formatTransactionDate(
                                alert.createdAt,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
