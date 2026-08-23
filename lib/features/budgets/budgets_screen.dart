import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/budget.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../dashboard/dashboard_controller.dart';
import 'add_edit_budget_sheet.dart';
import 'budget_detail_screen.dart';
import 'budgets_controller.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _add(BuildContext context) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => const AddEditBudgetSheet(),
  );

  void _month(WidgetRef ref, DateTime value) {
    ref.read(selectedDashboardMonthProvider.notifier).state = DateTime(value.year, value.month, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final month = ref.watch(selectedDashboardMonthProvider);
    final summaries = ref.watch(budgetSummariesProvider);
    final overall = ref.watch(overallBudgetSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets'), actions: const [
        Padding(padding: EdgeInsets.only(right: StillwaterTokens.spaceLg), child: Center(child: FfPrivacyBadge(label: 'On-device'))),
      ]),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async { ref.invalidate(activeBudgetsStreamProvider); ref.invalidate(budgetSummariesProvider); ref.invalidate(overallBudgetSummaryProvider); },
        child: ListView(padding: const EdgeInsets.fromLTRB(StillwaterTokens.spaceLg, StillwaterTokens.spaceMd, StillwaterTokens.spaceLg, 120), children: [
          _MonthSelector(month: month, onPrevious: () => _month(ref, DateTime(month.year, month.month - 1)), onNext: () => _month(ref, DateTime(month.year, month.month + 1)), onPick: () async {
            final picked = await showDatePicker(context: context, initialDate: month, firstDate: DateTime(2020), lastDate: DateTime(2035), helpText: 'Select budget month');
            if (picked != null && context.mounted) _month(ref, picked);
          }),
          const SizedBox(height: StillwaterTokens.spaceXl),
          AnimatedSwitcher(duration: StillwaterTokens.durationBase, child: overall.when(
            data: (value) => value.totalBudgeted <= 0 ? const SizedBox.shrink(key: ValueKey('no-overview')) : _OverviewCard(key: ValueKey('${month.year}-${month.month}'), value: value),
            loading: () => const SizedBox.shrink(key: ValueKey('overview-loading')),
            error: (_, __) => const SizedBox.shrink(key: ValueKey('overview-error')),
          )),
          const SizedBox(height: StillwaterTokens.spaceLg),
          const FfSectionHeader(title: 'Category Budgets'),
          AnimatedSwitcher(duration: StillwaterTokens.durationBase, child: _BudgetList(key: ValueKey('list-${month.year}-${month.month}'), summaries: summaries, onOpen: (b) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BudgetDetailScreen(budget: b))), onCreate: () => _add(context))),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: 'budgets_add_fab', tooltip: 'Add budget', onPressed: () => _add(context), icon: const Icon(Icons.add_rounded), label: const Text('Add Budget')),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month, required this.onPrevious, required this.onNext, required this.onPick});
  final DateTime month; final VoidCallback onPrevious; final VoidCallback onNext; final VoidCallback onPick;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme; final label = DateFormat('MMMM yyyy').format(month);
    return Semantics(container: true, label: 'Budget month: $label', child: Container(
      constraints: const BoxConstraints(minHeight: 64), padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceXs),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .42), borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg), border: Border.all(color: theme.dividerColor.withValues(alpha: .7), width: StillwaterTokens.borderWidthHairline)),
      child: Row(children: [
        _MonthButton(icon: Icons.chevron_left_rounded, label: 'Previous month', onPressed: onPrevious),
        Expanded(child: Semantics(button: true, label: 'Choose budget month, currently $label', child: InkWell(onTap: onPick, borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd), child: SizedBox(height: StillwaterTokens.touchTargetMin, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.calendar_month_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: StillwaterTokens.spaceSm), Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: theme.textTheme.titleMedium)), const SizedBox(width: StillwaterTokens.space2Xs), Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: theme.colorScheme.secondary),
        ]))))),
        _MonthButton(icon: Icons.chevron_right_rounded, label: 'Next month', onPressed: onNext),
      ]),
    ));
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.label, required this.onPressed}); final IconData icon; final String label; final VoidCallback onPressed;
  @override Widget build(BuildContext context) => Semantics(button: true, label: label, child: IconButton(onPressed: onPressed, tooltip: label, icon: Icon(icon), constraints: const BoxConstraints(minWidth: 48, minHeight: 48)));
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({super.key, required this.value});
  final ({double totalBudgeted, double totalSpent, double totalRemaining, int overBudgetCount}) value;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme; final colors = context.finColors; final exceeded = value.totalSpent > value.totalBudgeted; final progress = (value.totalSpent / value.totalBudgeted).clamp(0.0, 1.0);
    return FfCard(variant: FfCardVariant.elevated, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('PLANNED POOL', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, letterSpacing: 1.1, fontWeight: FontWeight.w700)), if (value.overBudgetCount > 0) Text('${value.overBudgetCount} over limit', style: theme.textTheme.labelSmall?.copyWith(color: colors.expense))]),
      const SizedBox(height: StillwaterTokens.spaceSm),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(CurrencyFormatter.formatINR(value.totalSpent), style: StillwaterTypography.numLg(color: exceeded ? colors.expense : theme.colorScheme.onSurface)))), const SizedBox(width: StillwaterTokens.spaceSm), Text('of ${CurrencyFormatter.formatINR(value.totalBudgeted)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary))]),
      const SizedBox(height: StillwaterTokens.spaceMd),
      ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: theme.colorScheme.surfaceContainerHighest, color: exceeded ? colors.expense : theme.colorScheme.primary)),
      const SizedBox(height: StillwaterTokens.spaceSm),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(progress * 100).toStringAsFixed(0)}% spent', style: theme.textTheme.bodySmall), Flexible(child: Text(exceeded ? '${CurrencyFormatter.formatINR(value.totalSpent - value.totalBudgeted)} over plan' : '${CurrencyFormatter.formatINR(value.totalRemaining)} remaining', overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: exceeded ? colors.expense : colors.income, fontWeight: FontWeight.w600)))]),
    ]));
  }
}

