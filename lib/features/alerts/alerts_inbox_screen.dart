import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/alert_item.dart';
import '../../repositories/alert_repository.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
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
        return context.accentColors.accent;
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
    final alertsAsync = ref.watch(activeAlertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark All Read',
            onPressed:
                () =>
                    ref.read(alertsControllerProvider.notifier).markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Alert Settings',
            onPressed: () => AlertSettingsSheet.show(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(
              child: FfPrivacyBadge(label: 'Local Rules', iconOnly: true),
            ),
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

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceMd,
            ),
            children: [
              FfSectionHeader(title: 'Active Notifications (${alerts.length})'),
              FfGroupedContainer(
                children:
                    alerts.map((alert) {
                      final iconColor = _getSeverityColor(
                        context,
                        alert.severity,
                      );
                      final iconData = _getAlertIcon(alert.type);

                      return Dismissible(
                        key: Key(alert.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(
                            right: StillwaterTokens.spaceLg,
                          ),
                          decoration: BoxDecoration(
                            color: context.secColors.error.withValues(
                              alpha: 0.15,
                            ),
                          ),
                          child: Icon(
                            Icons.archive_outlined,
                            color: context.secColors.error,
                          ),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(alertsControllerProvider.notifier)
                              .dismissAlert(alert.id);
                        },
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(alertsControllerProvider.notifier)
                                .markAsRead(alert.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              StillwaterTokens.spaceMd,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: StillwaterTokens.iconTileSize,
                                  height: StillwaterTokens.iconTileSize,
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusSm,
                                    ),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: iconColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: StillwaterTokens.spaceMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              alert.title,
                                              style: context
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight:
                                                        alert.isRead
                                                            ? FontWeight.w500
                                                            : FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          if (!alert.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: iconColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        alert.message,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  context.colorScheme.secondary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormatter.formatTransactionDate(
                                          alert.createdAt,
                                        ),
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  context.colorScheme.outline,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: CircularProgressIndicator(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
