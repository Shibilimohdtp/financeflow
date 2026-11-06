import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/ingestion/ingestion_coordinator.dart';
import '../../../services/ingestion/ingestion_platform.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../shared/widgets/ff_page_scaffold.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../../settings/settings_controller.dart';

class SmsPermissionScreen extends ConsumerStatefulWidget {
  const SmsPermissionScreen({super.key});

  @override
  ConsumerState<SmsPermissionScreen> createState() =>
      _SmsPermissionScreenState();
}

class _SmsPermissionScreenState extends ConsumerState<SmsPermissionScreen> {
  final List<String> _supportedBanks = const [
    'HDFC Bank (HDFCBK)',
    'ICICI Bank (ICICIB)',
    'State Bank of India (SBIN)',
    'Axis Bank (AXISBK)',
    'Federal Bank (FEDBNK)',
    'Canara Bank (CANBNK)',
    'Union Bank (UNIONB)',
    'UPI Payment Gateways',
  ];

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final status = ref.watch(ingestionPlatformStatusProvider).value;
    final permission =
        status?.smsPermission ?? IngestionPermissionState.unavailable;
    // Detection is on only when the app setting is on AND Android grants
    // SMS access. Android keeps the permission across reinstalls, so the
    // OS state alone can be "granted" while the app setting is off.
    final appSettings = ref.watch(settingsStreamProvider).value;
    final detectionOn =
        (appSettings?.isSmsDetectionEnabled ?? false) &&
        permission == IngestionPermissionState.granted;

    return FfPageScaffold(
      onAurora: true,
      title: 'Bank SMS Detection',
      subtitle: 'Read on-device, never uploaded',
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
                          'Privacy & SMS Security',
                          style: ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ff.color.statusSuccess,
                          ),
                        ),
                      ],
                    ),
                    const FfPrivacyBadge(label: '100% Offline'),
                  ],
                ),
                const SizedBox(height: FfSpace.sm),
                Text(
                  '• Only transactional debit/credit bank SMS are parsed.\n'
                  '• OTPs, login verification codes, and personal chats are NEVER parsed or stored.\n'
                  '• All regex parsing happens strictly on this device in memory.\n'
                  '• New financial sender IDs are reviewed locally when their format is unfamiliar.\n'
                  '• You can disable SMS detection anytime in Settings.',
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
                  'SMS Broadcast ➔ Regex Engine (Device RAM) ➔ Needs Review Queue\nZero network calls. Zero third-party telemetry.',
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
                    permission == IngestionPermissionState.granted
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                title: 'Android permission: ${_permissionLabel(permission)}',
                subtitle: _permissionExplanation(permission),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 4. Supported Banking Templates ───────────────────────────
          const FfSectionHeader(title: 'Supported banking templates'),
          FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              for (final bank in _supportedBanks)
                FfRow(icon: Icons.check_circle_rounded, title: bank),
            ],
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 5. Action Buttons ────────────────────────────────────────
          if (detectionOn) ...[
            FfButton(
              label: 'Disable On-Device SMS Detection',
              variant: FfButtonVariant.destructive,
              onPressed: () async {
                final coordinator = ref.read(ingestionCoordinatorProvider);
                final settings = ref.read(settingsStreamProvider).value;
                if (settings != null) {
                  final disabledSettings = settings.copyWith(
                    isSmsDetectionEnabled: false,
                  );
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(disabledSettings);
                  await coordinator.configure(disabledSettings);
                  if (context.mounted) {
                    FfToast.show(context, message: 'SMS detection disabled.');
                  }
                }
              },
            ),
          ] else ...[
            FfButton(
              label: 'Enable On-Device SMS Detection',
              variant: FfButtonVariant.primary,
              leadingIcon: const Icon(Icons.sms_outlined, size: 18),
              onPressed: () async {
                final coordinator = ref.read(ingestionCoordinatorProvider);
                final platformStatus =
                    permission == IngestionPermissionState.permanentlyDenied
                        ? null
                        : await coordinator.requestSmsPermission();
                if (permission == IngestionPermissionState.permanentlyDenied) {
                  await coordinator.openAppSettings();
                  return;
                }
                final settings = ref.read(settingsStreamProvider).value;
                if (settings != null &&
                    platformStatus?.smsPermission ==
                        IngestionPermissionState.granted) {
                  final enabledSettings = settings.copyWith(
                    isSmsDetectionEnabled: true,
                  );
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(enabledSettings);
                  await coordinator.configure(enabledSettings);
                  if (context.mounted) {
                    FfToast.show(
                      context,
                      message: 'On-device SMS detection enabled.',
                    );
                  }
                } else if (context.mounted) {
                  FfToast.show(
                    context,
                    tone: FfToastTone.warning,
                    message:
                        'SMS permission was not granted. Detection remains off.',
                  );
                }
              },
            ),
          ],

          const SizedBox(height: FfSpace.x4l),
        ],
      ),
    );
  }

  String _permissionLabel(IngestionPermissionState state) {
    switch (state) {
      case IngestionPermissionState.granted:
        return 'Granted';
      case IngestionPermissionState.denied:
        return 'Denied';
      case IngestionPermissionState.permanentlyDenied:
        return 'Permanently denied';
      case IngestionPermissionState.restricted:
        return 'Restricted by device policy';
      case IngestionPermissionState.unavailable:
        return 'Unavailable';
    }
  }

  String _permissionExplanation(IngestionPermissionState state) {
    switch (state) {
      case IngestionPermissionState.granted:
        return 'New matching bank SMS can be captured while the app is backgrounded.';
      case IngestionPermissionState.denied:
        return 'Android will ask for SMS access. The setting is not enabled unless access is granted.';
      case IngestionPermissionState.permanentlyDenied:
        return 'Permission must be restored from Android App Settings.';
      case IngestionPermissionState.restricted:
        return 'A device administrator or Android policy prevents SMS access.';
      case IngestionPermissionState.unavailable:
        return 'SMS ingestion is Android-only and requires telephony support.';
    }
  }
}
