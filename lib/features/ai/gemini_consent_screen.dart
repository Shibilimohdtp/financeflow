import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';
import 'ai_activity_log_screen.dart';
import 'gemini_controller.dart';

class GeminiConsentScreen extends ConsumerWidget {
  const GeminiConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final isConsentGranted =
        settings.geminiConsentGranted && settings.isGeminiEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistance (Gemini)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'AI Activity Log',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiActivityLogScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Privacy boundary hero card
          FfCard(
            variant: FfCardVariant.tinted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Privacy Boundary Disclosure',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.aiColors.accent,
                      ),
                    ),
                    const FfPrivacyBadge(label: 'Optional AI'),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  'Gemini AI is strictly optional. FinanceFlow is 100% complete and operational offline using on-device rules even when Gemini is disabled.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // What leaves device vs What stays on device
          Text('Data Minimization Policy', style: theme.textTheme.titleMedium),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: context.secColors.verified,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'What may be sent (Minimally)',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  '• Cleaned merchant name (e.g. "Swiggy")\n'
                  '• Transaction amount (e.g. ₹420)\n'
                  '• List of default category names for categorization',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                const Divider(),
                const SizedBox(height: StillwaterTokens.spaceMd),
                Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: context.secColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'What NEVER leaves this phone',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  '• Raw SMS messages or notification bodies\n'
                  '• Bank account numbers, PINs, or card digits\n'
                  '• Transaction notes, receipts, or attachments\n'
                  '• Full financial history or unassociated data',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // User Consent Status Card
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gemini Assistance Status',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      isConsentGranted ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isConsentGranted
                                ? context.secColors.verified
                                : theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                if (settings.geminiConsentDate != null) ...[
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Text(
                    'Consent granted on ${DateFormatter.formatFullDate(settings.geminiConsentDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          if (isConsentGranted)
            FfButton(
              label: 'Revoke Consent & Disable Gemini',
              variant: FfButtonVariant.destructive,
              onPressed: () async {
                await ref
                    .read(geminiControllerProvider.notifier)
                    .revokeConsent();
                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'Gemini disabled. Reverted to on-device rules.',
                  );
                }
              },
            )
          else
            FfButton(
              label: 'I Understand & Agree to Boundary Terms',
              variant: FfButtonVariant.filled,
              onPressed: () async {
                await ref
                    .read(geminiControllerProvider.notifier)
                    .grantConsent();
                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'Gemini assistance enabled.',
                  );
                }
              },
            ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          FfButton(
            label: 'View Local AI Activity Audit Log',
            variant: FfButtonVariant.outlined,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiActivityLogScreen()),
              );
            },
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}
