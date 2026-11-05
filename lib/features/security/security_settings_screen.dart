import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  void _showSetPinSheet(BuildContext context) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = ctx.theme;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(StillwaterTokens.radius2Xl),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FfSheetHeader(
                      title: 'Set Security PIN',
                      subtitle:
                          'PIN is stored in your device hardware keystore',
                    ),
                    const Divider(height: 1, thickness: 1),
                    Padding(
                      padding: EdgeInsets.only(
                        left: StillwaterTokens.spaceLg,
                        right: StillwaterTokens.spaceLg,
                        top: StillwaterTokens.spaceMd,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom +
                            StillwaterTokens.spaceMd,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'Enter 4-6 Digit PIN',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.spaceMd),
                          TextField(
                            controller: confirmController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'Confirm PIN',
                              counterText: '',
                              errorText: errorText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FfSheetFooter(
                      secondaryLabel: 'Cancel',
                      primaryLabel: 'Save PIN',
                      onPrimaryPressed: () async {
                        final pin = pinController.text.trim();
                        final confirm = confirmController.text.trim();

                        if (pin.length < 4) {
                          setSheetState(() {
                            errorText = 'PIN must be at least 4 digits.';
                          });
                          return;
                        }
                        if (pin != confirm) {
                          setSheetState(() {
                            errorText = 'PINs do not match.';
                          });
                          return;
                        }

                        final securityService = ref.read(
                          securityServiceProvider,
                        );
                        await securityService.setPin(pin);
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setPinEnabled(true);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          FfToast.show(
                            context,
                            message: 'App PIN set securely.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removePin(BuildContext context) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Remove Security PIN?',
      message: 'Your app will no longer require a PIN to open on this device.',
      confirmLabel: 'Remove PIN',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final securityService = ref.read(securityServiceProvider);
      await securityService.removePin();
      await ref.read(settingsControllerProvider.notifier).setPinEnabled(false);
      if (context.mounted) {
        FfToast.show(context, message: 'Security PIN removed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final settings = ref.watch(settingsStreamProvider).value;
    final isBiometric = settings?.isBiometricEnabled ?? false;
    final isPin = settings?.isPinEnabled ?? false;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;
    final isScreenshotProtection =
        settings?.isScreenshotProtectionEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'Hardware Keystore', iconOnly: true),
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
          // ── 1. Hardware Keystore Banner ──────────────────────────────
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
                    Icons.security_rounded,
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
                        'On-Device Storage Architecture',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.secColors.verified,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All database files reside in private app sandbox storage. No financial records ever leave your phone.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 2. App Authentication ────────────────────────────────────
          _SectionLabel(label: 'App Authentication & Lock'),
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
                _SecuritySwitchRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Authentication',
                  subtitle: 'Unlock with Fingerprint or Face ID',
                  value: isBiometric,
                  onChanged: (val) async {
                    if (val) {
                      final securityService = ref.read(securityServiceProvider);
                      final isAvailable =
                          await securityService.isBiometricsAvailable();
                      if (!isAvailable && context.mounted) {
                        FfToast.show(
                          context,
                          message:
                              'Biometric authentication is not configured on this device.',
                        );
                        return;
                      }
                      final authSuccess = await securityService
                          .authenticateWithBiometrics(
                            reason: 'Enable Biometric Lock',
                          );
                      if (authSuccess) {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setBiometricEnabled(true);
                      }
                    } else {
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .setBiometricEnabled(false);
                    }
                  },
                ),
                _SecurityDivider(),
                _SecurityActionRow(
                  icon: Icons.lock_outline_rounded,
                  title: isPin ? 'App PIN Protected' : 'Set Security PIN',
                  subtitle:
                      isPin
                          ? 'PIN is active. Tap to change or remove.'
                          : 'Require a 4-6 digit code on launch',
                  trailing:
                      isPin
                          ? TextButton(
                            onPressed: () => _removePin(context),
                            child: const Text('Remove'),
                          )
                          : null,
                  onTap: () => _showSetPinSheet(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 3. Privacy Safeguards ────────────────────────────────────
          _SectionLabel(label: 'Privacy & Screen Protection'),
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
                _SecuritySwitchRow(
                  icon: Icons.blur_on_rounded,
                  title: 'Privacy Blur Mode',
                  subtitle: 'Mask balance figures by default in views',
                  value: isPrivacyBlur,
                  onChanged: (val) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setPrivacyBlurEnabled(val);
                  },
                ),
                _SecurityDivider(),
                _SecuritySwitchRow(
                  icon: Icons.hide_image_outlined,
                  title: 'Screenshot & Recents Protection',
                  subtitle:
                      'Block app preview screenshots in Android task switcher',
                  value: isScreenshotProtection,
                  onChanged: (val) {
                    if (settings != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              isScreenshotProtectionEnabled: val,
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}

class _SecuritySwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SecuritySwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SecurityActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SecurityActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceMd,
          vertical: StillwaterTokens.spaceSm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: StillwaterTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SecurityDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: StillwaterTokens.borderWidthHairline,
      indent: StillwaterTokens.spaceMd + 20 + StillwaterTokens.spaceMd,
      endIndent: 0,
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
