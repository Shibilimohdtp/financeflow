import 'dart:async';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/alert_item.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/goal_contribution.dart';
import 'package:financeflow/models/investment.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/money_advance.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/alert_repository.dart';
import 'package:financeflow/repositories/budget_repository.dart';
import 'package:financeflow/repositories/category_repository.dart';
import 'package:financeflow/repositories/investment_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/money_record_repository.dart';
import 'package:financeflow/repositories/savings_goal_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/services/loan_calculator.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';

class FakePendingTransactionRepository implements PendingTransactionRepository {
  final Map<String, ParsedTransaction> _items = {};
  final _changes = StreamController<List<ParsedTransaction>>.broadcast();
  bool failSaving = false;

  @override
  Future<List<ParsedTransaction>> getPendingTransactions() async =>
      _items.values.toList();
  @override
  Future<ParsedTransaction?> getPendingTransactionById(String tempId) async =>
      _items[tempId];
  @override
  Stream<List<ParsedTransaction>> watchPendingTransactions() async* {
    yield _items.values.toList();
    yield* _changes.stream;
  }

  @override
  Future<void> savePendingTransaction(ParsedTransaction item) async {
    if (failSaving) throw StateError('Unable to save');
    _items[item.tempId] = item;
    _changes.add(_items.values.toList());
  }

  @override
  Future<void> savePendingTransactions(List<ParsedTransaction> items) async {
    for (final item in items) {
      await savePendingTransaction(item);
    }
  }

  @override
  Future<void> removePendingTransaction(String tempId) async {
    _items.remove(tempId);
    _changes.add(_items.values.toList());
  }

  @override
  Future<void> removePendingTransactions(List<String> tempIds) async {
    for (final id in tempIds) {
      await removePendingTransaction(id);
    }
  }

  @override
  Future<void> clearAllPending() async {
    _items.clear();
    _changes.add([]);
  }

  void dispose() => _changes.close();
}

class FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings;
  final StreamController<AppSettings> _controller =
      StreamController<AppSettings>.broadcast();

  FakeSettingsRepository([AppSettings? initial])
    : _settings = initial ?? const AppSettings() {
    _controller.add(_settings);
  }

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Stream<AppSettings> watchSettings() {
    return _controller.stream;
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    _controller.add(_settings);
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _settings = _settings.copyWith(hasCompletedOnboarding: completed);
    _controller.add(_settings);
  }

  @override
  Future<void> setThemePreference(AppThemePreference preference) async {
    _settings = _settings.copyWith(themePreference: preference);
    _controller.add(_settings);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    _settings = _settings.copyWith(isBiometricEnabled: enabled);
    _controller.add(_settings);
  }

  @override
  Future<void> setPinEnabled(bool enabled) async {
    _settings = _settings.copyWith(isPinEnabled: enabled);
    _controller.add(_settings);
  }

  @override
  Future<void> setPrivacyBlurEnabled(bool enabled) async {
    _settings = _settings.copyWith(isPrivacyBlurEnabled: enabled);
    _controller.add(_settings);
  }


  void dispose() {
    _controller.close();
  }
}

class FakeTransactionRepository implements TransactionRepository {
  final Map<String, Transaction> _transactions = {};
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  FakeTransactionRepository([List<Transaction>? initial]) {
    if (initial != null) {
      for (final tx in initial) {
        _transactions[tx.id] = tx;
      }
    }
  }

