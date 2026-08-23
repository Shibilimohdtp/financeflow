import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'backup_controller.dart';
import 'restore_preview_screen.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _passphraseController = TextEditingController();
  final _confirmPassphraseController = TextEditingController();
  List<File> _existingBackups = [];
  bool _isLoadingBackups = true;
  bool _isCreatingBackup = false;

  @override
  void initState() {
    super.initState();
    _loadExistingBackups();
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmPassphraseController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingBackups() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (await backupDir.exists()) {
        final files =
            backupDir
                .listSync()
                .whereType<File>()
                .where((f) => f.path.endsWith('.ffbackup'))
                .toList()
              ..sort(
                (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
              );
        setState(() {
          _existingBackups = files;
          _isLoadingBackups = false;
        });
      } else {
        setState(() {
          _existingBackups = [];
          _isLoadingBackups = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingBackups = false);
    }
  }

  Future<void> _createBackup() async {
    final pass = _passphraseController.text;
    final confirm = _confirmPassphraseController.text;

    if (pass.length < 6) {
      FfSnackbar.show(
        context,
        message: 'Passphrase must be at least 6 characters.',
      );
      return;
    }

    if (pass != confirm) {
      FfSnackbar.show(context, message: 'Passphrases do not match.');
      return;
    }

    setState(() => _isCreatingBackup = true);

    try {
      final path = await ref
          .read(backupControllerProvider.notifier)
          .createBackup(passphrase: pass);
      _passphraseController.clear();
      _confirmPassphraseController.clear();
      await _loadExistingBackups();

      if (mounted) {
        FfSnackbar.show(
          context,
          message:
              'Encrypted backup created: ${path.split(Platform.pathSeparator).last}',
        );
      }
    } catch (e) {
      if (mounted) {
        FfSnackbar.show(context, message: 'Backup failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }

  void _openRestore(File file) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => RestorePreviewScreen(backupFile: file),
          ),
        )
        .then((_) => _loadExistingBackups());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'AES-256 GCM')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. AES Encryption Guarantee ───────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.secColors.verified.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: context.secColors.verified,
                    size: 20,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zero-Knowledge Encrypted Backups',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.secColors.verified,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your data is encrypted with AES-256-GCM using your private passphrase. It cannot be unlocked without your passphrase.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 2. Create Encrypted Backup Form ──────────────────────────
          const FfSectionHeader(title: 'Create New Backup'),
          FfCard(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Encryption Passphrase',
                    hintText: 'Enter at least 6 characters',
                    prefixIcon: Icon(Icons.key_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                TextField(
                  controller: _confirmPassphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Passphrase',
                    hintText: 'Re-enter passphrase',
                    prefixIcon: Icon(Icons.key_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
                FfButton(
                  label: 'Generate Encrypted Backup',
                  isLoading: _isCreatingBackup,
                  leadingIcon: const Icon(Icons.download_rounded, size: 18),
                  onPressed: _isCreatingBackup ? null : _createBackup,
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Existing Local Backups ─────────────────────────────────
          FfSectionHeader(title: 'Local Backups (${_existingBackups.length})'),

          if (_isLoadingBackups)
            const Center(child: CircularProgressIndicator())
          else if (_existingBackups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: StillwaterTokens.spaceXl,
              ),
              child: FfEmptyState(
                icon: Icons.history_toggle_off_rounded,
                title: 'No backup files found',
                description:
                    'Generate your first encrypted backup above to keep an offline safeguard of your finances.',
              ),
            )
          else
            FfGroupedContainer(
              children: [
                for (int i = 0; i < _existingBackups.length; i++)
                  _BackupFileRow(
                    file: _existingBackups[i],
                    onRestore: () => _openRestore(_existingBackups[i]),
                  ),
              ],
            ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}

class _BackupFileRow extends StatelessWidget {
  final File file;
  final VoidCallback onRestore;

  const _BackupFileRow({required this.file, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final stat = file.statSync();
    final sizeKb = (stat.size / 1024).toStringAsFixed(1);
    final filename = file.path.split(Platform.pathSeparator).last;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: StillwaterTokens.iconTileSize,
            height: StillwaterTokens.iconTileSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
            ),
            child: Icon(
              Icons.archive_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${DateFormatter.formatTransactionDate(stat.modified)} · $sizeKb KB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          FfButton(
            label: 'Restore',
            size: FfButtonSize.sm,
            variant: FfButtonVariant.secondary,
            leadingIcon: const Icon(
              Icons.settings_backup_restore_rounded,
              size: 16,
            ),
            onPressed: onRestore,
          ),
        ],
      ),
    );
  }
}
