import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_tokens.dart';
import '../../services/ingestion/ingestion_coordinator.dart';
import '../../services/ingestion/ingestion_platform.dart';
import '../accounts/accounts_screen.dart';
import '../ai/ai_query_sheet.dart';
import '../ai/gemini_consent_screen.dart';
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
    final theme = context.theme;
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
                padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
                child: Center(
                  child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceMd,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Finance Modules ────────────────────────────────────────
                _SectionLabel(label: 'Finance Modules'),
                const SizedBox(height: StillwaterTokens.spaceXs),
                _NavGroup(
                  children: [
                    _NavRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Financial Accounts',
                      subtitle: 'Bank accounts, cards, cash & UPI',
                      onTap: () => _push(context, const AccountsScreen()),
                    ),
                    _NavRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Loans & EMI Tracker',
                      subtitle: 'Amortization, outstanding debt & EMIs',
                      onTap: () => _push(context, const LoansScreen()),
                    ),
                    _NavRow(
                      icon: Icons.handshake_outlined,
                      label: 'Lending & Borrowing',
                      subtitle: 'Track money lent to & borrowed from others',
                      onTap:
                          () => _push(context, const LendingBorrowingScreen()),
                    ),
                    _NavRow(
                      icon: Icons.repeat_rounded,
                      label: 'Subscriptions',
                      subtitle: 'Recurring services, renewals & burn rate',
                      onTap: () => _push(context, const SubscriptionsScreen()),
                    ),
                    _NavRow(
                      icon: Icons.flag_outlined,
                      label: 'Savings Goals',
                      subtitle: 'Emergency fund, vacation & targets',
                      onTap: () => _push(context, const SavingsGoalsScreen()),
                    ),
                    _NavRow(
                      icon: Icons.show_chart_rounded,
                      label: 'Investment Portfolio',
                      subtitle: 'Stocks, mutual funds, gold & valuations',
                      onTap: () => _push(context, const InvestmentsScreen()),
                    ),
                    _NavRow(
                      icon: Icons.health_and_safety_outlined,
                      label: 'Financial Health Score',
                      subtitle: '7-dimension on-device wellness score',
                      isLast: true,
                      onTap:
                          () => _push(context, const FinancialHealthScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.space2Xl),

                // ── Tools & Insights ───────────────────────────────────────
                _SectionLabel(label: 'Tools & Insights'),
                const SizedBox(height: StillwaterTokens.spaceXs),
                _NavGroup(
                  children: [
                    _NavRow(
                      icon: Icons.notifications_active_outlined,
                      label: 'Local Alerts Inbox',
                      subtitle: 'Budget limits, EMI reminders & renewals',
                      onTap: () => _push(context, const AlertsInboxScreen()),
                    ),
                    _NavRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: context.aiColors.accent,
                      label: 'Ask Your Finances',
                      subtitle: 'Natural language queries · on-device first',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const AiQuerySheet(),
                        );
                      },
                    ),
                    _NavRow(
                      icon: Icons.file_upload_outlined,
                      label: 'Import CSV Statement',
                      subtitle: 'Parse bank or credit card CSV files',
                      onTap: () => _push(context, const CsvImportScreen()),
                    ),
                    _NavRow(
                      icon: Icons.rate_review_outlined,
                      label: 'Needs Review Queue',
                      subtitle:
                          pendingCount > 0
                              ? '$pendingCount transactions need review'
                              : 'No pending transactions',
                      trailing:
                          pendingCount > 0
                              ? _CountBadge(count: pendingCount)
                              : null,
                      isLast: true,
                      onTap: () => _push(context, const NeedsReviewScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.space2Xl),

                // ── Data & Backup ──────────────────────────────────────────
                _SectionLabel(label: 'Data & Backup'),
                const SizedBox(height: StillwaterTokens.spaceXs),
                _NavGroup(
                  children: [
                    _NavRow(
                      icon: Icons.file_download_outlined,
                      label: 'Export Data',
                      subtitle: 'CSV, JSON, Excel spreadsheet & PDF reports',
                      onTap: () => _push(context, const ExportScreen()),
                    ),
                    _NavRow(
                      icon: Icons.lock_clock_outlined,
                      label: 'Encrypted Backup & Restore',
                      subtitle: 'PBKDF2 & AES-256 local encrypted files',
                      isLast: true,
                      onTap: () => _push(context, const BackupScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.space2Xl),

                // ── App settings ───────────────────────────────────────────
                _SectionLabel(label: 'App'),
                const SizedBox(height: StillwaterTokens.spaceXs),
                _NavGroup(
                  children: [
                    _NavRow(
                      icon: Icons.settings_outlined,
                      label: 'App Settings',
                      subtitle: 'Appearance, alerts, security & more',
                      isLast: true,
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

                const SizedBox(height: StillwaterTokens.space2Xl),

                // ── About footer ───────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const FinanceFlowLogo(
                        markSize: 40,
                        fontSize: 20,
                        axis: Axis.vertical,
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        AppConstants.appTagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        AppConstants.appVersion,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space4Xl),
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
    final theme = context.theme;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final ingestionStatus = ref.watch(ingestionPlatformStatusProvider).value;
    final awaitingReview = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. Appearance ────────────────────────────────────────────────
          _SectionLabel(label: 'Appearance'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          _SettingsGroup(
            children: [
              // Theme — opens bottom sheet
              _SettingsRow(
                icon: Icons.palette_outlined,
                label: 'Theme',
                value: settings.themePreference.displayName,
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              // Dense mode switch
              _SettingsSwitchRow(
                icon: Icons.density_medium_rounded,
                label: 'Ledger View',
                subtitle: 'Compact list rows and reduced padding',
                value: settings.isDenseMode,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setDenseMode(val);
                },
              ),
              // Currency — informational
              _SettingsRow(
                icon: Icons.currency_rupee_rounded,
                label: 'Currency',
                value: '₹ INR',
                isLast: true,
                onTap: null, // read-only informational row
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 2. Alerts & Notifications ────────────────────────────────────
          _SectionLabel(label: 'Alerts & Notifications'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          _SettingsGroup(
            children: [
              _SettingsSwitchRow(
                icon: Icons.notifications_outlined,
                label: 'All Alerts',
                subtitle: 'Master switch for all local notifications',
                value: settings.isAlertsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(settings.copyWith(isAlertsEnabled: val));
                },
              ),
              _SettingsSwitchRow(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Budget Alerts',
                subtitle: 'Notify when spending approaches limit',
                value: settings.isBudgetAlertsEnabled,
                enabled: settings.isAlertsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(isBudgetAlertsEnabled: val),
                      );
                },
              ),
              _SettingsSwitchRow(
                icon: Icons.repeat_rounded,
                label: 'Subscription Alerts',
                subtitle: 'Notify before renewal dates',
                value: settings.isSubscriptionAlertsEnabled,
                enabled: settings.isAlertsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(isSubscriptionAlertsEnabled: val),
                      );
                },
              ),
              _SettingsSwitchRow(
                icon: Icons.account_balance_outlined,
                label: 'Loan & EMI Alerts',
                subtitle: 'Remind before EMI due dates',
                value: settings.isLoanAlertsEnabled,
                enabled: settings.isAlertsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(isLoanAlertsEnabled: val),
                      );
                },
              ),
              _SettingsSwitchRow(
                icon: Icons.backup_outlined,
                label: 'Backup Reminder',
                subtitle: 'Periodic reminder to create a backup',
                value: settings.isBackupReminderEnabled,
                enabled: settings.isAlertsEnabled,
                isLast: true,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(isBackupReminderEnabled: val),
                      );
                },
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 3. Privacy & Security ────────────────────────────────────────
          _SectionLabel(label: 'Privacy & Security'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.shield_outlined,
                label: 'App Lock & Biometrics',
                subtitle: 'PIN, face ID, fingerprint & auto-lock',
                isLast: true,
                onTap: () => _push(context, const SecuritySettingsScreen()),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 4. Transaction Ingestion ─────────────────────────────────────
          _SectionLabel(label: 'Transaction Ingestion'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          _SettingsGroup(
            children: [
              _SettingsSwitchRow(
                icon: Icons.notifications_active_outlined,
                label: 'Notification Detection',
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
              _SettingsSwitchRow(
                icon: Icons.sms_outlined,
                label: 'Bank SMS Detection',
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
              _SettingsRow(
                icon: Icons.email_outlined,
                label: 'Bank Email Detection',
                subtitle:
                    'Not configured · Gmail OAuth and scanning are unavailable in this build',
                value: 'Unavailable',
                isLast: true,
                onTap: null,
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),
          _SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingestion diagnostics',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        height: 1.55,
                      ),
                    ),
                    if (settings.isSmsDetectionEnabled &&
                        ingestionStatus?.smsPermission !=
                            IngestionPermissionState.granted) ...[
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Action: open Bank SMS Detection and grant Android access.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 5. Intelligence ──────────────────────────────────────────────
          _SectionLabel(label: 'Intelligence'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.psychology_outlined,
                iconColor: context.aiColors.accent,
                label: 'Gemini AI Assistance',
                subtitle:
                    settings.isGeminiEnabled && settings.geminiConsentGranted
                        ? 'Enabled · boundary disclosure accepted'
                        : 'Disabled · 100% on-device rules apply',
                value:
                    settings.isGeminiEnabled && settings.geminiConsentGranted
                        ? 'On'
                        : 'Off',
                isLast: true,
                onTap: () => _push(context, const GeminiConsentScreen()),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 6. Developer Tools (collapsed) ───────────────────────────────
          _MoreOptionsToggle(
            label: 'Developer Tools',
            isExpanded: _showDevTools,
            onToggle: () => setState(() => _showDevTools = !_showDevTools),
          ),

          if (_showDevTools) ...[
            const SizedBox(height: StillwaterTokens.spaceMd),
            _SettingsGroup(
              children: [
                Padding(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seed Demo Dataset',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        'Load sample Indian transactions (Swiggy, Netflix, Salary, HDFC EMI) for UI review.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                      FfButton(
                        label: 'Load Realistic Demo Data',
                        variant: FfButtonVariant.outlined,
                        size: FfButtonSize.sm,
                        onPressed: () async {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .seedDemoData();
                          if (context.mounted) {
                            FfSnackbar.show(
                              context,
                              message: 'Demo dataset loaded on this device.',
                            );
                          }
                        },
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Wrap(
                        spacing: StillwaterTokens.spaceSm,
                        runSpacing: StillwaterTokens.spaceSm,
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
                                FfSnackbar.show(
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
                                FfSnackbar.show(
                                  context,
                                  message:
                                      'Sample notification: ${result.disposition.name}.',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
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

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 7. Data Reset ────────────────────────────────────────────────
          _SectionLabel(label: 'Data Reset'),
          const SizedBox(height: StillwaterTokens.spaceXs),

          // Danger zone — deliberately styled differently (no icon tint, no chip)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.20),
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Text(
                        'Wipe All App Data',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Text(
                    'Permanently deletes all stored transactions, accounts, loans, and security keys from this device. Cannot be undone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceMd),
                  Semantics(
                    label: 'Delete all data on device — destructive action',
                    child: FfButton(
                      label: 'Delete All Data on Device',
                      variant: FfButtonVariant.destructive,
                      size: FfButtonSize.sm,
                      onPressed: () async {
                        final confirmed = await FfConfirmDialog.show(
                          context,
                          title: 'Wipe All Data?',
                          message:
                              'This will permanently delete all records stored on this device. This action cannot be undone.',
                          confirmLabel: 'Wipe Everything',
                          isDestructive: true,
                        );
                        if (confirmed == true && context.mounted) {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .resetAllData();
                          if (context.mounted) {
                            FfSnackbar.show(
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

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      builder: (ctx) {
        final theme = ctx.theme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FfSheetHeader(
                title: 'Theme',
                subtitle: 'Choose your visual preference',
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceSm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...AppThemePreference.values.map((pref) {
                      final isSelected = settings.themePreference == pref;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          pref == AppThemePreference.system
                              ? Icons.brightness_auto_outlined
                              : pref == AppThemePreference.daylight
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                        ),
                        title: Text(pref.displayName),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_rounded,
                                  color: theme.colorScheme.primary,
                                )
                                : null,
                        onTap: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setThemePreference(pref);
                          Navigator.of(ctx).pop();
                        },
                      );
                    }),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Grouped block of rows — single rounded border, hairline dividers between rows.
class _NavGroup extends StatelessWidget {
  final List<Widget> children;
  const _NavGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// Settings group — same visual as _NavGroup.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// Navigation row — icon + label + subtitle + chevron.
class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool isLast;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveIconColor = iconColor ?? theme.colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: label,
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top:
                  isLast
                      ? Radius.zero
                      : const Radius.circular(StillwaterTokens.radiusLg),
              bottom:
                  isLast
                      ? const Radius.circular(StillwaterTokens.radiusLg)
                      : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceMd,
                vertical: StillwaterTokens.spaceSm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: effectiveIconColor),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  trailing ??
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            indent: StillwaterTokens.spaceMd + 22 + StillwaterTokens.spaceMd,
            endIndent: 0,
          ),
      ],
    );
  }
}

/// Settings row with an optional current-value chip and optional onTap.
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final String? value;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.subtitle,
    this.value,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveIconColor = iconColor ?? theme.colorScheme.secondary;
    final isReadOnly = onTap == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: value != null ? '$label: $value' : label,
          button: !isReadOnly,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top:
                  isLast
                      ? Radius.zero
                      : const Radius.circular(StillwaterTokens.radiusLg),
              bottom:
                  isLast
                      ? const Radius.circular(StillwaterTokens.radiusLg)
                      : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceMd,
                vertical: StillwaterTokens.spaceSm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: effectiveIconColor),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  if (value != null) ...[
                    Text(
                      value!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (!isReadOnly)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            indent: StillwaterTokens.spaceMd + 22 + StillwaterTokens.spaceMd,
            endIndent: 0,
          ),
      ],
    );
  }
}

/// Settings row with a Switch trailing control.
class _SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveColor =
        enabled
            ? theme.colorScheme.secondary
            : theme.colorScheme.secondary.withValues(alpha: 0.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '$label: ${value ? "on" : "off"}',
          toggled: value,
          child: Padding(
            padding: const EdgeInsets.only(
              left: StillwaterTokens.spaceMd,
              right: StillwaterTokens.spaceXs,
              top: StillwaterTokens.spaceXs,
              bottom: StillwaterTokens.spaceXs,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: effectiveColor),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              enabled
                                  ? null
                                  : theme.colorScheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: enabled ? 1.0 : 0.5,
                            ),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(value: value, onChanged: enabled ? onChanged : null),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            indent: StillwaterTokens.spaceMd + 22 + StillwaterTokens.spaceMd,
            endIndent: 0,
          ),
      ],
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
        horizontal: StillwaterTokens.spaceXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.aiColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.aiColors.accent,
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
    final theme = context.theme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: StillwaterTokens.spaceXs),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: StillwaterTokens.spaceXs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
