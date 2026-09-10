import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/services/ingestion/duplicate_matcher.dart';
import '../helpers/fake_repositories.dart';

void main() {
  group('Performance and Scalability Benchmarks', () {
    final DateTime baseDate = DateTime(2026, 8, 22);

    List<Transaction> generateSyntheticDataset(int count) {
      final Random rnd = Random(42);
      final List<String> categories = [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Entertainment',
        'Salary',
        'Investments',
      ];
      final List<String> merchants = [
        'Swiggy',
        'Uber',
        'Amazon',
        'Airtel',
        'Netflix',
        'Acme Corp',
        'DMart',
        'Petrol Pump',
      ];

      return List.generate(count, (index) {
        final isIncome = rnd.nextDouble() < 0.15;
        final cat =
            isIncome
                ? 'Salary'
                : categories[rnd.nextInt(categories.length - 1)];
        final merchant =
            isIncome ? 'Acme Corp' : merchants[rnd.nextInt(merchants.length)];
        final amount =
            isIncome
                ? 50000.0 + rnd.nextInt(50000)
                : (50.0 + rnd.nextInt(4950)).toDouble();

        return Transaction(
          id: 'perf_tx_$index',
          amount: amount,
          type: isIncome ? TransactionType.income : TransactionType.expense,
          categoryId: 'cat_${cat.toLowerCase()}',
          categoryName: cat,
          categoryIcon: 'receipt',
          categoryColor: 'clay',
          merchant: merchant,
          date: baseDate.subtract(Duration(hours: index * 2)),
          accountId: 'acc_${index % 3}',
          paymentMethod: 'UPI',
          isReviewed: true,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
      });
    }

    test('Scales smoothly with 100 transactions', () {
      final dataset = generateSyntheticDataset(100);
      final stopwatch = Stopwatch()..start();

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(dataset);
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: dataset,
        timeRange: AnalyticsTimeRange.month,
        referenceDate: baseDate,
      );

      stopwatch.stop();
      expect(cashFlow.totalIncome, greaterThan(0));
      expect(report.categoryBreakdown.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(250));
    });

    test('Scales smoothly with 1,000 transactions', () {
      final dataset = generateSyntheticDataset(1000);
      final stopwatch = Stopwatch()..start();

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(dataset);
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: dataset,
        timeRange: AnalyticsTimeRange.year,
      );

      final account = Account(
        id: 'acc_0',
        name: 'Primary Account',
        type: AccountType.bank,
        openingBalance: 10000.0,
        currentBalance: 10000.0,
        currency: 'INR',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final balance = BalanceCalculator.calculateAccountBalance(
        account: account,
        allTransactions: dataset,
      );

      stopwatch.stop();
      expect(cashFlow.totalIncome, greaterThan(0));
      expect(report.timeSeries.isNotEmpty, isTrue);
      expect(balance, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(250));
    });

    test('Scales smoothly with 5,000 transactions', () {
      final dataset = generateSyntheticDataset(5000);
      final stopwatch = Stopwatch()..start();

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(dataset);
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: dataset,
        timeRange: AnalyticsTimeRange.year,
      );

      stopwatch.stop();
      expect(cashFlow.totalIncome, greaterThan(0));
      expect(report.categoryBreakdown.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('DuplicateMatcher scans 1,000 transactions smoothly', () {
      final dataset = generateSyntheticDataset(1000);
      final stopwatch = Stopwatch()..start();

      final targetDate = DateTime(2026, 8, 22, 10, 0);
      final incoming = ParsedTransaction(
        amount: 450.0,
        type: TransactionType.expense,
        rawMerchant: 'Swiggy',
        normalizedMerchant: 'Swiggy',
        date: targetDate,
        accountId: 'acc_0',
        categoryId: 'cat_dining',
        categoryName: 'Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: '2026-08-22|450.00|swiggy|expense|noref',
      );

      final match = DuplicateMatcher.findDuplicate(
        incoming: incoming,
        existingTransactions: dataset,
      );

      stopwatch.stop();
      expect(match, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(250));
    });

    test('Repository search query executes quickly on 1,000 records', () async {
      final dataset = generateSyntheticDataset(1000);
      final repo = FakeTransactionRepository(dataset);

      final stopwatch = Stopwatch()..start();
      final results = await repo.searchAndFilterTransactions(query: 'swiggy');
      stopwatch.stop();

      expect(results.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(250));
    });
  });
}
