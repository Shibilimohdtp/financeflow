import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/budget.dart';
import 'budget_engine.dart';

enum BudgetSuggestionKind { raise, lower }

/// One concrete change, applied with a single tap.
class BudgetSuggestion {
  final BudgetSuggestionKind kind;
  final int newLimitMinor;

  /// When raising: how many typical purchases a period would need to skip
  /// to stay on the current plan instead. Null when not meaningful.
  final int? skipPurchases;

  const BudgetSuggestion({
    required this.kind,
    required this.newLimitMinor,
    this.skipPurchases,
  });
}

class MerchantTotal {
  final String name;
  final int amountMinor;
  final int count;

  const MerchantTotal(this.name, this.amountMinor, this.count);
}

/// What a budget's past says, and what to change.
class BudgetInsight {
  /// Closed periods considered, oldest first. Leading periods with no
  /// spending (before the user had data) are dropped.
  final List<BudgetPeriodResult> history;
  final int exceededCount;

  /// Average overspend in the periods that went over; 0 when none did.
  final int averageOvershootMinor;
  final int medianSpentMinor;

  /// Closed periods in a row, most recent first, that stayed within limit.
  final int withinLimitStreak;

  /// Biggest merchants in the period being viewed, largest first.
  final List<MerchantTotal> topMerchants;

  /// Average purchase size across the history and the viewed period.
  final int averagePurchaseMinor;
  final BudgetSuggestion? suggestion;

  const BudgetInsight({
    required this.history,
    required this.exceededCount,
    required this.averageOvershootMinor,
    required this.medianSpentMinor,
    required this.withinLimitStreak,
    required this.topMerchants,
    required this.averagePurchaseMinor,
    required this.suggestion,
  });

  /// Suggestions need at least this many closed periods with data.
  static const int minPeriodsForSuggestion = 3;

  /// "Lower" is suggested only when every period used less than this share.
  static const double underUseShare = 0.75;

  factory BudgetInsight.compute(
    BudgetEngine engine,
    Budget budget,
    Period period, {
    required DateTime now,
    int periods = 6,
    int merchants = 3,
  }) {
    final all = engine.history(budget, period, now: now, count: periods);
    final firstWithData = all.indexWhere((r) => r.spentMinor > 0);
    final history =
        firstWithData < 0 ? <BudgetPeriodResult>[] : all.sublist(firstWithData);

    final over = history.where((r) => r.spentMinor > r.limitMinor).toList();
    final averageOvershoot =
        over.isEmpty
            ? 0
            : over.fold<int>(0, (s, r) => s + r.overMinor) ~/ over.length;
    final spent = history.map((r) => r.spentMinor).toList()..sort();
    final median =
        spent.isEmpty
            ? 0
            : spent.length.isOdd
            ? spent[spent.length ~/ 2]
            : (spent[spent.length ~/ 2 - 1] + spent[spent.length ~/ 2]) ~/ 2;

    var streak = 0;
    for (final r in history.reversed) {
      if (r.spentMinor > r.limitMinor) break;
      streak++;
    }

    final current = engine.ledger.transactionsIn(budget.categoryIds, period);
    final byMerchant = <String, (int, int)>{};
    for (final row in current) {
      final key = row.merchant.trim().isEmpty ? 'Other' : row.merchant.trim();
      final (sum, count) = byMerchant[key] ?? (0, 0);
      byMerchant[key] = (sum + row.amountMinor, count + 1);
    }
    final top =
        byMerchant.entries
            .map((e) => MerchantTotal(e.key, e.value.$1, e.value.$2))
            .toList()
          ..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));

    var purchaseCount = current.length;
    var purchaseTotal = current.fold<int>(0, (s, r) => s + r.amountMinor);
    for (final r in history) {
      final rows = engine.ledger.transactionsIn(budget.categoryIds, r.period);
      purchaseCount += rows.length;
      purchaseTotal += rows.fold<int>(0, (s, row) => s + row.amountMinor);
    }
    final averagePurchase =
        purchaseCount > 0 ? purchaseTotal ~/ purchaseCount : 0;

    BudgetSuggestion? suggestion;
    final plan = budget.limitMinor;
    if (history.length >= minPeriodsForSuggestion) {
      if (over.length * 2 >= history.length) {
        final target = MoneyMath.niceCeilMinor(median);
        if (target > plan) {
          suggestion = BudgetSuggestion(
            kind: BudgetSuggestionKind.raise,
            newLimitMinor: target,
            skipPurchases:
                averagePurchase > 0
                    ? (averageOvershoot / averagePurchase).ceil()
                    : null,
          );
        }
      } else if (history.every((r) => r.spentMinor < plan * underUseShare)) {
        final target = MoneyMath.niceCeilMinor((median * 1.1).round());
        if (target > 0 && target < plan) {
          suggestion = BudgetSuggestion(
            kind: BudgetSuggestionKind.lower,
            newLimitMinor: target,
          );
        }
      }
    }

    return BudgetInsight(
      history: history,
      exceededCount: over.length,
      averageOvershootMinor: averageOvershoot,
      medianSpentMinor: median,
      withinLimitStreak: streak,
      topMerchants: top.take(merchants).toList(),
      averagePurchaseMinor: averagePurchase,
      suggestion: suggestion,
    );
  }
}
