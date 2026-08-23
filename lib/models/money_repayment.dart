import '../core/errors/app_error.dart';

class MoneyRepayment {
  final String id;
  final String moneyRecordId;
  final String userId;
  final double amount;
  final DateTime repaymentDate;
  final String? notes;
  final DateTime createdAt;

  const MoneyRepayment({
    required this.id,
    required this.moneyRecordId,
    this.userId = 'local_user',
    required this.amount,
    required this.repaymentDate,
    this.notes,
    required this.createdAt,
  });

  MoneyRepayment copyWith({
    String? id,
    String? moneyRecordId,
    String? userId,
    double? amount,
    DateTime? repaymentDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return MoneyRepayment(
      id: id ?? this.id,
      moneyRecordId: moneyRecordId ?? this.moneyRecordId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      repaymentDate: repaymentDate ?? this.repaymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  void validate({double? remainingBalance}) {
    if (moneyRecordId.trim().isEmpty) {
      throw const ValidationError(
        message: 'Record ID is required.',
        actionableStep: 'Associate this repayment with a valid lending/borrowing record.',
      );
    }
    if (amount <= 0) {
      throw const ValidationError(
        message: 'Repayment amount must be greater than zero.',
        actionableStep: 'Enter a valid positive repayment amount.',
      );
    }
    if (remainingBalance != null && amount > (remainingBalance + 0.001)) {
      throw const ValidationError(
        message: 'Repayment amount cannot exceed the remaining balance.',
        actionableStep: 'Enter an amount less than or equal to the outstanding balance.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'moneyRecordId': moneyRecordId,
    'userId': userId,
    'amount': amount,
    'repaymentDate': repaymentDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MoneyRepayment.fromJson(Map<String, dynamic> json) => MoneyRepayment(
    id: json['id'] as String,
    moneyRecordId: json['moneyRecordId'] as String,
    userId: json['userId'] as String? ?? 'local_user',
    amount: (json['amount'] as num).toDouble(),
    repaymentDate: DateTime.parse(json['repaymentDate'] as String),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
