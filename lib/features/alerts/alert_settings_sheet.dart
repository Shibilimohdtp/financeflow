import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_settings.dart';
import '../../services/notifications/local_notification_service.dart';
import '../../services/notifications/notification_coordinator.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_notification_preview_bubble.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_banner.dart';
import '../../shared/widgets/ff_consequence_line.dart';
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

    final alertsOn =
        settings.isAlertsEnabled && settings.isLocalNotificationsEnabled;

    Future<void> requestPermission() async {
      setState(() => _isRequestingPermission = true);
      try {
        final status =
            await notificationService.requestNotificationPermission();
        ref.invalidate(notificationPermissionStatusProvider);
        if (status == NotificationPermissionStatus.permanentlyDenied &&
            context.mounted) {
          await notificationService.openSystemNotificationSettings();
        }
      } finally {
        if (mounted) setState(() => _isRequestingPermission = false);
      }
    }

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FfSheetHeader(
          title: 'Notifications',
          subtitle: 'What FinanceFlow reminds you about',
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: FfSheetBody.standardPadding,
            children: [
              // ── System permission (archetype D: settings apply at once) ──
              if (!isPermissionGranted && !kIsWeb)
                FfSheetGroup(
                  children: [
                    FfBanner(
                      tone: FfBannerTone.warning,
                      icon: Icons.notifications_off_outlined,
                      title: 'Notifications are off for FinanceFlow',
                      message:
                          'Turn them on in Android so FinanceFlow can remind you about budgets, items to review and EMIs.',
                      actionLabel:
                          _isRequestingPermission ? 'Checking…' : 'Turn on',
                      onAction:
                          _isRequestingPermission ? null : requestPermission,
                    ),
                  ],
                ),

              // ── Master switch ────────────────────────────────────────────
              FfSheetGroup(
                children: [
                  FfGroupedContainer(
                    children: [
                      FfRow.toggle(
                        icon: Icons.notifications_outlined,
                        title: 'Alerts and notifications',
                        subtitle: 'Worked out on this device from your data',
                        value: alertsOn,
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
                ],
              ),

              if (alertsOn) ...[
                // ── Categories ─────────────────────────────────────────────
                FfSheetGroup(
                  label: 'Remind me about',
                  children: [
                    FfGroupedContainer(
                      children: [
                        FfRow.toggle(
                          icon: Icons.rate_review_outlined,
                          title: 'Items to review',
                          subtitle:
                              'Imported SMS or CSV items that need a look',
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
                          title: 'Budget limits',
                          subtitle: 'At 80% of a budget and when it is over',
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
                          title: 'Subscription renewals',
                          subtitle: 'Before a subscription renews',
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
                          title: 'Loan and EMI due dates',
                          subtitle: 'Before an EMI is due',
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
                          title: 'Backup reminders',
                          subtitle: '30 days after your last encrypted backup',
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
                  ],
                ),

                // ── Lock screen ────────────────────────────────────────────
                FfSheetGroup(
                  label: 'Lock screen',
                  children: [
                    FfGroupedContainer(
                      children: [
                        FfRow.toggle(
                          icon: Icons.visibility_off_outlined,
                          title: 'Hide amounts and payees',
                          subtitle:
                              'Show a privacy-safe line on the lock screen instead',
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
                    FfNotificationPreviewBubble(
                      hideSensitive: settings.hideSensitiveNotificationContent,
                    ),
                    Text(
                      settings.hideSensitiveNotificationContent
                          ? '1 imported transaction is waiting for your review.'
                          : 'How a notification looks on the lock screen.',
                      style: context.ff.text.label.copyWith(
                        color: context.ff.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Trust note ───────────────────────────────────────────────
              FfSheetGroup(
                last: !kDebugMode,
                children: const [
                  FfConsequenceLine(
                    text:
                        'Scheduled on this device, with no network or cloud. The Alerts inbox always stays up to date.',
                    icon: Icons.lock_outline_rounded,
                    tone: FfTone.success,
                  ),
                ],
              ),

              // ── Developer tools (debug builds only) ──────────────────────
              if (kDebugMode)
                FfSheetGroup(
                  label: 'Diagnostics',
                  last: true,
                  children: [
                    FfGroupedContainer(
                      children: [
                        FfRow(
                          icon: Icons.send_rounded,
                          title: 'Send a test notification',
                          subtitle:
                              'Checks that notifications reach this phone',
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
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
