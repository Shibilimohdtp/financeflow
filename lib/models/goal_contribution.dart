import '../core/errors/app_error.dart';

class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? accountId;
  final String? notes;
  final DateTime createdAt;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.accountId,
    this.notes,
    required this.createdAt,
  });

  GoalContribution copyWith({
    String? id,
    String? goalId,
    double? amount,
    DateTime? date,
    String? accountId,
    String? notes,
    DateTime? createdAt,
  }) {
    return GoalContribution(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  void validate() {
    if (amount <= 0) {
      throw const ValidationError(
        message: 'Contribution amount must be greater than zero.',
        actionableStep: 'Enter a valid amount in rupees.',
      );
    }
    if (goalId.trim().isEmpty) {
      throw const ValidationError(
        message: 'Goal ID is required.',
        actionableStep: 'Select a valid savings goal.',
      );
    }
  }
}
