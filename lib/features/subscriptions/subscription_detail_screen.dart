import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/app_settings.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_monogram_tile.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../settings/settings_controller.dart';
import '../transactions/add_edit_transaction_screen.dart';
import 'add_edit_subscription_sheet.dart';
import 'subscriptions_controller.dart';
import 'widgets/subscription_payment_history_section.dart';

/// The Stillwater Bloom Subscription Detail Screen (Pattern D, Sand Hero).
///
/// Features:
/// 1. Sand `FfHeroCard` with renewal progress ring wrapping generative monogram,
///    oversized light amount, and 3 hero figures (Monthly equiv, Annual pace, Total paid).
/// 2. Inline reminder chips (1d, 3d, 7d, Off) that immediately update notification preference.
/// 3. Plan details `FfGroupedContainer` for account, category, and cadence.
/// 4. 12-month visual payment history (`FfMonthGrid`) with price change banner.
/// 5. Ink primary "Record payment" button and separated destructive delete.
class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  static Future<T?> push<T>(
    BuildContext context, {
    required Subscription subscription,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (ctx) => SubscriptionDetailScreen(subscription: subscription),
      ),
    );
  }

  void _edit(BuildContext context, Subscription currentSub) {
    showFfSheet(
      context,
      builder: (_) => AddEditSubscriptionSheet(initialSubscription: currentSub),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Subscription currentSub,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Subscription?',
      message:
          'Are you sure you want to stop tracking "${currentSub.merchant}" on this device? Past recorded transactions will not be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(subscriptionsControllerProvider.notifier)
          .deleteSubscription(currentSub.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Subscription removed.');
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
      FfToast.show(
        context,
        message:
            newStatus == SubscriptionStatus.active
                ? 'Subscription resumed.'
                : 'Subscription paused.',
      );
    }
  }

  Future<void> _updateReminder(
    BuildContext context,
    WidgetRef ref,
    Subscription currentSub, {
    required bool enabled,
    required int daysBefore,
  }) async {
    final updated = currentSub.copyWith(
      isReminderEnabled: enabled,
      reminderDaysBefore: daysBefore,
      updatedAt: DateTime.now(),
    );
    await ref
        .read(subscriptionsControllerProvider.notifier)
        .updateSubscription(updated);
    if (context.mounted) {
      FfToast.show(
        context,
        message:
            enabled
                ? 'Reminder set: $daysBefore ${daysBefore == 1 ? 'day' : 'days'} before renewal.'
                : 'Reminder disabled.',
      );
    }
  }

  double _computeCycleProgress(Subscription sub) {
    if (sub.status != SubscriptionStatus.active) return 0.0;
    if (sub.lastPaymentDate != null) {
      final totalDays =
          sub.nextRenewalDate.difference(sub.lastPaymentDate!).inDays;
      if (totalDays > 0) {
        final elapsed = DateTime.now().difference(sub.lastPaymentDate!).inDays;
        return (elapsed / totalDays).clamp(0.0, 1.0);
      }
    }
    final cycleLength = switch (sub.billingFrequency) {
      SubscriptionFrequency.weekly => 7,
      SubscriptionFrequency.monthly => 30,
      SubscriptionFrequency.quarterly => 90,
      SubscriptionFrequency.yearly => 365,
      SubscriptionFrequency.custom => 30,
    };
    final daysLeft = sub.daysUntilRenewal();
    final elapsed = cycleLength - daysLeft;
    return (elapsed / cycleLength).clamp(0.0, 1.0);
  }

  String _formatStatusInWords(Subscription sub) {
    if (sub.status == SubscriptionStatus.paused) {
      return 'Paused · Next renewal postponed';
    }
    if (sub.status == SubscriptionStatus.cancelled) {
      return 'Cancelled · No upcoming charges';
    }
    final days = sub.daysUntilRenewal();
    final dateStr = DateFormatter.formatShortDate(sub.nextRenewalDate);
    if (days == 0) return 'Renews today · $dateStr';
    if (days == 1) return 'Renews tomorrow · $dateStr';
    if (days > 1) return 'Renews in $days days · $dateStr';
    return 'Overdue by ${days.abs()} days · $dateStr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ff = context.ff;

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

    final paymentTotals = ref.watch(
      subscriptionPaymentsTotalProvider(currentSub.id),
    );
    final recentPayments =
        ref.watch(subscriptionPaymentsStreamProvider(currentSub.id)).value ??
        [];

    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final isPrivacyBlur = settings.isPrivacyBlurEnabled;

    final isActive = currentSub.status == SubscriptionStatus.active;
    final cycleProgress = _computeCycleProgress(currentSub);
    final statusWords = _formatStatusInWords(currentSub);

    final frequencySuffix = switch (currentSub.billingFrequency) {
      SubscriptionFrequency.weekly => '/wk',
      SubscriptionFrequency.monthly => '/mo',
      SubscriptionFrequency.quarterly => '/qtr',
      SubscriptionFrequency.yearly => '/yr',
      SubscriptionFrequency.custom => '',
    };

    return Scaffold(
      appBar: FfAppBar(
        title: currentSub.merchant,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Subscription',
            onPressed: () => _edit(context, currentSub),
          ),
          const Padding(
            padding: EdgeInsets.only(right: FfSpace.md),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.pageMargin,
          FfSpace.sm,
          FfSpace.pageMargin,
          112,
        ),
        children: [
          // ── 1. Sand Hero Card (Pattern D) ───────────────────────────
          FfHeroCard(
            tone: isActive ? FfHeroTone.sand : FfHeroTone.dusk,
            leading:
                isActive
                    ? FfProgressRing(
                      value: cycleProgress,
                      size: 48,
                      semanticsLabel:
                          '${(cycleProgress * 100).round()}% of billing cycle elapsed',
                      color: ff.color.actionPrimary,
                      child: FfMonogramTile(
                        name: currentSub.merchant,
                        size: 34,
                        radius: FfRadius.md,
                      ),
                    )
                    : FfMonogramTile(
                      name: currentSub.merchant,
                      size: 48,
                      radius: FfRadius.md,
                    ),
            title:
                '${currentSub.billingFrequency.displayName.toUpperCase()} PLAN',
            subtitle: statusWords,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    FfAmountText(
                      amount: currentSub.amount,
                      size: FfAmountSize.hero,
                      style: FfAmountStyle.split,
                      isBlurred: isPrivacyBlur,
                    ),
                    if (frequencySuffix.isNotEmpty) ...[
                      const SizedBox(width: FfSpace.x2s),
                      Text(
                        frequencySuffix,
                        style: ff.text.titleSm.copyWith(
                          color: ff.color.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: FfSpace.md),
                FfHeroFigures([
                  FfHeroFigure(
                    'Monthly equiv',
                    isPrivacyBlur
                        ? '••••'
                        : CurrencyFormatter.formatAmount(
                          currentSub.monthlyEquivalentAmount,
                        ),
                  ),
                  FfHeroFigure(
                    'Annual pace',
                    isPrivacyBlur
                        ? '••••'
                        : CurrencyFormatter.formatAmount(
                          currentSub.yearlyEquivalentAmount,
                        ),
                  ),
                  FfHeroFigure(
                    'Total paid',
                    isPrivacyBlur
                        ? '••••'
                        : CurrencyFormatter.formatAmount(
                          paymentTotals.totalPaid,
                        ),
                  ),
                ]),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 2. Inline Reminder Chips ────────────────────────────────
          const FfSectionHeader(title: 'Renewal Reminder'),
          const SizedBox(height: FfSpace.xs),
          FfCard(
            padding: const EdgeInsets.all(FfSpace.md),
            child: Wrap(
              spacing: FfSpace.xs,
              runSpacing: FfSpace.xs,
              children: [
                FfChip(
                  label: '1 day before',
                  isSelected:
                      currentSub.isReminderEnabled &&
                      currentSub.reminderDaysBefore == 1,
                  onSelected:
                      () => _updateReminder(
                        context,
                        ref,
                        currentSub,
                        enabled: true,
                        daysBefore: 1,
                      ),
                ),
                FfChip(
                  label: '3 days before',
                  isSelected:
                      currentSub.isReminderEnabled &&
                      currentSub.reminderDaysBefore == 3,
                  onSelected:
                      () => _updateReminder(
                        context,
                        ref,
                        currentSub,
                        enabled: true,
                        daysBefore: 3,
                      ),
                ),
                FfChip(
                  label: '7 days before',
                  isSelected:
                      currentSub.isReminderEnabled &&
                      currentSub.reminderDaysBefore == 7,
                  onSelected:
                      () => _updateReminder(
                        context,
                        ref,
                        currentSub,
                        enabled: true,
                        daysBefore: 7,
                      ),
                ),
                FfChip(
                  label: 'Off',
                  isSelected: !currentSub.isReminderEnabled,
                  onSelected:
                      () => _updateReminder(
                        context,
                        ref,
                        currentSub,
                        enabled: false,
                        daysBefore: currentSub.reminderDaysBefore,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 3. Plan Configuration Details ───────────────────────────
          const FfSectionHeader(title: 'Plan Details'),
          const SizedBox(height: FfSpace.xs),
          FfGroupedContainer(
            children: [
              FfRow(
                icon: Icons.event_repeat_rounded,
                iconTone: FfTone.primary,
                title: 'Billing Cadence',
                subtitle:
                    '${currentSub.billingFrequency.displayName} · Next ${DateFormatter.formatShortDate(currentSub.nextRenewalDate)}',
                showChevron: false,
              ),
              FfRow(
                icon: Icons.category_outlined,
                iconTone: FfTone.primary,
                title: 'Category',
                subtitle: currentSub.category,
                showChevron: false,
              ),
              FfRow(
                icon: Icons.account_balance_outlined,
                iconTone: FfTone.primary,
                title: 'Linked Payment Account',
                subtitle: linkedAccount?.name ?? 'No account linked',
                showChevron: false,
              ),
              if (currentSub.notes != null && currentSub.notes!.isNotEmpty)
                FfRow(
                  icon: Icons.notes_rounded,
                  iconTone: FfTone.primary,
                  title: 'Notes',
                  subtitle: currentSub.notes!,
                  showChevron: false,
                ),
            ],
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 4. Payment History (12-Mo Grid + Transactions) ──────────
          SubscriptionPaymentHistorySection(
            subscription: currentSub,
            payments: recentPayments,
            paymentTotals: paymentTotals,
            isPrivacyBlur: isPrivacyBlur,
          ),

          const SizedBox(height: FfSpace.xl),

          // ── 5. Primary Action: Record Payment ────────────────────────
          FfButton(
            label: 'Record payment',
            variant: FfButtonVariant.primary,
            leadingIcon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () {
              AddEditTransactionScreen.push<void>(
                context,
                initialTransaction: Transaction(
                  id: '',
                  amount: currentSub.amount,
                  type: TransactionType.expense,
                  purpose: TransactionPurpose.subscriptionPayment,
                  categoryId: 'cat_subscriptions',
                  categoryName: 'Subscriptions',
                  categoryIcon: 'subscriptions',
                  categoryColor: 'indigo',
                  merchant: currentSub.merchant,
                  date: DateTime.now(),
                  accountId: currentSub.accountId ?? '',
                  linkedSubscriptionId: currentSub.id,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
            },
          ),

          const SizedBox(height: FfSpace.sm),

          // ── 6. Secondary Actions: Pause/Resume & Edit ────────────────
          Row(
            children: [
              Expanded(
                child: FfButton(
                  label: isActive ? 'Pause Plan' : 'Resume Plan',
                  variant: FfButtonVariant.secondary,
                  leadingIcon: Icon(
                    isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 18,
                  ),
                  onPressed: () => _toggleStatus(context, ref, currentSub),
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfButton(
                  label: 'Edit Plan',
                  variant: FfButtonVariant.secondary,
                  leadingIcon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _edit(context, currentSub),
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 7. Destructive Action: Delete Plan ───────────────────────
          Center(
            child: FfButton(
              label: 'Delete Subscription',
              variant: FfButtonVariant.destructive,
              leadingIcon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () => _delete(context, ref, currentSub),
            ),
          ),
        ],
      ),
    );
  }
}
