import 'package:financeflow/models/investment.dart';
import 'package:financeflow/services/investment_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvestmentCalculator Tests', () {
    final now = DateTime(2026, 8, 15);

    test(
      'calculatePortfolioSummary sums invested and current values with returns',
      () {
        final holdings = [
          Investment(
            id: 'i1',
            name: 'Nifty 50 Index Fund',
            assetType: AssetType.mutualFunds,
            purchasePrice: 100000.0,
            purchaseDate: DateTime(2025, 8, 15),
            currentValue: 125000.0,
            investedAmount: 100000.0,
            unrealizedProfitLoss: 25000.0,
            createdAt: now,
            updatedAt: now,
          ),
          Investment(
            id: 'i2',
            name: 'Sovereign Gold Bond',
            assetType: AssetType.gold,
            purchasePrice: 50000.0,
            purchaseDate: DateTime(2025, 1, 15),
            currentValue: 55000.0,
            investedAmount: 50000.0,
            unrealizedProfitLoss: 5000.0,
            createdAt: now,
            updatedAt: now,
          ),
          Investment(
            id: 'i3',
            name: 'Fixed Deposit',
            assetType: AssetType.fixedDeposits,
            purchasePrice: 100000.0,
            purchaseDate: DateTime(2026, 1, 1),
            currentValue: 104000.0,
            investedAmount: 100000.0,
            unrealizedProfitLoss: 4000.0,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final summary = InvestmentCalculator.calculatePortfolioSummary(
          holdings,
        );

        expect(summary.totalInvested, equals(250000.0));
        expect(summary.totalCurrentValue, equals(284000.0));
        expect(summary.absoluteReturn, equals(34000.0));
        expect(
          summary.percentageReturn,
          closeTo((34000.0 / 250000.0) * 100.0, 0.01),
        );
        expect(summary.totalHoldings, equals(3));
        expect(summary.allocationSlices.length, equals(3));
      },
    );
  });
}
