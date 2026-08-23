import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/backup_payload.dart';
import '../../services/backup_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
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
      final confirmed = await FfConfirmDialog.show(
        context,
        title: 'Replace All Current Data?',
        message:
            'This will overwrite existing local records with the contents of this backup. This action cannot be reversed.',
        confirmLabel: 'Replace Everything',
        isDestructive: true,
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
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Restore Complete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Restored ${result.restoredTransactions} transactions',
                  ),
                  Text('• Restored ${result.restoredAccounts} accounts'),
                  Text('• Restored ${result.restoredBudgets} budgets'),
                  Text(
                    '• Restored ${result.restoredSubscriptions} subscriptions',
                  ),
                  Text('• Restored ${result.restoredLoans} loans'),
                  Text('• Restored ${result.restoredInvestments} investments'),
                  if (result.skippedDuplicates > 0)
                    Text(
                      '• Skipped ${result.skippedDuplicates} duplicate transactions',
                    ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
      );
    } else if (mounted) {
      FfSnackbar.show(
        context,
        message: result.errorMessage ?? 'Restore failed.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final filename = widget.backupFile.path.split(Platform.pathSeparator).last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Encrypted Backup'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'AES Decryption')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // File Name Pill
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child: Text(
                    filename,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Passphrase Input Card
          if (_decryptedPayload == null) ...[
            _SectionLabel(label: 'Enter Passphrase to Unlock'),
            const SizedBox(height: StillwaterTokens.spaceXs),
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                border: Border.all(
                  color: theme.dividerColor,
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passphraseController,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Passphrase',
                      prefixIcon: const Icon(Icons.key_outlined, size: 20),
                      errorText: _errorMessage,
                    ),
                    onSubmitted: (_) => _decrypt(),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),
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
            _SectionLabel(label: 'Decrypted Backup Contents'),
            const SizedBox(height: StillwaterTokens.spaceXs),
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                border: Border.all(
                  color: theme.dividerColor,
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PAYLOAD METRICS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          color: theme.colorScheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.secColors.verified.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusFull,
                          ),
                        ),
                        child: Text(
                          'Verified AES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.secColors.verified,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceMd),
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
                    label: 'Subscriptions',
                    count: _decryptedPayload!.subscriptions.length,
                  ),
                  _MetricRow(
                    label: 'Loans & EMIs',
                    count: _decryptedPayload!.loans.length,
                  ),
                  _MetricRow(
                    label: 'Investments',
                    count: _decryptedPayload!.investments.length,
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Text(
                    'Exported on ${DateFormatter.formatTransactionDate(_decryptedPayload!.metadata.createdAt)} · App v${_decryptedPayload!.metadata.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.space2Xl),

            // Restore Mode Selector
            _SectionLabel(label: 'Choose Restore Method'),
            const SizedBox(height: StillwaterTokens.spaceXs),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                border: Border.all(
                  color: theme.dividerColor,
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Column(
                children: [
                  RadioListTile<RestoreMode>(
                    value: RestoreMode.merge,
                    groupValue: _selectedMode,
                    title: const Text('Merge with Existing Data'),
                    subtitle: const Text(
                      'Safely skip duplicate records and add missing entries.',
                    ),
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) => setState(() => _selectedMode = val!),
                  ),
                  Divider(
                    height: 1,
                    thickness: StillwaterTokens.borderWidthHairline,
                  ),
                  RadioListTile<RestoreMode>(
                    value: RestoreMode.replace,
                    groupValue: _selectedMode,
                    title: const Text('Clean Replace (Overwrite)'),
                    subtitle: const Text(
                      'Clear current database and restore state from this backup.',
                    ),
                    activeColor: context.secColors.error,
                    onChanged: (val) => setState(() => _selectedMode = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.space2Xl),

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

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int count;

  const _MetricRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            count.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