class _BudgetList extends StatelessWidget {
  const _BudgetList({super.key, required this.summaries, required this.onOpen, required this.onCreate}); final AsyncValue<List<BudgetSummary>> summaries; final ValueChanged<Budget> onOpen; final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => summaries.when(data: (items) => items.isEmpty ? Padding(padding: const EdgeInsets.symmetric(vertical: StillwaterTokens.space2Xl), child: FfEmptyState(icon: Icons.pie_chart_outline_rounded, title: 'No budgets for this month', description: 'Set up a category limit to make this month easier to follow.', actionLabel: 'Create Budget', onAction: onCreate)) : ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: StillwaterTokens.spaceSm), itemBuilder: (_, i) => _BudgetRow(summary: items[i], onTap: onOpen)), loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())), error: (error, _) => Padding(padding: const EdgeInsets.all(20), child: Text('Could not load budgets: $error')));
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.summary, required this.onTap}); final BudgetSummary summary; final ValueChanged<Budget> onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme; final colors = context.finColors; final b = summary.budget; final exceeded = summary.isExceeded; final progressColor = exceeded ? colors.expense : summary.isApproachingThreshold ? theme.colorScheme.tertiary : theme.colorScheme.primary;
    return Semantics(button: true, label: '${b.name}, ${CurrencyFormatter.formatINR(summary.amountSpent)} of ${CurrencyFormatter.formatINR(b.amountLimit)}', child: FfCard(onTap: () => onTap(b), padding: const EdgeInsets.all(StillwaterTokens.spaceMd), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [FfCategoryTile(iconIdentifier: b.categoryIcon ?? 'category', colorTokenIdentifier: b.categoryColor ?? 'shore', size: 40), const SizedBox(width: StillwaterTokens.spaceSm), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall), const SizedBox(height: 2), Text(b.period.displayName, style: theme.textTheme.bodySmall)])), const SizedBox(width: 8), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [FittedBox(fit: BoxFit.scaleDown, child: Text(CurrencyFormatter.formatINR(summary.amountSpent), style: StillwaterTypography.numMd(color: exceeded ? colors.expense : theme.colorScheme.onSurface))), Text('of ${CurrencyFormatter.formatINR(b.amountLimit)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall)]))]),
      const SizedBox(height: StillwaterTokens.spaceMd), ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: summary.percentageUsed.clamp(0.0, 1.0), minHeight: 6, backgroundColor: theme.colorScheme.surfaceContainerHighest, color: progressColor)), const SizedBox(height: StillwaterTokens.spaceXs), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(summary.percentageUsed * 100).toStringAsFixed(0)}%', style: theme.textTheme.bodySmall), Flexible(child: Text(exceeded ? '${CurrencyFormatter.formatINR(summary.amountSpent - b.amountLimit)} over limit' : '${CurrencyFormatter.formatINR(summary.remainingAmount)} left', overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: exceeded ? colors.expense : colors.income, fontWeight: FontWeight.w600)))])
    ])));
  }
}
