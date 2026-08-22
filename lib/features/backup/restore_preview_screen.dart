import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/backup_payload.dart';
import '../../services/backup_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Restore Encrypted Backup')),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_clock_outlined,
                      color: context.secColors.verified,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Encrypted Backup File',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  widget.backupFile.path.split(Platform.pathSeparator).last,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          if (_decryptedPayload == null) ...[
            // Enter passphrase step
            Text('Enter Backup Passphrase', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),
            FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passphraseController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Passphrase',
                      prefixIcon: Icon(Icons.password_rounded),
                    ),
                    onSubmitted: (_) => _decrypt(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: StillwaterTokens.spaceLg),
                  FfButton(
                    label:
                        _isDecrypting
                            ? 'Decrypting...'
                            : 'Decrypt & Preview Backup',
                    isLoading: _isDecrypting,
                    onPressed: _isDecrypting ? null : _decrypt,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Decrypted Preview
            Text('Backup Contents Preview', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),
            FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created: ${DateFormatter.formatFullDate(_decryptedPayload!.metadata.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceMd),
                  Row(
                    children: [
                      Expanded(
                        child: _previewTile(
                          context,
                          'Transactions',
                          '${_decryptedPayload!.transactions.length}',
                          Icons.receipt_long_outlined,
                        ),
                      ),
                      Expanded(
                        child: _previewTile(
                          context,
                          'Accounts',
                          '${_decryptedPayload!.accounts.length}',
                          Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Row(
                    children: [
                      Expanded(
                        child: _previewTile(
                          context,
                          'Budgets',
                          '${_decryptedPayload!.budgets.length}',
                          Icons.pie_chart_outline_rounded,
                        ),
                      ),
                      Expanded(
                        child: _previewTile(
                          context,
                          'Savings Goals',
                          '${_decryptedPayload!.savingsGoals.length}',
                          Icons.flag_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Row(
                    children: [
                      Expanded(
                        child: _previewTile(
                          context,
                          'Subscriptions',
                          '${_decryptedPayload!.subscriptions.length}',
                          Icons.repeat_rounded,
                        ),
                      ),
                      Expanded(
                        child: _previewTile(
                          context,
                          'Loans',
                          '${_decryptedPayload!.loans.length}',
                          Icons.account_balance_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            // Mode Selector
            Text('Restore Strategy', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),
            FfCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<RestoreMode>(
                    title: const Text('Merge with current records'),
                    subtitle: const Text(
                      'Deduplicates transactions and merges new items safely',
                    ),
                    value: RestoreMode.merge,
                    groupValue: _selectedMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMode = val);
                    },
                  ),
                  const Divider(),
                  RadioListTile<RestoreMode>(
                    title: const Text('Replace all current data'),
                    subtitle: const Text(
                      'Overwrites local database with this backup',
                    ),
                    value: RestoreMode.replace,
                    groupValue: _selectedMode,
                    activeColor: theme.colorScheme.error,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMode = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceXl),

            FfButton(
              label: _isRestoring ? 'Restoring...' : 'Restore Backup',
              isLoading: _isRestoring,
              variant:
                  _selectedMode == RestoreMode.replace
                      ? FfButtonVariant.destructive
                      : FfButtonVariant.filled,
              onPressed: _isRestoring ? null : _confirmAndRestore,
            ),
          ],
        ],
      ),
    );
  }

  Widget _previewTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: StillwaterTokens.spaceXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
