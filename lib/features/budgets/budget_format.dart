import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/money/money_math.dart';
import '../../models/budget.dart';
import '../../services/budgets/budget_board.dart';
import '../../services/budgets/budget_engine.dart';

/// Words, icons and spoken text for budget figures, shared by the Plan tab,
/// the budget detail and the Home card. Status is always words plus an icon,
/// never colour alone.
abstract final class BudgetFormat {
  static String money(int minor) =>
      CurrencyFormatter.formatAmount(MoneyMath.fromMinor(minor));

  static String status(BudgetStatus s) => switch (s) {
    BudgetStatus.over => 'Over',
    BudgetStatus.atRisk => 'At risk',
    BudgetStatus.onTrack => 'On track',
  };

  static IconData statusIcon(BudgetStatus s) => switch (s) {
    BudgetStatus.over => Icons.error_outline_rounded,
    BudgetStatus.atRisk => Icons.warning_amber_rounded,
    BudgetStatus.onTrack => Icons.check_circle_outline_rounded,
  };

  /// The plan's status in words, for the hero badge.
  static String planStatus(BudgetBoard board) => switch (board.timing) {
    PeriodTiming.future => 'Not started',
    PeriodTiming.past =>
      board.spentMinor > board.plannedMinor ? 'Over plan' : 'Within plan',
    PeriodTiming.current => switch (board.status) {
      BudgetStatus.over => 'Over plan',
      BudgetStatus.atRisk => 'Needs attention',
      BudgetStatus.onTrack => 'On track',
    },
  };

  static IconData planStatusIcon(BudgetBoard board) =>
      board.timing == PeriodTiming.past
          ? (board.spentMinor > board.plannedMinor
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded)
          : board.timing == PeriodTiming.future
          ? Icons.schedule_rounded
          : statusIcon(board.status);

  /// "Ahead of pace by ₹2,140", "Under pace by ₹900" or "On pace".
  static String pace(int spentMinor, int expectedMinor) {
    final diff = spentMinor - expectedMinor;
    if (diff.abs() < MoneyMath.minorPerMajor) return 'On pace';
    return diff > 0
        ? 'Ahead of pace by ${money(diff)}'
        : 'Under pace by ${money(-diff)}';
  }

  static int percent(double fraction) => (fraction * 100).round();

  /// What a budget's progress bar announces: "62% used, ₹2,400 left, ahead
  /// of pace by ₹300". Hidden amounts announce only the share.
  static String progressSemantics(
    BudgetPeriodResult r, {
    required bool hidden,
  }) {
    final used = '${percent(r.fractionUsed)}% used';
    if (hidden) return used;
    final left =
        r.overMinor > 0
            ? '${money(r.overMinor)} over'
            : '${money(r.leftMinor)} left';
    final parts = [used, left];
    if (r.timing == PeriodTiming.current) {
      parts.add(pace(r.spentMinor, r.expectedByTodayMinor).toLowerCase());
    }
    return parts.join(', ');
  }

  /// "month", "week", "year" for copy like "in 3 of the last 5 months".
  static String periodNoun(BudgetPeriod p, {int count = 1}) {
    final noun = switch (p) {
      BudgetPeriod.weekly => 'week',
      BudgetPeriod.yearly => 'year',
      BudgetPeriod.custom => 'period',
      BudgetPeriod.monthly => 'month',
    };
    return count == 1 ? noun : '${noun}s';
  }

  /// "1 Nov" style short date.
  static String shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
