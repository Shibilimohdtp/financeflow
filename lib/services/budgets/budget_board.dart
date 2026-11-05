import 'dart:math' as math;

import '../../core/period/period.dart';
import '../../models/budget.dart';
import 'budget_engine.dart';
import 'committed_bills.dart';

/// Totals for one budget group in a [BudgetBoard].
class BudgetGroupTotals {
  final BudgetGroup group;
  final List<BudgetPeriodResult> results;

  const BudgetGroupTotals(this.group, this.results);

  int get limitMinor => results.fold(0, (s, r) => s + r.limitMinor);
  int get spentMinor => results.fold(0, (s, r) => s + r.spentMinor);
}

/// The Budgets screen for one period: the plan hero, budgets by urgency and
/// group, and the budgets on other cadences.
class BudgetBoard {
  final Period period;
  final PeriodTiming timing;

  /// Budgets whose cadence matches [period], most urgent first.
  final List<BudgetPeriodResult> results;

  /// Budgets on other cadences (weekly in a month view, yearly, custom),
  /// each in its own period around the view's reference day.
  final List<BudgetPeriodResult> otherCadence;

  final CommittedBills bills;

  /// Sum of the limits of [results].
  final int plannedMinor;

  /// Counted spending across the union of [results]' categories: a
  /// transaction in a category shared by two budgets counts once here.
  final int spentMinor;

  /// Sum of each budget's own leftover. One overspent budget does not
  /// silently use up the others; its overspending is in [overspentMinor].
  final int leftMinor;
  final int overspentMinor;
  final int forecastMinor;

  /// Days left including today (0 for a past period).
  final int daysLeft;
  final int elapsedDays;
  final int totalDays;

  const BudgetBoard({
    required this.period,
    required this.timing,
    required this.results,
    required this.otherCadence,
    required this.bills,
    required this.plannedMinor,
    required this.spentMinor,
    required this.leftMinor,
    required this.overspentMinor,
    required this.forecastMinor,
    required this.daysLeft,
    required this.elapsedDays,
    required this.totalDays,
  });

  bool get isEmpty => results.isEmpty && otherCadence.isEmpty;

  /// The hero number: what can be spent per day for the rest of the period
  /// across flexible budgets. Bills are a separate line and never reduce it.
  int get safeTodayMinor =>
      timing == PeriodTiming.current && daysLeft > 0
          ? leftMinor ~/ daysLeft
          : 0;

  double get fractionSpent =>
      plannedMinor > 0 ? spentMinor / plannedMinor : (spentMinor > 0 ? 1 : 0);
  double get fractionElapsed => totalDays > 0 ? elapsedDays / totalDays : 0;

  /// over: the plan as a whole is overspent. atRisk: some budget needs
  /// attention or the plan is forecast to overrun. Otherwise on track.
  BudgetStatus get status {
    if (spentMinor > plannedMinor) return BudgetStatus.over;
    final forecastOver =
        timing == PeriodTiming.current &&
        forecastMinor > plannedMinor * (1 + BudgetEngine.riskMargin);
    if (forecastOver || results.any((r) => r.status != BudgetStatus.onTrack)) {
      return BudgetStatus.atRisk;
    }
    return BudgetStatus.onTrack;
  }

  /// A closed period that ended within plan, for a quiet "well done".
  bool get closedWithinPlan =>
      timing == PeriodTiming.past &&
      results.isNotEmpty &&
      spentMinor <= plannedMinor;

  List<BudgetPeriodResult> get needsAttention =>
      results.where((r) => r.status != BudgetStatus.onTrack).toList();

  List<BudgetGroupTotals> get groups => [
    for (final g in BudgetGroup.values)
      if (results.any((r) => r.budget.group == g))
        BudgetGroupTotals(
          g,
          results.where((r) => r.budget.group == g).toList(),
        ),
  ];

  /// Builds the board for [period] as seen on [now]. Archived budgets are
  /// left out; [budgets] may contain them.
  factory BudgetBoard.compute({
    required BudgetEngine engine,
    required Iterable<Budget> budgets,
    required Period period,
    required DateTime now,
    CommittedBills? bills,
  }) {
    final active = budgets.where((b) => !b.isArchived).toList();
    final matching =
        active
            .where(
              (b) =>
                  BudgetEngine.isRecurring(b) &&
                  BudgetEngine.unitOf(b.period) == period.unit,
            )
            .toList();

    final results = [
      for (final b in matching) engine.evaluate(b, period, now: now),
    ]..sort(BudgetEngine.compareUrgency);

    // Other cadences are shown around the day the view is "at": today for
    // the current period, the last day of a past one, the first of a future.
    final reference =
        period.contains(now)
            ? now
            : (now.isBefore(period.start) ? period.start : period.lastDay);
    final otherCadence = [
      for (final b in active)
        if (!matching.contains(b)) engine.evaluateAt(b, reference, now: now),
    ]..sort(BudgetEngine.compareUrgency);

    final timing =
        !now.isBefore(period.endExclusive)
            ? PeriodTiming.past
            : now.isBefore(period.start)
            ? PeriodTiming.future
            : PeriodTiming.current;
    final totalDays = period.dayCount;
    final elapsedDays = switch (timing) {
      PeriodTiming.past => totalDays,
      PeriodTiming.future => 0,
      PeriodTiming.current => period.elapsed(now).dayCount,
    };

    return BudgetBoard(
      period: period,
      timing: timing,
      results: results,
      otherCadence: otherCadence,
      bills: bills ?? CommittedBills.none(period),
      plannedMinor: results.fold(0, (s, r) => s + r.limitMinor),
      spentMinor: engine.ledger.spentMinor(
        results.expand((r) => r.budget.categoryIds),
        period,
      ),
      leftMinor: results.fold(0, (s, r) => s + r.leftMinor),
      overspentMinor: results.fold(0, (s, r) => s + r.overMinor),
      forecastMinor: results.fold(0, (s, r) => s + r.forecastMinor),
      daysLeft: switch (timing) {
        PeriodTiming.past => 0,
        PeriodTiming.future => totalDays,
        PeriodTiming.current => math.max(0, totalDays - elapsedDays + 1),
      },
      elapsedDays: elapsedDays,
      totalDays: totalDays,
    );
  }
}
