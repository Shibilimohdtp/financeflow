import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
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
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 8),
                    Text('Backup Created'),
                  ],
                ),
                content: const Text(
                  'Your encrypted backup is ready. You can share or transfer it now (to Google Drive, WhatsApp, or Downloads folder) to move to a new device or keep safe offline.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Done'),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share / Save File'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(path)],
                          subject: 'FinanceFlow Encrypted Backup',
                        ),
                      );
                    },
                  ),
                ],
              ),
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

  Future<void> _pickBackupFromDevice() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select FinanceFlow Backup File (.ffbackup)',
        type: FileType.any,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        _openRestore(pickedFile);
      }
    } catch (e) {
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not select backup file: $e');
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
        title: const Text('Full Backup & Migration'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'AES-256 CTR', iconOnly: true),
            ),
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
                        'Full disaster-recovery archive. Encrypted with AES-256 CTR + PBKDF2. Contains 100% of accounts, loans, settings, and histories.',
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

          // ── 2. Universal File Picker for Restore ───────────────────────
          FfCard(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_open_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Restore from File on Device',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Restore a .ffbackup file from your phone’s Downloads folder, Google Drive, WhatsApp, or SD Card.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                FfButton(
                  label: 'Browse & Select Backup File',
                  variant: FfButtonVariant.secondary,
                  leadingIcon: const Icon(
                    Icons.folder_open_rounded,
                    size: 18,
                  ),
                  onPressed: _pickBackupFromDevice,
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Create Encrypted Backup Form ──────────────────────────
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

          // ── 4. Existing Local Backups ─────────────────────────────────
          FfSectionHeader(
            title: 'On-Device Backup History (${_existingBackups.length})',
          ),

          if (_isLoadingBackups)
            const Center(child: CircularProgressIndicator())
          else if (_existingBackups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: StillwaterTokens.spaceLg,
              ),
              child: Container(
                padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusMd,
                  ),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: StillwaterTokens.borderWidthHairline,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'No backups in local app storage. Use "Browse & Select" above to pick a backup from Downloads or Drive.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
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
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            tooltip: 'Share / Save to Downloads',
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  files: [XFile(file.path)],
                  subject: 'FinanceFlow Encrypted Backup',
                ),
              );
            },
          ),
          const SizedBox(width: StillwaterTokens.space2Xs),
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
