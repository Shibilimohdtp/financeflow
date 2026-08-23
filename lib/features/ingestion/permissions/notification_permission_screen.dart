import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_snackbar.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../settings/settings_controller.dart';

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  final Map<String, String> _supportedApps = {
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'com.phonepe.app': 'PhonePe',
    'net.one97.paytm': 'Paytm',
    'in.org.npci.upiapp': 'BHIM UPI',
    'com.dreamplug.androidapp': 'CRED',
  };

  late Set<String> _selectedPackages;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsStreamProvider).value;
    _selectedPackages = Set<String>.from(
      settings?.selectedNotificationPackages ?? _supportedApps.keys,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detection')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. Privacy Guarantee Hero ─────────────────────────────────
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
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: context.secColors.verified,
                          size: 20,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),
                        Text(
                          '100% On-Device Reading',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.secColors.verified,
                          ),
                        ),
                      ],
                    ),
                    const FfPrivacyBadge(label: 'Zero Upload'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Padding(
                  padding: const EdgeInsets.only(
                    left: StillwaterTokens.spaceLg,
                  ),
                  child: Text(
                    '• Notification text is parsed locally in memory on your phone.\n'
                    '• No notification content is ever sent to any remote server or AI service.\n'
                    '• Non-financial notifications (WhatsApp, social media) are strictly ignored.\n'
                    '• You can revoke or disable this permission at any time.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 2. Supported Apps List ────────────────────────────────────
          _SectionLabel(label: 'Select Payment Apps to Monitor'),
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
                for (int i = 0; i < _supportedApps.entries.length; i++) ...[
                  CheckboxListTile(
                    title: Text(
                      _supportedApps.entries.elementAt(i).value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _supportedApps.entries.elementAt(i).key,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 10,
                      ),
                    ),
                    value: _selectedPackages.contains(
                      _supportedApps.entries.elementAt(i).key,
                    ),
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedPackages.add(
                            _supportedApps.entries.elementAt(i).key,
                          );
                        } else {
                          _selectedPackages.remove(
                            _supportedApps.entries.elementAt(i).key,
                          );
                        }
                      });
                    },
                  ),
                  if (i < _supportedApps.entries.length - 1)
                    Divider(
                      height: 1,
                      thickness: StillwaterTokens.borderWidthHairline,
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 3. Save Controls ─────────────────────────────────────────
          FfButton(
            label: 'Enable On-Device Notification Detection',
            leadingIcon: const Icon(Icons.check_rounded, size: 18),
            onPressed: () async {
              final settings = ref.read(settingsStreamProvider).value;
              if (settings != null) {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(
                      settings.copyWith(
                        isNotificationDetectionEnabled: true,
                        selectedNotificationPackages:
                            _selectedPackages.toList(),
                      ),
                    );
                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'On-device notification detection enabled.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
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
