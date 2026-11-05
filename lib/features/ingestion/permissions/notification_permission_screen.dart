import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../settings/settings_controller.dart';
import '../../../services/ingestion/ingestion_coordinator.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../shared/widgets/ff_app_bar.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../theme/ff.dart';

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
    final hasAccess =
        ref.watch(ingestionPlatformStatusProvider).value?.notificationAccess ??
        false;

    return Scaffold(
      appBar: FfAppBar(title: 'Notification Detection'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Privacy Guarantee Hero ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(FfSpace.lg),
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
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
                          color: context.ff.color.statusSuccess,
                          size: 20,
                        ),
                        const SizedBox(width: FfSpace.sm),
                        Text(
                          '100% On-Device Reading',
                          style: context.ff.text.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.ff.color.statusSuccess,
                          ),
                        ),
                      ],
                    ),
                    const FfPrivacyBadge(label: 'Zero Upload'),
                  ],
                ),
                const SizedBox(height: FfSpace.sm),
                Padding(
                  padding: const EdgeInsets.only(left: FfSpace.lg),
                  child: Text(
                    '• Notification text is parsed locally in memory on your phone.\n'
                    '• No notification content is ever sent to any remote server.\n'
                    '• Non-financial notifications (WhatsApp, social media) are strictly ignored.\n'
                    '• You can revoke or disable this permission at any time.',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.secondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          FfRow(
            icon: hasAccess ? Icons.check_circle_outline : Icons.info_outline,
            title:
                'Android notification access: ${hasAccess ? 'Allowed' : 'Not allowed'}',
            subtitle:
                hasAccess
                    ? 'The system notification-listener service is available.'
                    : 'Android requires a separate action in Notification Access settings.',
          ),

          const SizedBox(height: FfSpace.md),

          // ── 2. Supported Apps List ────────────────────────────────────
          _SectionLabel(label: 'Select Payment Apps to Monitor'),
          const SizedBox(height: FfSpace.xs),
          Container(
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _supportedApps.entries.length; i++) ...[
                  FfRow.checkbox(
                    title: _supportedApps.entries.elementAt(i).value,
                    subtitle: _supportedApps.entries.elementAt(i).key,
                    checked: _selectedPackages.contains(
                      _supportedApps.entries.elementAt(i).key,
                    ),
                    onChanged:
                        (checked) => setState(() {
                          if (checked) {
                            _selectedPackages.add(
                              _supportedApps.entries.elementAt(i).key,
                            );
                          } else {
                            _selectedPackages.remove(
                              _supportedApps.entries.elementAt(i).key,
                            );
                          }
                        }),
                  ),
                  if (i < _supportedApps.entries.length - 1) const FfDivider(),
                ],
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 3. Save Controls ─────────────────────────────────────────
          FfButton(
            label:
                hasAccess
                    ? 'Enable On-Device Notification Detection'
                    : 'Open Android Notification Access',
            leadingIcon: const Icon(Icons.check_rounded, size: 18),
            onPressed: () async {
              if (!hasAccess) {
                await ref
                    .read(ingestionCoordinatorProvider)
                    .openNotificationAccessSettings();
                return;
              }
              final settings = ref.read(settingsStreamProvider).value;
              if (settings != null) {
                final enabledSettings = settings.copyWith(
                  isNotificationDetectionEnabled: true,
                  selectedNotificationPackages: _selectedPackages.toList(),
                );
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(enabledSettings);
                await ref
                    .read(ingestionCoordinatorProvider)
                    .configure(enabledSettings);
                if (context.mounted) {
                  FfToast.show(
                    context,
                    message: 'On-device notification detection enabled.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: FfSpace.x4l),
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
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
