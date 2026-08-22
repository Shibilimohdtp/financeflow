import '../core/errors/app_error.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime targetDate;
  final String? linkedAccountId;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    this.linkedAccountId,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
    String? linkedAccountId,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  void validate() {
    if (name.trim().isEmpty) {
      throw const ValidationError(
        message: 'Goal name is required.',
        actionableStep: 'Enter a name for what you are saving towards.',
      );
    }
    if (targetAmount <= 0) {
      throw const ValidationError(
        message: 'Target amount must be greater than zero.',
        actionableStep: 'Enter a positive target amount in rupees.',
      );
    }
  }
}

/// Calculated metrics for a savings goal
class SavingsGoalSummary {
  final SavingsGoal goal;
  final double currentAmount;
  final double remainingAmount;
  final double progressPercentage; // 0.0 to 1.0
  final double suggestedMonthlyContribution;
  final double suggestedWeeklyContribution;
  final DateTime? estimatedCompletionDate;
  final int contributionCount;
  final bool isTargetReached;

  const SavingsGoalSummary({
    required this.goal,
    required this.currentAmount,
    required this.remainingAmount,
    required this.progressPercentage,
    required this.suggestedMonthlyContribution,
    required this.suggestedWeeklyContribution,
    this.estimatedCompletionDate,
    required this.contributionCount,
    required this.isTargetReached,
  });
}
