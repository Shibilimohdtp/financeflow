import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/app_currency.dart';
import '../../models/app_settings.dart';
import '../../services/ingestion/ingestion_coordinator.dart';
import '../../services/ingestion/ingestion_platform.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_hold_to_confirm_button.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_settings_index.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../alerts/alert_settings_sheet.dart';
import '../alerts/alerts_inbox_screen.dart';
import '../backup/backup_screen.dart';
import '../export/export_screen.dart';
import '../ingestion/csv_import_screen.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/permissions/notification_permission_screen.dart';
import '../ingestion/permissions/sms_permission_screen.dart';
import '../security/security_settings_screen.dart';
import 'branding_preview_screen.dart';
import 'settings_controller.dart';
import 'widgets/density_visualizer_card.dart';
import 'widgets/ingestion_diagnostics_card.dart';
import 'widgets/settings_picker_sheets.dart';
import 'widgets/settings_search_results.dart';

class SettingsDetailScreen extends ConsumerStatefulWidget {
  const SettingsDetailScreen({super.key});

  @override
  ConsumerState<SettingsDetailScreen> createState() =>
      _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends ConsumerState<SettingsDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _handleDestination(
    BuildContext context,
    SettingsDestination dest,
    AppSettings settings,
  ) {
    switch (dest) {
      case SettingsDestination.themeSheet:
      case SettingsDestination.appearance:
        showSettingsThemePicker(context, ref, settings);
        break;
      case SettingsDestination.currencySheet:
        showSettingsCurrencyPicker(context, ref, settings);
        break;
      case SettingsDestination.density:
        ref
            .read(settingsControllerProvider.notifier)
            .setDenseMode(!settings.isDenseMode);
        FfToast.show(
          context,
          message:
              settings.isDenseMode
                  ? 'Switched to comfortable view.'
                  : 'Switched to ledger view (dense).',
        );
        break;
      case SettingsDestination.security:
      case SettingsDestination.pinSheet:
      case SettingsDestination.biometrics:
      case SettingsDestination.privacyBlur:
      case SettingsDestination.screenshotProtection:
      case SettingsDestination.autoLock:
        _push(context, const SecuritySettingsScreen());
        break;
      case SettingsDestination.alerts:
      case SettingsDestination.alertSettingsSheet:
        AlertSettingsSheet.show(context);
        break;
      case SettingsDestination.alertsInbox:
        _push(context, const AlertsInboxScreen());
        break;
      case SettingsDestination.detection:
      case SettingsDestination.smsPermission:
        _push(context, const SmsPermissionScreen());
        break;
      case SettingsDestination.notificationPermission:
        _push(context, const NotificationPermissionScreen());
        break;
      case SettingsDestination.csvImport:
        _push(context, const CsvImportScreen());
        break;
      case SettingsDestination.backup:
      case SettingsDestination.restore:
        _push(context, const BackupScreen());
        break;
      case SettingsDestination.export:
        _push(context, const ExportScreen());
        break;
      case SettingsDestination.dangerZone:
        _showWipeConfirm(context);
        break;
      case SettingsDestination.about:
      case SettingsDestination.debugGallery:
        _push(context, const BrandingPreviewScreen());
        break;
    }
  }

  Future<void> _showWipeConfirm(BuildContext context) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Wipe All Data?',
      message:
          'This will permanently delete all records stored on this device. This action cannot be undone.',
      confirmLabel: 'Wipe Everything',
      destructive: true,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(settingsControllerProvider.notifier).resetAllData();
      if (context.mounted) {
        FfToast.show(context, message: 'All local data was wiped.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final ingestionStatus = ref.watch(ingestionPlatformStatusProvider).value;
    final awaitingReview = ref.watch(pendingReviewCountProvider);

    final isSearching = _searchQuery.trim().isNotEmpty;
    final searchMatches =
        isSearching ? searchSettings(_searchQuery) : const <SettingsEntry>[];

    return FfPageScaffold(
      title: 'Settings',
      subtitle: 'Preferences & privacy',
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.md,
        ),
        children: [
          // ── Search Field ─────────────────────────────────────────────────
          FfTextField.search(
            controller: _searchController,
            hint: 'Search settings (e.g. PIN, theme, SMS, currency)...',
            onChanged: (val) => setState(() => _searchQuery = val),
            onSubmitted: (val) => setState(() => _searchQuery = val),
          ),

          const SizedBox(height: FfSpace.md),

          // ── If Searching: Show Matching Results ──────────────────────────
          if (isSearching) ...[
            SettingsSearchResults(
              results: searchMatches,
              onSelect:
                  (entry) =>
                      _handleDestination(context, entry.destination, settings),
            ),
          ] else ...[
            // ── 1. Appearance ────────────────────────────────────────────────
            const FfSectionHeader(title: 'Appearance'),
            FfGroupedContainer(
              dividerInset: FfRowLeading.icon,
              children: [
                FfRow(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  detail: settings.themePreference.displayName,
                  onTap: () => showSettingsThemePicker(context, ref, settings),
                ),
                FfRow(
                  icon: Icons.payments_outlined,
                  title: 'Currency',
                  detail: () {
                    final currency = AppCurrency.fromCode(
                      settings.currencyCode,
                    );
                    return '${currency.symbol} ${currency.code}';
                  }(),
                  onTap:
                      () => showSettingsCurrencyPicker(context, ref, settings),
                ),
              ],
            ),
            const SizedBox(height: FfSpace.sm),
            DensityVisualizerCard(settings: settings),

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
                  subtitle:
                      'Remind when imported transactions need confirmation',
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

            // ── 4. Data Reset (Danger zone) ──────────────────────────────────
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
                      color: context.ff.color.textSecondary,
                    ),
                  ),
                  const SizedBox(height: FfSpace.md),
                  Semantics(
                    label:
                        'Hold 2.5s to wipe all local data — destructive action',
                    child: FfHoldToConfirmButton(
                      label: 'Hold 2.5s to Wipe All Local Data',
                      holdingLabel: 'Wiping all local data in 2.5s...',
                      onConfirmed: () async {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .resetAllData();
                        if (context.mounted) {
                          FfToast.show(
                            context,
                            message: 'All local data was wiped.',
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.x4l),
          ],
        ],
      ),
    );
  }
}
