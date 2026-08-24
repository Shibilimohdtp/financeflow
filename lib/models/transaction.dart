import '../core/errors/app_error.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  investment,
  loanEmi,
  cash;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.loanEmi:
        return 'Loan / EMI';
      case TransactionType.cash:
        return 'Cash';
    }
  }

  static TransactionType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'expense':
        return TransactionType.expense;
      case 'income':
        return TransactionType.income;
      case 'transfer':
        return TransactionType.transfer;
      case 'investment':
        return TransactionType.investment;
      case 'loan_emi':
      case 'loanemi':
      case 'loan':
      case 'emi':
        return TransactionType.loanEmi;
      case 'cash':
        return TransactionType.cash;
      default:
        return TransactionType.expense;
    }
  }

  String toDbString() {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
      case TransactionType.transfer:
        return 'transfer';
      case TransactionType.investment:
        return 'investment';
      case TransactionType.loanEmi:
        return 'loan_emi';
      case TransactionType.cash:
        return 'cash';
    }
  }
}

/// Why money moved. This is deliberately independent from how an entry is
/// grouped in the legacy UI (`TransactionType`).
enum TransactionPurpose {
  expense,
  income,
  internalTransfer,
  lending,
  borrowing,
  personalDebtRepaymentMade,
  personalDebtRepaymentReceived,
  loanDisbursement,
  loanRepayment,
  investmentPurchase,
  investmentRedemption,
  accountAdjustment,
  legacyCash;

  String get displayName => switch (this) {
    expense => 'Expense',
    income => 'Income',
    internalTransfer => 'Between owned accounts',
    lending => 'Lend to someone',
    borrowing => 'Borrow from someone',
    personalDebtRepaymentMade => 'Repay personal borrowing',
    personalDebtRepaymentReceived => 'Receive repayment',
    loanDisbursement => 'Loan disbursement',
    loanRepayment => 'Pay Loan / EMI',
    investmentPurchase => 'Invest',
    investmentRedemption => 'Investment redemption',
    accountAdjustment => 'Account adjustment',
    legacyCash => 'Legacy cash entry',
  };

  static TransactionPurpose? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return TransactionPurpose.values.where((e) => e.name == value).firstOrNull;
  }
}

enum AccountMovementDirection {
  inflow,
  outflow,
  internal;

  static AccountMovementDirection? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return AccountMovementDirection.values
        .where((e) => e.name == value)
        .firstOrNull;
  }
}

enum TransactionSource {
  manual,
  notification,
  sms,
  email,
  csv,
  xlsx,
  ofx,
  qif,
  other;

  String get displayName {
    switch (this) {
      case TransactionSource.manual:
        return 'Manual';
      case TransactionSource.notification:
        return 'Notification';
      case TransactionSource.sms:
        return 'SMS';
      case TransactionSource.email:
        return 'Email';
      case TransactionSource.csv:
        return 'CSV';
      case TransactionSource.xlsx:
        return 'Excel (XLSX)';
      case TransactionSource.ofx:
        return 'OFX';
      case TransactionSource.qif:
        return 'QIF';
      case TransactionSource.other:
        return 'Other';
    }
  }

  static TransactionSource fromString(String val) {
    switch (val.toLowerCase()) {
      case 'manual':
        return TransactionSource.manual;
      case 'notification':
        return TransactionSource.notification;
      case 'sms':
        return TransactionSource.sms;
      case 'email':
        return TransactionSource.email;
      case 'csv':
        return TransactionSource.csv;
      case 'xlsx':
        return TransactionSource.xlsx;
      case 'ofx':
        return TransactionSource.ofx;
      case 'qif':
        return TransactionSource.qif;
      default:
        return TransactionSource.other;
    }
  }

