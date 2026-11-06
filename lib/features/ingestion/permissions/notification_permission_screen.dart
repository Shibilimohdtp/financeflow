import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ingestion/ingestion_coordinator.dart';
import '../../../shared/widgets/ff_app_bar.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../../settings/settings_controller.dart';

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  final Map<String, String> _supportedApps = const {
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
    final ff = context.ff;
    final hasAccess =
        ref.watch(ingestionPlatformStatusProvider).value?.notificationAccess ??
        false;

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const FfAppBar(title: 'Notification Detection'),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.pageMargin,
            vertical: FfSpace.md,
          ),
          children: [
            // ── 1. Privacy Guarantee Hero Card ───────────────────────────
            FfCard(
              padding: const EdgeInsets.all(FfSpace.md),
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
                            color: ff.color.statusSuccess,
                            size: 20,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Text(
                            '100% On-Device Reading',
                            style: ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ff.color.statusSuccess,
                            ),
                          ),
                        ],
                      ),
                      const FfPrivacyBadge(label: 'Zero Upload'),
                    ],
                  ),
                  const SizedBox(height: FfSpace.sm),
                  Text(
                    '• Notification text is parsed strictly in memory on this device.\n'
                    '• No notification content is ever sent to any remote server.\n'
                    '• Non-financial notifications (messages, chats, social media) are ignored.\n'
                    '• You can revoke or disable this permission at any time.',
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.lg),

            // ── 2. On-Device Pipeline Visualization ─────────────────────
            FfCard(
              variant: FfCardVariant.tinted,
              tone: FfTone.success,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.memory_rounded,
                        size: 18,
                        color: ff.color.statusSuccess,
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Text(
                        'On-Device Ingestion Pipeline',
                        style: ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ff.color.statusSuccess,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Text(
                    'Push Notification ➔ Regex Engine (Device RAM) ➔ Needs Review Queue\nZero network calls. Zero third-party telemetry.',
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 3. OS Permission Status ──────────────────────────────────
            const FfSectionHeader(title: 'System permission status'),
            FfGroupedContainer(
              dividerInset: FfRowLeading.icon,
              children: [
                FfRow(
                  icon:
                      hasAccess
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                  title:
                      'Android notification access: ${hasAccess ? 'Allowed' : 'Not allowed'}',
                  subtitle:
                      hasAccess
                          ? 'The system notification-listener service is available.'
                          : 'Android requires enabling access in Notification Listener settings.',
                ),
              ],
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 4. Supported Apps List ────────────────────────────────────
            const FfSectionHeader(title: 'Payment apps to monitor'),
            FfGroupedContainer(
              children: [
                for (final entry in _supportedApps.entries)
                  FfRow.checkbox(
                    title: entry.value,
                    subtitle: entry.key,
                    checked: _selectedPackages.contains(entry.key),
                    onChanged:
                        (checked) => setState(() {
                          if (checked) {
                            _selectedPackages.add(entry.key);
                          } else {
                            _selectedPackages.remove(entry.key);
                          }
                        }),
                  ),
              ],
            ),

            const SizedBox(height: FfSpace.x2l),

            // ── 5. Save Controls ─────────────────────────────────────────
            FfButton(
              label:
                  hasAccess
                      ? 'Enable On-Device Notification Detection'
                      : 'Open Android Notification Access',
              variant: FfButtonVariant.primary,
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
      ),
    );
  }
}
