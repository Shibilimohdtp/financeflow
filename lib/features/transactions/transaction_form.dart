import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/investment.dart';
import '../../models/loan.dart';
import '../../models/money_record.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../services/merchant_normalization_service.dart';

/// Raw values from the add/edit form. Pure data, so validation and the
/// transaction it produces can be unit-tested without widgets.
class TransactionFormValues {
  final String amountText;
  final String payeeText;
  final String notesText;
  final String tagsText;
  final String counterpartyText;
  final String principalText;
  final String interestText;
  final String feeText;
  final TransactionType type;
  final TransactionPurpose purpose;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final Loan? loan;
  final MoneyRecord? moneyRecord;
  final Investment? investment;
  final Subscription? subscription;
  final DateTime date;
  final DateTime? debtDueDate;
  final bool createAsSeparateDebt;
  final String paymentMethod;

  const TransactionFormValues({
    required this.amountText,
    required this.payeeText,
    this.notesText = '',
    this.tagsText = '',
    this.counterpartyText = '',
    this.principalText = '',
    this.interestText = '',
    this.feeText = '',
    required this.type,
    required this.purpose,
    this.category,
    this.account,
    this.toAccount,
    this.loan,
    this.moneyRecord,
    this.investment,
    this.subscription,
    required this.date,
    this.debtDueDate,
    this.createAsSeparateDebt = false,
    this.paymentMethod = 'UPI',
  });

  bool get needsCategory => purpose != TransactionPurpose.internalTransfer;

  static const allPaymentMethods = <String>[
    'UPI',
    'Debit Card',
    'Credit Card',
    'Cash',
    'Net Banking',
    'Auto Debit',
    'IMPS / NEFT',
    'Other',
  ];

  static String defaultPaymentFor(TransactionType type) => switch (type) {
    TransactionType.cash => 'Cash',
    TransactionType.loanEmi => 'Auto Debit',
    TransactionType.transfer => 'IMPS / NEFT',
    _ => 'UPI',
  };

  static List<String> paymentMethodsFor(TransactionType type) => switch (type) {
    TransactionType.cash => const ['Cash', 'Other'],
    TransactionType.loanEmi => const [
      'Auto Debit',
      'UPI',
      'Net Banking',
      'Other',
    ],
    TransactionType.transfer => const [
      'IMPS / NEFT',
      'UPI',
      'Net Banking',
      'Other',
    ],
    _ => allPaymentMethods,
  };

  static TransactionType typeForPurpose(
    TransactionPurpose purpose,
  ) => switch (purpose) {
    TransactionPurpose.income ||
    TransactionPurpose.borrowing ||
    TransactionPurpose.loanDisbursement ||
    TransactionPurpose.personalDebtRepaymentReceived => TransactionType.income,
    TransactionPurpose.internalTransfer => TransactionType.transfer,
    TransactionPurpose.investmentPurchase ||
    TransactionPurpose.investmentRedemption => TransactionType.investment,
    TransactionPurpose.loanRepayment => TransactionType.loanEmi,
    TransactionPurpose.legacyCash => TransactionType.cash,
    _ => TransactionType.expense,
  };

