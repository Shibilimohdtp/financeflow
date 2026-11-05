import '../core/errors/app_error.dart';
import '../core/money/money_math.dart';

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }

  static BudgetPeriod fromString(String val) {
    switch (val.toLowerCase()) {
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      case 'custom':
        return BudgetPeriod.custom;
      default:
        return BudgetPeriod.monthly;
    }
  }

  String toDbString() => name;
}

/// Fixed budget groups. User-defined groups are a later addition.
enum BudgetGroup {
  essentials('Essentials'),
  lifestyle('Lifestyle'),
  other('Other');

  final String label;
  const BudgetGroup(this.label);

  static BudgetGroup fromString(String? value) => BudgetGroup.values.firstWhere(
    (g) => g.name == value,
    orElse: () => BudgetGroup.other,
  );
}

/// What happens to the difference between a period's limit and its spending.
enum RolloverMode {
  /// Every period starts from the plain limit.
  off,

  /// Leftover money is added to the next period; overspending is not carried.
  unspent,

  /// Leftover money is added and overspending is subtracted.
  both;

  static RolloverMode fromString(String? value) => RolloverMode.values
      .firstWhere((m) => m.name == value, orElse: () => RolloverMode.off);
}

class Budget {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amountLimit;
  final List<String>? _categoryIds;
  final int? _limitMinor;
  final BudgetGroup group;
  final RolloverMode rolloverMode;

  /// First day of the first period that receives a carried amount. Turning
  /// rollover on never adds money to periods before this one.
  final DateTime? rolloverSince;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final double alertThreshold; // e.g. 0.8 for 80%
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amountLimit,
    List<String>? categoryIds,
    int? limitMinor,
    this.group = BudgetGroup.other,
    this.rolloverMode = RolloverMode.off,
    this.rolloverSince,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    this.endDate,
    this.alertThreshold = 0.8,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  }) : _categoryIds = categoryIds,
       _limitMinor = limitMinor;

  /// Every category this budget covers. Budgets saved before multi-category
  /// support cover only [categoryId].
  List<String> get categoryIds {
    final ids = _categoryIds;
    if (ids == null || ids.isEmpty) return [categoryId];
    return ids;
  }

  /// The limit in integer minor units. Older budgets only stored the
  /// `double` [amountLimit]; it is converted once here.
  int get limitMinor => _limitMinor ?? MoneyMath.toMinor(amountLimit);

  Budget copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? amountLimit,
    List<String>? categoryIds,
    int? limitMinor,
    BudgetGroup? group,
    RolloverMode? rolloverMode,
    DateTime? rolloverSince,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Keep the double and minor-unit limits in step whichever one changed.
    final newMinor =
        limitMinor ??
        (amountLimit != null ? MoneyMath.toMinor(amountLimit) : _limitMinor);
    final newAmount =
        limitMinor != null
            ? MoneyMath.fromMinor(limitMinor)
            : (amountLimit ?? this.amountLimit);
    final newIds = categoryIds ?? _categoryIds;
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId:
          categoryId ??
          (newIds != null && newIds.isNotEmpty
              ? newIds.first
              : this.categoryId),
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      amountLimit: newAmount,
      categoryIds: newIds,
      limitMinor: newMinor,
      group: group ?? this.group,
      rolloverMode: rolloverMode ?? this.rolloverMode,
      rolloverSince: rolloverSince ?? this.rolloverSince,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  void validate() {
    if (name.trim().isEmpty) {
      throw const ValidationError(
        message: 'Budget name is required.',
        actionableStep: 'Enter a descriptive name for this budget.',
      );
    }
    if (limitMinor <= 0) {
      throw const ValidationError(
        message: 'Budget amount must be greater than zero.',
        actionableStep: 'Enter an amount above zero.',
      );
    }
    if (categoryIds.any((id) => id.trim().isEmpty)) {
      throw const ValidationError(
        message: 'Category is required for category budgets.',
        actionableStep: 'Select a category to track with this budget.',
      );
    }
    if (alertThreshold < 0.0 || alertThreshold > 1.0) {
      throw const ValidationError(
        message: 'Alert threshold must be between 0% and 100%.',
        actionableStep: 'Adjust the threshold slider.',
      );
    }
    if (period == BudgetPeriod.custom &&
        endDate != null &&
        endDate!.isBefore(startDate)) {
      throw const ValidationError(
        message: 'End date cannot be before start date.',
        actionableStep: 'Choose an end date after the start date.',
      );
    }
  }
}

/// Calculated metrics for a budget in a specific period
class BudgetSummary {
  final Budget budget;
  final double amountSpent;
  final double remainingAmount;
  final double percentageUsed; // 0.0 to 1.0+ (can exceed 1.0 if over budget)
  final double amountOverBudget;
  final int daysRemaining;
  final int totalDaysInPeriod;
  final int daysElapsed;
  final double dailyAllowanceRemaining;
  final double projectedPeriodEndSpending;
  final bool isApproachingThreshold;
  final bool isExceeded;

  const BudgetSummary({
    required this.budget,
    required this.amountSpent,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.amountOverBudget,
    required this.daysRemaining,
    required this.totalDaysInPeriod,
    required this.daysElapsed,
    required this.dailyAllowanceRemaining,
    required this.projectedPeriodEndSpending,
    required this.isApproachingThreshold,
    required this.isExceeded,
  });
}

/// Why a budget's limit differs from its plan for one period.
enum BudgetAdjustmentKind {
  /// "Raise or lower this period only".
  oneOff,

  /// Money moved into this budget from another one.
  moveIn,

  /// Money moved out of this budget into another one.
  moveOut;

  static BudgetAdjustmentKind fromString(String? value) =>
      BudgetAdjustmentKind.values.firstWhere(
        (k) => k.name == value,
        orElse: () => BudgetAdjustmentKind.oneOff,
      );
}

/// A change to one budget's limit for a single period. A move between
/// budgets is two adjustments sharing a [transferId].
class BudgetAdjustment {
  final String id;
  final String budgetId;

  /// Local midnight of the first day of the period the change applies to.
  final DateTime periodStart;

  /// Positive raises the limit, negative lowers it.
  final int deltaMinor;
  final BudgetAdjustmentKind kind;
  final String? transferId;
  final DateTime createdAt;

  const BudgetAdjustment({
    required this.id,
    required this.budgetId,
    required this.periodStart,
    required this.deltaMinor,
    this.kind = BudgetAdjustmentKind.oneOff,
    this.transferId,
    required this.createdAt,
  });
}
