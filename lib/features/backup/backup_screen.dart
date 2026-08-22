import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
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
              'Encrypted backup created on device: ${path.split(Platform.pathSeparator).last}',
        );
      }
    } catch (e) {
      if (mounted) {
        FfSnackbar.show(context, message: 'Backup failed: $e');
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
    final state = ref.watch(backupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'AES-256 Encrypted')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Trust Promise Card
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: context.secColors.verified,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Zero-Knowledge Local Encryption',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: context.secColors.verified,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Your backup is encrypted on this device using standard PBKDF2 and AES-256 before saving. Keep your passphrase safe — it cannot be recovered if lost.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Create Backup Section
          Text('Create Encrypted Backup', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Backup Passphrase',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                TextField(
                  controller: _confirmPassphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Passphrase',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
                FfButton(
                  label:
                      state.isLoading
                          ? 'Encrypting & Saving...'
                          : 'Create Encrypted Backup',
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : _createBackup,
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // Existing Local Backups List
          Text(
            'Available Backups on Device',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          if (_isLoadingBackups)
            const Center(child: CircularProgressIndicator())
          else if (_existingBackups.isEmpty)
            FfCard(
              child: Padding(
                padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                child: Center(
                  child: Text(
                    'No backups created yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _existingBackups.length,
              separatorBuilder:
                  (_, __) => const SizedBox(height: StillwaterTokens.spaceSm),
              itemBuilder: (context, index) {
                final file = _existingBackups[index];
                final stats = file.statSync();
                final name = file.path.split(Platform.pathSeparator).last;
                final sizeKb = (stats.size / 1024).toStringAsFixed(1);

                return FfCard(
                  onTap: () => _openRestore(file),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormatter.formatFullDate(stats.modified)} · $sizeKb KB',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _openRestore(file),
                        child: const Text('Restore'),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}
