import '../core/errors/app_error.dart';

class MoneyAdvance {
  final String id;
  final String moneyRecordId;
  final String userId;
  final double amount;
  final DateTime date;
  final DateTime dueDate;
  final String? notes;
  final String? accountId;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoneyAdvance({
    required this.id,
    required this.moneyRecordId,
    this.userId = 'local_user',
    required this.amount,
    required this.date,
    required this.dueDate,
    this.notes,
    this.accountId,
    this.transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  MoneyAdvance copyWith({
    String? id,
    String? moneyRecordId,
    String? userId,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    String? notes,
    String? accountId,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearTransactionId = false,
    bool clearAccountId = false,
    bool clearNotes = false,
  }) {
    return MoneyAdvance(
      id: id ?? this.id,
      moneyRecordId: moneyRecordId ?? this.moneyRecordId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      notes: clearNotes ? null : (notes ?? this.notes),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      transactionId:
          clearTransactionId ? null : (transactionId ?? this.transactionId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  void validate() {
    if (moneyRecordId.trim().isEmpty) {
      throw const ValidationError(
        message: 'Relationship record ID is required.',
        actionableStep: 'Associate this advance with a valid debt relationship.',
      );
    }
    if (amount <= 0) {
      throw const ValidationError(
        message: 'Advance amount must be greater than zero.',
        actionableStep: 'Enter a valid positive amount in rupees.',
      );
    }
    final advanceDay = DateTime(date.year, date.month, date.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (dueDay.isBefore(advanceDay)) {
      throw const ValidationError(
        message: 'Due date cannot be earlier than the advance date.',
        actionableStep: 'Set a due date on or after the advance date.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'moneyRecordId': moneyRecordId,
    'userId': userId,
    'amount': amount,
    'date': date.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'notes': notes,
    'accountId': accountId,
    'transactionId': transactionId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MoneyAdvance.fromJson(Map<String, dynamic> json) => MoneyAdvance(
    id: json['id'] as String,
    moneyRecordId: json['moneyRecordId'] as String,
    userId: json['userId'] as String? ?? 'local_user',
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    notes: json['notes'] as String?,
    accountId: json['accountId'] as String?,
    transactionId: json['transactionId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
