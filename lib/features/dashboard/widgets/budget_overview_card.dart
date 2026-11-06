import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/budget.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_skeleton_loader.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Where this month's spending stands against plan.
enum BudgetPace { onPace, fast, over }

/// Home's budget card (DS-B12c; DS-B7d reuses it): "Left to spend" as the key
/// figure, a pace bar (where spending is vs where it should be today), a
/// status badge in words, and the 2–3 budgets that need attention. With no
/// budgets it invites setup instead of disappearing.
class BudgetOverviewCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;
  final int overBudgetCount;
  final List<BudgetSummary>? activeBudgets;
  final bool isPrivacyBlur;
  final VoidCallback onViewBudgets;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overBudgetCount,
    this.activeBudgets,
    this.isPrivacyBlur = false,
    required this.onViewBudgets,
  });

  /// Share of the plan that should be spent by today, weighted by each
  /// budget's limit, or null when no budget reports its days.
  static double? paceOf(List<BudgetSummary>? budgets) {
    if (budgets == null || budgets.isEmpty) return null;
    var limit = 0.0;
    var expected = 0.0;
    for (final b in budgets) {
      if (b.totalDaysInPeriod <= 0) continue;
      limit += b.budget.amountLimit;
      expected +=
          b.budget.amountLimit *
          (b.daysElapsed / b.totalDaysInPeriod).clamp(0.0, 1.0);
    }
    return limit > 0 ? expected / limit : null;
  }

  static BudgetPace paceStatus(double spent, double budgeted, double? pace) {
    if (spent > budgeted) return BudgetPace.over;
    if (pace != null && budgeted > 0 && spent / budgeted > pace + 0.05) {
      return BudgetPace.fast;
    }
    return BudgetPace.onPace;
  }

  /// Budgets that are over or close to their limit, worst first.
  static List<BudgetSummary> needingAttention(List<BudgetSummary>? budgets) {
    final list =
        (budgets ?? const <BudgetSummary>[])
            .where((b) => b.isExceeded || b.isApproachingThreshold)
            .toList()
          ..sort((a, b) {
            if (a.isExceeded != b.isExceeded) return a.isExceeded ? -1 : 1;
            return b.percentageUsed.compareTo(a.percentageUsed);
          });
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final header = FfSectionHeader(
      title: 'Budgets',
      count: activeBudgets?.length,
      padding: FfSectionHeader.sectionPadding,
      trailing: FfSectionLink(
        label: 'See all',
        semanticLabel: 'See all budgets',
        onPressed: onViewBudgets,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (totalBudgeted <= 0)
            _SetupCard(onSetup: onViewBudgets)
          else
            _summary(context),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final pace = paceOf(activeBudgets);
    final status = paceStatus(totalSpent, totalBudgeted, pace);
    final isOver = status == BudgetPace.over;
    final attention = needingAttention(activeBudgets);
    final daysLeft =
        activeBudgets?.isNotEmpty == true
            ? activeBudgets!.first.daysRemaining
            : 0;
    final perDay = !isOver && daysLeft > 0 ? totalRemaining / daysLeft : null;
    final used = totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0;

    final (statusLabel, statusIcon, statusTone) = switch (status) {
      BudgetPace.over => (
        overBudgetCount > 1 ? '$overBudgetCount over plan' : 'Over plan',
        Icons.error_outline_rounded,
        FfTone.expense,
      ),
      BudgetPace.fast => ('Spending fast', Icons.speed_rounded, FfTone.warning),
      BudgetPace.onPace => ('On pace', Icons.check_rounded, FfTone.success),
    };

    final spoken =
        isPrivacyBlur
            ? 'Budgets this month, amounts hidden. $statusLabel'
            : isOver
            ? 'Budgets this month: over by '
                '${CurrencyFormatter.format(totalSpent - totalBudgeted)}. '
                'Spent ${CurrencyFormatter.format(totalSpent)} of '
                '${CurrencyFormatter.format(totalBudgeted)}. $statusLabel'
            : 'Budgets this month: ${CurrencyFormatter.format(totalRemaining)} '
                'left to spend of ${CurrencyFormatter.format(totalBudgeted)}. '
                '$statusLabel';

    return FfCard(
      key: const ValueKey('home-budgets'),
      density: FfDensity.comfortable,
      padding: EdgeInsets.zero,
      onTap: onViewBudgets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: spoken,
            excludeSemantics: true,
            child: Padding(
              padding: EdgeInsets.all(FfDensity.comfortable.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOver ? 'Over plan by' : 'Left to spend',
                              style: ff.text.label.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            FfAmountText(
                              amount:
                                  isOver
                                      ? totalSpent - totalBudgeted
                                      : totalRemaining,
                              size: FfAmountSize.lg,
                              style: FfAmountStyle.split,
                              tone: isOver ? FfTone.expense : FfTone.neutral,
                              isBlurred: isPrivacyBlur,
                            ),
                          ],
                        ),
                      ),
                      FfBadge(
                        label: statusLabel,
                        icon: statusIcon,
                        tone: statusTone,
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfProgressBar(
                    value: used.clamp(0.0, 1.0),
                    pace: pace,
                    tone: isOver ? FfTone.expense : null,
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _SpentOfLimit(
                          spent: totalSpent,
                          limit: totalBudgeted,
                          isBlurred: isPrivacyBlur,
                        ),
                      ),
                      if (perDay != null && !isPrivacyBlur)
                        Flexible(
                          child: Text(
                            '${CurrencyFormatter.format(perDay.floorToDouble())} a day',
                            style: ff.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (attention.isNotEmpty) ...[
            const FfDivider(),
            for (final b in attention)
              FfRow(
                leading:
                    b.budget.categoryIcon != null
                        ? FfCategoryTile(
                          iconIdentifier: b.budget.categoryIcon!,
                          colorTokenIdentifier:
                              b.budget.categoryColor ?? 'blue',
                        )
                        : const FfIconTile(
                          icon: Icons.pie_chart_outline_rounded,
                        ),
                title: b.budget.name,
                subtitle:
                    isPrivacyBlur
                        ? '${(b.percentageUsed * 100).round()}% used'
                        : '${CurrencyFormatter.format(b.amountSpent)} of '
                            '${CurrencyFormatter.format(b.budget.amountLimit)}',
                trailing: FfBadge(
                  label: b.isExceeded ? 'Over' : 'Near limit',
                  icon:
                      b.isExceeded
                          ? Icons.error_outline_rounded
                          : Icons.warning_amber_rounded,
                  tone: b.isExceeded ? FfTone.expense : FfTone.warning,
                ),
                onTap: onViewBudgets,
              ),
            const SizedBox(height: FfSpace.xs),
          ],
        ],
      ),
    );
  }
}

class _SpentOfLimit extends StatelessWidget {
  final double spent;
  final double limit;
  final bool isBlurred;

  const _SpentOfLimit({
    required this.spent,
    required this.limit,
    required this.isBlurred,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final quiet = ff.text.bodySm.copyWith(color: ff.color.textSecondary);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FfAmountText(
          amount: spent,
          size: FfAmountSize.sm,
          style: FfAmountStyle.inline,
          tone: FfTone.neutral,
          isBlurred: isBlurred,
        ),
        Text(' of ', style: quiet),
        FfAmountText(
          amount: limit,
          size: FfAmountSize.sm,
          style: FfAmountStyle.inline,
          tone: FfTone.neutral,
          isBlurred: isBlurred,
        ),
        Text(' spent', style: quiet),
      ],
    );
  }
}

