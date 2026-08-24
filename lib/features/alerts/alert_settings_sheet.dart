import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_switch_row.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';

class AlertSettingsSheet extends ConsumerWidget {
  const AlertSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FfSheetHeader(
              title: 'Alert Preferences',
              subtitle: 'Evaluated 100% locally on this device',
              trailing: FfPrivacyBadge(label: '100% Local'),
            ),
            const Divider(height: 1, thickness: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceMd,
                ),
                children: [
                  // ── 1. Master Switch ─────────────────────────────────────────
                  const FfSectionHeader(title: 'Master Switch'),
                  FfGroupedContainer(
                    children: [
                      FfSwitchRow(
                        icon: Icons.notifications_outlined,
                        title: 'Local Alerts & Reminders',
                        subtitle: 'Evaluated 100% on-device using local rules',
                        value: settings.isAlertsEnabled,
                        onChanged: (val) {
                          controller.updateSettings(
                            settings.copyWith(isAlertsEnabled: val),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: StillwaterTokens.spaceLg),

                  // ── 2. Category Triggers ─────────────────────────────────────
                  if (settings.isAlertsEnabled) ...[
                    const FfSectionHeader(
                      title: 'Active Notification Triggers',
                    ),
                    FfGroupedContainer(
                      children: [
                        FfSwitchRow(
                          icon: Icons.pie_chart_outline_rounded,
                          title: 'Budget Limits',
                          subtitle:
                              'Alert when category spending reaches 80% or exceeds limit',
                          value: settings.isBudgetAlertsEnabled,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(isBudgetAlertsEnabled: val),
                            );
                          },
                        ),
                        FfSwitchRow(
                          icon: Icons.repeat_rounded,
                          title: 'Subscription Renewals',
                          subtitle:
                              'Remind when upcoming subscriptions renew in ≤ 3 days',
                          value: settings.isSubscriptionAlertsEnabled,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(
                                isSubscriptionAlertsEnabled: val,
                              ),
                            );
                          },
                        ),
                        FfSwitchRow(
                          icon: Icons.account_balance_outlined,
                          title: 'Loan & EMI Due Dates',
                          subtitle:
                              'Remind when an upcoming loan EMI is due within 3 days',
                          value: settings.isLoanAlertsEnabled,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(isLoanAlertsEnabled: val),
                            );
                          },
                        ),
                        FfSwitchRow(
                          icon: Icons.rate_review_outlined,
                          title: 'Needs Review Transactions',
                          subtitle:
                              'Remind when imported SMS / CSV items require confirmation',
                          value: settings.isNeedsReviewAlertsEnabled,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(
                                isNeedsReviewAlertsEnabled: val,
                              ),
                            );
                          },
                        ),
                        FfSwitchRow(
                          icon: Icons.backup_outlined,
                          title: 'Encrypted Backup Reminders',
                          subtitle:
                              'Remind when 30 days have elapsed since last backup export',
                          value: settings.isBackupReminderEnabled,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(isBackupReminderEnabled: val),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceLg),
                  ],

                  // ── 3. Privacy Guarantee ─────────────────────────────────────
                  FfCard(
                    variant: FfCardVariant.tinted,
                    padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 24,
                          color: context.secColors.verified,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '100% On-Device Notifications',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'All alert rules evaluate strictly within your phone. No tracking data or transaction logs leave your device.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: StillwaterTokens.spaceXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
