import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_switch_row.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';
import '../../services/notifications/local_notification_service.dart';
import '../../services/notifications/notification_coordinator.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_sheet.dart';

final notificationPermissionStatusProvider =
    FutureProvider.autoDispose<NotificationPermissionStatus>((ref) async {
      final service = ref.watch(localNotificationServiceProvider);
      final isEnabled = await service.areNotificationsEnabled();
      if (isEnabled) return NotificationPermissionStatus.granted;
      return NotificationPermissionStatus.notRequested;
    });

/// Bottom sheet for configuring local push notifications and alerts preferences.
class AlertSettingsSheet extends ConsumerStatefulWidget {
  const AlertSettingsSheet({super.key});

  /// Helper to open the sheet with proper safe area and top margin constraints.
  static Future<void> show(BuildContext context) {
    return showFfSheet(context, builder: (_) => const AlertSettingsSheet());
  }

  @override
  ConsumerState<AlertSettingsSheet> createState() => _AlertSettingsSheetState();
}

/// Backwards compatibility alias for existing references.
typedef NotificationPreferencesScreen = AlertSettingsSheet;

class _AlertSettingsSheetState extends ConsumerState<AlertSettingsSheet> {
  bool _isRequestingPermission = false;

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final permissionAsync = ref.watch(notificationPermissionStatusProvider);
    final notificationService = ref.read(localNotificationServiceProvider);

    final isPermissionGranted = permissionAsync.value?.isGranted ?? false;

    return FfSheet(
      children: [
        const FfSheetHeader(
          title: 'Notification Preferences',
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
              // ── 1. System Permission Banner ──────────────────────────────
              if (!isPermissionGranted && !kIsWeb) ...[
                FfCard(
                  variant: FfCardVariant.elevated,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: context.secColors.verified,
                            size: 22,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceSm),
                          Expanded(
                            child: Text(
                              'System Notifications Disabled',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        'Enable Android notification permissions so FinanceFlow can alert you about budget thresholds, pending transaction reviews, and upcoming EMIs.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.secondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                      FfButton(
                        label:
                            _isRequestingPermission
                                ? 'Checking...'
                                : 'Enable System Notifications',
                        size: FfButtonSize.sm,
                        onPressed:
                            _isRequestingPermission
                                ? null
                                : () async {
                                  setState(
                                    () => _isRequestingPermission = true,
                                  );
                                  try {
                                    final status =
                                        await notificationService
                                            .requestNotificationPermission();
                                    ref.invalidate(
                                      notificationPermissionStatusProvider,
                                    );
                                    if (status ==
                                            NotificationPermissionStatus
                                                .permanentlyDenied &&
                                        context.mounted) {
                                      await notificationService
                                          .openSystemNotificationSettings();
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(
                                        () => _isRequestingPermission = false,
                                      );
                                    }
                                  }
                                },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
              ],

              // ── 2. Master Switch ─────────────────────────────────────────
              const FfSectionHeader(title: 'Master Switch'),
              FfGroupedContainer(
                children: [
                  FfSwitchRow(
                    icon: Icons.notifications_outlined,
                    title: 'Local Alerts & Notifications',
                    subtitle: 'Evaluated 100% on-device using local rules',
                    value:
                        settings.isAlertsEnabled &&
                        settings.isLocalNotificationsEnabled,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(
                          isAlertsEnabled: val,
                          isLocalNotificationsEnabled: val,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 3. Category Triggers ─────────────────────────────────────
              if (settings.isAlertsEnabled &&
                  settings.isLocalNotificationsEnabled) ...[
                const FfSectionHeader(title: 'Active Notification Categories'),
                FfGroupedContainer(
                  children: [
                    FfSwitchRow(
                      icon: Icons.rate_review_outlined,
                      title: 'Needs Review Transactions',
                      subtitle:
                          'Remind when imported SMS / CSV items require confirmation',
                      value:
                          settings.isNeedsReviewNotificationsEnabled &&
                          settings.isNeedsReviewAlertsEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            isNeedsReviewNotificationsEnabled: val,
                            isNeedsReviewAlertsEnabled: val,
                          ),
                        );
                      },
                    ),
                    FfSwitchRow(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'Budget Limits',
                      subtitle:
                          'Alert when category spending reaches 80% or exceeds limit',
                      value:
                          settings.isBudgetNotificationEnabled &&
                          settings.isBudgetAlertsEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            isBudgetNotificationEnabled: val,
                            isBudgetAlertsEnabled: val,
                          ),
                        );
                      },
                    ),
                    FfSwitchRow(
                      icon: Icons.repeat_rounded,
                      title: 'Subscription Renewals',
                      subtitle: 'Remind before upcoming subscriptions renew',
                      value:
                          settings.isSubscriptionNotificationEnabled &&
                          settings.isSubscriptionAlertsEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            isSubscriptionNotificationEnabled: val,
                            isSubscriptionAlertsEnabled: val,
                          ),
                        );
                      },
                    ),
                    FfSwitchRow(
                      icon: Icons.account_balance_outlined,
                      title: 'Loan & EMI Due Dates',
                      subtitle: 'Remind before upcoming loan EMIs are due',
                      value:
                          settings.isLoanNotificationEnabled &&
                          settings.isLoanAlertsEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            isLoanNotificationEnabled: val,
                            isLoanAlertsEnabled: val,
                          ),
                        );
                      },
                    ),
                    FfSwitchRow(
                      icon: Icons.backup_outlined,
                      title: 'Encrypted Backup Reminders',
                      subtitle:
                          'Remind when 30 days have elapsed since last backup export',
                      value:
                          settings.isBackupNotificationEnabled &&
                          settings.isBackupReminderEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            isBackupNotificationEnabled: val,
                            isBackupReminderEnabled: val,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── 4. Privacy Settings ───────────────────────────────────
                const FfSectionHeader(title: 'Lock Screen Privacy'),
                FfGroupedContainer(
                  children: [
                    FfSwitchRow(
                      icon: Icons.visibility_off_outlined,
                      title: 'Hide Financial Details',
                      subtitle:
                          'Show privacy-safe text instead of merchant and amounts on lock screen',
                      value: settings.hideSensitiveNotificationContent,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(
                            hideSensitiveNotificationContent: val,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceSm,
                  ),
                  child: Text(
                    settings.hideSensitiveNotificationContent
                        ? 'Preview: "1 imported transaction is waiting for your review."'
                        : 'Preview: "Swiggy · ${CurrencyFormatter.formatAmount(450)} is waiting for review."',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
              ],

              // ── 5. Privacy & Battery Guarantee ───────────────────────────
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
                            '100% Local & Battery Friendly',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All notifications are scheduled locally without background network drain or cloud trackers. The in-app Alerts inbox always stays up to date.',
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

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 6. Developer Tools (Test Notification) ───────────────────
              if (kDebugMode) ...[
                const FfSectionHeader(title: 'Diagnostics & Testing'),
                FfGroupedContainer(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.send_rounded),
                      title: const Text('Send Test Notification'),
                      subtitle: const Text(
                        'Triggers an immediate test notification to verify delivery',
                      ),
                      onTap: () async {
                        await ref
                            .read(notificationCoordinatorProvider)
                            .sendTestNotification(
                              title: 'FinanceFlow Test Notification',
                              body:
                                  'Local notification pipeline is active and functioning properly.',
                            );
                        if (context.mounted) {
                          FfToast.show(
                            context,
                            message: 'Test notification sent to device.',
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
              ],

              const SizedBox(height: StillwaterTokens.space2Xl),
            ],
          ),
        ),
      ],
    );
  }
}
