import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_subscription_sheet.dart';
import 'subscriptions_controller.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  void _edit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => AddEditSubscriptionSheet(initialSubscription: subscription),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Subscription?',
      message:
          'Are you sure you want to stop tracking "${subscription.merchant}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(subscriptionsControllerProvider.notifier)
          .deleteSubscription(subscription.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Subscription deleted.');
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final newStatus =
        subscription.status == SubscriptionStatus.active
            ? SubscriptionStatus.paused
            : SubscriptionStatus.active;

    await ref
        .read(subscriptionsControllerProvider.notifier)
        .updateStatus(subscription.id, newStatus);
    if (context.mounted) {
      Navigator.of(context).pop();
      FfSnackbar.show(
        context,
        message:
            newStatus == SubscriptionStatus.active
                ? 'Subscription resumed.'
                : 'Subscription paused.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final days = subscription.daysUntilRenewal();

    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.merchant),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Amount Hero Card
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recurring Amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            subscription.status == SubscriptionStatus.active
                                ? context.secColors.verified.withValues(
                                  alpha: 0.15,
                                )
                                : theme.colorScheme.secondary.withValues(
                                  alpha: 0.15,
                                ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subscription.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              subscription.status == SubscriptionStatus.active
                                  ? context.secColors.verified
                                  : theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  CurrencyFormatter.formatINR(subscription.amount),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Billed ${subscription.billingFrequency.displayName} · Next: ${DateFormatter.formatFullDate(subscription.nextRenewalDate)} ($days days)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Normalized Cost Summary
          FfCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Monthly Equivalent Cost'),
                  trailing: Text(
                    CurrencyFormatter.formatINR(
                      subscription.monthlyEquivalentAmount,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Annual Equivalent Cost'),
                  trailing: Text(
                    CurrencyFormatter.formatINR(
                      subscription.yearlyEquivalentAmount,
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Renewal Reminder'),
                  trailing: Text(
                    subscription.isReminderEnabled
                        ? '${subscription.reminderDaysBefore} day(s) before'
                        : 'Off',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),

          if (subscription.notes != null && subscription.notes!.isNotEmpty) ...[
            const SizedBox(height: StillwaterTokens.spaceLg),
            FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes', style: theme.textTheme.titleSmall),
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Text(subscription.notes!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],

          const SizedBox(height: StillwaterTokens.space2Xl),

          // Pause / Resume Button
          FfButton(
            label:
                subscription.status == SubscriptionStatus.active
                    ? 'Pause Subscription'
                    : 'Resume Subscription',
            variant: FfButtonVariant.outlined,
            onPressed: () => _toggleStatus(context, ref),
          ),
        ],
      ),
    );
  }
}
