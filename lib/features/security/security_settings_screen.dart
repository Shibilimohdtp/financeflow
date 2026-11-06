import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../settings/settings_controller.dart';

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

    showFfSheet(
      context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FfSheet(
              children: [
                const FfSheetHeader(
                  title: 'Set Security PIN',
                  subtitle: 'PIN is stored in your device hardware keystore',
                ),
                const FfDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.pageMargin,
                    vertical: FfSpace.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FfTextField(
                        controller: pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        label: 'Enter 4-6 Digit PIN',
                      ),
                      const SizedBox(height: FfSpace.md),
                      FfTextField(
                        controller: confirmController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        label: 'Confirm PIN',
                        errorText: errorText,
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

                    final securityService = ref.read(securityServiceProvider);
                    await securityService.setPin(pin);
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .setPinEnabled(true);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      FfToast.show(context, message: 'App PIN set securely.');
                    }
                  },
                ),
              ],
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
    final settings = ref.watch(settingsStreamProvider).value;
    final isBiometric = settings?.isBiometricEnabled ?? false;
    final isPin = settings?.isPinEnabled ?? false;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;
    final isScreenshotProtection =
        settings?.isScreenshotProtectionEnabled ?? false;

    return Scaffold(
      appBar: FfAppBar(
        title: 'Security & Privacy',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.pageMargin),
            child: Center(
              child: FfPrivacyBadge(label: 'Hardware Keystore', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Hardware Keystore Banner ──────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            tone: FfTone.success,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: context.ff.color.statusSuccess,
                  size: 24,
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'On-Device Storage Architecture',
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.ff.color.statusSuccess,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        'All database files reside in private app sandbox storage. No financial records ever leave your phone.',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 2. App Authentication ────────────────────────────────────
          const FfSectionHeader(title: 'App authentication & lock'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow.toggle(
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
              FfRow(
                icon: Icons.lock_outline_rounded,
                title: isPin ? 'App PIN Protected' : 'Set Security PIN',
                subtitle:
                    isPin
                        ? 'PIN is active. Tap to change or remove.'
                        : 'Require a 4-6 digit code on launch',
                trailing:
                    isPin
                        ? FfButton(
                          label: 'Remove',
                          variant: FfButtonVariant.text,
                          size: FfButtonSize.sm,
                          onPressed: () => _removePin(context),
                        )
                        : null,
                onTap: () => _showSetPinSheet(context),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 3. Privacy Safeguards ────────────────────────────────────
          const FfSectionHeader(title: 'Privacy & screen protection'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow.toggle(
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
              FfRow.toggle(
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
                          settings.copyWith(isScreenshotProtectionEnabled: val),
                        );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x4l),
        ],
      ),
    );
  }
}
