import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_snackbar.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../settings/settings_controller.dart';

class SmsPermissionScreen extends ConsumerStatefulWidget {
  const SmsPermissionScreen({super.key});

  @override
  ConsumerState<SmsPermissionScreen> createState() =>
      _SmsPermissionScreenState();
}

class _SmsPermissionScreenState extends ConsumerState<SmsPermissionScreen> {
  final List<String> _supportedBanks = [
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

    return Scaffold(
      appBar: AppBar(title: const Text('Bank SMS Detection')),
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
                      'Privacy & SMS Security',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.secColors.verified,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const FfPrivacyBadge(label: '100% Offline'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  '• Only transactional debit/credit bank SMS are parsed.\n'
                  '• OTPs, login verification codes, and personal conversations are NEVER read or stored.\n'
                  '• All parsing happens locally on your device in memory.\n'
                  '• Raw SMS text can be cleared anytime in Settings.\n'
                  '• You can disable SMS detection at any time.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          Text(
            'Supported Indian Banks & Senders',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: StillwaterTokens.space3Xs),
          Text(
            'FinanceFlow recognizes official banking SMS format templates from:',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),

          FfCard(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  _supportedBanks.map((bank) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: StillwaterTokens.space3Xs,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: context.secColors.verified,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceSm),
                          Text(bank, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          FfButton(
            label: 'Enable On-Device SMS Detection',
            leadingIcon: const Icon(Icons.sms_outlined),
            onPressed: () async {
              final settings = ref.read(settingsStreamProvider).value;
              if (settings != null) {
                final updated = settings.copyWith(isSmsDetectionEnabled: true);
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(updated);

                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'Bank SMS detection enabled on this device.',
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