  void _emit() {
    final list =
        _transactions.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    _controller.add(list);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() async* {
    yield await getAllTransactions();
    yield* _controller.stream;
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    final all = await getAllTransactions();
    return all.take(limit).toList();
  }

  @override
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) async* {
    yield await getRecentTransactions(limit: limit);
    yield* _controller.stream.map((list) => list.take(limit).toList());
  }

  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final all = await getAllTransactions();
    return all
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month) async* {
    yield await getTransactionsByMonth(month);
    yield* _controller.stream.map(
      (list) =>
          list
              .where(
                (t) => t.date.year == month.year && t.date.month == month.month,
              )
              .toList(),
    );
  }

  @override
  Future<List<Transaction>> searchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var list = await getAllTransactions();
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list =
          list
              .where(
                (t) =>
                    t.merchant.toLowerCase().contains(q) ||
                    t.categoryName.toLowerCase().contains(q) ||
                    (t.notes?.toLowerCase().contains(q) ?? false) ||
                    t.tags.any((tag) => tag.toLowerCase().contains(q)),
              )
              .toList();
    }
    if (type != null) {
      list = list.where((t) => t.type == type).toList();
    }
    if (categoryId != null) {
      list = list.where((t) => t.categoryId == categoryId).toList();
    }
    if (accountId != null) {
      list =
          list
              .where(
                (t) => t.accountId == accountId || t.toAccountId == accountId,
              )
              .toList();
    }
    if (startDate != null) {
      list = list.where((t) => !t.date.isBefore(startDate)).toList();
    }
    if (endDate != null) {
      list = list.where((t) => !t.date.isAfter(endDate)).toList();
    }
    return list;
  }

  @override
  Stream<List<Transaction>> watchTransactionsBetween(
    DateTime start,
    DateTime endExclusive,
  ) => watchAllTransactions().map(
    (all) =>
        all
            .where((t) => !t.date.isBefore(start) && t.date.isBefore(endExclusive))
            .toList(),
  );

  @override
  Stream<List<Transaction>> watchSearchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async* {
    yield await searchAndFilterTransactions(
      query: query,
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );
    yield* _controller.stream
        .map((_) {
          return searchAndFilterTransactions(
            query: query,
            type: type,
            categoryId: categoryId,
            accountId: accountId,
            startDate: startDate,
            endDate: endDate,
          );
        })
        .asyncMap((f) async => await f);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async => _transactions[id];

  @override
  Future<List<Transaction>> getTransactionsBySubscription(
    String subscriptionId,
  ) async {
    return _transactions.values
        .where((t) => t.linkedSubscriptionId == subscriptionId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Stream<List<Transaction>> watchTransactionsBySubscription(
    String subscriptionId,
  ) async* {
    yield await getTransactionsBySubscription(subscriptionId);
    yield* _controller.stream.map(
      (list) =>
          list
              .where((t) => t.linkedSubscriptionId == subscriptionId)
              .toList(),
    );
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    _transactions[transaction.id] = transaction;
    _emit();
  }

  @override
  Future<void> saveTransactions(List<Transaction> transactions) async {
    for (final tx in transactions) {
      _transactions[tx.id] = tx;
    }
    _emit();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.remove(id);
    _emit();
  }

  @override
  Future<void> deleteTransactions(List<String> ids) async {
    for (final id in ids) {
      _transactions.remove(id);
    }
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}

class FakeAccountRepository implements AccountRepository {
  final Map<String, Account> _accounts = {};
  final StreamController<List<Account>> _controller =
      StreamController<List<Account>>.broadcast();

  FakeAccountRepository([List<Account>? initial]) {
    if (initial != null) {
      for (final a in initial) {
        _accounts[a.id] = a;
      }
    }
  }

  void _emit() {
    _controller.add(_accounts.values.toList());
  }

  @override
  Future<List<Account>> getAllAccounts({bool includeArchived = false}) async {
    final list = _accounts.values.toList();
    if (!includeArchived) {
      return list.where((a) => !a.isArchived).toList();
    }
    return list;
  }

  @override
  Stream<List<Account>> watchAllAccounts({
    bool includeArchived = false,
  }) async* {
    yield await getAllAccounts(includeArchived: includeArchived);
    yield* _controller.stream.map((list) {
      if (!includeArchived) {
        return list.where((a) => !a.isArchived).toList();
      }
      return list;
    });
  }

  @override
  Future<Account?> getAccountById(String id) async => _accounts[id];

  @override
  Future<void> saveAccount(Account account) async {
    _accounts[account.id] = account;
    _emit();
  }

  @override
  Future<void> archiveAccount(String id, bool isArchived) async {
    final existing = _accounts[id];
    if (existing != null) {
      _accounts[id] = existing.copyWith(isArchived: isArchived);
      _emit();
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _accounts.remove(id);
    _emit();
  }

  @override
  Future<void> updateAccountBalance(String id, double newBalance) async {
    final existing = _accounts[id];
    if (existing != null) {
      _accounts[id] = existing.copyWith(currentBalance: newBalance);
      _emit();
    }
  }

  void dispose() {
    _controller.close();
  }
}

class FakeCategoryRepository implements CategoryRepository {
  final Map<String, Category> _categories = {};
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  FakeCategoryRepository([List<Category>? initial]) {
    if (initial != null) {
      for (final c in initial) {
        _categories[c.id] = c;
      }
    }
  }

  @override
  Future<List<Category>> getAllCategories({
    bool includeArchived = false,
  }) async {
    final list = _categories.values.toList();
    if (!includeArchived) {
      return list.where((c) => !c.isArchived).toList();
    }
    return list;
  }

  @override
  Stream<List<Category>> watchAllCategories({
    bool includeArchived = false,
  }) async* {
    yield await getAllCategories(includeArchived: includeArchived);
    yield* _controller.stream.map((list) {
      if (!includeArchived) {
        return list.where((c) => !c.isArchived).toList();
      }
      return list;
    });
  }

  @override
  Future<List<Category>> getCategoriesByType(String type) async {
    return _categories.values
        .where((c) => c.typeCompatibility.contains(type))
        .toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async => _categories[id];

  @override
  Future<void> saveCategory(Category category) async {
    _categories[category.id] = category;
    _controller.add(_categories.values.toList());
  }

  @override
  Future<void> archiveCategory(String id, bool isArchived) async {
    final existing = _categories[id];
    if (existing != null) {
      _categories[id] = existing.copyWith(isArchived: isArchived);
      _controller.add(_categories.values.toList());
    }
  }

  @override
  Future<void> ensureDefaultCategoriesSeeded() async {}

  void dispose() {
    _controller.close();
  }
}

class FakeBudgetRepository implements BudgetRepository {
  final Map<String, Budget> _budgets = {};
  final StreamController<List<Budget>> _controller =
      StreamController<List<Budget>>.broadcast();

  FakeBudgetRepository([List<Budget>? initial]) {
    if (initial != null) {
      for (final b in initial) {
        _budgets[b.id] = b;
      }
    }
  }

  void _emit() {
    _controller.add(_budgets.values.toList());
  }

  @override
  Future<List<Budget>> getAllBudgets() async => _budgets.values.toList();

  @override
  Stream<List<Budget>> watchAllBudgets() async* {
    yield await getAllBudgets();
    yield* _controller.stream;
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    return _budgets.values.where((b) => !b.isArchived).toList();
  }

  @override
  Stream<List<Budget>> watchActiveBudgets() async* {
    yield await getActiveBudgets();
    yield* _controller.stream.map(
      (list) => list.where((b) => !b.isArchived).toList(),
    );
  }

  @override
  Future<Budget?> getBudgetById(String id) async => _budgets[id];

  @override
  Future<void> saveBudget(Budget budget) async {
    _budgets[budget.id] = budget;
    _emit();
  }

  @override
  Future<void> deleteBudget(String id) async {
    _budgets.remove(id);
    _emit();
  }

  @override
  Future<void> archiveBudget(String id, bool isArchived) async {
    final existing = _budgets[id];
    if (existing != null) {
      _budgets[id] = existing.copyWith(isArchived: isArchived);
      _emit();
    }
  }

  void dispose() {
    _controller.close();
  }
}

class FakeSavingsGoalRepository implements SavingsGoalRepository {
  final Map<String, SavingsGoal> _goals = {};
  final List<GoalContribution> _contributions = [];
  final StreamController<List<SavingsGoal>> _goalsController =
      StreamController<List<SavingsGoal>>.broadcast();
  final StreamController<List<GoalContribution>> _contribsController =
      StreamController<List<GoalContribution>>.broadcast();

  FakeSavingsGoalRepository([
    List<SavingsGoal>? goals,
    List<GoalContribution>? contribs,
  ]) {
    if (goals != null) {
      for (final g in goals) {
        _goals[g.id] = g;
      }
    }
    if (contribs != null) {
      _contributions.addAll(contribs);
    }
  }

  @override
  Future<List<SavingsGoal>> getAllGoals() async => _goals.values.toList();

  @override
  Stream<List<SavingsGoal>> watchAllGoals() async* {
    yield await getAllGoals();
    yield* _goalsController.stream;
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async => _goals[id];

  @override
  Future<void> saveGoal(SavingsGoal goal) async {
    _goals[goal.id] = goal;
    _goalsController.add(_goals.values.toList());
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.remove(id);
    _contributions.removeWhere((c) => c.goalId == id);
    _goalsController.add(_goals.values.toList());
    _contribsController.add(_contributions);
  }

  @override
  Future<List<GoalContribution>> getAllContributions() async =>
      List.from(_contributions);

  @override
  Future<List<GoalContribution>> getContributionsForGoal(String goalId) async {
    return _contributions.where((c) => c.goalId == goalId).toList();
  }

  @override
  Stream<List<GoalContribution>> watchContributionsForGoal(
    String goalId,
  ) async* {
    yield await getContributionsForGoal(goalId);
    yield* _contribsController.stream.map(
      (list) => list.where((c) => c.goalId == goalId).toList(),
    );
  }

  @override
  Stream<List<GoalContribution>> watchAllContributions() async* {
    yield await getAllContributions();
    yield* _contribsController.stream;
  }

  @override
  Future<void> addContribution(GoalContribution contribution) async {
    _contributions.add(contribution);
    _contribsController.add(_contributions);
  }

  @override
  Future<void> deleteContribution(String id) async {
    _contributions.removeWhere((c) => c.id == id);
    _contribsController.add(_contributions);
  }

  void dispose() {
    _goalsController.close();
    _contribsController.close();
  }
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  final Map<String, Subscription> _subs = {};
  final StreamController<List<Subscription>> _controller =
      StreamController<List<Subscription>>.broadcast();

  FakeSubscriptionRepository([List<Subscription>? initial]) {
    if (initial != null) {
      for (final s in initial) {
        _subs[s.id] = s;
      }
    }
  }

  @override
  Future<List<Subscription>> getAllSubscriptions() async =>
      _subs.values.toList();

  @override
  Stream<List<Subscription>> watchAllSubscriptions() async* {
    yield await getAllSubscriptions();
    yield* _controller.stream;
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async => _subs[id];

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    _subs[subscription.id] = subscription;
    _controller.add(_subs.values.toList());
  }

  @override
  Future<void> deleteSubscription(String id) async {
    _subs.remove(id);
    _controller.add(_subs.values.toList());
  }

  @override
  Future<void> updateStatus(String id, SubscriptionStatus status) async {
    final existing = _subs[id];
    if (existing != null) {
      _subs[id] = existing.copyWith(status: status);
      _controller.add(_subs.values.toList());
    }
  }

  void dispose() {
    _controller.close();
  }
}

class FakeLoanRepository implements LoanRepository {
  final Map<String, Loan> _loans = {};
  final List<EmiPayment> _payments = [];
  final StreamController<List<Loan>> _controller =
      StreamController<List<Loan>>.broadcast();
  final StreamController<List<EmiPayment>> _paymentsController =
      StreamController<List<EmiPayment>>.broadcast();

  FakeLoanRepository([
    List<Loan>? initialLoans,
    List<EmiPayment>? initialPayments,
  ]) {
    if (initialLoans != null) {
      for (final l in initialLoans) {
        _loans[l.id] = l;
      }
    }
    if (initialPayments != null) {
      _payments.addAll(initialPayments);
    }
  }

  @override
  Future<List<Loan>> getAllLoans() async => _loans.values.toList();

  @override
  Stream<List<Loan>> watchAllLoans() async* {
    yield await getAllLoans();
    yield* _controller.stream;
  }

  @override
  Future<Loan?> getLoanById(String id) async => _loans[id];

  @override
  Future<void> saveLoan(Loan loan) async {
    _loans[loan.id] = loan;
    _controller.add(_loans.values.toList());
  }

  @override
  Future<void> deleteLoan(String id) async {
    _loans.remove(id);
    _payments.removeWhere((p) => p.loanId == id);
    _controller.add(_loans.values.toList());
    _paymentsController.add(List.from(_payments));
  }

  @override
  Future<void> updateLoanStatus(String id, LoanStatus status) async {
    final existing = _loans[id];
    if (existing != null) {
      _loans[id] = existing.copyWith(status: status);
      _controller.add(_loans.values.toList());
    }
  }

  @override
  Future<List<EmiPayment>> getPaymentsForLoan(String loanId) async {
    return _payments.where((p) => p.loanId == loanId).toList()
      ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));
  }

  @override
  Stream<List<EmiPayment>> watchPaymentsForLoan(String loanId) async* {
    yield await getPaymentsForLoan(loanId);
    yield* _paymentsController.stream.map(
      (list) =>
          list.where((p) => p.loanId == loanId).toList()..sort(
            (a, b) => a.installmentNumber.compareTo(b.installmentNumber),
          ),
    );
  }

  @override
  Future<List<EmiPayment>> getAllPayments() async => List.from(_payments);

  @override
  Future<void> recordEmiPayment(EmiPayment payment) async {
    payment.validate();

    final duplicate = _payments.any(
      (p) =>
          p.loanId == payment.loanId &&
          p.installmentNumber == payment.installmentNumber &&
          p.id != payment.id,
    );

    if (duplicate) {
      throw ValidationError(
        message:
            'EMI installment #${payment.installmentNumber} has already been marked as paid.',
      );
    }

    final existingIdx = _payments.indexWhere((p) => p.id == payment.id);
    if (existingIdx != -1) {
      _payments[existingIdx] = payment;
    } else {
      _payments.add(payment);
    }

    final loan = _loans[payment.loanId];
    if (loan != null) {
      final loanPayments =
          _payments.where((p) => p.loanId == payment.loanId).toList();
      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: loanPayments,
      );
      _loans[payment.loanId] = updated;
      _controller.add(_loans.values.toList());
    }

    _paymentsController.add(List.from(_payments));
  }

  @override
  Future<void> recordMultipleEmiPayments(List<EmiPayment> payments) async {
    if (payments.isEmpty) return;

    for (final p in payments) {
      p.validate();
      final duplicate = _payments.any(
        (existing) =>
            existing.loanId == p.loanId &&
            existing.installmentNumber == p.installmentNumber,
      );
      if (!duplicate) {
        _payments.add(p);
      }
    }

    final loanId = payments.first.loanId;
    final loan = _loans[loanId];
    if (loan != null) {
      final loanPayments = _payments.where((p) => p.loanId == loanId).toList();
      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: loanPayments,
      );
      _loans[loanId] = updated;
      _controller.add(_loans.values.toList());
    }

    _paymentsController.add(List.from(_payments));
  }

  @override
  Future<void> deleteEmiPayment(String paymentId) async {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx == -1) return;

    final loanId = _payments[idx].loanId;
    _payments.removeAt(idx);

    final loan = _loans[loanId];
    if (loan != null) {
      final loanPayments = _payments.where((p) => p.loanId == loanId).toList();
      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: loanPayments,
      );
      _loans[loanId] = updated;
      _controller.add(_loans.values.toList());
    }

    _paymentsController.add(List.from(_payments));
  }

  void dispose() {
    _controller.close();
    _paymentsController.close();
  }
}

