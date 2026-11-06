import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/date_formatter.dart';
import '../../models/alert_item.dart';
import '../../repositories/alert_repository.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'alert_settings_sheet.dart';
import 'alerts_controller.dart';

/// Alerts and notifications inbox: Pattern B (everyday list) on plain canvas.
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

  FfTone _getSeverityTone(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.urgent:
        return FfTone.expense;
      case AlertSeverity.attention:
        return FfTone.warning;
      case AlertSeverity.informational:
        return FfTone.primary;
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
      appBar: FfAppBar(
        title: 'Alerts & Reminders',
        actions: [
          FfCircleButton(
            icon: Icons.done_all_rounded,
            tooltip: 'Mark All Read',
            soft: true,
            onPressed:
                () =>
                    ref.read(alertsControllerProvider.notifier).markAllAsRead(),
          ),
          const SizedBox(width: FfSpace.xs),
          FfCircleButton(
            icon: Icons.tune_rounded,
            tooltip: 'Alert Settings',
            soft: true,
            onPressed: () => AlertSettingsSheet.show(context),
          ),
          const SizedBox(width: FfSpace.xs),
          const Padding(
            padding: EdgeInsets.only(right: FfSpace.pageMargin),
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
                padding: EdgeInsets.all(FfSpace.xl),
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
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.md,
            ),
            children: [
              FfSectionHeader(title: 'Active Notifications (${alerts.length})'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  for (final alert in alerts) _buildAlertRow(context, alert),
                ],
              ),
              const SizedBox(height: FfSpace.x4l),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(FfSpace.x4l),
                child: FfLoading(),
              ),
            ),
        error:
            (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.xl),
                child: Text(
                  'Error loading alerts: $e',
                  style: context.ff.text.body.copyWith(
                    color: context.ff.color.statusError,
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildAlertRow(BuildContext context, AlertItem alert) {
    final tone = _getSeverityTone(alert.severity);
    final iconData = _getAlertIcon(alert.type);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: FfSpace.lg),
        decoration: BoxDecoration(
          color: context.ff.color.statusErrorContainer,
          borderRadius: ffRadius(FfRadius.md),
        ),
        child: Icon(
          Icons.archive_outlined,
          color: context.ff.color.statusError,
        ),
      ),
      onDismissed: (_) {
        ref.read(alertsControllerProvider.notifier).dismissAlert(alert.id);
      },
      child: InkWell(
        onTap: () {
          ref.read(alertsControllerProvider.notifier).markAsRead(alert.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FfIconTile(icon: iconData, tone: tone),
              const SizedBox(width: FfSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: context.ff.text.titleSm.copyWith(
                              fontWeight:
                                  alert.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                              color:
                                  alert.isRead
                                      ? context.ff.color.secondary
                                      : context.ff.color.textPrimary,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: FfSpace.xs),
                            decoration: BoxDecoration(
                              color: context.ff.color.spark,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      alert.message,
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.secondary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.x2s),
                    Text(
                      DateFormatter.formatTransactionDate(alert.createdAt),
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.textTertiary,
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
  }
}
