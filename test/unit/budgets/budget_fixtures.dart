import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';

/// "Today" for most budget tests: Sunday 15 November 2026, mid-afternoon.
/// November has 30 days, so 15 have elapsed and 16 are left including today.
final DateTime kNow = DateTime(2026, 11, 15, 14, 30);

var _seq = 0;

Transaction tx(
  DateTime date,
  double amount, {
  String category = 'cat_dining',
  TransactionType type = TransactionType.expense,
  TransactionPurpose? purpose,
  String? subscriptionId,
  String? loanId,
  double? fee,
  String merchant = 'Shop',
  String? id,
}) {
  return Transaction(
    id: id ?? 'tx_${_seq++}',
    amount: amount,
    type: type,
    purpose: purpose,
    categoryId: category,
    categoryName: category,
    categoryIcon: 'category',
    categoryColor: 'shore',
    merchant: merchant,
    date: date,
    accountId: 'acc_1',
    toAccountId: type == TransactionType.transfer ? 'acc_2' : null,
    linkedSubscriptionId: subscriptionId,
    linkedLoanId: loanId,
    feeComponent: fee,
    createdAt: date,
    updatedAt: date,
  );
}

Budget budget({
  String id = 'b_dining',
  List<String> categories = const ['cat_dining'],
  double limit = 6000,
  BudgetPeriod period = BudgetPeriod.monthly,
  DateTime? start,
  DateTime? end,
  RolloverMode rollover = RolloverMode.off,
  DateTime? rolloverSince,
  double threshold = 0.8,
  BudgetGroup group = BudgetGroup.other,
  bool archived = false,
}) {
  final created = start ?? DateTime(2025, 1, 1);
  return Budget(
    id: id,
    name: id,
    categoryId: categories.first,
    categoryIds: categories,
    amountLimit: limit,
    period: period,
    startDate: created,
    endDate: end,
    rolloverMode: rollover,
    rolloverSince: rolloverSince,
    alertThreshold: threshold,
    group: group,
    isArchived: archived,
    createdAt: created,
    updatedAt: created,
  );
}
