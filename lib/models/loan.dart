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
