import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/date_formatter.dart';
import '../../models/alert_item.dart';
import '../../repositories/alert_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../backup/backup_screen.dart';
import '../budgets/budgets_screen.dart';
import '../ingestion/needs_review_screen.dart';
import '../loans/loans_screen.dart';
import '../savings_goals/savings_goals_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import 'alert_settings_sheet.dart';
import 'alerts_controller.dart';

/// Available filter categories for the alerts inbox.
enum AlertFilter {
  all('All'),
  reminders('Reminders'),
  alerts('Alerts'),
  unread('Unread');

  final String displayName;
  const AlertFilter(this.displayName);
}

class _AlertActionConfig {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AlertActionConfig({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

/// Alerts and notifications inbox: Stillwater Bloom Pattern A/B hybrid on [FfAurora].
/// Features a command status hero card, filter pill bar, and comfortable grouped dismissible rows.
class AlertsInboxScreen extends ConsumerStatefulWidget {
  const AlertsInboxScreen({super.key});

  @override
  ConsumerState<AlertsInboxScreen> createState() => _AlertsInboxScreenState();
}

class _AlertsInboxScreenState extends ConsumerState<AlertsInboxScreen> {
  AlertFilter _selectedFilter = AlertFilter.all;

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

  bool _isReminder(AlertType type) {
    switch (type) {
      case AlertType.upcomingEmi:
      case AlertType.upcomingSubscriptionRenewal:
      case AlertType.backupReminder:
      case AlertType.savingsGoalReminder:
        return true;
      default:
        return false;
    }
  }

  bool _isAlert(AlertType type) {
    switch (type) {
      case AlertType.budgetApproachingLimit:
      case AlertType.budgetExceeded:
      case AlertType.largeExpense:
      case AlertType.unusualSpending:
      case AlertType.needsReviewCount:
      case AlertType.incomeReceived:
        return true;
      default:
        return false;
    }
  }

  List<AlertItem> _filterAlerts(List<AlertItem> alerts, AlertFilter filter) {
    switch (filter) {
      case AlertFilter.all:
        return alerts;
      case AlertFilter.reminders:
        return alerts.where((a) => _isReminder(a.type)).toList();
      case AlertFilter.alerts:
        return alerts.where((a) => _isAlert(a.type)).toList();
      case AlertFilter.unread:
        return alerts.where((a) => !a.isRead).toList();
    }
  }

  _AlertActionConfig? _getAlertAction(BuildContext context, AlertItem alert) {
    switch (alert.type) {
      case AlertType.upcomingEmi:
        return _AlertActionConfig(
          label: 'Pay EMI',
          icon: Icons.account_balance_outlined,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoansScreen()));
          },
        );
      case AlertType.upcomingSubscriptionRenewal:
        return _AlertActionConfig(
          label: 'View Subscription',
          icon: Icons.repeat_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
            );
          },
        );
      case AlertType.needsReviewCount:
        return _AlertActionConfig(
          label: 'Review',
          icon: Icons.rate_review_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NeedsReviewScreen()),
            );
          },
        );
      case AlertType.backupReminder:
        return _AlertActionConfig(
          label: 'Backup',
          icon: Icons.backup_outlined,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BackupScreen()));
          },
        );
      case AlertType.budgetApproachingLimit:
      case AlertType.budgetExceeded:
        return _AlertActionConfig(
          label: 'View Budget',
          icon: Icons.pie_chart_outline_rounded,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BudgetsScreen()));
          },
        );
      case AlertType.savingsGoalReminder:
        return _AlertActionConfig(
          label: 'View Goal',
          icon: Icons.flag_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
            );
          },
        );
      case AlertType.largeExpense:
      case AlertType.unusualSpending:
      case AlertType.incomeReceived:
        return null;
    }
  }

  Map<String, List<AlertItem>> _groupAlerts(List<AlertItem> alerts) {
    final grouped = <String, List<AlertItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final alert in alerts) {
      final itemDate = DateTime(
        alert.createdAt.year,
        alert.createdAt.month,
        alert.createdAt.day,
      );
      final diff = today.difference(itemDate).inDays;
      final String groupName;
      if (diff <= 0) {
        groupName = 'Today';
      } else if (diff <= 7) {
        groupName = 'Earlier this week';
      } else {
        groupName = 'Earlier';
      }

      (grouped[groupName] ??= []).add(alert);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(activeAlertsStreamProvider);

    final actions = [
      FfCircleButton(
        icon: Icons.done_all_rounded,
        tooltip: 'Mark All Read',
        soft: true,
        onPressed: () {
          HapticFeedback.selectionClick();
          ref.read(alertsControllerProvider.notifier).markAllAsRead();
        },
      ),
      const SizedBox(width: FfSpace.xs),
      FfCircleButton(
        icon: Icons.tune_rounded,
        tooltip: 'Alert Settings',
        soft: true,
        onPressed: () => AlertSettingsSheet.show(context),
      ),
    ];

    return FfPageScaffold(
      onAurora: true,
      title: 'Alerts & Reminders',
      subtitle: 'Reminders, on-device',
      actions: actions,
      body: alertsAsync.when(
        data: (alerts) => _buildBody(context, alerts),
        loading:
            () => ListView(
              padding: const EdgeInsets.only(top: FfSpace.xs),
              children: [
                const Padding(
                  padding: EdgeInsets.all(FfSpace.x4l),
                  child: FfLoading(),
                ),
              ],
            ),
        error:
            (e, _) => ListView(
              padding: const EdgeInsets.only(top: FfSpace.xs),
              children: [
                Padding(
                  padding: const EdgeInsets.all(FfSpace.xl),
                  child: Text(
                    'Error loading alerts: $e',
                    style: context.ff.text.body.copyWith(
                      color: context.ff.color.statusError,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<AlertItem> alerts) {
    final totalCount = alerts.length;
    final unreadCount = alerts.where((a) => !a.isRead).length;
    final urgentCount =
        alerts.where((a) => a.severity == AlertSeverity.urgent).length;
    final attentionCount =
        alerts.where((a) => a.severity == AlertSeverity.attention).length;
    final dueSoonCount =
        alerts
            .where(
              (a) =>
                  a.type == AlertType.upcomingEmi ||
                  a.type == AlertType.upcomingSubscriptionRenewal ||
                  a.type == AlertType.backupReminder,
            )
            .length;

    final filteredAlerts = _filterAlerts(alerts, _selectedFilter);
    final grouped = _groupAlerts(filteredAlerts);

    return RefreshIndicator(
      color: context.ff.color.actionPrimary,
      onRefresh: () async {
        await ref.read(alertsControllerProvider.notifier).runAlertScan();
      },
      child: ListView(
        padding: const EdgeInsets.only(top: FfSpace.xs, bottom: FfSpace.x4l),
        children: [
          // ── Command Status Hero Card ───────────────────────────────────────
          _buildCommandHero(
            context: context,
            alerts: alerts,
            totalCount: totalCount,
            unreadCount: unreadCount,
            urgentCount: urgentCount,
            attentionCount: attentionCount,
            dueSoonCount: dueSoonCount,
          ),
          const SizedBox(height: FfSpace.md),

          // ── Filter Pills Bar ───────────────────────────────────────────────
          if (alerts.isNotEmpty) ...[
            FfPillBar<AlertFilter>(
              values: AlertFilter.values,
              selected: _selectedFilter,
              label: (filter) {
                final count = _filterAlerts(alerts, filter).length;
                switch (filter) {
                  case AlertFilter.all:
                    return 'All ($count)';
                  case AlertFilter.reminders:
                    return count > 0 ? 'Reminders ($count)' : 'Reminders';
                  case AlertFilter.alerts:
                    return count > 0 ? 'Alerts ($count)' : 'Alerts';
                  case AlertFilter.unread:
                    return count > 0 ? 'Unread ($count)' : 'Unread';
                }
              },
              onSelected: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            const SizedBox(height: FfSpace.md),
          ],

          // ── Content Sections / Empty States ────────────────────────────────
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
                vertical: FfSpace.xl,
              ),
              child: FfEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'All caught up',
                description:
                    'FinanceFlow monitors your local budgets, upcoming EMIs, and subscription renewals calmly in the background.\n\n100% on-device local monitoring.',
              ),
            )
          else if (filteredAlerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
                vertical: FfSpace.xl,
              ),
              child: FfEmptyState(
                icon: Icons.filter_list_off_rounded,
                title: 'No ${_selectedFilter.displayName.toLowerCase()}',
                description:
                    'You have no active alerts matching the "${_selectedFilter.displayName}" filter.',
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
              ),
              child: FfSectionHeader(
                title: 'Active Notifications (${filteredAlerts.length})',
              ),
            ),
            for (final entry in grouped.entries) ...[
              if (grouped.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FfSpace.pageMargin + FfSpace.xs,
                    FfSpace.sm,
                    FfSpace.pageMargin,
                    FfSpace.xs,
                  ),
                  child: Text(
                    entry.key,
                    style: context.ff.text.label.copyWith(
                      color: context.ff.color.textSecondary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.pageMargin,
                ),
                child: FfGroupedContainer(
                  dividerInset: FfRowLeading.tile,
                  children: [
                    for (final alert in entry.value)
                      _buildAlertRow(context, alert),
                  ],
                ),
              ),
              const SizedBox(height: FfSpace.md),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCommandHero({
    required BuildContext context,
    required List<AlertItem> alerts,
    required int totalCount,
    required int unreadCount,
    required int urgentCount,
    required int attentionCount,
    required int dueSoonCount,
  }) {
    final heroTone =
        urgentCount > 0
            ? FfHeroTone.rose
            : (attentionCount > 0 ? FfHeroTone.dusk : FfHeroTone.moss);

    final hero = context.ff.hero(heroTone);

    final double ringProgress =
        alerts.isEmpty
            ? 1.0
            : (unreadCount == 0
                ? 1.0
                : (totalCount - unreadCount) / totalCount);

    final IconData ringIcon =
        urgentCount > 0
            ? Icons.warning_amber_rounded
            : (unreadCount > 0
                ? Icons.notifications_active_outlined
                : (alerts.isEmpty
                    ? Icons.shield_outlined
                    : Icons.check_circle_outline_rounded));

    final String heroTitle =
        urgentCount > 0
            ? 'Needs Attention'
            : (alerts.isEmpty
                ? 'System Protected'
                : (unreadCount > 0 ? 'Active Alerts' : 'All Caught Up'));

    final String heroSubtitle =
        alerts.isEmpty
            ? 'No active alerts · Local protection active'
            : '$unreadCount unread · $totalCount active items';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: FfHeroCard(
        tone: heroTone,
        leading: FfProgressRing(
          value: ringProgress,
          icon: ringIcon,
          semanticsLabel:
              alerts.isEmpty
                  ? 'All clear, local protection active'
                  : '$unreadCount unread out of $totalCount alerts',
        ),
        title: heroTitle,
        subtitle: heroSubtitle,
        onOpen:
            unreadCount > 0
                ? () {
                  HapticFeedback.selectionClick();
                  ref.read(alertsControllerProvider.notifier).markAllAsRead();
                }
                : null,
        openTooltip: 'Mark all read',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$totalCount',
                  style: context.ff.text.displayLg.copyWith(
                    fontWeight: FontWeight.w300,
                    color: hero.onHero,
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Text(
                  totalCount == 1
                      ? 'active alert'
                      : 'active alerts & reminders',
                  style: context.ff.text.bodySm.copyWith(
                    color: hero.onHeroSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FfSpace.md),
            FfHeroFigures([
              FfHeroFigure('Unread', '$unreadCount'),
              FfHeroFigure('Due Soon', '$dueSoonCount'),
              FfHeroFigure('Protection', 'On-device'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(BuildContext context, AlertItem alert) {
    final tone = _getSeverityTone(alert.severity);
    final iconData = _getAlertIcon(alert.type);
    final action = _getAlertAction(context, alert);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: FfSpace.lg),
        decoration: ShapeDecoration(
          color: context.ff.color.statusErrorContainer,
          shape: FfShape.of(FfRadius.md),
        ),
        child: Icon(
          Icons.archive_outlined,
          color: context.ff.color.statusError,
          size: FfIconSize.md,
        ),
      ),
      onDismissed: (_) {
        ref.read(alertsControllerProvider.notifier).dismissAlert(alert.id);
      },
      child: Material(
        type: MaterialType.transparency,
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
                      if (action != null) ...[
                        const SizedBox(height: FfSpace.xs),
                        FfButton(
                          label: action.label,
                          size: FfButtonSize.sm,
                          variant: FfButtonVariant.secondary,
                          leadingIcon: Icon(action.icon, size: FfIconSize.xs),
                          onPressed: () {
                            ref
                                .read(alertsControllerProvider.notifier)
                                .markAsRead(alert.id);
                            action.onTap();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