class FakeInvestmentRepository implements InvestmentRepository {
  final Map<String, Investment> _investments = {};
  final StreamController<List<Investment>> _controller =
      StreamController<List<Investment>>.broadcast();

  FakeInvestmentRepository([List<Investment>? initial]) {
    if (initial != null) {
      for (final inv in initial) {
        _investments[inv.id] = inv;
      }
    }
  }

  @override
  Future<List<Investment>> getAllInvestments() async =>
      _investments.values.toList();

  @override
  Stream<List<Investment>> watchAllInvestments() async* {
    yield await getAllInvestments();
    yield* _controller.stream;
  }

  @override
  Future<Investment?> getInvestmentById(String id) async => _investments[id];

  @override
  Future<void> saveInvestment(Investment investment) async {
    _investments[investment.id] = investment;
    _controller.add(_investments.values.toList());
  }

  @override
  Future<void> deleteInvestment(String id) async {
    _investments.remove(id);
    _controller.add(_investments.values.toList());
  }

  @override
  Future<void> updateValuation(String id, double newValue) async {
    final existing = _investments[id];
    if (existing != null) {
      _investments[id] = existing.copyWith(
        currentValue: newValue,
        lastValuationDate: DateTime.now(),
      );
      _controller.add(_investments.values.toList());
    }
  }

