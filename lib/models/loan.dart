import '../core/errors/app_error.dart';

enum LoanType {
  homeLoan,
  personalLoan,
  educationLoan,
  vehicleLoan,
  creditCardEmi,
  bnpl,
  other;

  String get displayName {
    switch (this) {
      case LoanType.homeLoan:
        return 'Home Loan';
      case LoanType.personalLoan:
        return 'Personal Loan';
      case LoanType.educationLoan:
        return 'Education Loan';
      case LoanType.vehicleLoan:
        return 'Vehicle Loan';
      case LoanType.creditCardEmi:
        return 'Credit Card EMI';
      case LoanType.bnpl:
        return 'BNPL';
      case LoanType.other:
        return 'Other Loan';
    }
  }

  static LoanType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'home_loan':
      case 'homeloan':
        return LoanType.homeLoan;
      case 'personal_loan':
      case 'personalloan':
        return LoanType.personalLoan;
      case 'education_loan':
      case 'educationloan':
        return LoanType.educationLoan;
      case 'vehicle_loan':
      case 'vehicleloan':
      case 'car_loan':
      case 'bike_loan':
        return LoanType.vehicleLoan;
      case 'credit_card_emi':
      case 'creditcardemi':
        return LoanType.creditCardEmi;
      case 'bnpl':
        return LoanType.bnpl;
      default:
        return LoanType.other;
    }
  }

  String toDbString() {
    switch (this) {
      case LoanType.homeLoan:
        return 'home_loan';
      case LoanType.personalLoan:
        return 'personal_loan';
      case LoanType.educationLoan:
        return 'education_loan';
      case LoanType.vehicleLoan:
        return 'vehicle_loan';
      case LoanType.creditCardEmi:
        return 'credit_card_emi';
      case LoanType.bnpl:
        return 'bnpl';
      case LoanType.other:
        return 'other';
    }
  }
}

enum InterestType {
  reducingBalance,
  flatRate;

  String get displayName {
    switch (this) {
      case InterestType.reducingBalance:
        return 'Reducing Balance';
      case InterestType.flatRate:
        return 'Flat Rate';
    }
  }

  static InterestType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'flat_rate':
      case 'flat':
        return InterestType.flatRate;
      case 'reducing_balance':
      case 'reducing':
      default:
        return InterestType.reducingBalance;
    }
  }

  String toDbString() {
    switch (this) {
      case InterestType.flatRate:
        return 'flat_rate';
      case InterestType.reducingBalance:
        return 'reducing_balance';
    }
  }
}

enum LoanStatus {
  active,
  paidOff,
  paused,
  archived;

  String get displayName {
    switch (this) {
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.paidOff:
        return 'Paid Off';
      case LoanStatus.paused:
        return 'Paused';
      case LoanStatus.archived:
        return 'Archived';
    }
  }

  static LoanStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'paid_off':
      case 'paidoff':
      case 'closed':
        return LoanStatus.paidOff;
      case 'paused':
        return LoanStatus.paused;
      case 'archived':
        return LoanStatus.archived;
      case 'active':
      default:
        return LoanStatus.active;
    }
  }

  String toDbString() {
    switch (this) {
      case LoanStatus.paidOff:
        return 'paid_off';
      default:
        return name;
    }
  }
}

