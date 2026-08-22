import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/stillwater_tokens.dart';
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
import '../savings_goals/savings_goals_screen.dart';
import '../security/security_settings_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../transactions/transactions_controller.dart';
import 'branding_preview_screen.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final transactions = ref.watch(filteredTransactionsProvider).value ?? [];
    final pendingCount = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // 1. Storage & Privacy Facts Card
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Local Storage Facts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.secColors.verified,
                      ),
                    ),
                    const FfPrivacyBadge(label: '100% Offline'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  '• User data stored on servers: 0 Bytes\n'
                  '• Total transactions recorded locally: ${transactions.length}\n'
                  '• Local database: Isar Database\n'
                  '• No ad networks, no analytics trackers, no cloud sync.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 2. Financial Management Modules
          Text('Finance Modules', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.repeat_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Subscriptions Manager'),
                  subtitle: const Text(
                    'Track recurring services, renewals, and burn rate',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Loans & EMI Tracker'),
                  subtitle: const Text(
                    'Amortization schedules, outstanding debt, and EMIs',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoansScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.show_chart_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Investment Portfolio'),
                  subtitle: const Text(
                    'Stocks, mutual funds, gold, and manual valuations',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InvestmentsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Financial Accounts'),
                  subtitle: const Text(
                    'Bank accounts, cash wallets, cards, and UPI',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountsScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Savings Goals'),
                  subtitle: const Text(
                    'Emergency fund, vacation, and target savings',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SavingsGoalsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Financial Health Score'),
                  subtitle: const Text(
                    '7-dimension explainable on-device financial wellness score',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FinancialHealthScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 3. Local Alerts & Intelligence
          Text('Alerts & Assistance', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Local Alerts Inbox'),
                  subtitle: const Text(
                    'Budget limits, EMI reminders, and renewal notices',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AlertsInboxScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.auto_awesome,
                    color: context.aiColors.accent,
                  ),
                  title: const Text('Ask Your Finances'),
                  subtitle: const Text(
                    'Natural language financial queries (On-device first)',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const AiQuerySheet(),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.psychology_outlined,
                    color: context.aiColors.accent,
                  ),
                  title: const Text('Gemini AI Assistance & Consent'),
                  subtitle: Text(
                    settings.isGeminiEnabled && settings.geminiConsentGranted
                        ? 'Enabled with boundary disclosure'
                        : 'Disabled (100% On-device rules)',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GeminiConsentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 4. Data Management & Backup
          Text('Data Export & Backup', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.file_download_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Export Data'),
                  subtitle: const Text(
                    'CSV, JSON, Excel spreadsheet, and PDF reports',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExportScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.lock_clock_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Encrypted Backup & Restore'),
                  subtitle: const Text(
                    'PBKDF2 & AES-256 local encrypted backup files',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BackupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 5. Transaction Ingestion & Sources Section (Phase 3)
          Text(
            'Transaction Ingestion & Sources',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.file_upload_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Import CSV Statement'),
                  subtitle: const Text(
                    'Parse bank or credit card CSV files on-device',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CsvImportScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.rate_review_outlined,
                    color:
                        pendingCount > 0
                            ? context.aiColors.accent
                            : theme.colorScheme.primary,
                  ),
                  title: const Text('Needs Review Queue'),
                  subtitle: Text(
                    pendingCount > 0
                        ? '$pendingCount transactions require review'
                        : 'No pending transactions',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pendingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.aiColors.accent.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: TextStyle(
                              color: context.aiColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NeedsReviewScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Notification Detection'),
                  subtitle: Text(
                    settings.isNotificationDetectionEnabled
                        ? 'Active for ${settings.selectedNotificationPackages.length} payment apps'
                        : 'Disabled (Tap to view setup & rationale)',
                  ),
                  value: settings.isNotificationDetectionEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    if (val) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationPermissionScreen(),
                        ),
                      );
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
                const Divider(),
                SwitchListTile(
                  secondary: Icon(
                    Icons.sms_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Bank SMS Detection'),
                  subtitle: Text(
                    settings.isSmsDetectionEnabled
                        ? 'Active for Indian banking SMS templates'
                        : 'Disabled (Tap to view setup & rationale)',
                  ),
                  value: settings.isSmsDetectionEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    if (val) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SmsPermissionScreen(),
                        ),
                      );
                    } else {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(isSmsDetectionEnabled: false),
                          );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 6. Security & Privacy
          Text('Security & Privacy', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(
                Icons.shield_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Security Settings'),
              subtitle: const Text(
                'Biometric lock, PIN, privacy blur, auto-lock',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SecuritySettingsScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 7. Appearance & Display Section
          Text('Appearance & Display', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(settings.themePreference.displayName),
                  trailing: DropdownButton<AppThemePreference>(
                    value: settings.themePreference,
                    underline: const SizedBox.shrink(),
                    onChanged: (pref) {
                      if (pref != null) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setThemePreference(pref);
                      }
                    },
                    items:
                        AppThemePreference.values.map((pref) {
                          return DropdownMenuItem(
                            value: pref,
                            child: Text(pref.displayName),
                          );
                        }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.currency_rupee_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Currency Display'),
                  subtitle: const Text(
                    'Indian Rupee (INR · ₹) with Indian grouping',
                  ),
                  trailing: const Text('₹ INR'),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: Icon(
                    Icons.density_medium_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Ledger View (Dense Mode)'),
                  subtitle: const Text('Compact list rows and reduced padding'),
                  value: settings.isDenseMode,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setDenseMode(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 8. Development & Demo Tools Section
          Text('Development Tools', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seed Demo Dataset', style: theme.textTheme.titleSmall),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  'Load sample realistic Indian transactions (Swiggy, Netflix, Salary, HDFC EMI, Petrol) for testing and UI review.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                FfButton(
                  label: 'Load Realistic Demo Data',
                  variant: FfButtonVariant.outlined,
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
                FfButton(
                  label: 'Stillwater Brand Showcase',
                  variant: FfButtonVariant.text,
                  leadingIcon: const Icon(Icons.palette_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BrandingPreviewScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 9. Danger Zone / Privacy Data Reset
          Text('Privacy Data Reset', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wipe App Data',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  'Permanently delete all stored transactions, custom accounts, and security keys from this phone.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                FfButton(
                  label: 'Delete All Data on Device',
                  variant: FfButtonVariant.destructive,
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
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // 10. About Section
          Center(
            child: Column(
              children: [
                const FinanceFlowLogo(
                  markSize: 44,
                  fontSize: 22,
                  axis: Axis.vertical,
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  AppConstants.appTagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  AppConstants.appVersion,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  'Powered by Stillwater Design System',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space4Xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
