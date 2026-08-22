import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/app_settings.dart';
import '../../shared/widgets/ff_card.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';

class AlertSettingsSheet extends ConsumerWidget {
  const AlertSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Master switch
          FfCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Local Alerts & Reminders'),
              subtitle: const Text(
                'Evaluated 100% on-device using local rules',
              ),
              value: settings.isAlertsEnabled,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                controller.updateSettings(
                  settings.copyWith(isAlertsEnabled: val),
                );
              },
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          if (settings.isAlertsEnabled) ...[
            Text('Alert Categories', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),
            FfCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.pie_chart_outline_rounded),
                    title: const Text('Budget Limits'),
                    subtitle: const Text(
                      'Alert when spending reaches 80% or exceeds limit',
                    ),
                    value: settings.isBudgetAlertsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(isBudgetAlertsEnabled: val),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.repeat_rounded),
                    title: const Text('Subscription Renewals'),
                    subtitle: const Text(
                      'Remind when upcoming subscriptions renew in ≤ 3 days',
                    ),
                    value: settings.isSubscriptionAlertsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(isSubscriptionAlertsEnabled: val),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.account_balance_outlined),
                    title: const Text('Loan & EMI Due Dates'),
                    subtitle: const Text(
                      'Remind when an EMI is due within 3 days',
                    ),
                    value: settings.isLoanAlertsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(isLoanAlertsEnabled: val),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.rate_review_outlined),
                    title: const Text('Pending Review Transactions'),
                    subtitle: const Text(
                      'Remind when imported transactions await confirmation',
                    ),
                    value: settings.isNeedsReviewAlertsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(isNeedsReviewAlertsEnabled: val),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.backup_outlined),
                    title: const Text('Encrypted Backup Reminders'),
                    subtitle: const Text(
                      'Remind when 30 days have passed since last backup',
                    ),
                    value: settings.isBackupReminderEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.updateSettings(
                        settings.copyWith(isBackupReminderEnabled: val),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
