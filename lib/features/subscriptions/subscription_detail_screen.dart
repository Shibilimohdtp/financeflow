import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_typography.dart';
import '../transactions/add_edit_transaction_screen.dart';
import '../transactions/transaction_detail_screen.dart';
import 'add_edit_subscription_sheet.dart';
import 'subscriptions_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_row.dart';
import '../../theme/ff_tone.dart';
import '../../theme/ff.dart';

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
          'Are you sure you want to stop tracking "${currentSub.merchant}" on this device?',
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

    final paymentTotals = ref.watch(
      subscriptionPaymentsTotalProvider(currentSub.id),
    );
    final recentPayments =
        ref.watch(subscriptionPaymentsStreamProvider(currentSub.id)).value ??
        [];
    final displayPayments = recentPayments.take(5).toList();

    final days = currentSub.daysUntilRenewal();
    final isActive = currentSub.status == SubscriptionStatus.active;

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
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
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
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.sm,
                        vertical: FfSpace.x3s,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? context.ff.color.moneyIncomeContainer
                                : context.ff.color.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(FfRadius.full),
                      ),
                      child: Text(
                        currentSub.status.displayName,
                        style: context.ff.text.labelSm.copyWith(
                          color:
                              isActive
                                  ? context.ff.color.moneyIncome
                                  : context.ff.color.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.xs),
                Text(
                  CurrencyFormatter.formatAmount(currentSub.amount),
                  style: StillwaterTypography.numHero(
                    color: context.ff.color.textPrimary,
                  ),
                ),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  'Billed ${currentSub.billingFrequency.displayName.toLowerCase()}',
                  style: context.ff.text.body.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 2. Schedule & Financial Metrics ─────────────────────────
          Row(
            children: [
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT RENEWAL',
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.xs),
                      Text(
                        DateFormatter.formatShortDate(
                          currentSub.nextRenewalDate,
                        ),
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        isActive
                            ? (days == 0
                                ? 'Renews today'
                                : (days > 0
                                    ? 'In $days days'
                                    : '${days.abs()}d ago'))
                            : 'Plan inactive',
                        style: context.ff.text.bodySm.copyWith(
                          color:
                              isActive && days <= 3
                                  ? context.ff.color.statusWarning
                                  : context.ff.color.secondary,
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
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANNUAL COST',
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.xs),
                      Text(
                        CurrencyFormatter.formatAmount(
                          currentSub.yearlyEquivalentAmount,
                        ),
                        style: StillwaterTypography.numMd(
                          color: context.ff.color.actionPrimary,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        'Projected pace',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 3. Plan Configuration Details ───────────────────────────
          const FfSectionHeader(title: 'Plan Details'),
          FfGroupedContainer(
            children: [
              FfRow(
                icon: Icons.repeat_rounded,
                iconTone: FfTone.primary,
                title: 'Billing Frequency',
                subtitle: currentSub.billingFrequency.displayName,
                showChevron: false,
              ),
              FfRow(
                icon: Icons.account_balance_outlined,
                iconTone: FfTone.primary,
                title: 'Linked Payment Account',
                subtitle: linkedAccount?.name ?? 'No account linked',
                showChevron: false,
              ),
              FfRow(
                icon: Icons.notifications_active_outlined,
                iconTone: FfTone.primary,
                title: 'Renewal Reminder',
                subtitle:
                    currentSub.isReminderEnabled
                        ? '${currentSub.reminderDaysBefore} day before renewal'
                        : 'Disabled',
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

          const SizedBox(height: FfSpace.xl),

          // ── 4. Payment History ─────────────────────────────────────
          const FfSectionHeader(title: 'Payment History'),
          FfCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary row
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FfSpace.lg,
                    FfSpace.md,
                    FfSpace.lg,
                    FfSpace.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.formatAmount(
                                paymentTotals.totalPaid,
                              ),
                              style: StillwaterTypography.numHero(
                                color: context.ff.color.textPrimary,
                              ).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Total paid · ${paymentTotals.count} payment${paymentTotals.count == 1 ? '' : 's'}',
                              style: context.ff.text.bodySm.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paymentTotals.lastPaymentDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last paid',
                              style: context.ff.text.labelSm.copyWith(
                                color: context.ff.color.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DateFormatter.formatShortDate(
                                paymentTotals.lastPaymentDate!,
                              ),
                              style: context.ff.text.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (displayPayments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      FfSpace.lg,
                      FfSpace.x2s,
                      FfSpace.lg,
                      FfSpace.md,
                    ),
                    child: Text(
                      'No payments recorded yet. Use "Record payment" to link a manual payment.',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.textSecondary,
                      ),
                    ),
                  )
                else
                  ...displayPayments.map(
                    (tx) => _buildPaymentRow(context, tx, theme),
                  ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.md),

          // Record Payment button
          FfButton(
            label: 'Record payment',
            variant: FfButtonVariant.secondary,
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

          const SizedBox(height: FfSpace.xl),

          // ── 5. Action Buttons ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FfButton(
                  label: isActive ? 'Pause Plan' : 'Resume Plan',
                  variant: FfButtonVariant.secondary,
                  onPressed: () => _toggleStatus(context, ref, currentSub),
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfButton(
                  label: 'Delete Plan',
                  variant: FfButtonVariant.destructive,
                  onPressed: () => _delete(context, ref, currentSub),
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.x3l),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    Transaction tx,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transaction: tx),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatShortDate(tx.date),
                    style: context.ff.text.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (tx.notes != null && tx.notes!.isNotEmpty)
                    Text(
                      tx.notes!,
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            FfAmountText(
              amount: tx.amount,
              type: TransactionType.expense,
              size: FfAmountSize.sm,
            ),
            const SizedBox(width: FfSpace.x2s),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: context.ff.color.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
