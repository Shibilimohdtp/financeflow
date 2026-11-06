import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart';
import '../../services/budgets/budget_engine.dart';
import '../../services/budgets/budget_insights.dart';
import '../../services/budgets/budget_ledger.dart';
import '../../services/budgets/budget_setup_suggester.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_key_value_row.dart';
import '../../shared/widgets/ff_menu.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../accounts/accounts_controller.dart';
import '../settings/settings_controller.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transaction_list_utils.dart';
import 'budget_format.dart';
import 'budget_sheets.dart';
import 'budgets_controller.dart';
import 'plan_providers.dart';

/// One budget in its period (recipe D): what is left, how the period is
/// going against the ideal pace, the last six periods, the payments it
/// counts (the same ones Money shows), and its settings.
///
/// It watches the budget by id, so an edit shows at once. [budget] is only
/// the starting value while the stream loads.
class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({
    super.key,
    required this.budget,
    this.onShowTransactions,
  });

  final Budget budget;

  /// Opens Money with a query; null hides "See all in Money".
  final ValueChanged<TransactionQuery>? onShowTransactions;

  static const _listLimit = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allBudgetsStreamProvider).valueOrNull;
    final live =
        all == null
            ? budget
            : all.where((b) => b.id == budget.id).firstOrNull ?? budget;
    final b = live.copyWith(
      group: BudgetSetupSuggester.groupFor(live.categoryId),
    );
    final engine = ref.watch(budgetEngineProvider).valueOrNull;
    final now = ref.watch(planNowProvider);
    final planPeriod = ref.watch(planPeriodProvider);
    final isPrivacyBlur =
        ref.watch(settingsStreamProvider).valueOrNull?.isPrivacyBlurEnabled ??
        false;

    final subtitle = [
      b.period.displayName,
      if (BudgetEngine.isRecurring(b)) b.group.label,
      if (b.isArchived) 'Archived',
    ].join(' · ');

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: FfAppBar(
          title: b.name,
          subtitle: subtitle,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit budget',
              onPressed: () => openBudgetSheet(context, initial: b),
            ),
            FfMenuButton<String>(
              items: [
                FfMenuItem(
                  value: 'archive',
                  label: b.isArchived ? 'Restore budget' : 'Archive budget',
                  icon:
                      b.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                ),
                const FfMenuItem(
                  value: 'delete',
                  label: 'Delete budget',
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                ),
              ],
              onSelected:
                  (v) =>
                      v == 'archive'
                          ? _toggleArchive(context, ref, b)
                          : _delete(context, ref, b),
            ),
          ],
        ),
        body:
            engine == null
                ? const Center(child: CircularProgressIndicator())
                : _body(
                  context,
                  ref,
                  b,
                  engine,
                  now,
                  planPeriod,
                  isPrivacyBlur,
                ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    Budget b,
    BudgetEngine engine,
    DateTime now,
    Period planPeriod,
    bool isPrivacyBlur,
  ) {
    // Follow the Plan tab's period when the cadence matches; otherwise the
    // budget's current period.
    final reference =
        BudgetEngine.isRecurring(b) &&
                BudgetEngine.unitOf(b.period) == planPeriod.unit
            ? planPeriod.start
            : now;
    final r = engine.evaluateAt(b, reference, now: now);
    final history = engine.history(b, r.period, now: now);
    final insight = BudgetInsight.compute(engine, b, r.period, now: now);
    final rows = engine.ledger.transactionsIn(b.categoryIds, r.period)
      ..sort((x, y) => y.date.compareTo(x.date));
    final txById = {
      for (final t
          in ref.watch(allTransactionsStreamProvider).valueOrNull ??
              const <Transaction>[])
        t.id: t,
    };
    final ff = context.ff;
    final noun = BudgetFormat.periodNoun(b.period);
    const gap = SizedBox(height: FfSpace.lg);
    final m = isPrivacyBlur ? (int _) => '••••' : BudgetFormat.money;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.pageMargin,
        FfSpace.sm,
        FfSpace.pageMargin,
        FfSpace.x4l,
      ),
      children: [
        _Hero(result: r, isPrivacyBlur: isPrivacyBlur),
        if (r.timing == PeriodTiming.current &&
            r.status != BudgetStatus.onTrack) ...[
          gap,
          _Attention(
            result: r,
            suggestion: insight.suggestion,
            isPrivacyBlur: isPrivacyBlur,
            onRaise: (limit) => _applyLimit(context, ref, b, limit),
          ),
        ],
        if (r.timing != PeriodTiming.future && r.totalDays > 1) ...[
          gap,
          _Trend(result: r, rows: rows, noun: noun, money: m),
        ],
        if (history.isNotEmpty) ...[
          gap,
          _History(history: history, isPrivacyBlur: isPrivacyBlur),
        ],
        gap,
        FfSectionHeader(
          title: 'Spending this $noun',
          padding: EdgeInsets.zero,
          trailing:
              onShowTransactions == null || rows.isEmpty
                  ? null
                  : FfButton(
                    label: 'See all in Money',
                    variant: FfButtonVariant.text,
                    size: FfButtonSize.sm,
                    onPressed: () {
                      final show = onShowTransactions!;
                      Navigator.of(context).pop();
                      show(
                        TransactionQuery(
                          period: r.period,
                          budgetScope: BudgetScope(
                            categoryIds: b.categoryIds.toSet(),
                            label: b.name,
                          ),
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: FfSpace.sm),
        if (rows.isEmpty)
          FfCard(
            child: Text(
              'No spending in ${b.categoryName ?? 'this category'} '
              'this $noun yet.',
              style: ff.text.label,
            ),
          )
        else ...[
          FfGroupedContainer(
            children: [
              for (final row in rows.take(_listLimit))
                FfRow(
                  key: ValueKey('budget-tx-${row.id}'),
                  title: row.merchant,
                  subtitle: BudgetFormat.shortDate(row.date),
                  leading: FfCategoryTile(
                    iconIdentifier: b.categoryIcon ?? 'category',
                    colorTokenIdentifier: b.categoryColor ?? 'shore',
                  ),
                  trailing: FfAmountText(
                    amount: BudgetFormat.major(row.amountMinor),
                    size: FfAmountSize.sm,
                    tone: FfTone.neutral,
                    showSign: false,
                    isBlurred: isPrivacyBlur,
                  ),
                  onTap:
                      txById[row.id] == null
                          ? null
                          : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => TransactionDetailScreen(
                                    transaction: txById[row.id]!,
                                  ),
                            ),
                          ),
                ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          Text(
            [
              rows.length == 1 ? '1 payment' : '${rows.length} payments',
              '${m(r.spentMinor)} in all',
              if (rows.length > _listLimit) 'latest $_listLimit shown',
            ].join(' · '),
            style: ff.text.label,
          ),
        ],
        gap,
        const FfSectionHeader(title: 'Details', padding: EdgeInsets.zero),
        const SizedBox(height: FfSpace.sm),
        FfGroupedContainer(
          children: [
            FfKeyValueRow(
              icon: Icons.date_range_outlined,
              label: 'This $noun',
              value:
                  '${BudgetFormat.shortDate(r.period.start)} – '
                  '${BudgetFormat.shortDate(r.period.lastDay)}',
            ),
            FfKeyValueRow(
              icon: Icons.notifications_none_rounded,
              label: 'Alert at',
              value:
                  '${BudgetFormat.percent(b.alertThreshold)}% · '
                  '${m((r.limitMinor * b.alertThreshold).round())}',
            ),
            FfKeyValueRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: b.categoryName ?? 'Category',
            ),
            if (r.startedMidPeriod)
              FfKeyValueRow(
                icon: Icons.info_outline_rounded,
                label: 'Started',
                value:
                    '${BudgetFormat.shortDate(b.startDate)} · earlier '
                    'spending in the $noun counts',
              ),
          ],
        ),
        gap,
        FfButton(
          label: b.isArchived ? 'Restore budget' : 'Archive budget',
          variant: FfButtonVariant.outlined,
          leadingIcon: Icon(
            b.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
          ),
          width: double.infinity,
          onPressed: () => _toggleArchive(context, ref, b),
        ),
      ],
    );
  }

  Future<void> _applyLimit(
    BuildContext context,
    WidgetRef ref,
    Budget b,
    int newLimitMinor,
  ) async {
    final controller = ref.read(budgetsControllerProvider.notifier);
    final before = b.amountLimit;
    try {
      await controller.saveBudget(
        b.copyWith(
          amountLimit: MoneyMath.fromMinor(newLimitMinor),
          updatedAt: DateTime.now(),
        ),
      );
      if (!context.mounted) return;
      FfToast.show(
        context,
        message: 'Limit set to ${BudgetFormat.money(newLimitMinor)}.',
        actionLabel: 'Undo',
        onAction:
            () => controller.saveBudget(
              b.copyWith(amountLimit: before, updatedAt: DateTime.now()),
            ),
      );
    } catch (_) {
      if (context.mounted) {
        FfToast.show(
          context,
          message: 'Could not change the limit.',
          tone: FfToastTone.error,
        );
      }
    }
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Budget b,
  ) async {
    try {
      await ref
          .read(budgetsControllerProvider.notifier)
          .archiveBudget(b.id, !b.isArchived);
      if (context.mounted) {
        FfToast.show(
          context,
          message: b.isArchived ? 'Budget restored.' : 'Budget archived.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        FfToast.show(
          context,
          message: 'Could not change the budget.',
          tone: FfToastTone.error,
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Budget b) async {
    final ok = await FfDialog.confirm(
      context,
      title: 'Delete this budget?',
      message:
          '"${b.name}" will be removed. Your transactions stay as they are.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(budgetsControllerProvider.notifier).deleteBudget(b.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Budget deleted.');
      }
    } catch (_) {
      if (context.mounted) {
        FfToast.show(
          context,
          message: 'Could not delete the budget.',
          tone: FfToastTone.error,
        );
      }
    }
  }
}

/// The rose hero: what is left (or how much over), the status in words,
/// spent against the limit, the pace bar and three small figures.
class _Hero extends StatelessWidget {
  const _Hero({required this.result, required this.isPrivacyBlur});

  final BudgetPeriodResult result;
  final bool isPrivacyBlur;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final ff = context.ff;
    final over = r.overMinor > 0;
    final isCurrent = r.timing == PeriodTiming.current;
    final pct = BudgetFormat.percent(r.fractionUsed);
    final title = switch (r.timing) {
      PeriodTiming.past => over ? 'Went over by' : 'Left at the end',
      PeriodTiming.future => 'Planned',
      PeriodTiming.current => over ? 'Over by' : 'Left to spend',
    };
    final amount =
        r.timing == PeriodTiming.future
            ? r.limitMinor
            : (over ? r.overMinor : r.leftMinor);
    final m = isPrivacyBlur ? (int _) => '••••' : BudgetFormat.money;
    String hidden(String v) => isPrivacyBlur ? '••••' : v;

    return FfHeroCard(
      key: const ValueKey('budget-hero'),
      tone: FfHeroTone.rose,
      leading: FfProgressRing(
        value: r.fractionUsed.clamp(0.0, 1.0),
        icon: over ? Icons.priority_high_rounded : Icons.savings_outlined,
        semanticsLabel: '$pct% of the limit spent',
      ),
      title: title,
      subtitle: '$pct% used',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfAmountText(
            key: const ValueKey('budget-hero-amount'),
            amount: BudgetFormat.major(amount),
            size: FfAmountSize.hero,
            tone: FfTone.neutral,
            showSign: false,
            isBlurred: isPrivacyBlur,
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            'Spent ${m(r.spentMinor)} · limit ${m(r.limitMinor)}',
            style: ff.text.label.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: FfSpace.md),
          FfProgressBar(
            value: r.fractionUsed,
            pace: isCurrent ? r.fractionElapsed : null,
            onHero: true,
            semanticLabel: 'Limit used',
            semanticValue: BudgetFormat.progressSemantics(
              r,
              hidden: isPrivacyBlur,
            ),
          ),
          const SizedBox(height: FfSpace.sm),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: FfSpace.xs,
            runSpacing: FfSpace.x2s,
            children: [
              FfBadge(
                label: BudgetFormat.status(r.status),
                tone: FfTone.neutral,
                icon: BudgetFormat.statusIcon(r.status),
              ),
              if (isCurrent && !isPrivacyBlur)
                Text(
                  BudgetFormat.pace(r.spentMinor, r.expectedByTodayMinor),
                  style: ff.text.label,
                ),
            ],
          ),
          if (isCurrent) ...[
            const SizedBox(height: FfSpace.lg),
            FfHeroFigures([
              FfHeroFigure(
                'Per day',
                hidden(BudgetFormat.estimate(r.dailyAllowanceMinor)),
                semanticsValue: isPrivacyBlur ? 'hidden' : null,
              ),
              FfHeroFigure(
                'Forecast',
                hidden(BudgetFormat.estimate(r.forecastMinor)),
                semanticsValue: isPrivacyBlur ? 'hidden' : null,
              ),
              FfHeroFigure(
                'Days left',
                '${r.daysLeft}',
                semanticsValue:
                    r.daysLeft == 1 ? '1 day' : '${r.daysLeft} days',
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// Over or at risk: what is wrong, in words, and a one-tap fix.
class _Attention extends StatelessWidget {
  const _Attention({
    required this.result,
    required this.suggestion,
    required this.isPrivacyBlur,
    required this.onRaise,
  });

  final BudgetPeriodResult result;
  final BudgetSuggestion? suggestion;
  final bool isPrivacyBlur;
  final ValueChanged<int> onRaise;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final r = result;
    final m = isPrivacyBlur ? (int _) => '••••' : BudgetFormat.money;
    final over = r.status == BudgetStatus.over;
    final line =
        over
            ? '${m(r.overMinor)} over the limit'
            : r.runOutDate != null
            ? 'At this pace it runs out on '
                '${BudgetFormat.shortDate(r.runOutDate!)}'
            : 'Forecast ${m(r.forecastMinor)} against ${m(r.limitMinor)}';
    final s = suggestion;
    final raise = s != null && s.kind == BudgetSuggestionKind.raise;
    return FfCard(
      key: const ValueKey('budget-attention'),
      variant: FfCardVariant.warning,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(BudgetFormat.statusIcon(r.status), color: ff.color.textPrimary),
          const SizedBox(width: FfSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  over ? 'Over the limit' : 'Likely to go over',
                  style: ff.text.titleSm,
                ),
                const SizedBox(height: FfSpace.x2s),
                Text(line, style: ff.text.body),
                if (raise) ...[
                  const SizedBox(height: FfSpace.sm),
                  FfButton(
                    label: 'Raise to ${m(s.newLimitMinor)}',
                    size: FfButtonSize.sm,
                    onPressed: () => onRaise(s.newLimitMinor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Spending so far, day by day, against the ideal pace line.
class _Trend extends StatelessWidget {
  const _Trend({
    required this.result,
    required this.rows,
    required this.noun,
    required this.money,
  });

  final BudgetPeriodResult result;
  final List<CountedTransaction> rows;
  final String noun;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final r = result;
    final days = r.totalDays;
    final shown = r.timing == PeriodTiming.past ? days : r.elapsedDays;
    final perDay = List<int>.filled(days, 0);
    for (final row in rows) {
      final i =
          DateTime(
            row.date.year,
            row.date.month,
            row.date.day,
          ).difference(r.period.start).inDays;
      if (i >= 0 && i < days) perDay[i] += row.amountMinor;
    }
    var running = 0;
    final points = <FfChartPoint>[
      for (var i = 0; i < shown; i++)
        FfChartPoint(
          BudgetFormat.shortDate(r.period.start.add(Duration(days: i))),
          BudgetFormat.major(running += perDay[i]),
        ),
    ];
    final ideal = <double>[
      for (var i = 0; i < days; i++)
        BudgetFormat.major((r.limitMinor * (i + 1) / days).round()),
    ];
    if (points.isEmpty) return const SizedBox.shrink();
    return FfCard(
      key: const ValueKey('budget-trend'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This $noun', style: ff.text.titleLg),
          Text('Spent so far against an even pace', style: ff.text.label),
          const SizedBox(height: FfSpace.md),
          FfLineChart(
            points: points,
            reference: ideal,
            domainLength: days,
            initialIndex: points.length - 1,
            valueLabel: (p) => money(MoneyMath.toMinor(p.value)),
            referenceLabel:
                (i) => 'Even pace ${money(MoneyMath.toMinor(ideal[i]))}',
            hint: 'Swipe up or down to change the day',
          ),
        ],
      ),
    );
  }
}

/// The last six periods: within plan or over, with what was spent.
class _History extends StatelessWidget {
  const _History({required this.history, required this.isPrivacyBlur});

  final List<BudgetPeriodResult> history;
  final bool isPrivacyBlur;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final within = history.where((h) => h.overMinor == 0).length;
    String label(Period p) => switch (p.unit) {
      PeriodUnit.month => BudgetFormat.shortDate(p.start).split(' ').last,
      PeriodUnit.year => '${p.start.year}',
      _ => BudgetFormat.shortDate(p.start),
    };
    return FfCard(
      key: const ValueKey('budget-history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent ${BudgetFormat.periodNoun(history.first.budget.period, count: 2)}',
            style: ff.text.titleLg,
          ),
          const SizedBox(height: FfSpace.md),
          FfMonthGrid(
            months: [
              for (final h in history)
                FfMonthCell(
                  label: label(h.period),
                  status:
                      h.spentMinor == 0 && h.overMinor == 0
                          ? FfMonthStatus.none
                          : h.overMinor > 0
                          ? FfMonthStatus.over
                          : FfMonthStatus.under,
                  note:
                      isPrivacyBlur || h.spentMinor == 0
                          ? null
                          : BudgetFormat.estimate(h.spentMinor),
                ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          Text(
            'Within plan in $within of the last ${history.length}',
            style: ff.text.label,
          ),
        ],
      ),
    );
  }
}
