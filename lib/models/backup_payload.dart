import 'account.dart';
import 'alert_item.dart';
import 'budget.dart';
import 'category.dart';
import 'goal_contribution.dart';
import 'investment.dart';
import 'loan.dart';
import 'money_record.dart';
import 'money_repayment.dart';
import 'savings_goal.dart';
import 'subscription.dart';
import 'transaction.dart';

class BackupMetadata {
  final int formatVersion;
  final String appVersion;
  final DateTime createdAt;
  final String deviceLabel;
  final int transactionCount;
  final int accountCount;
  final int budgetCount;
  final int goalCount;
  final int subscriptionCount;
  final int loanCount;
  final int investmentCount;
  final int alertCount;
  final int moneyRecordCount;
  final int moneyRepaymentCount;

  const BackupMetadata({
    this.formatVersion = 1,
    this.appVersion = '1.0.0',
    required this.createdAt,
    this.deviceLabel = 'FinanceFlow Local Backup',
    required this.transactionCount,
    required this.accountCount,
    required this.budgetCount,
    required this.goalCount,
    required this.subscriptionCount,
    required this.loanCount,
    required this.investmentCount,
    this.alertCount = 0,
    this.moneyRecordCount = 0,
    this.moneyRepaymentCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toIso8601String(),
    'deviceLabel': deviceLabel,
    'transactionCount': transactionCount,
    'accountCount': accountCount,
    'budgetCount': budgetCount,
    'goalCount': goalCount,
    'subscriptionCount': subscriptionCount,
    'loanCount': loanCount,
    'investmentCount': investmentCount,
    'alertCount': alertCount,
    'moneyRecordCount': moneyRecordCount,
    'moneyRepaymentCount': moneyRepaymentCount,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
    formatVersion: json['formatVersion'] as int? ?? 1,
    appVersion: json['appVersion'] as String? ?? '1.0.0',
    createdAt: DateTime.parse(json['createdAt'] as String),
    deviceLabel: json['deviceLabel'] as String? ?? 'FinanceFlow Local Backup',
    transactionCount: json['transactionCount'] as int? ?? 0,
    accountCount: json['accountCount'] as int? ?? 0,
    budgetCount: json['budgetCount'] as int? ?? 0,
    goalCount: json['goalCount'] as int? ?? 0,
    subscriptionCount: json['subscriptionCount'] as int? ?? 0,
    loanCount: json['loanCount'] as int? ?? 0,
    investmentCount: json['investmentCount'] as int? ?? 0,
    alertCount: json['alertCount'] as int? ?? 0,
    moneyRecordCount: json['moneyRecordCount'] as int? ?? 0,
    moneyRepaymentCount: json['moneyRepaymentCount'] as int? ?? 0,
  );
}

class BackupDataPayload {
  final BackupMetadata metadata;
  final List<Account> accounts;
  final List<Transaction> transactions;
  final List<Category> categories;
  final List<Budget> budgets;
  final List<SavingsGoal> savingsGoals;
  final List<GoalContribution> goalContributions;
  final List<Subscription> subscriptions;
  final List<Loan> loans;
  final List<EmiPayment> emiPayments;
  final List<Investment> investments;
  final List<AlertItem> alerts;
  final List<MoneyRecord> moneyRecords;
  final List<MoneyRepayment> moneyRepayments;
  final Map<String, dynamic> settings;

  const BackupDataPayload({
    required this.metadata,
    this.accounts = const [],
    this.transactions = const [],
    this.categories = const [],
    this.budgets = const [],
    this.savingsGoals = const [],
    this.goalContributions = const [],
    this.subscriptions = const [],
    this.loans = const [],
    this.emiPayments = const [],
    this.investments = const [],
    this.alerts = const [],
    this.moneyRecords = const [],
    this.moneyRepayments = const [],
    this.settings = const {},
  });

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'accounts': accounts.map(_accountToJson).toList(),
    'transactions': transactions.map(_transactionToJson).toList(),
    'categories': categories.map(_categoryToJson).toList(),
    'budgets': budgets.map(_budgetToJson).toList(),
    'savingsGoals': savingsGoals.map(_savingsGoalToJson).toList(),
    'goalContributions':
        goalContributions.map(_goalContributionToJson).toList(),
    'subscriptions': subscriptions.map(_subscriptionToJson).toList(),
    'loans': loans.map(_loanToJson).toList(),
    'emiPayments': emiPayments.map((e) => e.toJson()).toList(),
    'investments': investments.map(_investmentToJson).toList(),
    'alerts': alerts.map((a) => a.toJson()).toList(),
    'moneyRecords': moneyRecords.map((r) => r.toJson()).toList(),
    'moneyRepayments': moneyRepayments.map((r) => r.toJson()).toList(),
    'settings': settings,
  };

