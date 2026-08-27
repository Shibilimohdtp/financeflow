import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
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
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(
              child: FfPrivacyBadge(label: 'Optional AI', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. Privacy Boundary Disclosure Hero ───────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: context.aiColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),
                        Text(
                          'Privacy Boundary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.aiColors.accent,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isConsentGranted
                                ? context.secColors.verified.withValues(
                                  alpha: 0.15,
                                )
                                : theme.colorScheme.secondary.withValues(
                                  alpha: 0.15,
                                ),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                      ),
                      child: Text(
                        isConsentGranted ? 'Consent Active' : 'Disabled',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isConsentGranted
                                  ? context.secColors.verified
                                  : theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  'Gemini AI is strictly optional. FinanceFlow is 100% complete and fully operational offline with local on-device rules even when Gemini is disabled.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 2. Data Minimization Policy ──────────────────────────────
          const FfSectionHeader(title: 'Data Minimization Policy'),
          FfCard(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
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
                      'Strict Data Scrubbing & Anonymization',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                Text(
                  '• Account numbers, personal names, phone numbers, and exact timestamps are completely stripped before processing.\n'
                  '• Only anonymized merchant names and amounts are analyzed when categorization confidence is low.\n'
                  '• No user account or profile is sent to Google.\n'
                  '• All queries and responses are recorded in your on-device AI Activity Log.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Consent Controls ──────────────────────────────────────
          const FfSectionHeader(title: 'Consent Controls'),
          FfGroupedContainer(
            children: [
              SwitchListTile.adaptive(
                title: const Text('Enable Gemini AI Assistance'),
                subtitle: Text(
                  isConsentGranted
                      ? 'Consent granted on ${settings.geminiConsentDate != null ? DateFormatter.formatShortDate(settings.geminiConsentDate!) : "this device"}'
                      : 'AI assistance is disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                value: isConsentGranted,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) async {
                  if (val) {
                    await ref
                        .read(geminiControllerProvider.notifier)
                        .grantConsent();
                  } else {
                    await ref
                        .read(geminiControllerProvider.notifier)
                        .revokeConsent();
                  }
                  if (context.mounted) {
                    FfSnackbar.show(
                      context,
                      message:
                          val
                              ? 'Gemini AI assistance enabled with data minimization.'
                              : 'Gemini AI assistance disabled.',
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space4Xl),
        ],
      ),
    );
  }
}
