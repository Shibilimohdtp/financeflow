import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/app_currency.dart';
import '../../core/constants/app_constants.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../services/ingestion/ingestion_coordinator.dart';
import '../../services/ingestion/ingestion_platform.dart';
import '../accounts/accounts_screen.dart';
import '../alerts/alert_settings_sheet.dart';
import '../alerts/alerts_inbox_screen.dart';
import '../backup/backup_screen.dart';
import '../export/export_screen.dart';
import '../financial_health/financial_health_screen.dart';
import '../ingestion/csv_import_screen.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../ingestion/permissions/notification_permission_screen.dart';
import '../ingestion/permissions/sms_permission_screen.dart';
import '../investments/investments_screen.dart';
import '../loans/loans_screen.dart';
import '../personal_debts/lending_borrowing_screen.dart';
import '../savings_goals/savings_goals_screen.dart';
import '../security/security_settings_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import 'branding_preview_screen.dart';
import 'settings_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../theme/ff.dart';

String _smsStatusLabel(IngestionPlatformStatus? status) {
  if (status == null) return 'Checking';
  switch (status.smsPermission) {
    case IngestionPermissionState.granted:
      return 'Granted';
    case IngestionPermissionState.denied:
      return 'Denied';
    case IngestionPermissionState.permanentlyDenied:
      return 'Permanently denied';
    case IngestionPermissionState.restricted:
      return 'Restricted';
    case IngestionPermissionState.unavailable:
      return 'Unavailable';
  }
}

