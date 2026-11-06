import 'package:flutter/material.dart';

import '../../../models/alert_item.dart';
import '../../../models/loan.dart';
import '../../../models/subscription.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_corner_badge.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

class _ActionableRowData {
  final String id;
  final IconData icon;
  final FfTone tone;
  final FfCorner? corner;
  final String title;
  final String? subtitle;
  final double? amount;
  final String? badgeText;
  final VoidCallback onTap;

  const _ActionableRowData({
    required this.id,
    required this.icon,
    required this.tone,
    this.corner,
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

  List<_ActionableRowData> _buildItems() {
    final items = <_ActionableRowData>[];

    // 1. Pending Review Imports
    if (pendingReviewCount > 0) {
      items.add(
        _ActionableRowData(
          id: 'pending_review',
          icon: Icons.rate_review_outlined,
          tone: FfTone.accent,
          corner: FfCorner.warning,
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
        _ActionableRowData(
          id: 'loan_${loan.id}',
          icon: Icons.account_balance_outlined,
          tone: isOverdue ? FfTone.expense : FfTone.debt,
          corner: isOverdue ? FfCorner.warning : null,
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
        _ActionableRowData(
          id: 'sub_${sub.id}',
          icon: Icons.repeat_rounded,
          tone: FfTone.neutral,
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
        _ActionableRowData(
          id: 'over_budget',
          icon: Icons.pie_chart_outline_rounded,
          tone: FfTone.expense,
          corner: FfCorner.warning,
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
    final items = _buildItems();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Actionable & Upcoming',
            padding: const EdgeInsets.only(bottom: FfSpace.xs),
            trailing:
                items.length > 2
                    ? Text(
                      '${items.length} items',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.textSecondary,
                      ),
                    )
                    : null,
          ),
          FfGroupedContainer(
            dividerInset: FfRowLeading.tile,
            children: [
              for (final item in items)
                FfRow(
                  leading: FfIconTile(
                    icon: item.icon,
                    tone: item.tone,
                    corner: item.corner,
                  ),
                  title: item.title,
                  subtitle: item.subtitle,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.badgeText != null) ...[
                        FfBadge(label: item.badgeText!, tone: item.tone),
                        if (item.amount != null)
                          const SizedBox(width: FfSpace.xs),
                      ],
                      if (item.amount != null)
                        FfAmountText(
                          amount: item.amount!,
                          size: FfAmountSize.sm,
                          style: FfAmountStyle.inline,
                          isBlurred: isPrivacyBlur,
                          showSign: false,
                          tone: FfTone.neutral,
                        ),
                    ],
                  ),
                  showChevron: true,
                  onTap: item.onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
