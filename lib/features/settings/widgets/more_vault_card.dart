import 'package:flutter/material.dart';
import '../../../models/app_settings.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// The Vault hero card on the More screen: displays backup freshness, lock
/// security state, and on-device privacy guarantee on a quiet sand hero surface.
class MoreVaultCard extends StatelessWidget {
  final AppSettings? settings;
  final VoidCallback onBackupTap;
  final VoidCallback onSecurityTap;

  const MoreVaultCard({
    super.key,
    required this.settings,
    required this.onBackupTap,
    required this.onSecurityTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastBackup = settings?.lastBackupDate;
    final isPin = settings?.isPinEnabled ?? false;
    final isBiometric = settings?.isBiometricEnabled ?? false;

    final now = DateTime.now();
    final isBackupOverdue =
        lastBackup == null || now.difference(lastBackup).inDays >= 14;

    String backupText;
    IconData backupIcon;
    if (lastBackup == null) {
      backupText = 'No backup created yet';
      backupIcon = Icons.warning_amber_rounded;
    } else {
      final days = now.difference(lastBackup).inDays;
      if (days == 0) {
        backupText = 'Backed up today';
        backupIcon = Icons.check_circle_outline_rounded;
      } else if (days == 1) {
        backupText = 'Last backup yesterday';
        backupIcon = Icons.check_circle_outline_rounded;
      } else {
        backupText = 'Last backup $days days ago';
        backupIcon =
            days >= 14
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded;
      }
    }

    String securityText;
    IconData securityIcon;
    if (isPin && isBiometric) {
      securityText = 'App lock active (PIN & Biometrics)';
      securityIcon = Icons.lock_outline_rounded;
    } else if (isPin) {
      securityText = 'App lock active (PIN protected)';
      securityIcon = Icons.lock_outline_rounded;
    } else if (isBiometric) {
      securityText = 'App lock active (Biometrics only)';
      securityIcon = Icons.fingerprint_rounded;
    } else {
      securityText = 'App lock off · Tap to secure';
      securityIcon = Icons.lock_open_rounded;
    }

    return FfHeroCard(
      tone: FfHeroTone.sand,
      leading: const FfIconTile(
        icon: Icons.shield_outlined,
        tone: FfTone.primary,
      ),
      title: 'Device Vault',
      subtitle: 'Local & encrypted storage',
      onOpen: onSecurityTap,
      openTooltip: 'Open security settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Backup status
          Row(
            children: [
              Icon(backupIcon, size: 16),
              const SizedBox(width: FfSpace.xs),
              Expanded(
                child: Text(
                  backupText,
                  style: context.ff.text.bodySm.copyWith(
                    fontWeight:
                        isBackupOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isBackupOverdue)
                FfButton(
                  label: 'Back up now',
                  variant: FfButtonVariant.spark,
                  size: FfButtonSize.sm,
                  onPressed: onBackupTap,
                ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),

          // Row 2: Security lock status
          InkWell(
            onTap: onSecurityTap,
            borderRadius: BorderRadius.circular(FfRadius.xs),
            child: Row(
              children: [
                Icon(securityIcon, size: 16),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  child: Text(securityText, style: context.ff.text.bodySm),
                ),
              ],
            ),
          ),
          const SizedBox(height: FfSpace.sm),

          // Row 3: Privacy assertion
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 16),
              const SizedBox(width: FfSpace.xs),
              Expanded(
                child: Text(
                  'All data stays on this device',
                  style: context.ff.text.bodySm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