class Loan {
  final String id;
  final String name;
  final String lender;
  final LoanType loanType;
  final String? accountId;
  final double principalAmount;
  final double interestRate; // Annual %
  final InterestType interestType;
  final int tenureMonths;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final double emiAmount;
  final int paymentDay;
  final double totalPrincipalPaid;
  final double totalInterestPaid;
  final double outstandingPrincipal;
  final DateTime nextDueDate;
  final LoanStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Loan({
    required this.id,
    required this.name,
    required this.lender,
    this.loanType = LoanType.personalLoan,
    this.accountId,
    required this.principalAmount,
    required this.interestRate,
    this.interestType = InterestType.reducingBalance,
    required this.tenureMonths,
    required this.startDate,
    required this.expectedEndDate,
    required this.emiAmount,
    this.paymentDay = 5,
    this.totalPrincipalPaid = 0.0,
    this.totalInterestPaid = 0.0,
    required this.outstandingPrincipal,
    required this.nextDueDate,
    this.status = LoanStatus.active,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (principalAmount <= 0) return 0.0;
    if (status == LoanStatus.paidOff || outstandingPrincipal <= 0.0) return 1.0;
    return (totalPrincipalPaid / principalAmount).clamp(0.0, 1.0);
  }

  int daysUntilDue({DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return due.difference(today).inDays;
  }

  bool isDueSoon({int daysThreshold = 3, DateTime? referenceDate}) {
    if (status != LoanStatus.active) return false;
    final diff = daysUntilDue(referenceDate: referenceDate);
    return diff >= 0 && diff <= daysThreshold;
  }

  Loan copyWith({
    String? id,
    String? name,
    String? lender,
    LoanType? loanType,
    String? accountId,
    double? principalAmount,
    double? interestRate,
    InterestType? interestType,
    int? tenureMonths,
    DateTime? startDate,
    DateTime? expectedEndDate,
    double? emiAmount,
    int? paymentDay,
    double? totalPrincipalPaid,
    double? totalInterestPaid,
    double? outstandingPrincipal,
    DateTime? nextDueDate,
    LoanStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      lender: lender ?? this.lender,
      loanType: loanType ?? this.loanType,
      accountId: accountId ?? this.accountId,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      interestType: interestType ?? this.interestType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      emiAmount: emiAmount ?? this.emiAmount,
      paymentDay: paymentDay ?? this.paymentDay,
      totalPrincipalPaid: totalPrincipalPaid ?? this.totalPrincipalPaid,
      totalInterestPaid: totalInterestPaid ?? this.totalInterestPaid,
      outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lender': lender,
    'loanType': loanType.name,
    'accountId': accountId,
    'principalAmount': principalAmount,
    'interestRate': interestRate,
    'interestType': interestType.name,
    'tenureMonths': tenureMonths,
    'startDate': startDate.toIso8601String(),
    'expectedEndDate': expectedEndDate.toIso8601String(),
    'emiAmount': emiAmount,
    'paymentDay': paymentDay,
    'totalPrincipalPaid': totalPrincipalPaid,
    'totalInterestPaid': totalInterestPaid,
    'outstandingPrincipal': outstandingPrincipal,
    'nextDueDate': nextDueDate.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as String,
    name: json['name'] as String,
    lender: json['lender'] as String,
    loanType: LoanType.fromString(json['loanType'] as String? ?? 'other'),
    accountId: json['accountId'] as String?,
    principalAmount: (json['principalAmount'] as num).toDouble(),
    interestRate: (json['interestRate'] as num).toDouble(),
    interestType: InterestType.fromString(
      json['interestType'] as String? ?? 'reducing_balance',
    ),
    tenureMonths: json['tenureMonths'] as int,
    startDate: DateTime.parse(json['startDate'] as String),
    expectedEndDate: DateTime.parse(json['expectedEndDate'] as String),
    emiAmount: (json['emiAmount'] as num).toDouble(),
    paymentDay: json['paymentDay'] as int? ?? 5,
    totalPrincipalPaid: (json['totalPrincipalPaid'] as num?)?.toDouble() ?? 0.0,
    totalInterestPaid: (json['totalInterestPaid'] as num?)?.toDouble() ?? 0.0,
    outstandingPrincipal: (json['outstandingPrincipal'] as num).toDouble(),
    nextDueDate: DateTime.parse(json['nextDueDate'] as String),
    status: LoanStatus.fromString(json['status'] as String? ?? 'active'),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

enum EmiPaymentStatus {
  paid,
  overdue,
  upcoming;

  String get displayName {
    switch (this) {
      case EmiPaymentStatus.paid:
        return 'Paid';
      case EmiPaymentStatus.overdue:
        return 'Overdue';
      case EmiPaymentStatus.upcoming:
        return 'Upcoming';
    }
  }

  static EmiPaymentStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'paid':
        return EmiPaymentStatus.paid;
      case 'overdue':
      case 'missed':
        return EmiPaymentStatus.overdue;
      case 'upcoming':
      case 'pending':
      default:
        return EmiPaymentStatus.upcoming;
    }
  }
}

class EmiPayment {
  final String id;
  final String loanId;
  final int installmentNumber;
  final DateTime dueDate;
  final DateTime paymentDate;
  final double principalPaid;
  final double interestPaid;
  final double emiAmount;
  final String? accountId;
  final String? transactionId;
  final bool isHistoricalStatusOnly;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmiPayment({
    required this.id,
    required this.loanId,
    required this.installmentNumber,
    required this.dueDate,
    required this.paymentDate,
    required this.principalPaid,
    required this.interestPaid,
    required this.emiAmount,
    this.accountId,
    this.transactionId,
    this.isHistoricalStatusOnly = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  void validate() {
    if (loanId.trim().isEmpty) {
      throw const ValidationError(
        message: 'Loan ID is required for recording an EMI payment.',
      );
    }
    if (installmentNumber <= 0) {
      throw const ValidationError(
        message: 'Installment number must be greater than 0.',
      );
    }
    if (emiAmount <= 0) {
      throw const ValidationError(
        message: 'Payment amount must be greater than 0.',
      );
    }
    if (principalPaid < 0 || interestPaid < 0) {
      throw const ValidationError(
        message: 'Principal and interest paid cannot be negative.',
      );
    }
  }

  EmiPayment copyWith({
    String? id,
    String? loanId,
    int? installmentNumber,
    DateTime? dueDate,
    DateTime? paymentDate,
    double? principalPaid,
    double? interestPaid,
    double? emiAmount,
    String? accountId,
    String? transactionId,
    bool? isHistoricalStatusOnly,
    bool clearTransactionId = false,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmiPayment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      principalPaid: principalPaid ?? this.principalPaid,
      interestPaid: interestPaid ?? this.interestPaid,
      emiAmount: emiAmount ?? this.emiAmount,
      accountId: accountId ?? this.accountId,
      transactionId:
          clearTransactionId ? null : transactionId ?? this.transactionId,
      isHistoricalStatusOnly:
          isHistoricalStatusOnly ?? this.isHistoricalStatusOnly,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'installmentNumber': installmentNumber,
    'dueDate': dueDate.toIso8601String(),
    'paymentDate': paymentDate.toIso8601String(),
    'principalPaid': principalPaid,
    'interestPaid': interestPaid,
    'emiAmount': emiAmount,
    'accountId': accountId,
    'transactionId': transactionId,
    'isHistoricalStatusOnly': isHistoricalStatusOnly,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory EmiPayment.fromJson(Map<String, dynamic> json) => EmiPayment(
    id: json['id'] as String,
    loanId: json['loanId'] as String,
    installmentNumber: json['installmentNumber'] as int,
    dueDate: DateTime.parse(json['dueDate'] as String),
    paymentDate: DateTime.parse(json['paymentDate'] as String),
    principalPaid: (json['principalPaid'] as num).toDouble(),
    interestPaid: (json['interestPaid'] as num).toDouble(),
    emiAmount: (json['emiAmount'] as num).toDouble(),
    accountId: json['accountId'] as String?,
    transactionId: json['transactionId'] as String?,
    isHistoricalStatusOnly: json['isHistoricalStatusOnly'] as bool? ?? false,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class EmiInstallment {
  final int installmentNumber;
  final DateTime dueDate;
  final double openingBalance;
  final double emiAmount;
  final double principalPaid;
  final double interestPaid;
  final double closingBalance;
  final EmiPaymentStatus status;
  final EmiPayment? payment;

  const EmiInstallment({
    required this.installmentNumber,
    required this.dueDate,
    required this.openingBalance,
    required this.emiAmount,
    required this.principalPaid,
    required this.interestPaid,
    required this.closingBalance,
    required this.status,
    this.payment,
  });

  bool get isPaid => status == EmiPaymentStatus.paid;
  bool get isOverdue => status == EmiPaymentStatus.overdue;
  bool get isUpcoming => status == EmiPaymentStatus.upcoming;

  int daysOverdue({DateTime? referenceDate}) {
    if (!isOverdue) return 0;
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = today.difference(due).inDays;
    return diff > 0 ? diff : 0;
  }
}