  factory BackupDataPayload.fromJson(Map<String, dynamic> json) {
    final meta = BackupMetadata.fromJson(
      json['metadata'] as Map<String, dynamic>,
    );
    return BackupDataPayload(
      metadata: meta,
      accounts:
          (json['accounts'] as List<dynamic>?)
              ?.map((e) => _accountFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((e) => _transactionFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => _categoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      budgets:
          (json['budgets'] as List<dynamic>?)
              ?.map((e) => _budgetFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      savingsGoals:
          (json['savingsGoals'] as List<dynamic>?)
              ?.map((e) => _savingsGoalFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      goalContributions:
          (json['goalContributions'] as List<dynamic>?)
              ?.map((e) => _goalContributionFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subscriptions:
          (json['subscriptions'] as List<dynamic>?)
              ?.map((e) => _subscriptionFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      loans:
          (json['loans'] as List<dynamic>?)
              ?.map((e) => _loanFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emiPayments:
          (json['emiPayments'] as List<dynamic>?)
              ?.map((e) => EmiPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      investments:
          (json['investments'] as List<dynamic>?)
              ?.map((e) => _investmentFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      alerts:
          (json['alerts'] as List<dynamic>?)
              ?.map((e) => AlertItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      moneyRecords:
          (json['moneyRecords'] as List<dynamic>?)
              ?.map((e) => MoneyRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      moneyRepayments:
          (json['moneyRepayments'] as List<dynamic>?)
              ?.map((e) => MoneyRepayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );
  }

  // --- Converters ---
  static Map<String, dynamic> _accountToJson(Account a) => {
    'id': a.id,
    'name': a.name,
    'type': a.type.toDbString(),
    'institutionName': a.institutionName,
    'maskedIdentifier': a.maskedIdentifier,
    'openingBalance': a.openingBalance,
    'currentBalance': a.currentBalance,
    'currency': a.currency,
    'isArchived': a.isArchived,
    'createdAt': a.createdAt.toIso8601String(),
    'updatedAt': a.updatedAt.toIso8601String(),
  };

  static Account _accountFromJson(Map<String, dynamic> j) => Account(
    id: j['id'] as String,
    name: j['name'] as String,
    type: AccountType.fromString(j['type'] as String? ?? 'bank'),
    institutionName: j['institutionName'] as String?,
    maskedIdentifier: j['maskedIdentifier'] as String?,
    openingBalance: (j['openingBalance'] as num?)?.toDouble() ?? 0.0,
    currentBalance: (j['currentBalance'] as num?)?.toDouble() ?? 0.0,
    currency: j['currency'] as String? ?? 'INR',
    isArchived: j['isArchived'] as bool? ?? false,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static Map<String, dynamic> _transactionToJson(Transaction t) => {
    'id': t.id,
    'amount': t.amount,
    'type': t.type.toDbString(),
    'categoryId': t.categoryId,
    'categoryName': t.categoryName,
    'categoryIcon': t.categoryIcon,
    'categoryColor': t.categoryColor,
    'merchant': t.merchant,
    'date': t.date.toIso8601String(),
    'notes': t.notes,
    'source': t.source.toDbString(),
    'paymentMethod': t.paymentMethod,
    'accountId': t.accountId,
    'toAccountId': t.toAccountId,
    'purpose': t.purpose?.name,
    'direction': t.direction?.name,
    'externalCounterpartyName': t.externalCounterpartyName,
    'linkedLoanId': t.linkedLoanId,
    'linkedMoneyRecordId': t.linkedMoneyRecordId,
    'linkedInvestmentId': t.linkedInvestmentId,
    'principalComponent': t.principalComponent,
    'interestComponent': t.interestComponent,
    'feeComponent': t.feeComponent,
    'tags': t.tags,
    'isReviewed': t.isReviewed,
    'originalMerchant': t.originalMerchant,
    'normalizedMerchant': t.normalizedMerchant,
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
  };

  static Transaction _transactionFromJson(
    Map<String, dynamic> j,
  ) => Transaction(
    id: j['id'] as String,
    amount: (j['amount'] as num).toDouble(),
    type: TransactionType.fromString(j['type'] as String? ?? 'expense'),
    categoryId: j['categoryId'] as String,
    categoryName: j['categoryName'] as String,
    categoryIcon: j['categoryIcon'] as String,
    categoryColor: j['categoryColor'] as String,
    merchant: j['merchant'] as String,
    date: DateTime.parse(j['date'] as String),
    notes: j['notes'] as String?,
    source: TransactionSource.fromString(j['source'] as String? ?? 'manual'),
    paymentMethod: j['paymentMethod'] as String?,
    accountId: j['accountId'] as String,
    toAccountId: j['toAccountId'] as String?,
    purpose: TransactionPurpose.fromString(j['purpose'] as String?),
    direction: AccountMovementDirection.fromString(j['direction'] as String?),
    externalCounterpartyName: j['externalCounterpartyName'] as String?,
    linkedLoanId: j['linkedLoanId'] as String?,
    linkedMoneyRecordId: j['linkedMoneyRecordId'] as String?,
    linkedInvestmentId: j['linkedInvestmentId'] as String?,
    principalComponent: (j['principalComponent'] as num?)?.toDouble(),
    interestComponent: (j['interestComponent'] as num?)?.toDouble(),
    feeComponent: (j['feeComponent'] as num?)?.toDouble(),
    tags: List<String>.from(j['tags'] as List? ?? []),
    isReviewed: j['isReviewed'] as bool? ?? true,
    originalMerchant: j['originalMerchant'] as String?,
    normalizedMerchant: j['normalizedMerchant'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static Map<String, dynamic> _categoryToJson(Category c) => {
    'id': c.id,
    'name': c.name,
    'iconIdentifier': c.iconIdentifier,
    'colorTokenIdentifier': c.colorTokenIdentifier,
    'typeCompatibility': c.typeCompatibility,
    'isDefault': c.isDefault,
    'isArchived': c.isArchived,
    'sortOrder': c.sortOrder,
    'createdAt': c.createdAt.toIso8601String(),
    'updatedAt': c.updatedAt.toIso8601String(),
  };

  static Category _categoryFromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as String,
    name: j['name'] as String,
    iconIdentifier: j['iconIdentifier'] as String,
    colorTokenIdentifier: j['colorTokenIdentifier'] as String,
    typeCompatibility: List<String>.from(j['typeCompatibility'] as List? ?? []),
    isDefault: j['isDefault'] as bool? ?? false,
    isArchived: j['isArchived'] as bool? ?? false,
    sortOrder: j['sortOrder'] as int? ?? 0,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static Map<String, dynamic> _budgetToJson(Budget b) => {
    'id': b.id,
    'name': b.name,
    'categoryId': b.categoryId,
    'categoryName': b.categoryName,
    'categoryIcon': b.categoryIcon,
    'categoryColor': b.categoryColor,
    'amountLimit': b.amountLimit,
    'period': b.period.toDbString(),
    'startDate': b.startDate.toIso8601String(),
    'endDate': b.endDate?.toIso8601String(),
    'alertThreshold': b.alertThreshold,
    'isArchived': b.isArchived,
    'createdAt': b.createdAt.toIso8601String(),
    'updatedAt': b.updatedAt.toIso8601String(),
  };

  static Budget _budgetFromJson(Map<String, dynamic> j) => Budget(
    id: j['id'] as String,
    name: j['name'] as String,
    categoryId: j['categoryId'] as String,
    categoryName: j['categoryName'] as String?,
    categoryIcon: j['categoryIcon'] as String?,
    categoryColor: j['categoryColor'] as String?,
    amountLimit: (j['amountLimit'] as num).toDouble(),
    period: BudgetPeriod.fromString(j['period'] as String? ?? 'monthly'),
    startDate: DateTime.parse(j['startDate'] as String),
    endDate:
        j['endDate'] != null ? DateTime.parse(j['endDate'] as String) : null,
    alertThreshold: (j['alertThreshold'] as num?)?.toDouble() ?? 0.8,
    isArchived: j['isArchived'] as bool? ?? false,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static Map<String, dynamic> _savingsGoalToJson(SavingsGoal g) => {
    'id': g.id,
    'name': g.name,
    'targetAmount': g.targetAmount,
    'targetDate': g.targetDate.toIso8601String(),
    'linkedAccountId': g.linkedAccountId,
    'notes': g.notes,
    'isCompleted': g.isCompleted,
    'createdAt': g.createdAt.toIso8601String(),
    'updatedAt': g.updatedAt.toIso8601String(),
  };

  static SavingsGoal _savingsGoalFromJson(Map<String, dynamic> j) =>
      SavingsGoal(
        id: j['id'] as String,
        name: j['name'] as String,
        targetAmount: (j['targetAmount'] as num).toDouble(),
        targetDate: DateTime.parse(j['targetDate'] as String),
        linkedAccountId: j['linkedAccountId'] as String?,
        notes: j['notes'] as String?,
        isCompleted: j['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  static Map<String, dynamic> _goalContributionToJson(GoalContribution gc) => {
    'id': gc.id,
    'goalId': gc.goalId,
    'amount': gc.amount,
    'date': gc.date.toIso8601String(),
    'accountId': gc.accountId,
    'notes': gc.notes,
    'createdAt': gc.createdAt.toIso8601String(),
  };

  static GoalContribution _goalContributionFromJson(Map<String, dynamic> j) =>
      GoalContribution(
        id: j['id'] as String,
        goalId: j['goalId'] as String,
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date'] as String),
        accountId: j['accountId'] as String?,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  static Map<String, dynamic> _subscriptionToJson(Subscription s) => {
    'id': s.id,
    'merchant': s.merchant,
    'normalizedMerchant': s.normalizedMerchant,
    'amount': s.amount,
    'billingFrequency': s.billingFrequency.name,
    'nextRenewalDate': s.nextRenewalDate.toIso8601String(),
    'accountId': s.accountId,
    'category': s.category,
    'notes': s.notes,
    'isReminderEnabled': s.isReminderEnabled,
    'reminderDaysBefore': s.reminderDaysBefore,
    'status': s.status.name,
    'createdAt': s.createdAt.toIso8601String(),
    'updatedAt': s.updatedAt.toIso8601String(),
  };

  static Subscription _subscriptionFromJson(Map<String, dynamic> j) =>
      Subscription(
        id: j['id'] as String,
        merchant: j['merchant'] as String,
        normalizedMerchant:
            j['normalizedMerchant'] as String? ??
            (j['merchant'] as String).toLowerCase(),
        amount: (j['amount'] as num).toDouble(),
        billingFrequency: SubscriptionFrequency.values.firstWhere(
          (e) => e.name == j['billingFrequency'],
          orElse: () => SubscriptionFrequency.monthly,
        ),
        nextRenewalDate: DateTime.parse(j['nextRenewalDate'] as String),
        accountId: j['accountId'] as String?,
        category: j['category'] as String? ?? 'Subscriptions',
        notes: j['notes'] as String?,
        isReminderEnabled: j['isReminderEnabled'] as bool? ?? true,
        reminderDaysBefore: j['reminderDaysBefore'] as int? ?? 1,
        status: SubscriptionStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => SubscriptionStatus.active,
        ),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  static Map<String, dynamic> _loanToJson(Loan l) => {
    'id': l.id,
    'name': l.name,
    'lender': l.lender,
    'loanType': l.loanType.name,
    'accountId': l.accountId,
    'principalAmount': l.principalAmount,
    'interestRate': l.interestRate,
    'interestType': l.interestType.name,
    'tenureMonths': l.tenureMonths,
    'startDate': l.startDate.toIso8601String(),
    'expectedEndDate': l.expectedEndDate.toIso8601String(),
    'emiAmount': l.emiAmount,
    'paymentDay': l.paymentDay,
    'totalPrincipalPaid': l.totalPrincipalPaid,
    'totalInterestPaid': l.totalInterestPaid,
    'outstandingPrincipal': l.outstandingPrincipal,
    'nextDueDate': l.nextDueDate.toIso8601String(),
    'status': l.status.name,
    'notes': l.notes,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

  static Loan _loanFromJson(Map<String, dynamic> j) => Loan(
    id: j['id'] as String,
    name: j['name'] as String,
    lender: j['lender'] as String,
    loanType: LoanType.values.firstWhere(
      (e) => e.name == j['loanType'],
      orElse: () => LoanType.personalLoan,
    ),
    accountId: j['accountId'] as String?,
    principalAmount: (j['principalAmount'] as num).toDouble(),
    interestRate: (j['interestRate'] as num).toDouble(),
    interestType: InterestType.values.firstWhere(
      (e) => e.name == j['interestType'],
      orElse: () => InterestType.reducingBalance,
    ),
    tenureMonths: j['tenureMonths'] as int,
    startDate: DateTime.parse(j['startDate'] as String),
    expectedEndDate: DateTime.parse(j['expectedEndDate'] as String),
    emiAmount: (j['emiAmount'] as num).toDouble(),
    paymentDay: j['paymentDay'] as int? ?? 5,
    totalPrincipalPaid: (j['totalPrincipalPaid'] as num?)?.toDouble() ?? 0.0,
    totalInterestPaid: (j['totalInterestPaid'] as num?)?.toDouble() ?? 0.0,
    outstandingPrincipal:
        (j['outstandingPrincipal'] as num?)?.toDouble() ??
        (j['principalAmount'] as num).toDouble(),
    nextDueDate: DateTime.parse(j['nextDueDate'] as String),
    status: LoanStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => LoanStatus.active,
    ),
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static Map<String, dynamic> _investmentToJson(Investment i) => {
    'id': i.id,
    'name': i.name,
    'assetType': i.assetType.name,
    'accountId': i.accountId,
    'quantityOrUnits': i.quantityOrUnits,
    'purchasePrice': i.purchasePrice,
    'purchaseDate': i.purchaseDate.toIso8601String(),
    'currentValue': i.currentValue,
    'investedAmount': i.investedAmount,
    'unrealizedProfitLoss': i.unrealizedProfitLoss,
    'lastValuationDate': i.lastValuationDate?.toIso8601String(),
    'notes': i.notes,
    'createdAt': i.createdAt.toIso8601String(),
    'updatedAt': i.updatedAt.toIso8601String(),
    'ledgerBaselineInvestedAmount': i.ledgerBaselineInvestedAmount,
    'ledgerBaselineCurrentValue': i.ledgerBaselineCurrentValue,
    'ledgerBaselineRealizedProfitLoss': i.ledgerBaselineRealizedProfitLoss,
  };

  static Investment _investmentFromJson(Map<String, dynamic> j) => Investment(
    id: j['id'] as String,
    name: j['name'] as String,
    assetType: AssetType.values.firstWhere(
      (e) => e.name == j['assetType'],
      orElse: () => AssetType.mutualFunds,
    ),
    accountId: j['accountId'] as String?,
    quantityOrUnits: (j['quantityOrUnits'] as num?)?.toDouble() ?? 1.0,
    purchasePrice: (j['purchasePrice'] as num).toDouble(),
    purchaseDate: DateTime.parse(j['purchaseDate'] as String),
    currentValue: (j['currentValue'] as num).toDouble(),
    investedAmount: (j['investedAmount'] as num).toDouble(),
    unrealizedProfitLoss:
        (j['unrealizedProfitLoss'] as num?)?.toDouble() ?? 0.0,
    lastValuationDate:
        j['lastValuationDate'] != null
            ? DateTime.parse(j['lastValuationDate'] as String)
            : null,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    ledgerBaselineInvestedAmount:
        (j['ledgerBaselineInvestedAmount'] as num?)?.toDouble(),
    ledgerBaselineCurrentValue:
        (j['ledgerBaselineCurrentValue'] as num?)?.toDouble(),
    ledgerBaselineRealizedProfitLoss:
        (j['ledgerBaselineRealizedProfitLoss'] as num?)?.toDouble(),
  );
}

enum RestoreMode {
  replace,
  merge;

  String get displayName {
    switch (this) {
      case RestoreMode.replace:
        return 'Replace Current Data';
      case RestoreMode.merge:
        return 'Merge with Current Data';
    }
  }
}

class RestoreResult {
  final bool isSuccess;
  final RestoreMode mode;
  final int restoredTransactions;
  final int restoredAccounts;
  final int restoredBudgets;
  final int restoredGoals;
  final int restoredSubscriptions;
  final int restoredLoans;
  final int restoredInvestments;
  final int skippedDuplicates;
  final String? errorMessage;

  const RestoreResult({
    required this.isSuccess,
    required this.mode,
    this.restoredTransactions = 0,
    this.restoredAccounts = 0,
    this.restoredBudgets = 0,
    this.restoredGoals = 0,
    this.restoredSubscriptions = 0,
    this.restoredLoans = 0,
    this.restoredInvestments = 0,
    this.skippedDuplicates = 0,
    this.errorMessage,
  });
}
