/// The single definition of reporting periods used by home, insights,
/// budgets and the transaction list.
///
/// Boundaries are local calendar days. All arithmetic goes through
/// `DateTime(y, m, d + n)` rather than adding `Duration`s, so a period never
/// gains or loses an hour (or a day) across DST changes. Ranges are half-open:
/// `[start, endExclusive)`.
enum PeriodUnit {
  day,
  week,
  month,
  year,
  custom;

  String get label => switch (this) {
    day => 'Day',
    week => 'Week',
    month => 'Month',
    year => 'Year',
    custom => 'Custom',
  };
}

class Period {
  final PeriodUnit unit;

  /// Local midnight of the first day.
  final DateTime start;

  /// Local midnight of the day after the last day.
  final DateTime endExclusive;

  /// `DateTime.monday` … `DateTime.sunday`; only meaningful for weeks.
  final int weekStart;

  const Period._(this.unit, this.start, this.endExclusive, this.weekStart);

  /// The day/week/month/year period that contains [reference].
  factory Period.containing(
    PeriodUnit unit,
    DateTime reference, {
    int weekStart = DateTime.monday,
  }) {
    assert(unit != PeriodUnit.custom, 'Use Period.custom for custom ranges');
    assert(weekStart >= DateTime.monday && weekStart <= DateTime.sunday);
    final r = reference;
    switch (unit) {
      case PeriodUnit.day:
        return Period._(
          unit,
          DateTime(r.year, r.month, r.day),
          DateTime(r.year, r.month, r.day + 1),
          weekStart,
        );
      case PeriodUnit.week:
        final offset = (r.weekday - weekStart + 7) % 7;
        return Period._(
          unit,
          DateTime(r.year, r.month, r.day - offset),
          DateTime(r.year, r.month, r.day - offset + 7),
          weekStart,
        );
      case PeriodUnit.month:
        return Period._(
          unit,
          DateTime(r.year, r.month),
          DateTime(r.year, r.month + 1),
          weekStart,
        );
      case PeriodUnit.year:
        return Period._(
          unit,
          DateTime(r.year),
          DateTime(r.year + 1),
          weekStart,
        );
      case PeriodUnit.custom:
        throw ArgumentError('Use Period.custom for custom ranges');
    }
  }

  /// Inclusive calendar days [firstDay]..[lastDay]; times are ignored.
  factory Period.custom(DateTime firstDay, DateTime lastDay) {
    var a = DateTime(firstDay.year, firstDay.month, firstDay.day);
    var b = DateTime(lastDay.year, lastDay.month, lastDay.day);
    if (b.isBefore(a)) (a, b) = (b, a);
    return Period._(
      PeriodUnit.custom,
      a,
      DateTime(b.year, b.month, b.day + 1),
      DateTime.monday,
    );
  }

  /// Last calendar day in the period (local midnight).
  DateTime get lastDay =>
      DateTime(endExclusive.year, endExclusive.month, endExclusive.day - 1);

  /// Last representable instant, for APIs that take an inclusive end.
  DateTime get endInclusive =>
      endExclusive.subtract(const Duration(milliseconds: 1));

  int get dayCount {
    var n = 0;
    var d = start;
    while (d.isBefore(endExclusive)) {
      n++;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return n;
  }

  /// Every day in the period, as local midnights.
  List<DateTime> get days => [
    for (var i = 0; i < dayCount; i++)
      DateTime(start.year, start.month, start.day + i),
  ];

  bool contains(DateTime instant) =>
      !instant.isBefore(start) && instant.isBefore(endExclusive);

  Period shift(int steps) {
    if (steps == 0) return this;
    switch (unit) {
      case PeriodUnit.day:
      case PeriodUnit.week:
      case PeriodUnit.year:
      case PeriodUnit.month:
        final anchor = switch (unit) {
          PeriodUnit.day => DateTime(
            start.year,
            start.month,
            start.day + steps,
          ),
          PeriodUnit.week => DateTime(
            start.year,
            start.month,
            start.day + 7 * steps,
          ),
          PeriodUnit.month => DateTime(start.year, start.month + steps),
          _ => DateTime(start.year + steps),
        };
        return Period.containing(unit, anchor, weekStart: weekStart);
      case PeriodUnit.custom:
        final n = dayCount * steps;
        return Period.custom(
          DateTime(start.year, start.month, start.day + n),
          DateTime(lastDay.year, lastDay.month, lastDay.day + n),
        );
    }
  }

  Period previous() => shift(-1);
  Period next() => shift(1);

  bool isCurrent(DateTime now) => contains(now);

  /// The part of this period that has already happened by [now], ending at
  /// the end of [now]'s day. Past periods are returned whole; future periods
  /// are empty (start == end).
  Period elapsed(DateTime now) {
    if (!now.isBefore(endExclusive)) return this;
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(start)) {
      return Period._(unit, start, start, weekStart);
    }
    return Period._(
      unit,
      start,
      DateTime(today.year, today.month, today.day + 1),
      weekStart,
    );
  }

  /// A like-for-like comparison window for "versus last period".
  ///
  /// For the period in progress this is the same number of elapsed days at
  /// the start of the previous period (e.g. 1–5 Nov vs 1–5 Oct), so a partial
  /// month is never compared with a full one. Day counts are clamped to the
  /// previous period's length (31 Mar vs 1–28 Feb). For finished periods it
  /// is simply the whole previous period.
  ({Period current, Period previous}) comparison(DateTime now) {
    final current = elapsed(now);
    final prev = previous();
    if (current.endExclusive == endExclusive) {
      return (current: this, previous: prev);
    }
    final elapsedDays = current.dayCount;
    final prevDays = prev.dayCount;
    final n = elapsedDays < prevDays ? elapsedDays : prevDays;
    return (
      current: current,
      previous: Period._(
        prev.unit,
        prev.start,
        DateTime(prev.start.year, prev.start.month, prev.start.day + n),
        weekStart,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Period &&
      other.unit == unit &&
      other.start == start &&
      other.endExclusive == endExclusive &&
      other.weekStart == weekStart;

  @override
  int get hashCode => Object.hash(unit, start, endExclusive, weekStart);

  @override
  String toString() => 'Period(${unit.name}, $start → $endExclusive)';
}
