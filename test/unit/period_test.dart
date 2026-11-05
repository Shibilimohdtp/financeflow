import 'package:financeflow/core/period/period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Period.containing', () {
    test('day covers exactly one calendar day', () {
      final p = Period.containing(
        PeriodUnit.day,
        DateTime(2026, 11, 5, 23, 59),
      );
      expect(p.start, DateTime(2026, 11, 5));
      expect(p.endExclusive, DateTime(2026, 11, 6));
      expect(p.contains(DateTime(2026, 11, 5, 23, 59, 59, 999)), isTrue);
      expect(p.contains(DateTime(2026, 11, 6)), isFalse);
    });

    test('week starts on Monday by default', () {
      // Thursday 5 Nov 2026.
      final p = Period.containing(PeriodUnit.week, DateTime(2026, 11, 5));
      expect(p.start, DateTime(2026, 11, 2));
      expect(p.endExclusive, DateTime(2026, 11, 9));
      expect(p.dayCount, 7);
    });

    test('week honours a Sunday or Saturday week start', () {
      final sun = Period.containing(
        PeriodUnit.week,
        DateTime(2026, 11, 5),
        weekStart: DateTime.sunday,
      );
      expect(sun.start, DateTime(2026, 11, 1));
      final sat = Period.containing(
        PeriodUnit.week,
        DateTime(2026, 11, 7), // a Saturday
        weekStart: DateTime.saturday,
      );
      expect(sat.start, DateTime(2026, 11, 7));
    });

    test('week crossing a month and year boundary', () {
      final p = Period.containing(PeriodUnit.week, DateTime(2027, 1, 1));
      expect(p.start, DateTime(2026, 12, 28));
      expect(p.endExclusive, DateTime(2027, 1, 4));
    });

    test('month and year lengths, including leap February', () {
      expect(
        Period.containing(PeriodUnit.month, DateTime(2028, 2, 10)).dayCount,
        29,
      );
      expect(
        Period.containing(PeriodUnit.month, DateTime(2026, 2, 10)).dayCount,
        28,
      );
      expect(
        Period.containing(PeriodUnit.year, DateTime(2028, 6, 1)).dayCount,
        366,
      );
    });
  });

  group('navigation', () {
    test('previous/next month across year end', () {
      final dec = Period.containing(PeriodUnit.month, DateTime(2026, 12, 15));
      expect(dec.next().start, DateTime(2027, 1));
      expect(dec.next().previous(), dec);
    });

    test('custom range shifts by its own length', () {
      final p = Period.custom(DateTime(2026, 11, 1), DateTime(2026, 11, 10));
      expect(p.dayCount, 10);
      final prev = p.previous();
      expect(prev.start, DateTime(2026, 10, 22));
      expect(prev.lastDay, DateTime(2026, 10, 31));
    });

    test('custom range accepts reversed dates', () {
      final p = Period.custom(DateTime(2026, 11, 10), DateTime(2026, 11, 1));
      expect(p.start, DateTime(2026, 11, 1));
      expect(p.lastDay, DateTime(2026, 11, 10));
    });
  });

  group('comparison', () {
    test('month in progress compares the same elapsed days', () {
      final now = DateTime(2026, 11, 5, 14);
      final c = Period.containing(PeriodUnit.month, now).comparison(now);
      expect(c.current.start, DateTime(2026, 11, 1));
      expect(c.current.endExclusive, DateTime(2026, 11, 6));
      expect(c.previous.start, DateTime(2026, 10, 1));
      expect(c.previous.endExclusive, DateTime(2026, 10, 6));
    });

    test('elapsed days are clamped to a shorter previous month', () {
      final now = DateTime(2026, 3, 31);
      final c = Period.containing(PeriodUnit.month, now).comparison(now);
      expect(c.current.dayCount, 31);
      expect(c.previous.start, DateTime(2026, 2, 1));
      expect(c.previous.endExclusive, DateTime(2026, 3, 1));
    });

    test('a finished period compares with the whole previous period', () {
      final now = DateTime(2026, 11, 5);
      final october = Period.containing(PeriodUnit.month, DateTime(2026, 10));
      final c = october.comparison(now);
      expect(c.current, october);
      expect(c.previous, october.previous());
    });

    test('week in progress', () {
      final now = DateTime(2026, 11, 4); // Wednesday
      final c = Period.containing(PeriodUnit.week, now).comparison(now);
      expect(c.current.dayCount, 3);
      expect(c.previous.start, DateTime(2026, 10, 26));
      expect(c.previous.dayCount, 3);
    });
  });

  test('day boundaries survive a DST change (no Duration arithmetic)', () {
    // Whatever the host time zone, every day in a year is a distinct local
    // midnight and the year has 365 of them.
    final year = Period.containing(PeriodUnit.year, DateTime(2026, 7, 1));
    final days = year.days;
    expect(days, hasLength(365));
    for (final d in days) {
      expect(d.hour, 0);
    }
    expect(days.toSet(), hasLength(365));
  });
}