  void dispose() {
    _controller.close();
  }
}

class FakeAlertRepository implements AlertRepository {
  final Map<String, AlertItem> _alerts = {};
  final StreamController<List<AlertItem>> _controller =
      StreamController<List<AlertItem>>.broadcast();

  FakeAlertRepository([List<AlertItem>? initial]) {
    if (initial != null) {
      for (final a in initial) {
        _alerts[a.id] = a;
      }
    }
  }

  @override
  Future<List<AlertItem>> getAllAlerts() async {
    return _alerts.values.toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Future<List<AlertItem>> getActiveAlerts() async {
    return _alerts.values.where((a) => !a.isDismissed).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Stream<List<AlertItem>> watchActiveAlerts() async* {
    yield await getActiveAlerts();
    yield* _controller.stream.map(
      (list) =>
          list.where((a) => !a.isDismissed).toList()
            ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt)),
    );
  }

  @override
  Future<void> saveAlert(AlertItem alert) async {
    _alerts[alert.id] = alert;
    _controller.add(_alerts.values.toList());
  }

  @override
  Future<void> markAsRead(String id) async {
    final existing = _alerts[id];
    if (existing != null) {
      _alerts[id] = existing.copyWith(isRead: true);
      _controller.add(_alerts.values.toList());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (final entry in _alerts.entries) {
      _alerts[entry.key] = entry.value.copyWith(isRead: true);
    }
    _controller.add(_alerts.values.toList());
  }

  @override
  Future<void> dismissAlert(String id) async {
    final existing = _alerts[id];
    if (existing != null) {
      _alerts[id] = existing.copyWith(isDismissed: true);
      _controller.add(_alerts.values.toList());
    }
  }

  @override
  Future<void> clearAllAlerts() async {
    _alerts.clear();
    _controller.add([]);
  }

  @override
  Future<void> deduplicateAlerts() async {
    final newestByKey = <String, AlertItem>{};
    for (final alert in _alerts.values) {
      final day =
          '${alert.createdAt.year}-${alert.createdAt.month}-${alert.createdAt.day}';
      final identity =
          alert.relatedEntityId ?? '${alert.title}\u0000${alert.message}';
      final key = '${alert.type}\u0000$identity\u0000$day';
      final current = newestByKey[key];
      if (current == null || alert.createdAt.isAfter(current.createdAt)) {
        newestByKey[key] = alert;
      }
    }
    _alerts
      ..clear()
      ..addEntries(
        newestByKey.values.map((alert) => MapEntry(alert.id, alert)),
      );
    _controller.add(_alerts.values.toList());
  }

  @override
  Future<bool> alertExistsForEntity({
    required AlertType type,
    required String relatedEntityId,
    required DateTime sinceDate,
  }) async {
    return _alerts.values.any(
      (a) =>
          a.type == type &&
          a.relatedEntityId == relatedEntityId &&
          !a.createdAt.isBefore(sinceDate),
    );
  }

  void dispose() {
    _controller.close();
  }
}

class FakeMoneyRecordRepository implements MoneyRecordRepository {
  final Map<String, MoneyRecord> _records = {};
  final Map<String, MoneyAdvance> _advances = {};
  final Map<String, MoneyRepayment> _repayments = {};
  final StreamController<List<MoneyRecord>> _recordsController =
      StreamController<List<MoneyRecord>>.broadcast();
  final StreamController<List<MoneyAdvance>> _advancesController =
      StreamController<List<MoneyAdvance>>.broadcast();
  final StreamController<List<MoneyRepayment>> _repaymentsController =
      StreamController<List<MoneyRepayment>>.broadcast();

