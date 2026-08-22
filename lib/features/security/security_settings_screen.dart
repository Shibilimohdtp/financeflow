import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  void _showSetPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: StillwaterTokens.spaceLg,
                right: StillwaterTokens.spaceLg,
                top: StillwaterTokens.spaceLg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    StillwaterTokens.spaceLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set App Security PIN',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Text(
                    'Your PIN is securely stored in your device’s hardware keystore.',
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),
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
                  const SizedBox(height: StillwaterTokens.spaceXl),
                  Row(
                    children: [
                      Expanded(
                        child: FfButton(
                          label: 'Cancel',
                          variant: FfButtonVariant.outlined,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: FfButton(
                          label: 'Save PIN',
                          onPressed: () async {
                            final pin = pinController.text.trim();
                            final confirm = confirmController.text.trim();

                            if (pin.length < 4) {
                              setState(() {
                                errorText = 'PIN must be at least 4 digits.';
                              });
                              return;
                            }
                            if (pin != confirm) {
                              setState(() {
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
                              FfSnackbar.show(
                                context,
                                message: 'PIN lock enabled securely.',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final settings = ref.watch(settingsStreamProvider).value;
    final securityService = ref.watch(securityServiceProvider);

    final isBiometric = settings?.isBiometricEnabled ?? false;
    final isPin = settings?.isPinEnabled ?? false;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On-Device Verified Banner
            FfCard(
              variant: FfCardVariant.tinted,
              child: Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 28,
                    color: context.secColors.verified,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On-Device Storage Architecture',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: context.secColors.verified,
                          ),
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        Text(
                          'All database files reside in private app storage. No financial records ever leave your phone.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.space2Xl),

            Text('App Protection', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Biometric Authentication Toggle
            FfCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text(
                      'Use fingerprint or face recognition to unlock FinanceFlow.',
                    ),
                    value: isBiometric,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (enabled) async {
                      if (enabled) {
                        final available =
                            await securityService.isBiometricsAvailable();

                        if (!available && context.mounted) {
                          FfSnackbar.show(
                            context,
                            message:
                                'Biometric authentication is not supported or enrolled on this device.',
                          );
                          return;
                        }

                        final authenticated = await securityService
                            .authenticateWithBiometrics(
                              reason:
                                  'Confirm your biometric to enable app lock',
                            );

                        if (authenticated) {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .setBiometricEnabled(true);
                          if (context.mounted) {
                            FfSnackbar.show(
                              context,
                              message: 'Biometric lock enabled.',
                            );
                          }
                        }
                      } else {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setBiometricEnabled(false);
                      }
                    },
                  ),
                  const Divider(),

                  // PIN Lock
                  ListTile(
                    title: const Text('Security PIN Lock'),
                    subtitle: Text(
                      isPin
                          ? 'PIN lock is active'
                          : 'Set a backup 4-6 digit PIN',
                    ),
                    trailing:
                        isPin
                            ? TextButton(
                              onPressed: () async {
                                final confirmed = await FfConfirmDialog.show(
                                  context,
                                  title: 'Remove PIN Lock?',
                                  message:
                                      'Are you sure you want to remove the PIN lock on this device?',
                                  confirmLabel: 'Remove',
                                  isDestructive: true,
                                );
                                if (confirmed == true) {
                                  await securityService.removePin();
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .setPinEnabled(false);
                                  if (context.mounted) {
                                    FfSnackbar.show(
                                      context,
                                      message: 'PIN lock removed.',
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            )
                            : TextButton(
                              onPressed: () => _showSetPinDialog(context),
                              child: const Text('Set PIN'),
                            ),
                  ),
                  const Divider(),

                  // Privacy Blur
                  SwitchListTile(
                    title: const Text('Privacy Amount Blur'),
                    subtitle: const Text(
                      'Blur balances on screen and in recent apps for privacy in public spaces.',
                    ),
                    value: isPrivacyBlur,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (enabled) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setPrivacyBlurEnabled(enabled);
                    },
                  ),
                  const Divider(),

                  // Auto-Lock Timeout
                  ListTile(
                    title: const Text('Auto-Lock Timeout'),
                    subtitle: const Text(
                      'Automatically lock app when backgrounded or inactive',
                    ),
                    trailing: DropdownButton<int>(
                      value: settings?.autoLockTimeoutMinutes ?? 0,
                      underline: const SizedBox.shrink(),
                      onChanged: (val) {
                        if (val != null && settings != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .updateSettings(
                                settings.copyWith(autoLockTimeoutMinutes: val),
                              );
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Immediately')),
                        DropdownMenuItem(value: 1, child: Text('1 Minute')),
                        DropdownMenuItem(value: 5, child: Text('5 Minutes')),
                        DropdownMenuItem(value: 15, child: Text('15 Minutes')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.space2Xl),

            Text('Privacy Guarantees', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Zero-permission status
            FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FfPrivacyBadge(label: 'Zero Remote Servers'),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Text(
                    'FinanceFlow runs fully offline on your device. PIN and encryption keys are protected by hardware-backed keystores and never transmitted over the internet.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
