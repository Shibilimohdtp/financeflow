import '../core/errors/app_error.dart';

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

class Budget {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amountLimit;
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
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    this.endDate,
    this.alertThreshold = 0.8,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? amountLimit,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      amountLimit: amountLimit ?? this.amountLimit,
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
    if (amountLimit <= 0) {
      throw const ValidationError(
        message: 'Budget amount must be greater than zero.',
        actionableStep: 'Enter a valid positive amount limit in rupees.',
      );
    }
    if (categoryId.trim().isEmpty) {
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