  String toDbString() => name;
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final String merchant;
  final DateTime date;
  final String? notes;
  final TransactionSource source;
  final String? paymentMethod;
  final String accountId;
  final String? toAccountId;
  final TransactionPurpose? purpose;
  final AccountMovementDirection? direction;
  final String? externalCounterpartyName;
  final String? linkedLoanId;
  final String? linkedMoneyRecordId;
  final String? linkedInvestmentId;
  final double? principalComponent;
  final double? interestComponent;
  final double? feeComponent;
  final List<String> tags;
  final bool isReviewed;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Phase 3 Ingestion & Provenance Extensions
  final String? originalMerchant;
  final String? normalizedMerchant;
  final String? sourceName;
  final String? sourceReference;
  final String? sourceMessageId;
  final String? fingerprint;
  final String? duplicateGroupId;
  final List<String> mergedSources;
  final DateTime? importedAt;
  final DateTime? detectedAt;
  final String
  reviewStatus; // 'confirmed', 'needs_review', 'merged', 'excluded'
  final double? categorizationConfidence;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.merchant,
    required this.date,
    this.notes,
    this.source = TransactionSource.manual,
    this.paymentMethod,
    required this.accountId,
    this.toAccountId,
    this.purpose,
    this.direction,
    this.externalCounterpartyName,
    this.linkedLoanId,
    this.linkedMoneyRecordId,
    this.linkedInvestmentId,
    this.principalComponent,
    this.interestComponent,
    this.feeComponent,
    this.tags = const [],
    this.isReviewed = true,
    required this.createdAt,
    required this.updatedAt,
    this.originalMerchant,
    this.normalizedMerchant,
    this.sourceName,
    this.sourceReference,
    this.sourceMessageId,
    this.fingerprint,
    this.duplicateGroupId,
    this.mergedSources = const [],
    this.importedAt,
    this.detectedAt,
    this.reviewStatus = 'confirmed',
    this.categorizationConfidence,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? merchant,
    DateTime? date,
    String? notes,
    TransactionSource? source,
    String? paymentMethod,
    String? accountId,
    String? toAccountId,
    bool clearToAccountId = false,
    TransactionPurpose? purpose,
    AccountMovementDirection? direction,
    String? externalCounterpartyName,
    String? linkedLoanId,
    String? linkedMoneyRecordId,
    String? linkedInvestmentId,
    double? principalComponent,
    double? interestComponent,
    double? feeComponent,
    bool clearSemanticLinks = false,
    List<String>? tags,
    bool? isReviewed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? originalMerchant,
    String? normalizedMerchant,
    String? sourceName,
    String? sourceReference,
    String? sourceMessageId,
    String? fingerprint,
    String? duplicateGroupId,
    List<String>? mergedSources,
    DateTime? importedAt,
    DateTime? detectedAt,
    String? reviewStatus,
    double? categorizationConfidence,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      toAccountId: clearToAccountId ? null : toAccountId ?? this.toAccountId,
      purpose: purpose ?? this.purpose,
      direction: direction ?? this.direction,
      externalCounterpartyName:
          clearSemanticLinks
              ? null
              : externalCounterpartyName ?? this.externalCounterpartyName,
      linkedLoanId:
          clearSemanticLinks ? null : linkedLoanId ?? this.linkedLoanId,
      linkedMoneyRecordId:
          clearSemanticLinks
              ? null
              : linkedMoneyRecordId ?? this.linkedMoneyRecordId,
      linkedInvestmentId:
          clearSemanticLinks
              ? null
              : linkedInvestmentId ?? this.linkedInvestmentId,
      principalComponent:
          clearSemanticLinks
              ? null
              : principalComponent ?? this.principalComponent,
      interestComponent:
          clearSemanticLinks
              ? null
              : interestComponent ?? this.interestComponent,
      feeComponent:
          clearSemanticLinks ? null : feeComponent ?? this.feeComponent,
      tags: tags ?? this.tags,
      isReviewed: isReviewed ?? this.isReviewed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalMerchant: originalMerchant ?? this.originalMerchant,
      normalizedMerchant: normalizedMerchant ?? this.normalizedMerchant,
      sourceName: sourceName ?? this.sourceName,
      sourceReference: sourceReference ?? this.sourceReference,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      fingerprint: fingerprint ?? this.fingerprint,
      duplicateGroupId: duplicateGroupId ?? this.duplicateGroupId,
      mergedSources: mergedSources ?? this.mergedSources,
      importedAt: importedAt ?? this.importedAt,
      detectedAt: detectedAt ?? this.detectedAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      categorizationConfidence:
          categorizationConfidence ?? this.categorizationConfidence,
    );
  }

  TransactionPurpose get effectivePurpose =>
      purpose ??
      switch (type) {
        TransactionType.expense => TransactionPurpose.expense,
        TransactionType.income => TransactionPurpose.income,
        TransactionType.transfer => TransactionPurpose.internalTransfer,
        TransactionType.investment => TransactionPurpose.investmentPurchase,
        TransactionType.loanEmi => TransactionPurpose.loanRepayment,
        TransactionType.cash => TransactionPurpose.legacyCash,
      };

  AccountMovementDirection get effectiveDirection =>
      direction ??
      switch (effectivePurpose) {
        TransactionPurpose.income ||
        TransactionPurpose.borrowing ||
        TransactionPurpose.personalDebtRepaymentReceived ||
        TransactionPurpose.loanDisbursement ||
        TransactionPurpose
            .investmentRedemption => AccountMovementDirection.inflow,
        TransactionPurpose.internalTransfer =>
          AccountMovementDirection.internal,
        _ => AccountMovementDirection.outflow,
      };

  double get feeAmount => feeComponent ?? 0;
  double get interestAmount => interestComponent ?? 0;
  double get principalAmount => principalComponent ?? 0;

  double get earnedIncomeAmount => switch (effectivePurpose) {
    TransactionPurpose.income => amount,
    TransactionPurpose.investmentRedemption => interestAmount,
    _ => 0,
  };

  double get consumptionExpenseAmount => switch (effectivePurpose) {
    TransactionPurpose.expense || TransactionPurpose.legacyCash => amount,
    TransactionPurpose.loanRepayment => interestAmount + feeAmount,
    TransactionPurpose.investmentPurchase ||
    TransactionPurpose.investmentRedemption => feeAmount,
    _ => 0,
  };

  double get cashInflowAmount =>
      effectiveDirection == AccountMovementDirection.inflow ? amount : 0;
  double get cashOutflowAmount =>
      effectiveDirection == AccountMovementDirection.outflow ? amount : 0;

  bool get isLinkedOperation =>
      linkedLoanId != null ||
      linkedMoneyRecordId != null ||
      linkedInvestmentId != null;

  /// Validation according to Phase 1 and 3 rules
  void validate() {
    if (amount <= 0) {
      throw const ValidationError(
        message: 'Amount must be greater than zero.',
        actionableStep: 'Enter a valid amount in rupees.',
      );
    }
    if (merchant.trim().isEmpty) {
      throw const ValidationError(
        message: 'Payee / Merchant name is required.',
        actionableStep: 'Enter the name of the merchant or recipient.',
      );
    }
    if (accountId.trim().isEmpty) {
      throw const ValidationError(
        message: 'Account is required.',
        actionableStep: 'Select an account for this transaction.',
      );
    }
    if (type == TransactionType.transfer) {
      if (toAccountId == null || toAccountId!.trim().isEmpty) {
        throw const ValidationError(
          message: 'Destination account is required for transfers.',
          actionableStep: 'Select the account receiving the funds.',
        );
      }
      if (toAccountId == accountId) {
        throw const ValidationError(
          message:
              'Transfer source and destination accounts must be different.',
          actionableStep: 'Choose two distinct accounts.',
        );
      }
    } else {
      if (categoryId.trim().isEmpty) {
        throw const ValidationError(
          message: 'Category is required.',
          actionableStep: 'Choose a category for this transaction.',
        );
      }
    }
    if (principalAmount < 0 || interestAmount < 0 || feeAmount < 0) {
      throw const ValidationError(
        message: 'Transaction components cannot be negative.',
      );
    }
  }
}
