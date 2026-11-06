import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_page_header.dart';
import '../../shared/widgets/ff_quick_toggle.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/financeflow_mark.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../accounts/accounts_screen.dart';
import '../alerts/alert_settings_sheet.dart';
import '../alerts/alerts_inbox_screen.dart';
import '../backup/backup_screen.dart';
import '../export/export_screen.dart';
import '../financial_health/financial_health_screen.dart';
import '../ingestion/csv_import_screen.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../ingestion/permissions/sms_permission_screen.dart';
import '../investments/investments_screen.dart';
import '../loans/loans_screen.dart';
import '../personal_debts/lending_borrowing_screen.dart';
import '../savings_goals/savings_goals_screen.dart';
import '../security/security_settings_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import 'branding_preview_screen.dart';
import 'settings_controller.dart';
import 'settings_detail_screen.dart';
import 'widgets/more_vault_card.dart';

/// The More navigation hub (tab 4): redesigned to Stillwater Bloom as the
/// launcher hub on FfAurora, combining quick settings toggles, vault status,
/// feature module launchers, and preferences.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final pendingCount = ref.watch(pendingReviewCountProvider);

    final isLockActive = settings.isPinEnabled || settings.isBiometricEnabled;
    final isAmountsBlurred = settings.isPrivacyBlurEnabled;
    final isSmsActive = settings.isSmsDetectionEnabled;

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.md,
            ),
            children: [
              // ── Header on Aurora ───────────────────────────────────────────
              FfPageHeader(
                title: 'More',
                subtitle: 'Modules & preferences',
                padding: const EdgeInsetsDirectional.only(bottom: FfSpace.x2s),
                actions: [
                  FfCircleButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'App Settings',
                    onPressed:
                        () => _push(context, const SettingsDetailScreen()),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.md),

              // ── Quick Settings Strip ───────────────────────────────────────
              FfQuickToggleStrip(
                tiles: [
                  FfQuickToggleTile(
                    icon:
                        isAmountsBlurred
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                    title: 'Amounts',
                    statusText: isAmountsBlurred ? 'Hidden' : 'Shown',
                    statusIcon:
                        isAmountsBlurred
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                    isActive: isAmountsBlurred,
                    onTap: () {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setPrivacyBlurEnabled(!isAmountsBlurred);
                    },
                  ),
                  FfQuickToggleTile(
                    icon:
                        isLockActive
                            ? Icons.lock_outline_rounded
                            : Icons.lock_open_rounded,
                    title: 'App Lock',
                    statusText: isLockActive ? 'Active' : 'Off',
                    statusIcon:
                        isLockActive
                            ? Icons.shield_rounded
                            : Icons.info_outline,
                    isActive: isLockActive,
                    onTap: () => _push(context, const SecuritySettingsScreen()),
                  ),
                  FfQuickToggleTile(
                    icon:
                        settings.themePreference == AppThemePreference.deepWater
                            ? Icons.dark_mode_outlined
                            : settings.themePreference ==
                                AppThemePreference.daylight
                            ? Icons.light_mode_outlined
                            : Icons.brightness_auto_outlined,
                    title: 'Theme',
                    statusText:
                        settings.themePreference == AppThemePreference.deepWater
                            ? 'Dark'
                            : settings.themePreference ==
                                AppThemePreference.daylight
                            ? 'Light'
                            : 'Auto',
                    statusIcon: Icons.palette_outlined,
                    isActive:
                        settings.themePreference != AppThemePreference.system,
                    onTap: () => _push(context, const SettingsDetailScreen()),
                  ),
                  FfQuickToggleTile(
                    icon:
                        isSmsActive
                            ? Icons.sms_outlined
                            : Icons.sms_failed_outlined,
                    title: 'Bank SMS',
                    statusText: isSmsActive ? 'Active' : 'Off',
                    statusIcon:
                        isSmsActive
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                    isActive: isSmsActive,
                    onTap: () {
                      if (!isSmsActive) {
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
                ],
              ),

              const SizedBox(height: FfSpace.lg),

              // ── Vault Hero Card ───────────────────────────────────────────
              MoreVaultCard(
                settings: settings,
                onBackupTap: () => _push(context, const BackupScreen()),
                onSecurityTap:
                    () => _push(context, const SecuritySettingsScreen()),
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 1. Your Data (Finance Modules) ─────────────────────────────
              const FfSectionHeader(title: 'Your data'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  FfRow(
                    icon: Icons.account_balance_wallet_outlined,
                    iconTone: FfTone.income,
                    title: 'Financial Accounts',
                    subtitle: 'Bank accounts, cards, cash & UPI',
                    onTap: () => _push(context, const AccountsScreen()),
                  ),
                  FfRow(
                    icon: Icons.account_balance_outlined,
                    iconTone: FfTone.debt,
                    title: 'Loans & EMI Tracker',
                    subtitle: 'Amortization, outstanding debt & EMIs',
                    onTap: () => _push(context, const LoansScreen()),
                  ),
                  FfRow(
                    icon: Icons.flag_outlined,
                    iconTone: FfTone.savings,
                    title: 'Savings Goals',
                    subtitle: 'Emergency fund, vacation & targets',
                    onTap: () => _push(context, const SavingsGoalsScreen()),
                  ),
                  FfRow(
                    icon: Icons.repeat_rounded,
                    iconTone: FfTone.neutral,
                    title: 'Subscriptions',
                    subtitle: 'Recurring services, renewals & burn rate',
                    onTap: () => _push(context, const SubscriptionsScreen()),
                  ),
                  FfRow(
                    icon: Icons.show_chart_rounded,
                    iconTone: FfTone.investment,
                    title: 'Investment Portfolio',
                    subtitle: 'Stocks, mutual funds, gold & valuations',
                    onTap: () => _push(context, const InvestmentsScreen()),
                  ),
                  FfRow(
                    icon: Icons.handshake_outlined,
                    iconTone: FfTone.accent,
                    title: 'Lending & Borrowing',
                    subtitle: 'Track money lent to & borrowed from others',
                    onTap: () => _push(context, const LendingBorrowingScreen()),
                  ),
                  FfRow(
                    icon: Icons.rate_review_outlined,
                    iconTone: FfTone.warning,
                    title: 'Needs Review Queue',
                    subtitle:
                        pendingCount > 0
                            ? '$pendingCount transactions need review'
                            : 'No pending transactions',
                    trailing:
                        pendingCount > 0
                            ? FfBadge(
                              label: '$pendingCount',
                              tone: FfTone.warning,
                            )
                            : null,
                    onTap: () => _push(context, const NeedsReviewScreen()),
                  ),
                  FfRow(
                    icon: Icons.health_and_safety_outlined,
                    iconTone: FfTone.income,
                    title: 'Financial Health Score',
                    subtitle: '7-dimension on-device wellness score',
                    onTap: () => _push(context, const FinancialHealthScreen()),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 2. Alerts ──────────────────────────────────────────────────
              const FfSectionHeader(title: 'Alerts'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  FfRow(
                    icon: Icons.notifications_active_outlined,
                    iconTone: FfTone.warning,
                    title: 'Local Alerts Inbox',
                    subtitle: 'Budget limits, EMI reminders & renewals',
                    onTap: () => _push(context, const AlertsInboxScreen()),
                  ),
                  FfRow(
                    icon: Icons.tune_rounded,
                    iconTone: FfTone.neutral,
                    title: 'Notification Preferences',
                    subtitle: 'Categories, lock screen privacy & permissions',
                    onTap: () => AlertSettingsSheet.show(context),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 3. Security and Privacy ────────────────────────────────────
              const FfSectionHeader(title: 'Security and privacy'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  FfRow(
                    icon: Icons.shield_outlined,
                    iconTone: FfTone.primary,
                    title: 'App Lock & Biometrics',
                    subtitle: 'PIN, face ID, fingerprint & auto-lock',
                    onTap: () => _push(context, const SecuritySettingsScreen()),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 4. Backup and Export ───────────────────────────────────────
              const FfSectionHeader(title: 'Backup and export'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  FfRow(
                    icon: Icons.lock_clock_outlined,
                    iconTone: FfTone.primary,
                    title: 'Encrypted Backup & Restore',
                    subtitle: 'PBKDF2 & AES-256 local encrypted files',
                    onTap: () => _push(context, const BackupScreen()),
                  ),
                  FfRow(
                    icon: Icons.file_download_outlined,
                    iconTone: FfTone.primary,
                    title: 'Export Data',
                    subtitle: 'CSV, JSON, Excel spreadsheet & reports',
                    onTap: () => _push(context, const ExportScreen()),
                  ),
                  FfRow(
                    icon: Icons.file_upload_outlined,
                    iconTone: FfTone.primary,
                    title: 'Import CSV Statement',
                    subtitle: 'Parse bank or credit card CSV files',
                    onTap: () => _push(context, const CsvImportScreen()),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.xl),

              // ── 5. Appearance and Preferences ──────────────────────────────
              const FfSectionHeader(title: 'Appearance and preferences'),
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  FfRow(
                    icon: Icons.settings_outlined,
                    iconTone: FfTone.neutral,
                    title: 'App Settings',
                    subtitle: 'Theme, ledger view, currency & diagnostics',
                    onTap: () => _push(context, const SettingsDetailScreen()),
                  ),
                ],
              ),

              const SizedBox(height: FfSpace.x2l),

              // ── 6. About Footer ────────────────────────────────────
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
                    GestureDetector(
                      onLongPress: () {
                        _push(context, const BrandingPreviewScreen());
                      },
                      child: Text(
                        AppConstants.appVersion,
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.borderStrong,
                        ),
                      ),
                    ),
                    const SizedBox(height: FfSpace.x4l),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backwards compatibility alias for the More tab.
typedef SettingsScreen = MoreScreen;
