import 'dart:convert';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportService Tests', () {
    final now = DateTime(2026, 8, 15);

    final testAccount = Account(
      id: 'acc_1',
      name: 'HDFC Salary',
      type: AccountType.bank,
      maskedIdentifier: '••4321',
      openingBalance: 50000.0,
      currentBalance: 75000.0,
      createdAt: now,
      updatedAt: now,
    );

    final testTxs = [
      Transaction(
        id: 't1',
        amount: 2500.0,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_basket',
        categoryColor: 'moss',
        merchant: 'Blinkit',
        date: DateTime(2026, 8, 10),
        accountId: 'acc_1',
        paymentMethod: 'UPI',
        notes: 'Weekly staples',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 't2',
        amount: 80000.0,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'work',
        categoryColor: 'grove',
        merchant: 'ACME Corp',
        date: DateTime(2026, 8, 1),
        accountId: 'acc_1',
        paymentMethod: 'Bank Transfer',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('generateCsv produces valid RFC 4180 CSV with headers and masking', () {
      final csv = ExportService.generateCsv(
        transactions: testTxs,
        accounts: [testAccount],
        maskSensitive: true,
      );

      expect(
        csv,
        contains(
          'Date,Type,Amount (INR),Merchant,Category,Account,Payment Method,Notes,Source',
        ),
      );
      expect(csv, contains('Blinkit'));
      expect(csv, contains('2500.00'));
      expect(csv, contains('HDFC Salary (••4321)'));
    });

    test('generateJson produces valid parseable JSON envelope', () {
      final jsonStr = ExportService.generateJson(
        transactions: testTxs,
        accounts: [testAccount],
      );

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['transactions'], isA<List>());
      expect((decoded['transactions'] as List).length, equals(2));
      expect(decoded['accounts'], isA<List>());
      expect((decoded['accounts'] as List).length, equals(1));
    });

    test('generateExcelHtml produces valid spreadsheet table markup', () {
      final html = ExportService.generateExcelHtml(
        transactions: testTxs,
        accounts: [testAccount],
      );

      expect(html, contains('<h2>FinanceFlow Transaction Export</h2>'));
      expect(html, contains('<table>'));
      expect(html, contains('<td>Blinkit</td>'));
    });

    test(
      'generateReportText produces formatted text summary with cash flow totals',
      () {
        final report = ExportService.generateReportText(
          transactions: testTxs,
          budgets: [
            Budget(
              id: 'b1',
              name: 'Groceries',
              categoryId: 'cat_groceries',
              categoryName: 'Groceries',
              amountLimit: 10000.0,
              startDate: DateTime(2026, 8, 1),
              createdAt: now,
              updatedAt: now,
            ),
          ],
          accounts: [testAccount],
        );

        expect(report, contains('FINANCEFLOW FINANCIAL REPORT'));
        expect(report, contains('Total Income:    ₹80,000'));
        expect(report, contains('Total Expenses:  ₹2,500'));
        expect(report, contains('Net Savings:     ₹77,500'));
        expect(report, contains('Groceries'));
      },
    );
  });
}
