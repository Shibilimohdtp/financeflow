import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/investment.dart';
import '../../repositories/investment_repository.dart';
import '../../services/investment_calculator.dart';

final portfolioSummaryProvider = Provider<PortfolioSummary>((ref) {
  final investments = ref.watch(allInvestmentsStreamProvider).value ?? const [];
  return InvestmentCalculator.calculatePortfolioSummary(investments);
});

class InvestmentsController extends StateNotifier<AsyncValue<void>> {
  final InvestmentRepository _repository;
  static const _uuid = Uuid();

  InvestmentsController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addInvestment({
    required String name,
    required AssetType assetType,
    String? accountId,
    double quantityOrUnits = 1.0,
    required double purchasePrice,
    required DateTime purchaseDate,
    required double currentValue,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final invested = purchasePrice * quantityOrUnits;
      final unrealized = currentValue - invested;

      final inv = Investment(
        id: 'inv_${_uuid.v4()}',
        name: name,
        assetType: assetType,
        accountId: accountId,
        quantityOrUnits: quantityOrUnits,
        purchasePrice: purchasePrice,
        purchaseDate: purchaseDate,
        currentValue: currentValue,
        investedAmount: invested,
        unrealizedProfitLoss: unrealized,
        lastValuationDate: now,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.saveInvestment(inv);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateInvestment(Investment investment) async {
    state = const AsyncValue.loading();
    try {
      final updated = investment.copyWith(
        investedAmount: investment.purchasePrice * investment.quantityOrUnits,
        unrealizedProfitLoss:
            investment.currentValue -
            (investment.purchasePrice * investment.quantityOrUnits),
        updatedAt: DateTime.now(),
      );
      await _repository.saveInvestment(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateValuation(String id, double newCurrentValue) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateValuation(id, newCurrentValue);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteInvestment(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteInvestment(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final investmentsControllerProvider =
    StateNotifierProvider<InvestmentsController, AsyncValue<void>>((ref) {
      final repo = ref.watch(investmentRepositoryProvider);
      return InvestmentsController(repo);
    });
