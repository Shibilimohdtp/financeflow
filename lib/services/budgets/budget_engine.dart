import 'dart:math' as math;

import '../../core/period/period.dart';
import '../../models/budget.dart';
import 'budget_ledger.dart';

/// Where a period sits relative to today.
enum PeriodTiming { past, current, future }

/// Urgency, most urgent first. Always shown with an icon and words, never
/// colour alone.
enum BudgetStatus { over, atRisk, onTrack }

/// Everything the UI, alerts and health score need about one budget in one
/// period. All money is in integer minor units.
class BudgetPeriodResult {
  final Budget budget;
  final Period period;
  final PeriodTiming timing;

  /// The plan before this period's changes.
  final int planMinor;

  /// "This period only" changes and money moved in or out.
  final int adjustmentMinor;

  /// Carried from the previous period by rollover (negative = overspending).
  final int carryInMinor;

  /// What this period may spend: plan + adjustments + carry, never below 0.
  final int limitMinor;
  final int spentMinor;

  final int totalDays;

  /// Days of the period up to and including today (0 for future periods).
  final int elapsedDays;

  /// Days left including today (0 for past periods).
  final int daysLeft;

  /// Where spending would be today if it followed the limit evenly.
  final int expectedByTodayMinor;

  /// Expected spending at the end of the period.
  final int forecastMinor;

  /// Spending per day that keeps the budget within its limit, including today.
  final int dailyAllowanceMinor;

  /// The day the budget is expected to run out, when that is inside the
  /// period and it has not run out yet.
  final DateTime? runOutDate;

  final BudgetStatus status;

  /// The budget began after this period started. Its limit is not
  /// pro-rated: earlier spending in the period still counts.
  final bool startedMidPeriod;

  const BudgetPeriodResult({
    required this.budget,
    required this.period,
    required this.timing,
    required this.planMinor,
    required this.adjustmentMinor,
    required this.carryInMinor,
    required this.limitMinor,
    required this.spentMinor,
    required this.totalDays,
    required this.elapsedDays,
    required this.daysLeft,
    required this.expectedByTodayMinor,
    required this.forecastMinor,
    required this.dailyAllowanceMinor,
    required this.runOutDate,
    required this.status,
    required this.startedMidPeriod,
  });

  /// Limit minus spending; negative when over.
  int get remainingMinor => limitMinor - spentMinor;
  int get leftMinor => math.max(0, remainingMinor);
  int get overMinor => math.max(0, -remainingMinor);

  /// Share of the limit used (may exceed 1). A zero limit with spending
  /// reads as fully used.
  double get fractionUsed =>
      limitMinor > 0 ? spentMinor / limitMinor : (spentMinor > 0 ? 1.0 : 0.0);

  /// Share of the period elapsed, for the pace marker.
  double get fractionElapsed => totalDays > 0 ? elapsedDays / totalDays : 0;

  bool get isAheadOfPace =>
      timing == PeriodTiming.current && spentMinor > expectedByTodayMinor;
}

/// Pure budget arithmetic over a [BudgetLedger]. See
/// `docs/features/budgets.md` for the rules this implements.
class BudgetEngine {
  /// Rollover looks back at most this many periods.
  static const int maxRolloverPeriods = 12;

  /// Previous periods used to learn a category's usual daily spending.
  static const int historyPeriodsForForecast = 3;

  /// A single transaction at least this share of the limit is a one-off
  /// (rent, an appliance): it counts as spent but does not set the pace.
  static const double lumpShare = 0.4;

  /// The forecast must exceed the limit by this much to flag "at risk".
  static const double riskMargin = 0.05;

  final BudgetLedger ledger;
  final int weekStart;
  final Map<String, List<BudgetAdjustment>> _adjustments;

  BudgetEngine({
    required this.ledger,
    Iterable<BudgetAdjustment> adjustments = const [],
    this.weekStart = DateTime.monday,
  }) : _adjustments = _groupAdjustments(adjustments);

  static Map<String, List<BudgetAdjustment>> _groupAdjustments(
    Iterable<BudgetAdjustment> adjustments,
  ) {
    final map = <String, List<BudgetAdjustment>>{};
    for (final a in adjustments) {
      (map[a.budgetId] ??= []).add(a);
    }
    return map;
  }

  static PeriodUnit unitOf(BudgetPeriod period) => switch (period) {
    BudgetPeriod.weekly => PeriodUnit.week,
    BudgetPeriod.monthly => PeriodUnit.month,
    BudgetPeriod.yearly => PeriodUnit.year,
    BudgetPeriod.custom => PeriodUnit.custom,
  };

