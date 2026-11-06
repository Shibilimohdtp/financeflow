import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/app_currency.dart';
import '../../models/app_settings.dart';
import '../../services/ingestion/ingestion_coordinator.dart';
import '../../services/ingestion/ingestion_platform.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../alerts/alert_settings_sheet.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/permissions/notification_permission_screen.dart';
import '../ingestion/permissions/sms_permission_screen.dart';
import 'branding_preview_screen.dart';
import 'settings_controller.dart';
import 'widgets/ingestion_diagnostics_card.dart';

class SettingsDetailScreen extends ConsumerStatefulWidget {
  const SettingsDetailScreen({super.key});

  @override
  ConsumerState<SettingsDetailScreen> createState() =>
      _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends ConsumerState<SettingsDetailScreen> {
  bool _showDevTools = false;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final ingestionStatus = ref.watch(ingestionPlatformStatusProvider).value;
    final awaitingReview = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      appBar: const FfAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Appearance ────────────────────────────────────────────────
          const FfSectionHeader(title: 'Appearance'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow(
                icon: Icons.palette_outlined,
                title: 'Theme',
                detail: settings.themePreference.displayName,
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              FfRow.toggle(
                icon: Icons.density_medium_rounded,
                title: 'Ledger View',
                subtitle: 'Compact list rows and reduced padding',
                value: settings.isDenseMode,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setDenseMode(val);
                },
              ),
              FfRow(
                icon: Icons.payments_outlined,
                title: 'Currency',
                detail: () {
                  final currency = AppCurrency.fromCode(settings.currencyCode);
                  return '${currency.symbol} ${currency.code}';
                }(),
                onTap: () => _showCurrencyPicker(context, ref, settings),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 2. Alerts & Notifications ────────────────────────────────────
          const FfSectionHeader(title: 'Alerts & Notifications'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow.toggle(
                icon: Icons.notifications_outlined,
                title: 'All Alerts & Notifications',
                subtitle: 'Master switch for local alerts and notifications',
                value:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isAlertsEnabled: val,
                          isLocalNotificationsEnabled: val,
                        ),
                      );
                },
              ),
              FfRow(
                icon: Icons.tune_rounded,
                title: 'Notification & Alert Preferences',
                subtitle: 'Categories, lock screen privacy & permissions',
                onTap: () => AlertSettingsSheet.show(context),
              ),
              FfRow.toggle(
                icon: Icons.rate_review_outlined,
                title: 'Needs Review Alerts',
                subtitle: 'Remind when imported transactions need confirmation',
                value:
                    settings.isNeedsReviewNotificationsEnabled &&
                    settings.isNeedsReviewAlertsEnabled,
                enabled:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isNeedsReviewNotificationsEnabled: val,
                          isNeedsReviewAlertsEnabled: val,
                        ),
                      );
                },
              ),
              FfRow.toggle(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Budget Alerts',
                subtitle: 'Notify when spending approaches limit',
                value:
                    settings.isBudgetNotificationEnabled &&
                    settings.isBudgetAlertsEnabled,
                enabled:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isBudgetNotificationEnabled: val,
                          isBudgetAlertsEnabled: val,
                        ),
                      );
                },
              ),
              FfRow.toggle(
                icon: Icons.repeat_rounded,
                title: 'Subscription Alerts',
                subtitle: 'Notify before renewal dates',
                value:
                    settings.isSubscriptionNotificationEnabled &&
                    settings.isSubscriptionAlertsEnabled,
                enabled:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isSubscriptionNotificationEnabled: val,
                          isSubscriptionAlertsEnabled: val,
                        ),
                      );
                },
              ),
              FfRow.toggle(
                icon: Icons.account_balance_outlined,
                title: 'Loan & EMI Alerts',
                subtitle: 'Remind before EMI due dates',
                value:
                    settings.isLoanNotificationEnabled &&
                    settings.isLoanAlertsEnabled,
                enabled:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isLoanNotificationEnabled: val,
                          isLoanAlertsEnabled: val,
                        ),
                      );
                },
              ),
              FfRow.toggle(
                icon: Icons.backup_outlined,
                title: 'Backup Reminder',
                subtitle: 'Periodic reminder to create a backup',
                value:
                    settings.isBackupNotificationEnabled &&
                    settings.isBackupReminderEnabled,
                enabled:
                    settings.isAlertsEnabled &&
                    settings.isLocalNotificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
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

          // ── 3. Transaction Ingestion ─────────────────────────────────────
          const FfSectionHeader(title: 'Transaction Ingestion'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow.toggle(
                icon: Icons.notifications_active_outlined,
                title: 'Notification Detection',
                subtitle:
                    settings.isNotificationDetectionEnabled
                        ? ingestionStatus?.notificationAccess == true
                            ? 'Active for ${settings.selectedNotificationPackages.length} payment apps'
                            : 'Enabled, but Android access is not allowed'
                        : 'Disabled · tap to set up',
                value:
                    settings.isNotificationDetectionEnabled &&
                    ingestionStatus?.notificationAccess == true,
                onChanged: (val) {
                  if (val) {
                    _push(context, const NotificationPermissionScreen());
                  } else {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(
                            isNotificationDetectionEnabled: false,
                          ),
                        );
                  }
                },
              ),
              FfRow.toggle(
                icon: Icons.sms_outlined,
                title: 'Bank SMS Detection',
                subtitle:
                    settings.isSmsDetectionEnabled
                        ? ingestionStatus?.smsPermission ==
                                IngestionPermissionState.granted
                            ? 'Active for Indian banking SMS templates'
                            : 'Enabled, but Android SMS permission is not granted'
                        : 'Disabled · tap to set up',
                value:
                    settings.isSmsDetectionEnabled &&
                    ingestionStatus?.smsPermission ==
                        IngestionPermissionState.granted,
                onChanged: (val) {
                  if (val) {
                    _push(context, const SmsPermissionScreen());
                  } else {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(isSmsDetectionEnabled: false),
                        );
                  }
                },
              ),
              const FfRow(
                icon: Icons.email_outlined,
                title: 'Bank Email Detection',
                subtitle:
                    'Not configured · Gmail OAuth and scanning are unavailable in this build',
                detail: 'Unavailable',
                onTap: null,
              ),
            ],
          ),

          const SizedBox(height: FfSpace.md),
          IngestionDiagnosticsCard(
            settings: settings,
            ingestionStatus: ingestionStatus,
            awaitingReview: awaitingReview,
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 4. Developer Tools (collapsed) ───────────────────────────────
          _MoreOptionsToggle(
            label: 'Developer Tools',
            isExpanded: _showDevTools,
            onToggle: () => setState(() => _showDevTools = !_showDevTools),
          ),

          if (_showDevTools) ...[
            const SizedBox(height: FfSpace.md),
            FfCard(
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seed Demo Dataset', style: context.ff.text.titleSm),
                  const SizedBox(height: FfSpace.x2s),
                  Text(
                    'Load sample Indian transactions (Swiggy, Netflix, Salary, HDFC EMI) for UI review.',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.secondary,
                    ),
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfButton(
                    label: 'Load Realistic Demo Data',
                    variant: FfButtonVariant.outlined,
                    size: FfButtonSize.sm,
                    onPressed: () async {
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .seedDemoData();
                      if (context.mounted) {
                        FfToast.show(
                          context,
                          message: 'Demo dataset loaded on this device.',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: FfSpace.sm),
                  Wrap(
                    spacing: FfSpace.sm,
                    runSpacing: FfSpace.sm,
                    children: [
                      FfButton(
                        label: 'Inject Sample SMS',
                        variant: FfButtonVariant.outlined,
                        size: FfButtonSize.sm,
                        onPressed: () async {
                          final result =
                              await ref
                                  .read(ingestionCoordinatorProvider)
                                  .injectSampleSms();
                          if (context.mounted) {
                            FfToast.show(
                              context,
                              message:
                                  'Sample SMS: ${result.disposition.name}.',
                            );
                          }
                        },
                      ),
                      FfButton(
                        label: 'Inject Sample Notification',
                        variant: FfButtonVariant.outlined,
                        size: FfButtonSize.sm,
                        onPressed: () async {
                          final result =
                              await ref
                                  .read(ingestionCoordinatorProvider)
                                  .injectSampleNotification();
                          if (context.mounted) {
                            FfToast.show(
                              context,
                              message:
                                  'Sample notification: ${result.disposition.name}.',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.sm),
                  FfButton(
                    label: 'Stillwater Brand Showcase',
                    variant: FfButtonVariant.text,
                    size: FfButtonSize.sm,
                    leadingIcon: const Icon(Icons.palette_outlined, size: 16),
                    onPressed: () {
                      _push(context, const BrandingPreviewScreen());
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: FfSpace.xl),

          // ── 5. Data Reset (Danger zone) ──────────────────────────────────
          const FfSectionHeader(title: 'Data Reset'),
          FfCard(
            variant: FfCardVariant.warning,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: context.ff.color.statusError,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Text(
                      'Wipe All App Data',
                      style: context.ff.text.titleSm.copyWith(
                        color: context.ff.color.statusError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.xs),
                Text(
                  'Permanently deletes all stored transactions, accounts, loans, and security keys from this device. Cannot be undone.',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
                const SizedBox(height: FfSpace.md),
                Semantics(
                  label: 'Delete all data on device — destructive action',
                  child: FfButton(
                    label: 'Delete All Data on Device',
                    variant: FfButtonVariant.destructive,
                    size: FfButtonSize.sm,
                    onPressed: () async {
                      final confirmed = await FfDialog.confirm(
                        context,
                        title: 'Wipe All Data?',
                        message:
                            'This will permanently delete all records stored on this device. This action cannot be undone.',
                        confirmLabel: 'Wipe Everything',
                        destructive: true,
                      );
                      if (confirmed == true && context.mounted) {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .resetAllData();
                        if (context.mounted) {
                          FfToast.show(
                            context,
                            message: 'All local data was wiped.',
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x4l),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final selected = AppCurrency.fromCode(settings.currencyCode);
    showFfSheet(
      context,
      builder: (ctx) {
        return FfSheet(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FfSheetHeader(
              title: 'Currency',
              subtitle: 'Changes how amounts are shown. No conversion.',
            ),
            const FfDivider(),
            for (final currency in AppCurrency.values)
              FfRow(
                key: ValueKey('currency-${currency.code}'),
                leading: SizedBox(
                  width: FfRowTokens.iconTile,
                  child: Center(
                    child: Text(currency.symbol, style: context.ff.text.title),
                  ),
                ),
                title: currency.displayName,
                subtitle: currency.code,
                selected: currency == selected,
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (currency != selected) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(currencyCode: currency.code),
                        );
                  }
                },
              ),
          ],
        );
      },
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showFfSheet(
      context,
      builder: (ctx) {
        return FfSheet(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FfSheetHeader(
              title: 'Theme',
              subtitle: 'Choose your visual preference',
            ),
            const FfDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
                vertical: FfSpace.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...AppThemePreference.values.map((pref) {
                    final isSelected = settings.themePreference == pref;
                    return FfRow(
                      icon:
                          pref == AppThemePreference.system
                              ? Icons.brightness_auto_outlined
                              : pref == AppThemePreference.daylight
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                      title: pref.displayName,
                      selected: isSelected,
                      onTap: () {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setThemePreference(pref);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                  const SizedBox(height: FfSpace.sm),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoreOptionsToggle extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MoreOptionsToggle({
    required this.label,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(FfRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: context.ff.color.secondary,
            ),
            const SizedBox(width: FfSpace.xs),
            Text(
              label,
              style: context.ff.text.bodySm.copyWith(
                color: context.ff.color.actionPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