  static String formatInitialAmount(double amount) =>
      amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);

  /// Computes a helpful, human-readable one-line consequence of saving the
  /// transaction with the given [account], [toAccount], and [amount].
  static ({String text, bool isWarning})? calculateConsequenceLine({
    required TransactionType type,
    required TransactionPurpose purpose,
    required Account? account,
    required Account? toAccount,
    required double amount,
    Loan? loan,
    MoneyRecord? moneyRecord,
  }) {
    if (account == null) return null;

    if (amount <= 0) {
      return (
        text:
            '${account.name} current balance: ${CurrencyFormatter.formatAmount(account.currentBalance)}',
        isWarning: false,
      );
    }

    if (purpose == TransactionPurpose.internalTransfer ||
        type == TransactionType.transfer) {
      final fromAfter = account.currentBalance - amount;
      if (toAccount != null) {
        final toAfter = toAccount.currentBalance + amount;
        return (
          text:
              '${account.name}: ${CurrencyFormatter.formatAmount(fromAfter)} → ${toAccount.name}: ${CurrencyFormatter.formatAmount(toAfter)}',
          isWarning: fromAfter < 0 && account.type != AccountType.creditCard,
        );
      }
      return (
        text:
            '${account.name} balance after: ${CurrencyFormatter.formatAmount(fromAfter)}',
        isWarning: fromAfter < 0 && account.type != AccountType.creditCard,
      );
    }

    if (type == TransactionType.income) {
      final after = account.currentBalance + amount;
      return (
        text:
            '${account.name} balance after: ${CurrencyFormatter.formatAmount(after)}',
        isWarning: false,
      );
    }

    if (purpose == TransactionPurpose.loanRepayment && loan != null) {
      final principalLeft = loan.outstandingPrincipal - amount;
      final formattedLeft = CurrencyFormatter.formatAmount(
        principalLeft > 0 ? principalLeft : 0,
      );
      return (
        text: 'Expected EMI payment · Principal left: $formattedLeft',
        isWarning: false,
      );
    }

    final after = account.currentBalance - amount;
    return (
      text:
          '${account.name} balance after: ${CurrencyFormatter.formatAmount(after)}',
      isWarning: after < 0 && account.type != AccountType.creditCard,
    );
  }

  bool get needsCounterparty => const {
    TransactionPurpose.lending,
    TransactionPurpose.borrowing,
    TransactionPurpose.loanDisbursement,
  }.contains(purpose);

  bool get createsDebt =>
      purpose == TransactionPurpose.lending ||
      purpose == TransactionPurpose.borrowing;

  String? get _trimmedNotes {
    final n = notesText.trim();
    return n.isEmpty ? null : n;
  }

  /// The payee to store. Optional in the form: a blank payee is named after
  /// the category (or the destination account for transfers) so logging can
  /// be just amount → category → save.
  String effectivePayee() {
    final typed = payeeText.trim();
    if (typed.isNotEmpty) return typed;
    final counterparty = counterpartyText.trim();
    if (counterparty.isNotEmpty) return counterparty;
    if (moneyRecord != null) return moneyRecord!.personName;
    if (purpose == TransactionPurpose.internalTransfer && toAccount != null) {
      return 'To ${toAccount!.name}';
    }
    if (loan != null) return loan!.name;
    if (investment != null) return investment!.name;
    if (subscription != null) return subscription!.merchant;
    if (category != null) return category!.name;
    return purpose.displayName;
  }
}

/// Field-level errors; all null means the form can be saved.
class TransactionFormErrors {
  final String? amount;
  final String? payee;
  final String? category;
  final String? account;
  final String? toAccount;

  const TransactionFormErrors({
    this.amount,
    this.payee,
    this.category,
    this.account,
    this.toAccount,
  });

  bool get isValid =>
      amount == null &&
      payee == null &&
      category == null &&
      account == null &&
      toAccount == null;
}

/// Validates in the order the form is laid out and reports only the first
/// problem, so the user fixes one thing at a time.
TransactionFormErrors validateTransactionForm(TransactionFormValues v) {
  final amount = CurrencyFormatter.parse(v.amountText);
  if (amount == null || amount <= 0) {
    return const TransactionFormErrors(
      amount: 'Please enter an amount greater than zero.',
    );
  }
  if (v.needsCounterparty && v.counterpartyText.trim().isEmpty) {
    return const TransactionFormErrors(payee: 'Enter the person or lender.');
  }
  if ((v.purpose == TransactionPurpose.personalDebtRepaymentMade ||
          v.purpose == TransactionPurpose.personalDebtRepaymentReceived) &&
      v.moneyRecord == null) {
    return const TransactionFormErrors(
      payee: 'Select the debt record being repaid.',
    );
  }
  if (v.account == null) {
    return const TransactionFormErrors(account: 'Please select an account.');
  }
  if (v.purpose == TransactionPurpose.internalTransfer ||
      v.type == TransactionType.transfer) {
    if (v.toAccount == null) {
      return const TransactionFormErrors(
        toAccount: 'Please select a destination account.',
      );
    }
    if (v.toAccount!.id == v.account!.id) {
      return const TransactionFormErrors(
        toAccount: 'Source and destination accounts must differ.',
      );
    }
  }
  if (v.needsCategory && v.category == null) {
    return const TransactionFormErrors(category: 'Please select a category.');
  }
  return const TransactionFormErrors();
}

