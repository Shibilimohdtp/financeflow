import 'package:flutter/material.dart';
import '../core/errors/app_error.dart';
import '../theme/stillwater_colors.dart';
import 'money_repayment.dart';

enum MoneyRecordType {
  lent,
  borrowed;

  String get displayName {
    switch (this) {
      case MoneyRecordType.lent:
        return 'Lent (Owed to Me)';
      case MoneyRecordType.borrowed:
        return 'Borrowed (I Owe)';
    }
  }

  String get shortName {
    switch (this) {
      case MoneyRecordType.lent:
        return 'Lent';
      case MoneyRecordType.borrowed:
        return 'Borrowed';
    }
  }

  String get directionLabel {
    switch (this) {
      case MoneyRecordType.lent:
        return 'Money Owed to Me';
      case MoneyRecordType.borrowed:
        return 'Money I Owe';
    }
  }

  Color get color {
    switch (this) {
      case MoneyRecordType.lent:
        return StillwaterColors.lightIncome;
      case MoneyRecordType.borrowed:
        return StillwaterColors.lightExpense;
    }
  }

  IconData get icon {
    switch (this) {
      case MoneyRecordType.lent:
        return Icons.call_made_rounded;
      case MoneyRecordType.borrowed:
        return Icons.call_received_rounded;
    }
  }

  static MoneyRecordType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'lent':
      case 'owed_to_me':
      case 'owedtome':
        return MoneyRecordType.lent;
      case 'borrowed':
      case 'i_owe':
      case 'iowe':
      default:
        return MoneyRecordType.borrowed;
    }
  }

  String toDbString() {
    switch (this) {
      case MoneyRecordType.lent:
        return 'lent';
      case MoneyRecordType.borrowed:
        return 'borrowed';
    }
  }
}

enum MoneyRecordStatus {
  active,
  dueSoon,
  overdue,
  partiallyPaid,
  settled;

  String get displayName {
    switch (this) {
      case MoneyRecordStatus.active:
        return 'Active';
      case MoneyRecordStatus.dueSoon:
        return 'Due Soon';
      case MoneyRecordStatus.overdue:
        return 'Overdue';
      case MoneyRecordStatus.partiallyPaid:
        return 'Partially Paid';
      case MoneyRecordStatus.settled:
        return 'Settled';
    }
  }

  Color get color {
    switch (this) {
      case MoneyRecordStatus.active:
        return StillwaterColors.lightPrimary;
      case MoneyRecordStatus.dueSoon:
        return StillwaterColors.lightWarning;
      case MoneyRecordStatus.overdue:
        return StillwaterColors.lightError;
      case MoneyRecordStatus.partiallyPaid:
        return StillwaterColors.lightTransfer;
      case MoneyRecordStatus.settled:
        return StillwaterColors.lightIncome;
    }
  }
}

class MoneyRecord {
  final String id;
  final String userId;
  final MoneyRecordType type;
  final String personName;
  final double originalAmount;
  final DateTime transactionDate;
  final DateTime dueDate;
  final String? notes;
  final bool isReminderEnabled;
  final int reminderDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? settledAt;

  const MoneyRecord({
    required this.id,
    this.userId = 'local_user',
    required this.type,
    required this.personName,
    required this.originalAmount,
    required this.transactionDate,
    required this.dueDate,
    this.notes,
    this.isReminderEnabled = true,
    this.reminderDaysBefore = 1,
    required this.createdAt,
    required this.updatedAt,
    this.settledAt,
  });

  MoneyRecord copyWith({
    String? id,
    String? userId,
    MoneyRecordType? type,
    String? personName,
    double? originalAmount,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? notes,
    bool? isReminderEnabled,
    int? reminderDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? settledAt,
    bool clearSettledAt = false,
  }) {
    return MoneyRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      originalAmount: originalAmount ?? this.originalAmount,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settledAt: clearSettledAt ? null : (settledAt ?? this.settledAt),
    );
  }

  void validate() {
    if (personName.trim().isEmpty) {
      throw const ValidationError(
        message: "Person's name is required.",
        actionableStep: 'Enter the name of the person you lent to or borrowed from.',
      );
    }
    if (originalAmount <= 0) {
      throw const ValidationError(
        message: 'Amount must be greater than zero.',
        actionableStep: 'Enter a valid positive amount.',
      );
    }

    final txDay = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (dueDay.isBefore(txDay)) {
      throw const ValidationError(
        message: 'Due date cannot be earlier than the transaction date.',
        actionableStep: 'Set a due date on or after the transaction date.',
      );
    }
  }

  double calculateTotalRepaid(List<MoneyRepayment> repayments) {
    return repayments
        .where((r) => r.moneyRecordId == id)
        .fold<double>(0.0, (sum, r) => sum + r.amount);
  }

  double calculateRemainingAmount(List<MoneyRepayment> repayments) {
    final repaid = calculateTotalRepaid(repayments);
    final remaining = originalAmount - repaid;
    return remaining > 0.001 ? remaining : 0.0;
  }

  bool isFullySettled(List<MoneyRepayment> repayments) {
    if (settledAt != null) return true;
    return calculateRemainingAmount(repayments) <= 0.001;
  }

  bool isOverdue({DateTime? asOfDate, List<MoneyRepayment>? repayments}) {
    if (repayments != null && isFullySettled(repayments)) return false;
    final now = asOfDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDay.isBefore(today);
  }

  bool isDueSoon({
    DateTime? asOfDate,
    int thresholdDays = 7,
    List<MoneyRepayment>? repayments,
  }) {
    if (repayments != null && isFullySettled(repayments)) return false;
    final now = asOfDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDay.difference(today).inDays;
    return difference >= 0 && difference <= thresholdDays;
  }

  MoneyRecordStatus calculateStatus(
    List<MoneyRepayment> repayments, {
    DateTime? asOfDate,
    int dueSoonThresholdDays = 7,
  }) {
    if (isFullySettled(repayments)) {
      return MoneyRecordStatus.settled;
    }

    final repaid = calculateTotalRepaid(repayments);
    final isOver = isOverdue(asOfDate: asOfDate, repayments: repayments);
    final isSoon = isDueSoon(
      asOfDate: asOfDate,
      thresholdDays: dueSoonThresholdDays,
      repayments: repayments,
    );

    if (isOver) {
      return MoneyRecordStatus.overdue;
    }

    if (isSoon) {
      return MoneyRecordStatus.dueSoon;
    }

    if (repaid > 0.001) {
      return MoneyRecordStatus.partiallyPaid;
    }

    return MoneyRecordStatus.active;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.toDbString(),
    'personName': personName,
    'originalAmount': originalAmount,
    'transactionDate': transactionDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'notes': notes,
    'isReminderEnabled': isReminderEnabled,
    'reminderDaysBefore': reminderDaysBefore,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'settledAt': settledAt?.toIso8601String(),
  };

  factory MoneyRecord.fromJson(Map<String, dynamic> json) => MoneyRecord(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? 'local_user',
    type: MoneyRecordType.fromString(json['type'] as String? ?? 'lent'),
    personName: json['personName'] as String,
    originalAmount: (json['originalAmount'] as num).toDouble(),
    transactionDate: DateTime.parse(json['transactionDate'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    notes: json['notes'] as String?,
    isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
    reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 1,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    settledAt: json['settledAt'] != null ? DateTime.parse(json['settledAt'] as String) : null,
  );
}
