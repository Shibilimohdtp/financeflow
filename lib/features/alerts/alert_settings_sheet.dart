import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/app_settings.dart';
import '../../services/notifications/local_notification_service.dart';
import '../../services/notifications/notification_coordinator.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../settings/settings_controller.dart';

final notificationPermissionStatusProvider =
    FutureProvider.autoDispose<NotificationPermissionStatus>((ref) async {
      final service = ref.watch(localNotificationServiceProvider);
      final isEnabled = await service.areNotificationsEnabled();
      if (isEnabled) return NotificationPermissionStatus.granted;
      return NotificationPermissionStatus.notRequested;
    });

/// Bottom sheet for configuring local push notifications and alerts preferences: Pattern E.
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
        const FfDivider(),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.md,
            ),
            children: [
              // ── 1. System Permission Banner ──────────────────────────────
              if (!isPermissionGranted && !kIsWeb) ...[
                FfCard(
                  variant: FfCardVariant.tinted,
                  tone: FfTone.warning,
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: context.ff.color.statusWarning,
                            size: 22,
                          ),
                          const SizedBox(width: FfSpace.sm),
                          Expanded(
                            child: Text(
                              'System Notifications Disabled',
                              style: context.ff.text.titleSm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.ff.color.statusWarning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FfSpace.xs),
                      Text(
                        'Enable Android notification permissions so FinanceFlow can alert you about budget thresholds, pending transaction reviews, and upcoming EMIs.',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: FfSpace.md),
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
                const SizedBox(height: FfSpace.xl),
              ],

              // ── 2. Master Switch ─────────────────────────────────────────
              const FfSectionHeader(title: 'Master Switch'),
              FfGroupedContainer(
                children: [
                  FfRow.toggle(
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

              const SizedBox(height: FfSpace.xl),

              // ── 3. Category Triggers ─────────────────────────────────────
              if (settings.isAlertsEnabled &&
                  settings.isLocalNotificationsEnabled) ...[
                const FfSectionHeader(title: 'Active Notification Categories'),
                FfGroupedContainer(
                  children: [
                    FfRow.toggle(
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
                    FfRow.toggle(
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
                    FfRow.toggle(
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
                    FfRow.toggle(
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
                    FfRow.toggle(
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
                const SizedBox(height: FfSpace.xl),

                // ── 4. Privacy Settings ───────────────────────────────────
                const FfSectionHeader(title: 'Lock Screen Privacy'),
                FfGroupedContainer(
                  children: [
                    FfRow.toggle(
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
                const SizedBox(height: FfSpace.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FfSpace.sm),
                  child: Text(
                    settings.hideSensitiveNotificationContent
                        ? 'Preview: "1 imported transaction is waiting for your review."'
                        : 'Preview: "Swiggy · ${CurrencyFormatter.formatAmount(450)} is waiting for review."',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: FfSpace.xl),
              ],

              // ── 5. Privacy & Battery Guarantee ───────────────────────────
              FfCard(
                variant: FfCardVariant.tinted,
                tone: FfTone.success,
                padding: const EdgeInsets.all(FfSpace.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 24,
                      color: context.ff.color.statusSuccess,
                    ),
                    const SizedBox(width: FfSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Local & Battery Friendly',
                            style: context.ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: FfSpace.x3s),
                          Text(
                            'All notifications are scheduled locally without background network drain or cloud trackers. The in-app Alerts inbox always stays up to date.',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 6. Developer Tools (Test Notification) ───────────────────
              if (kDebugMode) ...[
                const FfSectionHeader(title: 'Diagnostics & Testing'),
                FfGroupedContainer(
                  children: [
                    FfRow(
                      icon: Icons.send_rounded,
                      title: 'Send Test Notification',
                      subtitle:
                          'Triggers an immediate test notification to verify delivery',
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
                const SizedBox(height: FfSpace.xl),
              ],

              const SizedBox(height: FfSpace.x2l),
            ],
          ),
        ),
      ],
    );
  }
}