/// Builds the transaction (and, for lending/borrowing, the debt record it
/// opens or adds to) from validated [v]. Provenance fields of [initial] are
/// preserved when editing.
({Transaction transaction, MoneyRecord? debt}) buildTransactionFromForm(
  TransactionFormValues v, {
  required String id,
  required DateTime now,
  Transaction? initial,
  List<MoneyRecord> existingDebts = const [],
}) {
  final amount = CurrencyFormatter.parse(v.amountText)!;
  final payee = v.effectivePayee();
  final counterparty = v.counterpartyText.trim();

  String? debtRecordId;
  MoneyRecord? debt;
  if (v.createsDebt) {
    final personName = counterparty.isNotEmpty ? counterparty : payee;
    final debtType =
        v.purpose == TransactionPurpose.lending
            ? MoneyRecordType.lent
            : MoneyRecordType.borrowed;
    final normalized = MoneyRecord.normalizePersonName(personName);
    final matching =
        existingDebts
            .where(
              (d) =>
                  d.type == debtType &&
                  d.settledAt == null &&
                  !d.isCustomSeparateObligation &&
                  d.normalizedPersonName == normalized,
            )
            .firstOrNull;
    debtRecordId =
        v.createAsSeparateDebt
            ? (initial?.linkedMoneyRecordId ?? 'debt_$id')
            : (v.moneyRecord?.id ??
                matching?.id ??
                initial?.linkedMoneyRecordId ??
                'debt_$id');
    debt = MoneyRecord(
      id: debtRecordId,
      type: debtType,
      personName: personName,
      originalAmount: amount,
      transactionDate: v.date,
      dueDate:
          v.debtDueDate ?? DateTime(v.date.year, v.date.month, v.date.day + 30),
      notes: v._trimmedNotes,
      createdAt: now,
      updatedAt: now,
      isCustomSeparateObligation: v.createAsSeparateDebt,
      originTransactionId: id,
    );
  }

  final hasComponents = v.loan != null || v.investment != null;
  final category = v.needsCategory ? v.category : null;

  final tx = Transaction(
    id: id,
    amount: amount,
    type: v.type,
    purpose: v.purpose,
    categoryId: category?.id ?? 'cat_transfer',
    categoryName: category?.name ?? 'Transfer',
    categoryIcon: category?.iconIdentifier ?? 'sync',
    categoryColor: category?.colorTokenIdentifier ?? 'slate',
    merchant: payee,
    normalizedMerchant: MerchantNormalizationService.normalize(payee),
    date: v.date,
    notes: v._trimmedNotes,
    source: initial?.source ?? TransactionSource.manual,
    paymentMethod: v.paymentMethod,
    accountId: v.account!.id,
    toAccountId:
        v.purpose == TransactionPurpose.internalTransfer
            ? v.toAccount?.id
            : null,
    externalCounterpartyName:
        counterparty.isEmpty ? v.moneyRecord?.personName : counterparty,
    linkedLoanId:
        v.purpose == TransactionPurpose.loanRepayment ? v.loan?.id : null,
    linkedMoneyRecordId: v.createsDebt ? debtRecordId : v.moneyRecord?.id,
    linkedInvestmentId:
        v.purpose == TransactionPurpose.investmentPurchase ||
                v.purpose == TransactionPurpose.investmentRedemption
            ? v.investment?.id
            : null,
    linkedSubscriptionId:
        v.purpose == TransactionPurpose.subscriptionPayment
            ? v.subscription?.id
            : null,
    principalComponent:
        hasComponents ? CurrencyFormatter.parse(v.principalText) : null,
    interestComponent:
        hasComponents ? CurrencyFormatter.parse(v.interestText) : null,
    feeComponent: hasComponents ? CurrencyFormatter.parse(v.feeText) : null,
    tags:
        v.tagsText
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
    isReviewed: true,
    createdAt: initial?.createdAt ?? now,
    updatedAt: now,
    originalMerchant: initial?.originalMerchant,
    sourceName: initial?.sourceName,
    sourceReference: initial?.sourceReference,
    sourceMessageId: initial?.sourceMessageId,
    fingerprint: initial?.fingerprint,
    duplicateGroupId: initial?.duplicateGroupId,
    mergedSources: initial?.mergedSources ?? const [],
    importedAt: initial?.importedAt,
    detectedAt: initial?.detectedAt,
    reviewStatus: initial?.reviewStatus ?? 'confirmed',
    categorizationConfidence: initial?.categorizationConfidence,
  );
  return (transaction: tx, debt: debt);
}
