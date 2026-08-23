import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_subscription_sheet.dart';
import 'subscriptions_controller.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  void _edit(BuildContext context, Subscription currentSub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSubscriptionSheet(initialSubscription: currentSub),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Subscription currentSub,
  ) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Subscription?',
      message:
          'Are you sure you want to stop tracking "${currentSub.merchant}" on this device?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(subscriptionsControllerProvider.notifier)
          .deleteSubscription(currentSub.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Subscription removed.');
      }
    }
  }

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    Subscription currentSub,
  ) async {
    final newStatus =
        currentSub.status == SubscriptionStatus.active
            ? SubscriptionStatus.paused
            : SubscriptionStatus.active;

    await ref
        .read(subscriptionsControllerProvider.notifier)
        .updateStatus(currentSub.id, newStatus);
    if (context.mounted) {
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

    // Watch live subscription stream
    final subsAsync = ref.watch(allSubscriptionsStreamProvider);
    final currentSub =
        subsAsync.value?.firstWhere(
          (s) => s.id == subscription.id,
          orElse: () => subscription,
        ) ??
        subscription;

    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final linkedAccount = accountsAsync.value?.firstWhere(
      (a) => a.id == currentSub.accountId,
      orElse: () => null as dynamic,
    );

    final days = currentSub.daysUntilRenewal();
    final isActive = currentSub.status == SubscriptionStatus.active;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSub.merchant),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Subscription',
            onPressed: () => _edit(context, currentSub),
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: '100% Local')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. Top Amount & Status Hero Card ────────────────────────
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECURRING COMMITMENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? context.finColors.incomeContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                      ),
                      child: Text(
                        currentSub.status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              isActive
                                  ? context.finColors.income
                                  : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  CurrencyFormatter.formatINR(currentSub.amount),
                  style: StillwaterTypography.numHero(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Billed ${currentSub.billingFrequency.displayName.toLowerCase()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 2. Schedule & Financial Metrics ─────────────────────────
          Row(
            children: [
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT RENEWAL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        DateFormatter.formatShortDate(
                          currentSub.nextRenewalDate,
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive
                            ? (days == 0
                                ? 'Renews today'
                                : (days > 0
                                    ? 'In $days days'
                                    : '${days.abs()}d ago'))
                            : 'Plan inactive',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isActive && days <= 3
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.secondary,
                          fontWeight:
                              isActive && days <= 3
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANNUAL COST',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        CurrencyFormatter.formatINR(
                          currentSub.yearlyEquivalentAmount,
                        ),
                        style: StillwaterTypography.numMd(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Projected pace',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Plan Configuration Details ───────────────────────────
          const FfSectionHeader(title: 'Plan Details'),
          FfGroupedContainer(
            children: [
              FfListRow(
                icon: Icons.repeat_rounded,
                title: 'Billing Frequency',
                subtitle: currentSub.billingFrequency.displayName,
                showChevron: false,
              ),
              FfListRow(
                icon: Icons.account_balance_outlined,
                title: 'Linked Payment Account',
                subtitle: linkedAccount?.name ?? 'No account linked',
                showChevron: false,
              ),
              FfListRow(
                icon: Icons.notifications_active_outlined,
                title: 'Renewal Reminder',
                subtitle:
                    currentSub.isReminderEnabled
                        ? '${currentSub.reminderDaysBefore} day before renewal'
                        : 'Disabled',
                showChevron: false,
              ),
              if (currentSub.notes != null && currentSub.notes!.isNotEmpty)
                FfListRow(
                  icon: Icons.notes_rounded,
                  title: 'Notes',
                  subtitle: currentSub.notes!,
                  showChevron: false,
                ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          // ── 4. Action Buttons ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FfButton(
                  label: isActive ? 'Pause Plan' : 'Resume Plan',
                  variant: FfButtonVariant.secondary,
                  onPressed: () => _toggleStatus(context, ref, currentSub),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: FfButton(
                  label: 'Delete Plan',
                  variant: FfButtonVariant.destructive,
                  onPressed: () => _delete(context, ref, currentSub),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.space3Xl),
        ],
      ),
    );
  }
}