  static bool isRecurring(Budget budget) =>
      budget.period != BudgetPeriod.custom;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The period of [budget] that contains [reference]. A custom budget has
  /// one period: its start and (inclusive) end day. An old custom budget
  /// without an end date runs for one year.
  Period periodFor(Budget budget, DateTime reference) {
    if (!isRecurring(budget)) {
      final start = _day(budget.startDate);
      final end =
          budget.endDate != null
              ? _day(budget.endDate!)
              : DateTime(start.year + 1, start.month, start.day - 1);
      return Period.custom(start, end);
    }
    return Period.containing(
      unitOf(budget.period),
      reference,
      weekStart: weekStart,
    );
  }

  int adjustmentMinor(Budget budget, Period period) {
    var total = 0;
    for (final a in _adjustments[budget.id] ?? const <BudgetAdjustment>[]) {
      if (_day(a.periodStart) == period.start) total += a.deltaMinor;
    }
    return total;
  }

  /// The amount carried into [period] from earlier periods.
  ///
  /// Computed by replaying from the later of the rollover start and the
  /// budget's first period (at most [maxRolloverPeriods] back), so edits to
  /// past transactions are always reflected and nothing stored can drift.
  int carryInMinor(Budget budget, Period period) {
    if (budget.rolloverMode == RolloverMode.off ||
        budget.rolloverSince == null ||
        !isRecurring(budget)) {
      return 0;
    }
    final first = periodFor(budget, budget.rolloverSince!);
    final budgetFirst = periodFor(budget, budget.startDate);
    final chainStart =
        budgetFirst.start.isAfter(first.start) ? budgetFirst : first;
    if (!chainStart.start.isBefore(period.start)) return 0;

    // Walk back to the chain start, bounded.
    var p = period.previous();
    var steps = 1;
    while (p.start.isAfter(chainStart.start) && steps < maxRolloverPeriods) {
      p = p.previous();
      steps++;
    }

    var carry = 0;
    while (p.start.isBefore(period.start)) {
      final limit = math.max(
        0,
        budget.limitMinor + adjustmentMinor(budget, p) + carry,
      );
      final left = limit - ledger.spentMinor(budget.categoryIds, p);
      carry =
          budget.rolloverMode == RolloverMode.unspent
              ? math.max(0, left)
              : left;
      p = p.next();
    }
    return carry;
  }

  /// [budget] in its period containing [reference], as seen on [now].
  BudgetPeriodResult evaluateAt(
    Budget budget,
    DateTime reference, {
    required DateTime now,
  }) => evaluate(budget, periodFor(budget, reference), now: now);

  BudgetPeriodResult evaluate(
    Budget budget,
    Period period, {
    required DateTime now,
  }) {
    final plan = budget.limitMinor;
    final adjustment = adjustmentMinor(budget, period);
    final carry = carryInMinor(budget, period);
    final limit = math.max(0, plan + adjustment + carry);
    final rows = ledger.transactionsIn(budget.categoryIds, period);
    final spent = rows.fold<int>(0, (sum, r) => sum + r.amountMinor);

    final totalDays = period.dayCount;
    final timing =
        !now.isBefore(period.endExclusive)
            ? PeriodTiming.past
            : now.isBefore(period.start)
            ? PeriodTiming.future
            : PeriodTiming.current;
    final elapsedDays = switch (timing) {
      PeriodTiming.past => totalDays,
      PeriodTiming.future => 0,
      PeriodTiming.current => period.elapsed(now).dayCount,
    };
    final daysLeft = switch (timing) {
      PeriodTiming.past => 0,
      PeriodTiming.future => totalDays,
      PeriodTiming.current => totalDays - elapsedDays + 1,
    };
    final expectedByToday =
        totalDays > 0 ? (limit * elapsedDays / totalDays).round() : 0;
    final dailyAllowance =
        daysLeft > 0 ? math.max(0, limit - spent) ~/ daysLeft : 0;

    var forecast = spent;
    DateTime? runOut;
    if (timing == PeriodTiming.current) {
      final rate = _blendedDailyRate(
        budget,
        period,
        rows,
        limit: limit,
        elapsedDays: elapsedDays,
        totalDays: totalDays,
        paceEnd: period.elapsed(now).endExclusive,
      );
      final daysAfterToday = totalDays - elapsedDays;
      forecast = spent + (rate * daysAfterToday).round();
      if (spent <= limit && forecast > limit && rate > 0) {
        final days = ((limit - spent) / rate).ceil();
        final today = _day(now);
        final date = DateTime(today.year, today.month, today.day + days);
        if (!date.isAfter(period.lastDay)) runOut = date;
      }
    }

    // At risk: clearly forecast to overrun, or past the alert threshold and
    // forecast to overrun at all. Being past the threshold alone is not
    // enough (rent paid on the 1st can use 80% of a housing budget safely).
    final BudgetStatus status;
    if (spent > limit) {
      status = BudgetStatus.over;
    } else if (timing == PeriodTiming.current &&
        (forecast > limit * (1 + riskMargin) ||
            (limit > 0 &&
                spent >= limit * budget.alertThreshold &&
                forecast > limit))) {
      status = BudgetStatus.atRisk;
    } else {
      status = BudgetStatus.onTrack;
    }

    final start = _day(budget.startDate);
    return BudgetPeriodResult(
      budget: budget,
      period: period,
      timing: timing,
      planMinor: plan,
      adjustmentMinor: adjustment,
      carryInMinor: carry,
      limitMinor: limit,
      spentMinor: spent,
      totalDays: totalDays,
      elapsedDays: elapsedDays,
      daysLeft: daysLeft,
      expectedByTodayMinor: expectedByToday,
      forecastMinor: forecast,
      dailyAllowanceMinor: dailyAllowance,
      runOutDate: runOut,
      status: status,
      startedMidPeriod:
          start.isAfter(period.start) && start.isBefore(period.endExclusive),
    );
  }

