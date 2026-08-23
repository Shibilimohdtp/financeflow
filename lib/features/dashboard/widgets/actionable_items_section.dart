import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/alert_item.dart';
import '../../../models/loan.dart';
import '../../../models/subscription.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';

class ActionableItemData {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String title;
  final String? subtitle;
  final double? amount;
  final String? badgeText;
  final VoidCallback onTap;

  const ActionableItemData({
    required this.id,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    required this.title,
    this.subtitle,
    this.amount,
    this.badgeText,
    required this.onTap,
  });
}

class ActionableItemsSection extends StatelessWidget {
  final int pendingReviewCount;
  final List<Loan> upcomingLoans;
  final List<Subscription> upcomingSubscriptions;
  final int overBudgetCount;
  final List<AlertItem> activeAlerts;
  final bool isPrivacyBlur;
  final VoidCallback onOpenNeedsReview;
  final ValueChanged<Loan> onOpenLoanDetail;
  final VoidCallback onOpenLoans;
  final VoidCallback onOpenSubscriptions;
  final VoidCallback onOpenBudgets;
  final VoidCallback onOpenAlerts;

  const ActionableItemsSection({
    super.key,
    this.pendingReviewCount = 0,
    this.upcomingLoans = const [],
    this.upcomingSubscriptions = const [],
    this.overBudgetCount = 0,
    this.activeAlerts = const [],
    required this.isPrivacyBlur,
    required this.onOpenNeedsReview,
    required this.onOpenLoanDetail,
    required this.onOpenLoans,
    required this.onOpenSubscriptions,
    required this.onOpenBudgets,
    required this.onOpenAlerts,
  });

  List<ActionableItemData> _buildActionableItems(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;
    final aiColors = context.aiColors;
    final items = <ActionableItemData>[];

    // 1. Pending Review Imports
    if (pendingReviewCount > 0) {
      items.add(
        ActionableItemData(
          id: 'pending_review',
          icon: Icons.rate_review_outlined,
          iconColor: aiColors.accent,
          backgroundColor: aiColors.accent.withValues(alpha: 0.10),
          title:
              pendingReviewCount == 1
                  ? '1 imported transaction needs review'
                  : '$pendingReviewCount imported transactions need review',
          subtitle: 'Verify merchant and category',
          onTap: onOpenNeedsReview,
        ),
      );
    }

    // 2. Upcoming or Overdue EMIs
    for (final loan in upcomingLoans.take(2)) {
      final days = loan.daysUntilDue();
      final isOverdue = days < 0;
      final badge =
          isOverdue
              ? 'Overdue'
              : days == 0
              ? 'Due today'
              : days == 1
              ? 'Due tomorrow'
              : 'Due in $days days';

      items.add(
        ActionableItemData(
          id: 'loan_${loan.id}',
          icon: Icons.account_balance_outlined,
          iconColor: isOverdue ? finColors.expense : finColors.debt,
          backgroundColor: (isOverdue ? finColors.expense : finColors.debt)
              .withValues(alpha: 0.10),
          title: '${loan.name} (${loan.lender})',
          subtitle: badge,
          amount: loan.emiAmount,
          badgeText: isOverdue ? 'Overdue' : null,
          onTap: () => onOpenLoanDetail(loan),
        ),
      );
    }

    // 3. Upcoming Subscriptions (Due soon)
    for (final sub in upcomingSubscriptions.take(2)) {
      final days = sub.daysUntilRenewal();
      final dueText =
          days == 0
              ? 'Renews today'
              : days == 1
              ? 'Renews tomorrow'
              : 'Renews in $days days';

      items.add(
        ActionableItemData(
          id: 'sub_${sub.id}',
          icon: Icons.repeat_rounded,
          iconColor: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.10),
          title: sub.merchant,
          subtitle: dueText,
          amount: sub.amount,
          onTap: onOpenSubscriptions,
        ),
      );
    }

    // 4. Over Budget Notice
    if (overBudgetCount > 0) {
      items.add(
        ActionableItemData(
          id: 'over_budget',
          icon: Icons.pie_chart_outline_rounded,
          iconColor: finColors.expense,
          backgroundColor: finColors.expense.withValues(alpha: 0.10),
          title:
              overBudgetCount == 1
                  ? '1 budget reached limit'
                  : '$overBudgetCount budgets exceeded planned limits',
          subtitle: 'Review monthly category budgets',
          onTap: onOpenBudgets,
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final items = _buildActionableItems(context);

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actionable & Upcoming',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              if (items.length > 2)
                Text(
                  '${items.length} items',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(height: StillwaterTokens.spaceXs),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, theme, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ThemeData theme,
    ActionableItemData item,
  ) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceMd,
            vertical: StillwaterTokens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      item.backgroundColor ??
                      item.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                ),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: StillwaterTokens.space3Xs),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (item.amount != null) ...[
                const SizedBox(width: StillwaterTokens.spaceSm),
                FfAmountText(
                  amount: item.amount!,
                  size: FfAmountSize.sm,
                  isBlurred: isPrivacyBlur,
                  showSign: false,
                  colorOverride: theme.colorScheme.onSurface,
                ),
              ],
              const SizedBox(width: StillwaterTokens.spaceXs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
