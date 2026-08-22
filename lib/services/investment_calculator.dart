import '../models/investment.dart';

class AssetAllocationSlice {
  final AssetType assetType;
  final String label;
  final double totalValue;
  final double percentage; // 0.0 to 100.0

  const AssetAllocationSlice({
    required this.assetType,
    required this.label,
    required this.totalValue,
    required this.percentage,
  });
}

class PortfolioSummary {
  final double totalInvested;
  final double totalCurrentValue;
  final double absoluteReturn;
  final double percentageReturn;
  final bool isProfitable;
  final List<AssetAllocationSlice> allocationSlices;
  final int totalHoldings;

  const PortfolioSummary({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.absoluteReturn,
    required this.percentageReturn,
    required this.isProfitable,
    required this.allocationSlices,
    required this.totalHoldings,
  });
}

class InvestmentCalculator {
  InvestmentCalculator._();

  static PortfolioSummary calculatePortfolioSummary(
    List<Investment> investments,
  ) {
    final active = investments.where((i) => !i.isArchived).toList();

    if (active.isEmpty) {
      return const PortfolioSummary(
        totalInvested: 0.0,
        totalCurrentValue: 0.0,
        absoluteReturn: 0.0,
        percentageReturn: 0.0,
        isProfitable: true,
        allocationSlices: [],
        totalHoldings: 0,
      );
    }

    final totalInvested = active.fold<double>(
      0.0,
      (s, i) => s + i.investedAmount,
    );
    final totalCurrentValue = active.fold<double>(
      0.0,
      (s, i) => s + i.currentValue,
    );
    final absoluteReturn = totalCurrentValue - totalInvested;
    final percentageReturn =
        totalInvested > 0 ? (absoluteReturn / totalInvested) * 100.0 : 0.0;

    // Group by AssetType
    final Map<AssetType, double> valueByType = {};
    for (final inv in active) {
      valueByType[inv.assetType] =
          (valueByType[inv.assetType] ?? 0.0) + inv.currentValue;
    }

    final List<AssetAllocationSlice> slices = [];
    for (final entry in valueByType.entries) {
      final val = entry.value;
      final pct =
          totalCurrentValue > 0 ? (val / totalCurrentValue) * 100.0 : 0.0;
      slices.add(
        AssetAllocationSlice(
          assetType: entry.key,
          label: entry.key.displayName,
          totalValue: val,
          percentage: double.parse(pct.toStringAsFixed(1)),
        ),
      );
    }

    // Sort slices by largest percentage descending
    slices.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    return PortfolioSummary(
      totalInvested: totalInvested,
      totalCurrentValue: totalCurrentValue,
      absoluteReturn: absoluteReturn,
      percentageReturn: percentageReturn,
      isProfitable: absoluteReturn >= 0,
      allocationSlices: slices,
      totalHoldings: active.length,
    );
  }
}