  FakeMoneyRecordRepository({
    List<MoneyRecord>? initialRecords,
    List<MoneyAdvance>? initialAdvances,
    List<MoneyRepayment>? initialRepayments,
  }) {
    if (initialRecords != null) {
      for (final r in initialRecords) {
        _records[r.id] = r;
      }
    }
    if (initialAdvances != null) {
      for (final adv in initialAdvances) {
        _advances[adv.id] = adv;
      }
    } else if (initialRecords != null) {
      // Synthesize advances for initial records if not explicitly given
      for (final r in initialRecords) {
        final advId =
            r.originTransactionId != null
                ? 'adv_${r.originTransactionId}'
                : 'adv_${r.id}';
        _advances[advId] = MoneyAdvance(
          id: advId,
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
      }
    }
    if (initialRepayments != null) {
      for (final rep in initialRepayments) {
        _repayments[rep.id] = rep;
      }
    }
    _recordsController.add(_records.values.toList());
    _advancesController.add(_advances.values.toList());
    _repaymentsController.add(_repayments.values.toList());
  }

  @override
  Future<void> migrateAdvancesAndConsolidateDuplicates({
    String userId = 'local_user',
  }) async {
    // 1. Ensure advances exist for each record
    for (final r in _records.values.where((r) => r.userId == userId).toList()) {
      final existingAdvs =
          _advances.values.where((a) => a.moneyRecordId == r.id).toList();
      if (existingAdvs.isEmpty) {
        final advId =
            r.originTransactionId != null
                ? 'adv_${r.originTransactionId}'
                : 'adv_${r.id}';
        _advances[advId] = MoneyAdvance(
          id: advId,
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
      }
    }

    // 2. Consolidate duplicate active records
    final active =
        _records.values
            .where(
              (r) =>
                  r.userId == userId &&
                  r.settledAt == null &&
                  !r.isCustomSeparateObligation,
            )
            .toList();

    final grouped = <String, List<MoneyRecord>>{};
    for (final r in active) {
      final key = '${r.type.toDbString()}_${r.normalizedPersonName}';
      grouped.putIfAbsent(key, () => []).add(r);
    }

    for (final group in grouped.values) {
      if (group.length <= 1) continue;
      group.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final primary = group.first;
      final secondaries = group.sublist(1);

      for (final sec in secondaries) {
        for (final advEntry in _advances.entries.toList()) {
          if (advEntry.value.moneyRecordId == sec.id) {
            _advances[advEntry.key] = advEntry.value.copyWith(
              moneyRecordId: primary.id,
            );
          }
        }
        for (final repEntry in _repayments.entries.toList()) {
          if (repEntry.value.moneyRecordId == sec.id) {
            _repayments[repEntry.key] = repEntry.value.copyWith(
              moneyRecordId: primary.id,
            );
          }
        }
        _records.remove(sec.id);
      }

      final allAdvs =
          _advances.values.where((a) => a.moneyRecordId == primary.id).toList();
      final total = allAdvs.fold<double>(0.0, (s, a) => s + a.amount);
      _records[primary.id] = primary.copyWith(
        originalAmount: total,
        updatedAt: DateTime.now(),
      );
    }

    _recordsController.add(_records.values.toList());
    _advancesController.add(_advances.values.toList());
    _repaymentsController.add(_repayments.values.toList());
  }

  @override
  Future<List<MoneyRecord>> getAllRecords({
    String userId = 'local_user',
  }) async {
    return _records.values.where((r) => r.userId == userId).toList();
  }

  @override
  Stream<List<MoneyRecord>> watchAllRecords({
    String userId = 'local_user',
  }) async* {
    yield await getAllRecords(userId: userId);
    yield* _recordsController.stream.map(
      (list) => list.where((r) => r.userId == userId).toList(),
    );
  }

  @override
  Future<MoneyRecord?> getRecordById(
    String id, {
    String userId = 'local_user',
  }) async {
    final r = _records[id];
    if (r == null || r.userId != userId) return null;
    return r;
  }

  @override
  Future<void> saveRecord(MoneyRecord record) async {
    record.validate();
    _records[record.id] = record;
    _recordsController.add(_records.values.toList());
  }

  @override
  Future<void> deleteRecord(String id, {String userId = 'local_user'}) async {
    _records.remove(id);
    _advances.removeWhere(
      (key, adv) => adv.moneyRecordId == id && adv.userId == userId,
    );
    _repayments.removeWhere(
      (key, rep) => rep.moneyRecordId == id && rep.userId == userId,
    );
    _recordsController.add(_records.values.toList());
    _advancesController.add(_advances.values.toList());
    _repaymentsController.add(_repayments.values.toList());
  }

  // --- Advances ---

  @override
  Future<List<MoneyAdvance>> getAllAdvances({
    String userId = 'local_user',
  }) async {
    return _advances.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<List<MoneyAdvance>> getAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    return _advances.values
        .where((a) => a.moneyRecordId == recordId && a.userId == userId)
        .toList();
  }

  @override
  Stream<List<MoneyAdvance>> watchAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async* {
    yield await getAdvancesForRecord(recordId, userId: userId);
    yield* _advancesController.stream.map(
      (list) =>
          list
              .where((a) => a.moneyRecordId == recordId && a.userId == userId)
              .toList(),
    );
  }

  @override
  Stream<List<MoneyAdvance>> watchAllAdvances({
    String userId = 'local_user',
  }) async* {
    yield await getAllAdvances(userId: userId);
    yield* _advancesController.stream.map(
      (list) => list.where((a) => a.userId == userId).toList(),
    );
  }

  @override
  Future<void> saveAdvance(MoneyAdvance advance) async {
    advance.validate();
    _advances[advance.id] = advance;
    _advancesController.add(_advances.values.toList());
  }

  @override
  Future<void> saveAdvances(List<MoneyAdvance> advances) async {
    for (final a in advances) {
      a.validate();
      _advances[a.id] = a;
    }
    _advancesController.add(_advances.values.toList());
  }

  @override
  Future<void> deleteAdvance(String id, {String userId = 'local_user'}) async {
    _advances.remove(id);
    _advancesController.add(_advances.values.toList());
  }

  @override
  Future<void> deleteAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    _advances.removeWhere(
      (key, a) => a.moneyRecordId == recordId && a.userId == userId,
    );
    _advancesController.add(_advances.values.toList());
  }

  // --- Repayments ---

  @override
  Future<List<MoneyRepayment>> getAllRepayments({
    String userId = 'local_user',
  }) async {
    return _repayments.values.where((r) => r.userId == userId).toList();
  }

  @override
  Future<List<MoneyRepayment>> getRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    return _repayments.values
        .where((r) => r.moneyRecordId == recordId && r.userId == userId)
        .toList();
  }

  @override
  Stream<List<MoneyRepayment>> watchRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async* {
    yield await getRepaymentsForRecord(recordId, userId: userId);
    yield* _repaymentsController.stream.map(
      (list) =>
          list
              .where((r) => r.moneyRecordId == recordId && r.userId == userId)
              .toList(),
    );
  }

  @override
  Stream<List<MoneyRepayment>> watchAllRepayments({
    String userId = 'local_user',
  }) async* {
    yield await getAllRepayments(userId: userId);
    yield* _repaymentsController.stream.map(
      (list) => list.where((r) => r.userId == userId).toList(),
    );
  }

  @override
  Future<void> addRepayment(MoneyRepayment repayment) async {
    repayment.validate();
    _repayments[repayment.id] = repayment;
    _repaymentsController.add(_repayments.values.toList());
  }

  @override
  Future<void> deleteRepayment(
    String id, {
    String userId = 'local_user',
  }) async {
    _repayments.remove(id);
    _repaymentsController.add(_repayments.values.toList());
  }

  void dispose() {
    _recordsController.close();
    _advancesController.close();
    _repaymentsController.close();
  }
}
