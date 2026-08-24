import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/alert_engine_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  test('does not recreate a budget alert when scanned repeatedly', () async {
    final alerts = FakeAlertRepository();
    final service = AlertEngineService(alertRepository: alerts);
    final now = DateTime(2026, 8, 24, 14, 47);
    final budget = Budget(
      id: 'budget_food',
      name: 'Food',
      categoryId: 'food',
      categoryName: 'Food',
      amountLimit: 100,
      startDate: DateTime(2026, 8, 1),
      alertThreshold: .8,
      createdAt: now,
      updatedAt: now,
    );
    final transactions = [
      Transaction(
        id: 'food_expense',
        amount: 95,
        type: TransactionType.expense,
        categoryId: 'food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'orange',
        merchant: 'Market',
        date: now,
        accountId: 'cash',
        createdAt: now,
        updatedAt: now,
      ),
    ];
    const settings = AppSettings(isBackupReminderEnabled: false);

    await service.scanAndGenerateAlerts(
      settings: settings,
      activeBudgets: [budget],
      monthTransactions: transactions,
      activeSubscriptions: const [],
      activeLoans: const [],
      pendingReviewCount: 0,
      referenceDate: now,
    );
    await service.scanAndGenerateAlerts(
      settings: settings,
      activeBudgets: [budget],
      monthTransactions: transactions,
      activeSubscriptions: const [],
      activeLoans: const [],
      pendingReviewCount: 0,
      referenceDate: now.add(const Duration(minutes: 3)),
    );

    final saved = await alerts.getActiveAlerts();
    expect(saved, hasLength(1));
    expect(saved.single.relatedEntityType, 'budget');
    expect(saved.single.relatedEntityId, budget.id);
  });
}
