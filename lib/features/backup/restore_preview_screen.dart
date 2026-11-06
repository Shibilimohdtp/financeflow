import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/date_formatter.dart';
import '../../models/backup_payload.dart';
import '../../services/backup_service.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_banner.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_key_value_row.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../accounts/accounts_controller.dart';
import '../transactions/transactions_controller.dart';
import 'backup_controller.dart';

class RestorePreviewScreen extends ConsumerStatefulWidget {
  final File backupFile;

  const RestorePreviewScreen({super.key, required this.backupFile});

  @override
  ConsumerState<RestorePreviewScreen> createState() =>
      _RestorePreviewScreenState();
}

class _RestorePreviewScreenState extends ConsumerState<RestorePreviewScreen> {
  final _passphraseController = TextEditingController();
  BackupDataPayload? _decryptedPayload;
  String? _errorMessage;
  RestoreMode _selectedMode = RestoreMode.merge;
  bool _isDecrypting = false;
  bool _isRestoring = false;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _decrypt() async {
    final pass = _passphraseController.text;
    if (pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter the backup passphrase.');
      return;
    }

    setState(() {
      _isDecrypting = true;
      _errorMessage = null;
    });

    try {
      final content = await widget.backupFile.readAsString();
      final payload = BackupService.decryptAndPreview(
        backupFileContent: content,
        passphrase: pass,
      );
      setState(() {
        _decryptedPayload = payload;
        _isDecrypting = false;
      });
    } on DecryptionException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isDecrypting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'That passphrase didn’t match this backup.';
        _isDecrypting = false;
      });
    }
  }

  Future<void> _confirmAndRestore() async {
    if (_decryptedPayload == null) return;

    if (_selectedMode == RestoreMode.replace) {
      final confirmed = await FfDialog.confirm(
        context,
        title: 'Replace All Current Data?',
        message:
            'This will overwrite existing local records with the contents of this backup. This action cannot be reversed.',
        confirmLabel: 'Replace Everything',
        destructive: true,
      );
      if (confirmed != true) return;
    }

    setState(() => _isRestoring = true);

    final result = await ref
        .read(backupControllerProvider.notifier)
        .executeRestore(payload: _decryptedPayload!, mode: _selectedMode);

    setState(() => _isRestoring = false);

    if (result.isSuccess && mounted) {
      ref.invalidate(filteredTransactionsProvider);
      ref.invalidate(allTransactionsStreamProvider);
      await FfDialog.info(
        context,
        title: 'Restore complete',
        tone: FfDialogTone.success,
        dismissible: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Restored ${result.restoredTransactions} transactions'),
            Text('• Restored ${result.restoredAccounts} accounts'),
            Text('• Restored ${result.restoredCategories} categories'),
            Text('• Restored ${result.restoredBudgets} budgets'),
            Text(
              '• Restored ${result.restoredGoals} goals (${result.restoredGoalContributions} contributions)',
            ),
            Text('• Restored ${result.restoredSubscriptions} subscriptions'),
            Text(
              '• Restored ${result.restoredLoans} loans (${result.restoredEmiPayments} EMI records)',
            ),
            Text(
              '• Restored ${result.restoredMoneyRecords} lending/borrowing records (${result.restoredMoneyRepayments} repayments)',
            ),
            Text('• Restored ${result.restoredInvestments} investments'),
            if (result.restoredPendingTransactions > 0)
              Text(
                '• Restored ${result.restoredPendingTransactions} inbox transactions',
              ),
            if (result.restoredSettings)
              const Text('• Restored application settings & preferences'),
            if (result.skippedDuplicates > 0)
              Text('• Skipped ${result.skippedDuplicates} duplicate records'),
            if (result.hadSecurityLockConfigured) ...[
              const SizedBox(height: FfSpace.md),
              const FfBanner(
                tone: FfBannerTone.warning,
                icon: Icons.lock_reset_rounded,
                message:
                    'For safety across devices, turn PIN and biometric lock back on in Settings.',
              ),
            ],
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } else if (mounted) {
      FfToast.show(
        context,
        tone: FfToastTone.error,
        message: result.errorMessage ?? 'Restore failed.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final filename = widget.backupFile.path.split(Platform.pathSeparator).last;

    return FfPageScaffold(
      onAurora: true,
      title: 'Restore Encrypted Backup',
      subtitle: 'Preview before you restore',
      children: [
        // File Name Card
        FfCard(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: ff.color.actionPrimary,
              ),
              const SizedBox(width: FfSpace.md),
              Expanded(
                child: Text(
                  filename,
                  style: ff.text.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.lg),

        // Passphrase Input Card
        if (_decryptedPayload == null) ...[
          const FfSectionHeader(title: 'Enter passphrase to unlock'),
          FfCard(
            padding: const EdgeInsets.all(FfSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FfTextField(
                  controller: _passphraseController,
                  obscureText: true,
                  autofocus: true,
                  label: 'Passphrase',
                  icon: Icons.key_outlined,
                  errorText: _errorMessage,
                  onSubmitted: (_) => _decrypt(),
                ),
                const SizedBox(height: FfSpace.lg),
                FfButton(
                  label: 'Decrypt & Inspect Contents',
                  isLoading: _isDecrypting,
                  leadingIcon: const Icon(Icons.lock_open_rounded, size: 18),
                  onPressed: _isDecrypting ? null : _decrypt,
                ),
              ],
            ),
          ),
        ] else ...[
          // Decrypted Contents Overview
          const FfSectionHeader(title: 'Decrypted backup contents'),
          FfCard(
            padding: const EdgeInsets.all(FfSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PAYLOAD METRICS', style: ff.text.labelSm),
                    const FfBadge(
                      label: 'Verified AES',
                      tone: FfTone.success,
                      icon: Icons.verified_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.md),
                _MetricRow(
                  label: 'Transactions',
                  count: _decryptedPayload!.transactions.length,
                ),
                _MetricRow(
                  label: 'Accounts',
                  count: _decryptedPayload!.accounts.length,
                ),
                _MetricRow(
                  label: 'Categories',
                  count: _decryptedPayload!.categories.length,
                ),
                _MetricRow(
                  label: 'Budgets',
                  count: _decryptedPayload!.budgets.length,
                ),
                _MetricRow(
                  label: 'Savings Goals & Contributions',
                  count:
                      _decryptedPayload!.savingsGoals.length +
                      _decryptedPayload!.goalContributions.length,
                ),
                _MetricRow(
                  label: 'Subscriptions',
                  count: _decryptedPayload!.subscriptions.length,
                ),
                _MetricRow(
                  label: 'Loans & EMI History',
                  count:
                      _decryptedPayload!.loans.length +
                      _decryptedPayload!.emiPayments.length,
                ),
                _MetricRow(
                  label: 'Lending & Borrowing Records',
                  count:
                      _decryptedPayload!.moneyRecords.length +
                      _decryptedPayload!.moneyRepayments.length,
                ),
                _MetricRow(
                  label: 'Investments',
                  count: _decryptedPayload!.investments.length,
                ),
                if (_decryptedPayload!.pendingTransactions.isNotEmpty)
                  _MetricRow(
                    label: 'Inbox / Pending Queue',
                    count: _decryptedPayload!.pendingTransactions.length,
                  ),
                _MetricRow(
                  label: 'Application Settings',
                  count: _decryptedPayload!.appSettings != null ? 1 : 0,
                ),
                const SizedBox(height: FfSpace.sm),
                Text(
                  'Exported on ${DateFormatter.formatTransactionDate(_decryptedPayload!.metadata.createdAt)} · App v${_decryptedPayload!.metadata.appVersion}',
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.xl),

          // Restore Method Selector
          const FfSectionHeader(title: 'Choose restore method'),
          FfGroupedContainer(
            children: [
              FfRow.radio(
                title: 'Merge with Existing Data',
                subtitle:
                    'Safely skip duplicate records and add missing entries.',
                selected: _selectedMode == RestoreMode.merge,
                onTap: () => setState(() => _selectedMode = RestoreMode.merge),
              ),
              FfRow.radio(
                title: 'Clean Replace (Overwrite)',
                subtitle:
                    'Clear current database and restore state from this backup.',
                selected: _selectedMode == RestoreMode.replace,
                onTap:
                    () => setState(() => _selectedMode = RestoreMode.replace),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xl),

          FfButton(
            label:
                _selectedMode == RestoreMode.merge
                    ? 'Merge Backup Into Device'
                    : 'Replace Everything & Restore',
            isLoading: _isRestoring,
            variant:
                _selectedMode == RestoreMode.replace
                    ? FfButtonVariant.destructive
                    : FfButtonVariant.filled,
            leadingIcon: const Icon(
              Icons.settings_backup_restore_rounded,
              size: 18,
            ),
            onPressed: _isRestoring ? null : _confirmAndRestore,
          ),
        ],

        const SizedBox(height: FfSpace.x4l),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int count;

  const _MetricRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return FfKeyValueRow(label: label, value: '$count');
  }
}
