import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/category_colors.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/charts/ff_donut_chart.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../theme/ff.dart';

/// The ring and its numbered, directly labeled comparison rows share one order.
/// Rows also provide large, keyboard/screen-reader accessible drill-down targets.
class ExpenseCategoryBreakdown extends StatefulWidget {
  final List<CategorySpend> categories;
  final ValueChanged<CategorySpend> onOpenCategory;

  const ExpenseCategoryBreakdown({
    super.key,
    required this.categories,
    required this.onOpenCategory,
  });

  @override
  State<ExpenseCategoryBreakdown> createState() =>
      _ExpenseCategoryBreakdownState();
}

class _ExpenseCategoryBreakdownState extends State<ExpenseCategoryBreakdown> {
  String? _selectedId;

  @override
  void didUpdateWidget(covariant ExpenseCategoryBreakdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) _selectedId = null;
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.categories
            .where((c) => c.amount.isFinite && c.amount > 0)
            .toList();
    if (categories.isEmpty) {
      return const FfCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: FfSpace.lg),
          child: Text('No expenses recorded for this period.'),
        ),
      );
    }
    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);
    final count = categories.fold<int>(0, (sum, c) => sum + c.transactionCount);
    final largest = categories.reduce((a, b) => a.amount >= b.amount ? a : b);
    final selectedIndex = categories.indexWhere(
      (c) => c.categoryId == _selectedId,
    );
    final index =
        selectedIndex < 0 ? categories.indexOf(largest) : selectedIndex;
    final selected = categories[index];
    final share = _percentage(selected.amount / total);

    return FfCard(
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total expenses',
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.textSecondary,
            ),
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            CurrencyFormatter.format(total),
            key: const ValueKey('category-expense-total'),
            style: context.ff.text.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            '$count ${count == 1 ? 'payment' : 'payments'} in this period',
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.textSecondary,
            ),
          ),
          const SizedBox(height: FfSpace.lg),
          FfDonutChart(
            slices:
                categories
                    .map(
                      (c) => DonutSlice(
                        label: c.categoryName,
                        value: c.amount,
                        colorToken: c.categoryColor,
                      ),
                    )
                    .toList(),
            selectedSliceIndex: index,
            showSegmentNumbers: true,
            onSliceSelected:
                (value) =>
                    setState(() => _selectedId = categories[value].categoryId),
          ),
          const SizedBox(height: FfSpace.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              '${selected == largest ? 'Largest category' : 'Selected category'} · ${selected.categoryName} · $share',
              key: const ValueKey('category-selection-summary'),
              textAlign: TextAlign.center,
              style: context.ff.text.bodySm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: TextButton.icon(
              key: const ValueKey('view-category-payments'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => widget.onOpenCategory(selected),
              label: Text(
                'View ${selected.transactionCount} ${selected.transactionCount == 1 ? 'payment' : 'payments'}',
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              iconAlignment: IconAlignment.end,
            ),
          ),
          Text(
            'Tap a segment to explore. Tap a category for payments.',
            textAlign: TextAlign.center,
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.textSecondary,
            ),
          ),
          const SizedBox(height: FfSpace.md),
          const FfDivider(),
          const SizedBox(height: FfSpace.md),
          Text(
            'Share of total spending',
            style: context.ff.text.label.copyWith(
              color: context.ff.color.textSecondary,
            ),
          ),
          const SizedBox(height: FfSpace.xs),
          for (var i = 0; i < categories.length; i++)
            _CategoryRow(
              category: categories[i],
              number: i + 1,
              fraction: categories[i].amount / total,
              selected: i == index,
              onTap: () {
                setState(() => _selectedId = categories[i].categoryId);
                widget.onOpenCategory(categories[i]);
              },
            ),
        ],
      ),
    );
  }
}

String _percentage(double fraction) =>
    fraction > 0 && fraction < .001
        ? '<0.1%'
        : '${(fraction * 100).toStringAsFixed(1)}%';

class _CategoryRow extends StatelessWidget {
  final CategorySpend category;
  final int number;
  final double fraction;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.number,
    required this.fraction,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryColors.getColor(
      category.categoryColor,
      isDark: theme.brightness == Brightness.dark,
    );
    final amount = CurrencyFormatter.format(category.amount);
    final percent = _percentage(fraction);
    final payments =
        '${category.transactionCount} ${category.transactionCount == 1 ? 'payment' : 'payments'}';
    return Semantics(
      button: true,
      selected: selected,
      label: '${category.categoryName}, $amount, $percent of total, $payments',
      hint: 'View payments',
      onTap: onTap,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: FfSpace.x2s),
        child: Material(
          color:
              selected
                  ? context.ff.color.textPrimary.withValues(
                    alpha: FfTint.whisper.alpha,
                  )
                  : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FfRadius.md),
            side: BorderSide(
              color:
                  selected ? context.ff.color.borderSubtle : Colors.transparent,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('category-row-${category.categoryId}'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.xs,
                vertical: FfSpace.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: FfTint.subtle.alpha),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$number',
                      style: context.ff.text.label.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked =
                            constraints.maxWidth < 220 ||
                            MediaQuery.textScalerOf(context).scale(14) > 19;
                        final name = Text(
                          category.categoryName,
                          style: context.ff.text.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        );
                        final value = Text(
                          amount,
                          style: context.ff.text.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (stacked) ...[
                              name,
                              value,
                            ] else
                              Row(
                                children: [
                                  Expanded(child: name),
                                  const SizedBox(width: FfSpace.xs),
                                  value,
                                ],
                              ),
                            const SizedBox(height: FfSpace.x2s),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  payments,
                                  style: context.ff.text.bodySm.copyWith(
                                    color: context.ff.color.textSecondary,
                                  ),
                                ),
                                Text(
                                  percent,
                                  style: context.ff.text.label.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: FfSpace.xs),
                            ExcludeSemantics(
                              child: FfProgressBar(
                                value: fraction,
                                color: color,
                                size: FfProgressSize.sm,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
          ),
        ),
      ),
    );
  }
}