class _SetupCard extends StatelessWidget {
  final VoidCallback onSetup;

  const _SetupCard({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return FfCard(
      key: const ValueKey('home-budgets-setup'),
      density: FfDensity.comfortable,
      onTap: onSetup,
      child: Row(
        children: [
          const FfIconTile(
            icon: Icons.pie_chart_outline_rounded,
            tone: FfTone.primary,
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan this month', style: ff.text.titleSm),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  'Set limits for what you spend most on and see your pace here.',
                  style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
                ),
                const SizedBox(height: FfSpace.sm),
                FfButton(
                  label: 'Set up budgets',
                  size: FfButtonSize.sm,
                  onPressed: onSetup,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading shape of [BudgetOverviewCard].
class BudgetOverviewCardSkeleton extends StatelessWidget {
  const BudgetOverviewCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const FfCard(
      density: FfDensity.comfortable,
      child: FfSkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FfSkeletonBlock(width: FfSpace.x4l * 2, height: FfSpace.sm),
            SizedBox(height: FfSpace.xs),
            FfSkeletonBlock(width: FfSpace.x4l * 3, height: FfSpace.x3l),
            SizedBox(height: FfSpace.md),
            FfSkeletonBlock(height: FfSpace.xs),
            SizedBox(height: FfSpace.xs),
            FfSkeletonBlock(width: FfSpace.x4l * 3, height: FfSpace.sm),
          ],
        ),
      ),
    );
  }
}
