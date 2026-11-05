import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../settings/settings_controller.dart';
import '../../../services/ingestion/ingestion_coordinator.dart';
import '../../../services/ingestion/ingestion_platform.dart';
import '../../../shared/widgets/ff_toast.dart';

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
    final theme = context.theme;
    final status = ref.watch(ingestionPlatformStatusProvider).value;
    final permission =
        status?.smsPermission ?? IngestionPermissionState.unavailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Bank SMS Detection')),
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
                          'Privacy & SMS Security',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.secColors.verified,
                          ),
                        ),
                      ],
                    ),
                    const FfPrivacyBadge(label: '100% Offline'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Padding(
                  padding: const EdgeInsets.only(
                    left: StillwaterTokens.spaceLg,
                  ),
                  child: Text(
                    '• Only transactional debit/credit bank SMS are parsed.\n'
                    '• OTPs, login verification codes, and personal chats are NEVER parsed or stored.\n'
                    '• All regex parsing happens strictly on this device in memory.\n'
                    '• New financial sender IDs are reviewed locally when their format is unfamiliar.\n'
                    '• You can disable SMS detection anytime in Settings.',
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

          ListTile(
            leading: Icon(
              permission == IngestionPermissionState.granted
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
            ),
            title: Text('Android permission: ${_permissionLabel(permission)}'),
            subtitle: Text(_permissionExplanation(permission)),
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // ── 2. Supported Indian Banks List ───────────────────────────
          _SectionLabel(label: 'Supported Banking Templates'),
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
                for (int i = 0; i < _supportedBanks.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceMd,
                      vertical: StillwaterTokens.spaceSm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: context.secColors.verified,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceMd),
                        Expanded(
                          child: Text(
                            _supportedBanks[i],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _supportedBanks.length - 1)
                    Divider(
                      height: 1,
                      thickness: StillwaterTokens.borderWidthHairline,
                      indent:
                          StillwaterTokens.spaceMd +
                          18 +
                          StillwaterTokens.spaceMd,
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          // ── 3. Enable Button ─────────────────────────────────────────
          FfButton(
            label: 'Enable On-Device SMS Detection',
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
                // Do not leave the receiver waiting for an asynchronous stream
                // update after the user has granted SMS permission.
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
                  message:
                      'SMS permission was not granted. Detection remains off.',
                );
              }
            },
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
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
