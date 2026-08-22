import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/savings_goal_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/export_service.dart';

class ExportController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  ExportController(this._ref) : super(const AsyncValue.data(null));

  Future<String> exportData(ExportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final txRepo = _ref.read(transactionRepositoryProvider);
      final accRepo = _ref.read(accountRepositoryProvider);
      final budgetRepo = _ref.read(budgetRepositoryProvider);
      final goalRepo = _ref.read(savingsGoalRepositoryProvider);
      final subRepo = _ref.read(subscriptionRepositoryProvider);
      final loanRepo = _ref.read(loanRepositoryProvider);
      final invRepo = _ref.read(investmentRepositoryProvider);

      final accounts = await accRepo.getAllAccounts();
      final allTransactions = await txRepo.getAllTransactions();
      final budgets = await budgetRepo.getAllBudgets();
      final goals = await goalRepo.getAllGoals();
      final subscriptions = await subRepo.getAllSubscriptions();
      final loans = await loanRepo.getAllLoans();
      final investments = await invRepo.getAllInvestments();

      // Apply date and filter scopes if applicable
      final filteredTxs =
          allTransactions.where((t) {
            if (request.startDate != null &&
                t.date.isBefore(request.startDate!)) {
              return false;
            }
            if (request.endDate != null && t.date.isAfter(request.endDate!)) {
              return false;
            }
            if (request.selectedAccountIds.isNotEmpty &&
                !request.selectedAccountIds.contains(t.accountId)) {
              return false;
            }
            return true;
          }).toList();

      final String fileContent;
      switch (request.format) {
        case ExportFormat.csv:
          fileContent = ExportService.generateCsv(
            transactions: filteredTxs,
            accounts: accounts,
            maskSensitive: !request.includeSensitiveFields,
          );
          break;
        case ExportFormat.json:
          fileContent = ExportService.generateJson(
            transactions: filteredTxs,
            accounts: accounts,
            budgets: budgets,
            savingsGoals: goals,
            subscriptions: subscriptions,
            loans: loans,
            investments: investments,
            maskSensitive: !request.includeSensitiveFields,
          );
          break;
        case ExportFormat.excel:
          fileContent = ExportService.generateExcelHtml(
            transactions: filteredTxs,
            accounts: accounts,
            maskSensitive: !request.includeSensitiveFields,
          );
          break;
        case ExportFormat.pdf:
          fileContent = ExportService.generateReportText(
            transactions: filteredTxs,
            budgets: budgets,
            accounts: accounts,
            startDate: request.startDate,
            endDate: request.endDate,
          );
          break;
      }

      // Save to local documents / exports directory
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${exportDir.path}/financeflow_export_$timestamp.${request.format.fileExtension}';
      final file = File(filePath);
      await file.writeAsString(fileContent);

      state = AsyncValue.data(filePath);
      return filePath;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final exportControllerProvider =
    StateNotifierProvider<ExportController, AsyncValue<String?>>((ref) {
      return ExportController(ref);
    });
