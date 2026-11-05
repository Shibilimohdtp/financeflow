import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/charts/ff_bar_chart.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';
import '../cash_flow_chart_data.dart';
import '../../../shared/widgets/ff_divider.dart';

enum _FlowView { compare, expenses, income }

class AnalyticsCashFlowCard extends StatefulWidget {
  final List<TimeSeriesPoint> points;
  final AnalyticsTimeRange range;
  final DateTime start;
  final DateTime end;

  const AnalyticsCashFlowCard({
    super.key,
    required this.points,
    required this.range,
    required this.start,
    required this.end,
  });

  @override
  State<AnalyticsCashFlowCard> createState() => _AnalyticsCashFlowCardState();
}

class _AnalyticsCashFlowCardState extends State<AnalyticsCashFlowCard> {
  _FlowView _view = _FlowView.compare;
  int? _selected;

  @override
  void didUpdateWidget(covariant AnalyticsCashFlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points ||
        oldWidget.start != widget.start ||
        oldWidget.end != widget.end ||
        oldWidget.range != widget.range) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.finColors;
    final data = CashFlowChartData.fromPoints(
      points: widget.points,
      range: widget.range,
      start: widget.start,
      end: widget.end,
    );
    if (data.buckets.isEmpty ||
        data.buckets.every((b) => b.income == 0 && b.expense == 0)) {
      return const FfCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No income or expenses in this period.'),
        ),
      );
    }
    final buckets = data.buckets;
    // Begin with the most active period, so details never start on an empty day.
    final peak = buckets.reduce(
      (a, b) => a.income + a.expense >= b.income + b.expense ? a : b,
    );
    final index = (_selected ?? buckets.indexOf(peak)).clamp(
      0,
      buckets.length - 1,
    );
    final selected = buckets[index];
    final income = buckets.fold<double>(0, (v, b) => v + b.income);
    final expense = buckets.fold<double>(0, (v, b) => v + b.expense);
    final net = income - expense;
    final period =
        widget.start.year == widget.end.year &&
                widget.start.month == widget.end.month
            ? DateFormat('MMM yyyy').format(widget.start)
            : '${DateFormat('MMM yyyy').format(widget.start)} – ${DateFormat('MMM yyyy').format(widget.end)}';

    return FfCard(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${data.groupingLabel} · $period',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            net == 0
                ? 'Income matched expenses'
                : net > 0
                ? '${CurrencyFormatter.format(net)} more in than out'
                : '${CurrencyFormatter.format(-net)} more out than in',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final view in _FlowView.values)
                ChoiceChip(
                  key: ValueKey('flow-view-${view.name}'),
                  label: Text(switch (view) {
                    _FlowView.compare => 'Compare',
                    _FlowView.expenses => 'Expenses',
                    _FlowView.income => 'Income',
                  }),
                  selected: _view == view,
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color:
                        _view == view
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _view = view),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              if (_view != _FlowView.income)
                _FlowLegend(
                  label: 'Expenses',
                  color: colors.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              if (_view != _FlowView.expenses)
                _FlowLegend(
                  label: 'Income',
                  color: colors.income,
                  icon: Icons.arrow_downward_rounded,
                ),
            ],
          ),
          const SizedBox(height: 16),
          FfBarChart(
            items:
                buckets
                    .map(
                      (b) => BarChartItem(
                        label: b.label,
                        value: _view == _FlowView.income ? b.income : b.expense,
                        secondaryValue:
                            _view == _FlowView.compare ? b.income : null,
                        color:
                            _view == _FlowView.income
                                ? colors.income
                                : colors.expense,
                        secondaryColor: colors.income,
                      ),
                    )
                    .toList(),
            height: 190,
            showYAxis: true,
            showSelectionDetails: false,
            selectedIndex: index,
            onSelected: (i) => setState(() => _selected = i),
            primaryLabel: _view == _FlowView.income ? 'Income' : 'Expenses',
            semanticsSummary: '${data.groupingLabel} cash flow chart',
          ),
          const SizedBox(height: 8),
          Text(
            _view == _FlowView.compare
                ? 'Same scale · Tap a period for exact values'
                : '${_view == _FlowView.expenses ? 'Expense' : 'Income'} scale · Tap a period for exact values',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: .035),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          selected.dateLabel,
                          key: const ValueKey('flow-selected-period'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('flow-previous'),
                      tooltip: 'Previous period',
                      onPressed:
                          index > 0
                              ? () => setState(() => _selected = index - 1)
                              : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    ),
                    IconButton(
                      key: const ValueKey('flow-next'),
                      tooltip: 'Next period',
                      onPressed:
                          index < buckets.length - 1
                              ? () => setState(() => _selected = index + 1)
                              : null,
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    ),
                  ],
                ),
                Semantics(
                  liveRegion: true,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked =
                          constraints.maxWidth < 250 ||
                          MediaQuery.textScalerOf(context).scale(14) > 19;
                      final values = [
                        _FlowValue(
                          label: 'Income',
                          amount: selected.income,
                          color: colors.income,
                        ),
                        _FlowValue(
                          label: 'Expenses',
                          amount: selected.expense,
                          color: colors.expense,
                        ),
                      ];
                      return stacked
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              values[0],
                              const SizedBox(height: 8),
                              values[1],
                            ],
                          )
                          : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: values[0]),
                              const SizedBox(width: 12),
                              Expanded(child: values[1]),
                            ],
                          );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const FfDivider(),
                const SizedBox(height: 10),
                Text(
                  'Net ${CurrencyFormatter.format(selected.net, showSign: selected.net != 0)}',
                  key: const ValueKey('flow-selected-net'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowLegend extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _FlowLegend({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _FlowValue extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _FlowValue({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(
        CurrencyFormatter.format(amount),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
