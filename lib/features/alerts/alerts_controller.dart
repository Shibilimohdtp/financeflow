import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/alert_engine_service.dart';
import '../../services/notifications/notification_coordinator.dart';
import '../ingestion/needs_review_controller.dart';

final alertEngineServiceProvider = Provider<AlertEngineService>((ref) {
  final alertRepo = ref.watch(alertRepositoryProvider);
  return AlertEngineService(alertRepository: alertRepo);
});

class AlertsController extends StateNotifier<AsyncValue<void>> {
  final AlertRepository _repository;
  final AlertEngineService _engine;
  final Ref _ref;

  AlertsController(this._repository, this._engine, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> runAlertScan() async {
    state = const AsyncValue.loading();
    try {
      final settings =
          await _ref.read(settingsRepositoryProvider).getSettings();
      final budgets = await _ref.read(budgetRepositoryProvider).getAllBudgets();
      final transactions =
          await _ref.read(transactionRepositoryProvider).getAllTransactions();
      final subscriptions =
          await _ref.read(subscriptionRepositoryProvider).getAllSubscriptions();
      final loans = await _ref.read(loanRepositoryProvider).getAllLoans();
      final pendingCount = _ref.read(pendingReviewCountProvider);

      await _engine.scanAndGenerateAlerts(
        settings: settings,
        activeBudgets: budgets,
        monthTransactions: transactions,
        activeSubscriptions: subscriptions,
        activeLoans: loans,
        pendingReviewCount: pendingCount,
      );

      // Synchronize device notifications after in-app alert decisions are committed
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }

  Future<void> dismissAlert(String id) async {
    try {
      await _repository.dismissAlert(id);
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllAlerts();
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
    } catch (_) {}
  }
}

final alertsControllerProvider =
    StateNotifierProvider<AlertsController, AsyncValue<void>>((ref) {
      final repo = ref.watch(alertRepositoryProvider);
      final engine = ref.watch(alertEngineServiceProvider);
      return AlertsController(repo, engine, ref);
    });
