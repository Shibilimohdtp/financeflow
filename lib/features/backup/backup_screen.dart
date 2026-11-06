import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/formatting/date_formatter.dart';
import '../../features/settings/settings_controller.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
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
  final _passphraseFocusNode = FocusNode();
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
    _passphraseFocusNode.dispose();
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
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Passphrase must be at least 6 characters.',
      );
      return;
    }

    if (pass != confirm) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Passphrases do not match.',
      );
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
        FfDialog.info(
          context,
          title: 'Backup created',
          tone: FfDialogTone.success,
          message:
              'Your encrypted backup is ready. Share or save it now (Google Drive, WhatsApp or your Downloads folder) to keep it safe off this phone or move to a new device.',
          actionLabel: 'Share or save file',
          actionIcon: Icons.share_rounded,
          onAction:
              () => SharePlus.instance.share(
                ShareParams(
                  files: [XFile(path)],
                  subject: 'FinanceFlow Encrypted Backup',
                ),
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Backup failed: $e',
        );
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
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not select backup file: $e',
        );
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
    final ff = context.ff;
    final settings = ref.watch(settingsStreamProvider).value;
    final lastBackup = settings?.lastBackupDate;

    String freshnessText;
    IconData freshnessIcon;
    if (lastBackup == null) {
      freshnessText = 'No backup created yet';
      freshnessIcon = Icons.warning_amber_rounded;
    } else {
      final days = DateTime.now().difference(lastBackup).inDays;
      if (days == 0) {
        freshnessText = 'Backed up today';
        freshnessIcon = Icons.check_circle_outline_rounded;
      } else if (days == 1) {
        freshnessText = 'Last backup yesterday';
        freshnessIcon = Icons.check_circle_outline_rounded;
      } else {
        freshnessText = 'Last backup $days days ago';
        freshnessIcon =
            days >= 14
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded;
      }
    }

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const FfAppBar(
          title: 'Full Backup & Migration',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: FfSpace.pageMargin),
              child: Center(child: FfPrivacyBadge(label: 'AES-256 CTR')),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.pageMargin,
            vertical: FfSpace.md,
          ),
          children: [
            // ── 1. Status Hero Card ───────────────────────────────────────
            FfHeroCard(
              tone: FfHeroTone.sand,
              leading: const FfIconTile(
                icon: Icons.lock_clock_outlined,
                tone: FfTone.primary,
              ),
              title: 'Encrypted Backup Archive',
              subtitle: 'Local disaster-recovery export',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(freshnessIcon, size: 16),
                      const SizedBox(width: FfSpace.xs),
                      Expanded(
                        child: Text(
                          freshnessText,
                          style: ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Text(
                    'Zero-knowledge AES-256 CTR + PBKDF2 encryption. Archive contains 100% of accounts, loans, settings, and histories.',
                    style: ff.text.bodySm,
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfButton(
                    label: 'Create Backup Now',
                    variant: FfButtonVariant.primary,
                    size: FfButtonSize.sm,
                    onPressed: () => _passphraseFocusNode.requestFocus(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.lg),

            // ── 2. Prominent Passphrase Warning ───────────────────────────
            FfCard(
              variant: FfCardVariant.tinted,
              tone: FfTone.warning,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: ff.color.statusWarning,
                    size: 22,
                  ),
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep your passphrase safe',
                          style: ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ff.color.statusWarning,
                          ),
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          'Zero-knowledge encryption means nobody can recover your data without your passphrase. Write it down and keep it in a safe place.',
                          style: ff.text.bodySm.copyWith(
                            color: ff.color.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 3. Create Encrypted Backup Form ──────────────────────────
            const FfSectionHeader(title: 'Create new backup'),
            FfCard(
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FfTextField(
                    controller: _passphraseController,
                    focusNode: _passphraseFocusNode,
                    obscureText: true,
                    label: 'Encryption Passphrase',
                    hint: 'Enter at least 6 characters',
                    icon: Icons.key_outlined,
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfTextField(
                    controller: _confirmPassphraseController,
                    obscureText: true,
                    label: 'Confirm Passphrase',
                    hint: 'Re-enter passphrase',
                    icon: Icons.key_outlined,
                  ),
                  const SizedBox(height: FfSpace.lg),
                  FfButton(
                    label: 'Generate Encrypted Backup',
                    isLoading: _isCreatingBackup,
                    leadingIcon: const Icon(Icons.download_rounded, size: 18),
                    onPressed: _isCreatingBackup ? null : _createBackup,
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 4. Restore from File on Device ────────────────────────────
            const FfSectionHeader(title: 'Restore from file'),
            FfCard(
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.file_open_rounded,
                        color: ff.color.actionPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Text(
                        'Restore from File on Device',
                        style: ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Text(
                    'Restore a .ffbackup file from your phone’s Downloads folder, Google Drive, WhatsApp, or SD Card.',
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                  ),
                  const SizedBox(height: FfSpace.md),
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

            const SizedBox(height: FfSpace.xl),

            // ── 5. Existing Local Backups ─────────────────────────────────
            FfSectionHeader(
              title: 'On-device backup history (${_existingBackups.length})',
            ),

            if (_isLoadingBackups)
              const FfLoading()
            else if (_existingBackups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: FfSpace.sm),
                child: FfCard(
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: ff.color.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Text(
                          'No backups in local app storage. Use "Browse & Select" above to pick a backup from Downloads or Drive.',
                          style: ff.text.bodySm.copyWith(
                            color: ff.color.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              FfGroupedContainer(
                dividerInset: FfRowLeading.tile,
                children: [
                  for (final file in _existingBackups)
                    _buildBackupRow(context, file),
                ],
              ),

            const SizedBox(height: FfSpace.x4l),
          ],
        ),
      ),
    );
  }

  FfRow _buildBackupRow(BuildContext context, File file) {
    final stat = file.statSync();
    final sizeKb = (stat.size / 1024).toStringAsFixed(1);
    final filename = file.path.split(Platform.pathSeparator).last;

    return FfRow(
      icon: Icons.archive_outlined,
      iconTone: FfTone.primary,
      title: filename,
      subtitle:
          '${DateFormatter.formatTransactionDate(stat.modified)} · $sizeKb KB',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(width: FfSpace.x2s),
          FfButton(
            label: 'Restore',
            size: FfButtonSize.sm,
            variant: FfButtonVariant.secondary,
            leadingIcon: const Icon(
              Icons.settings_backup_restore_rounded,
              size: 16,
            ),
            onPressed: () => _openRestore(file),
          ),
        ],
      ),
    );
  }
}
