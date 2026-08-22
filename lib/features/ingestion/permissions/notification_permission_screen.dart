import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
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
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Privacy Banner
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '100% On-Device Reading',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.secColors.verified,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const FfPrivacyBadge(label: 'Zero Upload'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  '• Notification text is parsed locally in memory on your phone.\n'
                  '• No notification content is ever sent to any remote server or AI service.\n'
                  '• Unrelated notifications (WhatsApp, Telegram, Social media) are strictly ignored.\n'
                  '• You can revoke or disable this permission at any time in Settings.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          Text(
            'Select Payment Apps to Monitor',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: StillwaterTokens.space3Xs),
          Text(
            'Only notifications from selected apps will be scanned for financial transactions.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),

          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children:
                  _supportedApps.entries.map((entry) {
                    final isSelected = _selectedPackages.contains(entry.key);
                    return CheckboxListTile(
                      title: Text(entry.value),
                      subtitle: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 10),
                      ),
                      value: isSelected,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPackages.add(entry.key);
                          } else {
                            _selectedPackages.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          FfButton(
            label: 'Enable On-Device Notification Detection',
            leadingIcon: const Icon(Icons.notifications_active_outlined),
            onPressed: () async {
              final settings = ref.read(settingsStreamProvider).value;
              if (settings != null) {
                final updated = settings.copyWith(
                  isNotificationDetectionEnabled: true,
                  selectedNotificationPackages: _selectedPackages.toList(),
                );
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(updated);

                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'Notification detection enabled on this device.',
                  );
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfButton(
            label: 'Keep Disabled',
            variant: FfButtonVariant.outlined,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