String _ingestionTime(DateTime? value) {
  if (value == null) return 'Never';
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// More Screen — navigation hub (tab 4)
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            title: const Text('More'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: FfSpace.md),
                child: Center(
                  child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.lg,
              vertical: FfSpace.md,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Finance Modules ────────────────────────────────────────
                const _SectionLabel(label: 'Finance Modules'),
                const SizedBox(height: FfSpace.xs),
                FfGroupedContainer(
                  dividerInset: FfRowLeading.icon,
                  children: [
                    FfRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Financial Accounts',
                      subtitle: 'Bank accounts, cards, cash & UPI',
                      onTap: () => _push(context, const AccountsScreen()),
                    ),
                    FfRow(
                      icon: Icons.account_balance_outlined,
                      title: 'Loans & EMI Tracker',
                      subtitle: 'Amortization, outstanding debt & EMIs',
                      onTap: () => _push(context, const LoansScreen()),
                    ),
                    FfRow(
                      icon: Icons.handshake_outlined,
                      title: 'Lending & Borrowing',
                      subtitle: 'Track money lent to & borrowed from others',
                      onTap:
                          () => _push(context, const LendingBorrowingScreen()),
                    ),
                    FfRow(
                      icon: Icons.repeat_rounded,
                      title: 'Subscriptions',
                      subtitle: 'Recurring services, renewals & burn rate',
                      onTap: () => _push(context, const SubscriptionsScreen()),
                    ),
                    FfRow(
                      icon: Icons.flag_outlined,
                      title: 'Savings Goals',
                      subtitle: 'Emergency fund, vacation & targets',
                      onTap: () => _push(context, const SavingsGoalsScreen()),
                    ),
                    FfRow(
                      icon: Icons.show_chart_rounded,
                      title: 'Investment Portfolio',
                      subtitle: 'Stocks, mutual funds, gold & valuations',
                      onTap: () => _push(context, const InvestmentsScreen()),
                    ),
                    FfRow(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Financial Health Score',
                      subtitle: '7-dimension on-device wellness score',
                      onTap:
                          () => _push(context, const FinancialHealthScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: FfSpace.x2l),

                // ── Tools & Insights ───────────────────────────────────────
                const _SectionLabel(label: 'Tools & Insights'),
                const SizedBox(height: FfSpace.xs),
                FfGroupedContainer(
                  dividerInset: FfRowLeading.icon,
                  children: [
                    FfRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Local Alerts Inbox',
                      subtitle: 'Budget limits, EMI reminders & renewals',
                      onTap: () => _push(context, const AlertsInboxScreen()),
                    ),
                    FfRow(
                      icon: Icons.file_upload_outlined,
                      title: 'Import CSV Statement',
                      subtitle: 'Parse bank or credit card CSV files',
                      onTap: () => _push(context, const CsvImportScreen()),
                    ),
                    FfRow(
                      icon: Icons.rate_review_outlined,
                      title: 'Needs Review Queue',
                      subtitle:
                          pendingCount > 0
                              ? '$pendingCount transactions need review'
                              : 'No pending transactions',
                      trailing:
                          pendingCount > 0
                              ? _CountBadge(count: pendingCount)
                              : null,
                      onTap: () => _push(context, const NeedsReviewScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: FfSpace.x2l),

                // ── Data & Backup ──────────────────────────────────────────
                const _SectionLabel(label: 'Data & Backup'),
                const SizedBox(height: FfSpace.xs),
                FfGroupedContainer(
                  dividerInset: FfRowLeading.icon,
                  children: [
                    FfRow(
                      icon: Icons.file_download_outlined,
                      title: 'Export Data',
                      subtitle: 'CSV, JSON, Excel spreadsheet & PDF reports',
                      onTap: () => _push(context, const ExportScreen()),
                    ),
                    FfRow(
                      icon: Icons.lock_clock_outlined,
                      title: 'Encrypted Backup & Restore',
                      subtitle: 'PBKDF2 & AES-256 local encrypted files',
                      onTap: () => _push(context, const BackupScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: FfSpace.x2l),

                // ── App settings ───────────────────────────────────────────
                const _SectionLabel(label: 'App'),
                const SizedBox(height: FfSpace.xs),
                FfGroupedContainer(
                  dividerInset: FfRowLeading.icon,
                  children: [
                    FfRow(
                      icon: Icons.settings_outlined,
                      title: 'App Settings',
                      subtitle: 'Appearance, alerts, security & more',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const _SettingsDetailScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: FfSpace.x2l),

                // ── About footer ───────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const FinanceFlowLogo(
                        markSize: 40,
                        fontSize: 20,
                        axis: Axis.vertical,
                      ),
                      const SizedBox(height: FfSpace.xs),
                      Text(
                        AppConstants.appTagline,
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x2s),
                      Text(
                        AppConstants.appVersion,
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.borderStrong,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x4l),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Detail Screen — pushed from More
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsDetailScreen extends ConsumerStatefulWidget {
  const _SettingsDetailScreen();

  @override
  ConsumerState<_SettingsDetailScreen> createState() =>
      _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends ConsumerState<_SettingsDetailScreen> {
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
      appBar: FfAppBar(title: 'Settings', leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Appearance ────────────────────────────────────────────────
          const _SectionLabel(label: 'Appearance'),
          const SizedBox(height: FfSpace.xs),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              // Theme — opens bottom sheet
              FfRow(
                icon: Icons.palette_outlined,
                title: 'Theme',
                detail: settings.themePreference.displayName,
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              // Dense mode switch
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

          const SizedBox(height: FfSpace.x2l),

          // ── 2. Alerts & Notifications ────────────────────────────────────
          const _SectionLabel(label: 'Alerts & Notifications'),
          const SizedBox(height: FfSpace.xs),
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

          const SizedBox(height: FfSpace.x2l),

          // ── 3. Privacy & Security ────────────────────────────────────────
          const _SectionLabel(label: 'Privacy & Security'),
          const SizedBox(height: FfSpace.xs),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow(
                icon: Icons.shield_outlined,
                title: 'App Lock & Biometrics',
                subtitle: 'PIN, face ID, fingerprint & auto-lock',
                onTap: () => _push(context, const SecuritySettingsScreen()),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 4. Transaction Ingestion ─────────────────────────────────────
          const _SectionLabel(label: 'Transaction Ingestion'),
          const SizedBox(height: FfSpace.xs),
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
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              Padding(
                padding: const EdgeInsets.all(FfSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingestion diagnostics',
                      style: context.ff.text.titleSm,
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Text(
                      'SMS permission: ${_smsStatusLabel(ingestionStatus)}\n'
                      'Notification access: ${ingestionStatus?.notificationAccess == true ? 'Allowed' : 'Not allowed'}\n'
                      'Gmail connection: Not configured\n'
                      'Last SMS event: ${_ingestionTime(settings.lastSuccessfulSmsEvent)}\n'
                      'Last notification event: ${_ingestionTime(settings.lastSuccessfulNotificationEvent)}\n'
                      'Last Gmail scan: Never\n'
                      'Parsed: ${settings.ingestionParsedCount} · Rejected: ${settings.ingestionRejectedCount}\n'
                      'Duplicates: ${settings.ingestionDuplicateCount} · Awaiting review: $awaitingReview\n'
                      'Last error: ${settings.ingestionLastError ?? 'None'}',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.secondary,
                        height: 1.55,
                      ),
                    ),
                    if (settings.isSmsDetectionEnabled &&
                        ingestionStatus?.smsPermission !=
                            IngestionPermissionState.granted) ...[
                      const SizedBox(height: FfSpace.sm),
                      Text(
                        'Action: open Bank SMS Detection and grant Android access.',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.statusError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 6. Developer Tools (collapsed) ───────────────────────────────
          _MoreOptionsToggle(
            label: 'Developer Tools',
            isExpanded: _showDevTools,
            onToggle: () => setState(() => _showDevTools = !_showDevTools),
          ),

          if (_showDevTools) ...[
            const SizedBox(height: FfSpace.md),
            FfGroupedContainer(
              dividerInset: FfRowLeading.icon,
              children: [
                Padding(
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
                        leadingIcon: const Icon(
                          Icons.palette_outlined,
                          size: 16,
                        ),
                        onPressed: () {
                          _push(context, const BrandingPreviewScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: FfSpace.x2l),

          // ── 7. Data Reset ────────────────────────────────────────────────
          const _SectionLabel(label: 'Data Reset'),
          const SizedBox(height: FfSpace.xs),

          // Danger zone — deliberately styled differently (no icon tint, no chip)
          Container(
            decoration: BoxDecoration(
              color: context.ff.color.statusErrorContainer.withValues(
                alpha: FfTint.faint.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.statusError.withValues(
                  alpha: FfTint.medium.alpha,
                ),
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
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
                horizontal: FfSpace.lg,
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

// ─────────────────────────────────────────────────────────────────────────────
// Private shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// All-caps section heading — consistent with loan_detail_screen redesign.
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}

/// Count badge — consistent chip style.
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.xs,
        vertical: FfSpace.x3s,
      ),
      decoration: BoxDecoration(
        color: context.ff.color.accent.withValues(alpha: FfTint.subtle.alpha),
        borderRadius: BorderRadius.circular(FfRadius.full),
      ),
      child: Text(
        '$count',
        style: context.ff.text.labelSm.copyWith(
          fontWeight: FontWeight.w700,
          color: context.ff.color.accent,
        ),
      ),
    );
  }
}

/// Expandable toggle — same pattern as add_edit_loan_sheet.
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