  /// Expected spending per remaining day, in minor units.
  ///
  /// Blends this period's pace with the category's usual pace, trusting the
  /// current pace more as the period goes on. Early in a period a few
  /// purchases therefore do not project a runaway month, and one-off large
  /// payments never set the pace. With no history, the part of the plan not
  /// already taken by one-off payments is assumed to be spent evenly.
  /// Future-dated transactions count as spent but do not set the pace.
  double _blendedDailyRate(
    Budget budget,
    Period period,
    List<CountedTransaction> rows, {
    required int limit,
    required int elapsedDays,
    required int totalDays,
    required DateTime paceEnd,
  }) {
    if (totalDays <= 0) return 0;
    final lump = limit > 0 ? limit * lumpShare : double.infinity;
    var steady = 0;
    var lumps = 0;
    for (final r in rows) {
      if (r.amountMinor >= lump) {
        lumps += r.amountMinor;
      } else if (r.date.isBefore(paceEnd)) {
        steady += r.amountMinor;
      }
    }
    final current = elapsedDays > 0 ? steady / elapsedDays : 0.0;
    final usual =
        _usualDailyRate(budget, period, lump) ??
        (math.max(0, limit - lumps) / totalDays);
    final w = elapsedDays / totalDays;
    return w * current + (1 - w) * usual;
  }

  /// Median daily steady spending over the previous periods that had any
  /// spending; null when there is none (a new user or a new category).
  double? _usualDailyRate(Budget budget, Period period, double lump) {
    if (!isRecurring(budget)) return null;
    final rates = <double>[];
    var p = period;
    for (var i = 0; i < historyPeriodsForForecast; i++) {
      p = p.previous();
      final rows = ledger.transactionsIn(budget.categoryIds, p);
      if (rows.isEmpty) continue;
      final steady = rows
          .where((r) => r.amountMinor < lump)
          .fold<int>(0, (sum, r) => sum + r.amountMinor);
      rates.add(steady / p.dayCount);
    }
    if (rates.isEmpty) return null;
    rates.sort();
    final mid = rates.length ~/ 2;
    return rates.length.isOdd ? rates[mid] : (rates[mid - 1] + rates[mid]) / 2;
  }

  /// The [count] periods before [period], oldest first.
  List<BudgetPeriodResult> history(
    Budget budget,
    Period period, {
    required DateTime now,
    int count = 6,
  }) {
    if (!isRecurring(budget)) return const [];
    final results = <BudgetPeriodResult>[];
    var p = period;
    for (var i = 0; i < count; i++) {
      p = p.previous();
      results.add(evaluate(budget, p, now: now));
    }
    return results.reversed.toList();
  }

  /// Most urgent first: over (largest overspend first), then at risk
  /// (largest projected overshoot first), then on track (most used first).
  static int compareUrgency(BudgetPeriodResult a, BudgetPeriodResult b) {
    final byStatus = a.status.index.compareTo(b.status.index);
    if (byStatus != 0) return byStatus;
    switch (a.status) {
      case BudgetStatus.over:
        return b.overMinor.compareTo(a.overMinor);
      case BudgetStatus.atRisk:
        double overshoot(BudgetPeriodResult r) =>
            r.limitMinor > 0 ? r.forecastMinor / r.limitMinor : 0;
        return overshoot(b).compareTo(overshoot(a));
      case BudgetStatus.onTrack:
        return b.fractionUsed.compareTo(a.fractionUsed);
    }
  }
}
