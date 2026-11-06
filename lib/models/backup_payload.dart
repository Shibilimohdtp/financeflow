import 'account.dart';
import 'alert_item.dart';
import 'app_settings.dart';
import 'budget.dart';
import 'category.dart';
import 'goal_contribution.dart';
import 'ingestion/parsed_transaction.dart';
import 'investment.dart';
import 'loan.dart';
import 'money_advance.dart';
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
  final int categoryCount;
  final int budgetCount;
  final int goalCount;
  final int goalContributionCount;
  final int subscriptionCount;
  final int loanCount;
  final int emiPaymentCount;
  final int investmentCount;
  final int alertCount;
  final int moneyRecordCount;
  final int moneyAdvanceCount;
  final int moneyRepaymentCount;
  final int pendingTransactionCount;
  final bool settingsIncluded;

  const BackupMetadata({
    this.formatVersion = 2,
    this.appVersion = '1.0.0',
    required this.createdAt,
    this.deviceLabel = 'FinanceFlow Local Backup',
    required this.transactionCount,
    required this.accountCount,
    this.categoryCount = 0,
    required this.budgetCount,
    required this.goalCount,
    this.goalContributionCount = 0,
    required this.subscriptionCount,
    required this.loanCount,
    this.emiPaymentCount = 0,
    required this.investmentCount,
    this.alertCount = 0,
    this.moneyRecordCount = 0,
    this.moneyAdvanceCount = 0,
    this.moneyRepaymentCount = 0,
    this.pendingTransactionCount = 0,
    this.settingsIncluded = false,
  });

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toIso8601String(),
    'deviceLabel': deviceLabel,
    'transactionCount': transactionCount,
    'accountCount': accountCount,
    'categoryCount': categoryCount,
    'budgetCount': budgetCount,
    'goalCount': goalCount,
    'goalContributionCount': goalContributionCount,
    'subscriptionCount': subscriptionCount,
    'loanCount': loanCount,
    'emiPaymentCount': emiPaymentCount,
    'investmentCount': investmentCount,
    'alertCount': alertCount,
    'moneyRecordCount': moneyRecordCount,
    'moneyAdvanceCount': moneyAdvanceCount,
    'moneyRepaymentCount': moneyRepaymentCount,
    'pendingTransactionCount': pendingTransactionCount,
    'settingsIncluded': settingsIncluded,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
    formatVersion: json['formatVersion'] as int? ?? 1,
    appVersion: json['appVersion'] as String? ?? '1.0.0',
    createdAt: DateTime.parse(json['createdAt'] as String),
    deviceLabel: json['deviceLabel'] as String? ?? 'FinanceFlow Local Backup',
    transactionCount: json['transactionCount'] as int? ?? 0,
    accountCount: json['accountCount'] as int? ?? 0,
    categoryCount: json['categoryCount'] as int? ?? 0,
    budgetCount: json['budgetCount'] as int? ?? 0,
    goalCount: json['goalCount'] as int? ?? 0,
    goalContributionCount: json['goalContributionCount'] as int? ?? 0,
    subscriptionCount: json['subscriptionCount'] as int? ?? 0,
    loanCount: json['loanCount'] as int? ?? 0,
    emiPaymentCount: json['emiPaymentCount'] as int? ?? 0,
    investmentCount: json['investmentCount'] as int? ?? 0,
    alertCount: json['alertCount'] as int? ?? 0,
    moneyRecordCount: json['moneyRecordCount'] as int? ?? 0,
    moneyAdvanceCount: json['moneyAdvanceCount'] as int? ?? 0,
    moneyRepaymentCount: json['moneyRepaymentCount'] as int? ?? 0,
    pendingTransactionCount: json['pendingTransactionCount'] as int? ?? 0,
    settingsIncluded: json['settingsIncluded'] as bool? ?? false,
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
  final List<MoneyAdvance> moneyAdvances;
  final List<MoneyRepayment> moneyRepayments;
  final List<ParsedTransaction> pendingTransactions;
  final AppSettings? appSettings;
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
    this.moneyAdvances = const [],
    this.moneyRepayments = const [],
    this.pendingTransactions = const [],
    this.appSettings,
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
    'moneyAdvances': moneyAdvances.map((a) => a.toJson()).toList(),
    'moneyRepayments': moneyRepayments.map((r) => r.toJson()).toList(),
    'pendingTransactions':
        pendingTransactions.map(_pendingTransactionToJson).toList(),
    if (appSettings != null)
      'appSettings': _appSettingsToJson(appSettings!)
    else if (settings.isNotEmpty)
      'settings': settings,
  };

  factory BackupDataPayload.fromJson(Map<String, dynamic> json) {
    final meta = BackupMetadata.fromJson(
      json['metadata'] as Map<String, dynamic>,
    );

    AppSettings? parsedSettings;
    if (json['appSettings'] != null) {
      parsedSettings = _appSettingsFromJson(
        json['appSettings'] as Map<String, dynamic>,
      );
    }

    final records =
        (json['moneyRecords'] as List<dynamic>?)
            ?.map((e) => MoneyRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final rawAdvances =
        (json['moneyAdvances'] as List<dynamic>?)
            ?.map((e) => MoneyAdvance.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <MoneyAdvance>[];

    // Backward compatibility: synthesize advances if missing
    final advances =
        rawAdvances.isNotEmpty
            ? rawAdvances
            : records.map((r) {
              return MoneyAdvance(
                id:
                    r.originTransactionId != null
                        ? 'adv_${r.originTransactionId}'
                        : 'adv_${r.id}',
                moneyRecordId: r.id,
                userId: r.userId,
                amount: r.originalAmount,
                date: r.transactionDate,
                dueDate: r.dueDate,
                notes: r.notes,
                transactionId: r.originTransactionId,
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
              );
            }).toList();

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
      moneyRecords: records,
      moneyAdvances: advances,
      moneyRepayments:
          (json['moneyRepayments'] as List<dynamic>?)
              ?.map((e) => MoneyRepayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pendingTransactions:
          (json['pendingTransactions'] as List<dynamic>?)
              ?.map(
                (e) => _pendingTransactionFromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      appSettings: parsedSettings,
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
    'linkedSubscriptionId': t.linkedSubscriptionId,
    'principalComponent': t.principalComponent,
    'interestComponent': t.interestComponent,
    'feeComponent': t.feeComponent,
    'tags': t.tags,
    'isReviewed': t.isReviewed,
    'originalMerchant': t.originalMerchant,
    'normalizedMerchant': t.normalizedMerchant,
    'sourceName': t.sourceName,
    'sourceReference': t.sourceReference,
    'sourceMessageId': t.sourceMessageId,
    'fingerprint': t.fingerprint,
    'duplicateGroupId': t.duplicateGroupId,
    'mergedSources': t.mergedSources,
    'importedAt': t.importedAt?.toIso8601String(),
    'detectedAt': t.detectedAt?.toIso8601String(),
    'reviewStatus': t.reviewStatus,
    'categorizationConfidence': t.categorizationConfidence,
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
    linkedSubscriptionId: j['linkedSubscriptionId'] as String?,
    principalComponent: (j['principalComponent'] as num?)?.toDouble(),
    interestComponent: (j['interestComponent'] as num?)?.toDouble(),
    feeComponent: (j['feeComponent'] as num?)?.toDouble(),
    tags: List<String>.from(j['tags'] as List? ?? []),
    isReviewed: j['isReviewed'] as bool? ?? true,
    originalMerchant: j['originalMerchant'] as String?,
    normalizedMerchant: j['normalizedMerchant'] as String?,
    sourceName: j['sourceName'] as String?,
    sourceReference: j['sourceReference'] as String?,
    sourceMessageId: j['sourceMessageId'] as String?,
    fingerprint: j['fingerprint'] as String?,
    duplicateGroupId: j['duplicateGroupId'] as String?,
    mergedSources: List<String>.from(j['mergedSources'] as List? ?? []),
    importedAt:
        j['importedAt'] != null
            ? DateTime.parse(j['importedAt'] as String)
            : null,
    detectedAt:
        j['detectedAt'] != null
            ? DateTime.parse(j['detectedAt'] as String)
            : null,
    reviewStatus: j['reviewStatus'] as String? ?? 'confirmed',
    categorizationConfidence:
        (j['categorizationConfidence'] as num?)?.toDouble(),
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
    'currency': s.currency,
    'billingFrequency': s.billingFrequency.name,
    'nextRenewalDate': s.nextRenewalDate.toIso8601String(),
    'lastPaymentDate': s.lastPaymentDate?.toIso8601String(),
    'accountId': s.accountId,
    'category': s.category,
    'paymentMethod': s.paymentMethod,
    'sourceTransactionId': s.sourceTransactionId,
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
        currency: j['currency'] as String? ?? 'INR',
        billingFrequency: SubscriptionFrequency.values.firstWhere(
          (e) => e.name == j['billingFrequency'],
          orElse: () => SubscriptionFrequency.monthly,
        ),
        nextRenewalDate: DateTime.parse(j['nextRenewalDate'] as String),
        lastPaymentDate:
            j['lastPaymentDate'] != null
                ? DateTime.parse(j['lastPaymentDate'] as String)
                : null,
        accountId: j['accountId'] as String?,
        category: j['category'] as String? ?? 'Subscriptions',
        paymentMethod: j['paymentMethod'] as String?,
        sourceTransactionId: j['sourceTransactionId'] as String?,
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
    'realizedProfitLoss': i.realizedProfitLoss,
    'unrealizedProfitLoss': i.unrealizedProfitLoss,
    'lastValuationDate': i.lastValuationDate?.toIso8601String(),
    'notes': i.notes,
    'isArchived': i.isArchived,
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
    realizedProfitLoss: (j['realizedProfitLoss'] as num?)?.toDouble(),
    unrealizedProfitLoss:
        (j['unrealizedProfitLoss'] as num?)?.toDouble() ?? 0.0,
    lastValuationDate:
        j['lastValuationDate'] != null
            ? DateTime.parse(j['lastValuationDate'] as String)
            : null,
    notes: j['notes'] as String?,
    isArchived: j['isArchived'] as bool? ?? false,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    ledgerBaselineInvestedAmount:
        (j['ledgerBaselineInvestedAmount'] as num?)?.toDouble(),
    ledgerBaselineCurrentValue:
        (j['ledgerBaselineCurrentValue'] as num?)?.toDouble(),
    ledgerBaselineRealizedProfitLoss:
        (j['ledgerBaselineRealizedProfitLoss'] as num?)?.toDouble(),
  );

  static Map<String, dynamic> _pendingTransactionToJson(ParsedTransaction p) =>
      {
        'tempId': p.tempId,
        'source': p.source.toDbString(),
        'sourceName': p.sourceName,
        'rawSource': p.rawSource,
        'sourceIdentifier': p.sourceIdentifier,
        'amount': p.amount,
        'type': p.type.toDbString(),
        'rawMerchant': p.rawMerchant,
        'normalizedMerchant': p.normalizedMerchant,
        'merchantDisplayName': p.merchantDisplayName,
        'externalCounterpartyName': p.externalCounterpartyName,
        'date': p.date.toIso8601String(),
        'time': p.time?.toIso8601String(),
        'notes': p.notes,
        'accountId': p.accountId,
        'toAccountId': p.toAccountId,
        'paymentMethod': p.paymentMethod,
        'categoryId': p.categoryId,
        'categoryName': p.categoryName,
        'categoryIcon': p.categoryIcon,
        'categoryColor': p.categoryColor,
        'purpose': p.purpose?.name,
        'direction': p.direction?.name,
        'linkedLoanId': p.linkedLoanId,
        'linkedMoneyRecordId': p.linkedMoneyRecordId,
        'linkedInvestmentId': p.linkedInvestmentId,
        'principalComponent': p.principalComponent,
        'interestComponent': p.interestComponent,
        'feeComponent': p.feeComponent,
        'tags': p.tags,
        'categorizationConfidence': p.categorizationConfidence,
        'categorizationReason': p.categorizationReason,
        'referenceNumber': p.referenceNumber,
        'fingerprint': p.fingerprint,
        'warnings': p.warnings,
        'validationErrors': p.validationErrors,
        'duplicateStatus': p.duplicateStatus.name,
        'matchedTransactionId': p.matchedTransactionId,
        'duplicateReasons': p.duplicateReasons,
        'duplicateConfidence': p.duplicateConfidence,
        'duplicateResolution': p.duplicateResolution.name,
        'isIncluded': p.isIncluded,
        'reviewStatus': p.reviewStatus.name,
        'importedAt': p.importedAt.toIso8601String(),
        'detectedAt': p.detectedAt.toIso8601String(),
      };

  static ParsedTransaction _pendingTransactionFromJson(
    Map<String, dynamic> j,
  ) => ParsedTransaction(
    tempId: j['tempId'] as String?,
    source: TransactionSource.fromString(j['source'] as String? ?? 'csv'),
    sourceName: j['sourceName'] as String?,
    rawSource: j['rawSource'] as String?,
    sourceIdentifier: j['sourceIdentifier'] as String?,
    amount: (j['amount'] as num).toDouble(),
    type: TransactionType.fromString(j['type'] as String? ?? 'expense'),
    rawMerchant: j['rawMerchant'] as String? ?? '',
    normalizedMerchant: j['normalizedMerchant'] as String? ?? '',
    merchantDisplayName: j['merchantDisplayName'] as String?,
    externalCounterpartyName: j['externalCounterpartyName'] as String?,
    date: DateTime.parse(j['date'] as String),
    time: j['time'] != null ? DateTime.parse(j['time'] as String) : null,
    notes: j['notes'] as String?,
    accountId: j['accountId'] as String? ?? '',
    toAccountId: j['toAccountId'] as String?,
    paymentMethod: j['paymentMethod'] as String?,
    categoryId: j['categoryId'] as String? ?? '',
    categoryName: j['categoryName'] as String? ?? '',
    categoryIcon: j['categoryIcon'] as String? ?? '',
    categoryColor: j['categoryColor'] as String? ?? '',
    purpose: TransactionPurpose.fromString(j['purpose'] as String?),
    direction: AccountMovementDirection.fromString(j['direction'] as String?),
    linkedLoanId: j['linkedLoanId'] as String?,
    linkedMoneyRecordId: j['linkedMoneyRecordId'] as String?,
    linkedInvestmentId: j['linkedInvestmentId'] as String?,
    principalComponent: (j['principalComponent'] as num?)?.toDouble(),
    interestComponent: (j['interestComponent'] as num?)?.toDouble(),
    feeComponent: (j['feeComponent'] as num?)?.toDouble(),
    tags: List<String>.from(j['tags'] as List? ?? []),
    categorizationConfidence:
        (j['categorizationConfidence'] as num?)?.toDouble() ?? 0.5,
    categorizationReason: j['categorizationReason'] as String?,
    referenceNumber: j['referenceNumber'] as String?,
    fingerprint: j['fingerprint'] as String? ?? '',
    warnings: List<String>.from(j['warnings'] as List? ?? []),
    validationErrors: List<String>.from(j['validationErrors'] as List? ?? []),
    duplicateStatus: DuplicateMatchLevel.values.firstWhere(
      (e) => e.name == j['duplicateStatus'],
      orElse: () => DuplicateMatchLevel.none,
    ),
    matchedTransactionId: j['matchedTransactionId'] as String?,
    duplicateReasons: List<String>.from(j['duplicateReasons'] as List? ?? []),
    duplicateConfidence: (j['duplicateConfidence'] as num?)?.toDouble() ?? 0.0,
    duplicateResolution: DuplicateResolution.values.firstWhere(
      (e) => e.name == j['duplicateResolution'],
      orElse: () => DuplicateResolution.unresolved,
    ),
    isIncluded: j['isIncluded'] as bool? ?? true,
    reviewStatus: ReviewStatus.values.firstWhere(
      (e) => e.name == j['reviewStatus'],
      orElse: () => ReviewStatus.pending,
    ),
    importedAt:
        j['importedAt'] != null
            ? DateTime.parse(j['importedAt'] as String)
            : null,
    detectedAt:
        j['detectedAt'] != null
            ? DateTime.parse(j['detectedAt'] as String)
            : null,
  );

  static Map<String, dynamic> _appSettingsToJson(AppSettings s) => {
    'hasCompletedOnboarding': s.hasCompletedOnboarding,
    'themePreference': s.themePreference.toDbString(),
    'isBiometricEnabled': s.isBiometricEnabled,
    'isPinEnabled': s.isPinEnabled,
    'isPrivacyBlurEnabled': s.isPrivacyBlurEnabled,
    'isScreenshotProtectionEnabled': s.isScreenshotProtectionEnabled,
    'currencyCode': s.currencyCode,
    'isNotificationDetectionEnabled': s.isNotificationDetectionEnabled,
    'isSmsDetectionEnabled': s.isSmsDetectionEnabled,
    'selectedNotificationPackages': s.selectedNotificationPackages,
    'selectedSmsSenders': s.selectedSmsSenders,
    'lastIngestionScan': s.lastIngestionScan?.toIso8601String(),
    'lastSuccessfulSmsEvent': s.lastSuccessfulSmsEvent?.toIso8601String(),
    'lastSuccessfulNotificationEvent':
        s.lastSuccessfulNotificationEvent?.toIso8601String(),
    'lastGmailScan': s.lastGmailScan?.toIso8601String(),
    'ingestionParsedCount': s.ingestionParsedCount,
    'ingestionRejectedCount': s.ingestionRejectedCount,
    'ingestionDuplicateCount': s.ingestionDuplicateCount,
    'ingestionLastError': s.ingestionLastError,
    'isAlertsEnabled': s.isAlertsEnabled,
    'isBudgetAlertsEnabled': s.isBudgetAlertsEnabled,
    'isSubscriptionAlertsEnabled': s.isSubscriptionAlertsEnabled,
    'isLoanAlertsEnabled': s.isLoanAlertsEnabled,
    'isNeedsReviewAlertsEnabled': s.isNeedsReviewAlertsEnabled,
    'isBackupReminderEnabled': s.isBackupReminderEnabled,
    'lastBackupDate': s.lastBackupDate?.toIso8601String(),
    'lastAlertScan': s.lastAlertScan?.toIso8601String(),
    'autoLockTimeoutMinutes': s.autoLockTimeoutMinutes,
    'dismissedInsightIds': s.dismissedInsightIds,
    'isLocalNotificationsEnabled': s.isLocalNotificationsEnabled,
    'isNeedsReviewNotificationsEnabled': s.isNeedsReviewNotificationsEnabled,
    'isBudgetNotificationEnabled': s.isBudgetNotificationEnabled,
    'isSubscriptionNotificationEnabled': s.isSubscriptionNotificationEnabled,
    'isLoanNotificationEnabled': s.isLoanNotificationEnabled,
    'isBackupNotificationEnabled': s.isBackupNotificationEnabled,
    'hideSensitiveNotificationContent': s.hideSensitiveNotificationContent,
  };

  static AppSettings _appSettingsFromJson(Map<String, dynamic> j) =>
      AppSettings(
        hasCompletedOnboarding: j['hasCompletedOnboarding'] as bool? ?? false,
        themePreference: AppThemePreference.fromString(
          j['themePreference'] as String? ?? 'system',
        ),
        isBiometricEnabled: j['isBiometricEnabled'] as bool? ?? false,
        isPinEnabled: j['isPinEnabled'] as bool? ?? false,
        isPrivacyBlurEnabled: j['isPrivacyBlurEnabled'] as bool? ?? false,
        isScreenshotProtectionEnabled:
            j['isScreenshotProtectionEnabled'] as bool? ?? false,
        currencyCode: j['currencyCode'] as String? ?? 'INR',
        isNotificationDetectionEnabled:
            j['isNotificationDetectionEnabled'] as bool? ?? false,
        isSmsDetectionEnabled: j['isSmsDetectionEnabled'] as bool? ?? false,
        selectedNotificationPackages: List<String>.from(
          j['selectedNotificationPackages'] as List? ?? [],
        ),
        selectedSmsSenders: List<String>.from(
          j['selectedSmsSenders'] as List? ?? [],
        ),
        lastIngestionScan:
            j['lastIngestionScan'] != null
                ? DateTime.parse(j['lastIngestionScan'] as String)
                : null,
        lastSuccessfulSmsEvent:
            j['lastSuccessfulSmsEvent'] != null
                ? DateTime.parse(j['lastSuccessfulSmsEvent'] as String)
                : null,
        lastSuccessfulNotificationEvent:
            j['lastSuccessfulNotificationEvent'] != null
                ? DateTime.parse(j['lastSuccessfulNotificationEvent'] as String)
                : null,
        lastGmailScan:
            j['lastGmailScan'] != null
                ? DateTime.parse(j['lastGmailScan'] as String)
                : null,
        ingestionParsedCount: j['ingestionParsedCount'] as int? ?? 0,
        ingestionRejectedCount: j['ingestionRejectedCount'] as int? ?? 0,
        ingestionDuplicateCount: j['ingestionDuplicateCount'] as int? ?? 0,
        ingestionLastError: j['ingestionLastError'] as String?,
        isAlertsEnabled: j['isAlertsEnabled'] as bool? ?? true,
        isBudgetAlertsEnabled: j['isBudgetAlertsEnabled'] as bool? ?? true,
        isSubscriptionAlertsEnabled:
            j['isSubscriptionAlertsEnabled'] as bool? ?? true,
        isLoanAlertsEnabled: j['isLoanAlertsEnabled'] as bool? ?? true,
        isNeedsReviewAlertsEnabled:
            j['isNeedsReviewAlertsEnabled'] as bool? ?? true,
        isBackupReminderEnabled: j['isBackupReminderEnabled'] as bool? ?? true,
        lastBackupDate:
            j['lastBackupDate'] != null
                ? DateTime.parse(j['lastBackupDate'] as String)
                : null,
        lastAlertScan:
            j['lastAlertScan'] != null
                ? DateTime.parse(j['lastAlertScan'] as String)
                : null,
        autoLockTimeoutMinutes: j['autoLockTimeoutMinutes'] as int? ?? 0,
        dismissedInsightIds: List<String>.from(
          j['dismissedInsightIds'] as List? ?? [],
        ),
        isLocalNotificationsEnabled:
            j['isLocalNotificationsEnabled'] as bool? ?? true,
        isNeedsReviewNotificationsEnabled:
            j['isNeedsReviewNotificationsEnabled'] as bool? ?? true,
        isBudgetNotificationEnabled:
            j['isBudgetNotificationEnabled'] as bool? ?? true,
        isSubscriptionNotificationEnabled:
            j['isSubscriptionNotificationEnabled'] as bool? ?? true,
        isLoanNotificationEnabled:
            j['isLoanNotificationEnabled'] as bool? ?? true,
        isBackupNotificationEnabled:
            j['isBackupNotificationEnabled'] as bool? ?? true,
        hideSensitiveNotificationContent:
            j['hideSensitiveNotificationContent'] as bool? ?? false,
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
  final int restoredCategories;
  final int restoredBudgets;
  final int restoredGoals;
  final int restoredGoalContributions;
  final int restoredSubscriptions;
  final int restoredLoans;
  final int restoredEmiPayments;
  final int restoredInvestments;
  final int restoredMoneyRecords;
  final int restoredMoneyRepayments;
  final int restoredAlerts;
  final int restoredPendingTransactions;
  final bool restoredSettings;
  final int skippedDuplicates;
  final String? errorMessage;
  final bool hadSecurityLockConfigured;

  const RestoreResult({
    required this.isSuccess,
    required this.mode,
    this.restoredTransactions = 0,
    this.restoredAccounts = 0,
    this.restoredCategories = 0,
    this.restoredBudgets = 0,
    this.restoredGoals = 0,
    this.restoredGoalContributions = 0,
    this.restoredSubscriptions = 0,
    this.restoredLoans = 0,
    this.restoredEmiPayments = 0,
    this.restoredInvestments = 0,
    this.restoredMoneyRecords = 0,
    this.restoredMoneyRepayments = 0,
    this.restoredAlerts = 0,
    this.restoredPendingTransactions = 0,
    this.restoredSettings = false,
    this.skippedDuplicates = 0,
    this.errorMessage,
    this.hadSecurityLockConfigured = false,
  });
}
