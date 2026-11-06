import 'package:flutter/material.dart';

import '../../../models/alert_item.dart';
import '../../../models/loan.dart';
import '../../../models/subscription.dart';
import '../../../shared/widgets/ff_action_tile.dart';
import '../../../shared/widgets/ff_corner_badge.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Home's "Needs attention" strip: one compact tile per thing to act on,
/// each a count or due date plus one verb ("2 to review", "EMI due in 2
/// days", "Renews tomorrow", "1 budget is over plan"). Hidden when empty.
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

  static String _due(int days, String verb) =>
      days == 0
          ? '$verb today'
          : days == 1
          ? '$verb tomorrow'
          : '$verb in $days days';

  List<FfActionTile> _tiles() => [
    if (pendingReviewCount > 0)
      FfActionTile(
        key: const ValueKey('attention-review'),
        icon: Icons.rate_review_outlined,
        tone: FfTone.accent,
        corner: FfCorner.warning,
        title: '$pendingReviewCount to review',
        subtitle:
            pendingReviewCount == 1
                ? 'Imported transaction'
                : 'Imported transactions',
        onTap: onOpenNeedsReview,
      ),
    for (final loan in upcomingLoans.take(2))
      FfActionTile(
        key: ValueKey('attention-loan-${loan.id}'),
        icon: Icons.account_balance_outlined,
        tone: loan.daysUntilDue() < 0 ? FfTone.expense : FfTone.debt,
        corner: loan.daysUntilDue() < 0 ? FfCorner.warning : null,
        title:
            loan.daysUntilDue() < 0
                ? 'EMI overdue'
                : _due(loan.daysUntilDue(), 'EMI due'),
        subtitle: loan.name,
        onTap: () => onOpenLoanDetail(loan),
      ),
    for (final sub in upcomingSubscriptions.take(2))
      FfActionTile(
        key: ValueKey('attention-sub-${sub.id}'),
        icon: Icons.repeat_rounded,
        tone: FfTone.neutral,
        title: _due(sub.daysUntilRenewal(), 'Renews'),
        subtitle: sub.merchant,
        onTap: onOpenSubscriptions,
      ),
    if (overBudgetCount > 0)
      FfActionTile(
        key: const ValueKey('attention-budgets'),
        icon: Icons.pie_chart_outline_rounded,
        tone: FfTone.expense,
        corner: FfCorner.warning,
        title:
            overBudgetCount == 1
                ? '1 budget is over plan'
                : '$overBudgetCount budgets are over plan',
        subtitle: 'See your plan',
        onTap: onOpenBudgets,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles();
    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          child: FfSectionHeader(
            title: 'Needs attention',
            count: tiles.length,
            padding: FfSectionHeader.sectionPadding,
          ),
        ),
        FfActionStrip(tiles: tiles),
      ],
    );
  }
}
