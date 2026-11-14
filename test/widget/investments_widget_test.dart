import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/investment.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/investment_repository.dart';
import 'package:financeflow/features/investments/add_edit_investment_sheet.dart';
import 'package:financeflow/features/investments/investment_detail_screen.dart';
import 'package:financeflow/features/investments/investments_controller.dart';
import 'package:financeflow/features/investments/investments_screen.dart';
import 'package:financeflow/shared/widgets/ff_allocation_band.dart';
import 'package:financeflow/shared/widgets/ff_card.dart';
import 'package:financeflow/shared/widgets/ff_consequence_line.dart';
import 'package:financeflow/shared/widgets/ff_empty_state.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:financeflow/shared/widgets/ff_amount_field.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

Widget _buildTestApp({
  required Widget child,
  required FakeInvestmentRepository investmentRepo,
  FakeAccountRepository? accountRepo,
}) {
  final accRepo = accountRepo ?? FakeAccountRepository();

  return ProviderScope(
    overrides: [
      investmentRepositoryProvider.overrideWithValue(investmentRepo),
      allInvestmentsStreamProvider.overrideWith(
        (ref) => investmentRepo.watchAllInvestments(),
      ),
      accountRepositoryProvider.overrideWithValue(accRepo),
      allAccountsStreamProvider.overrideWith(
        (ref) => accRepo.watchAllAccounts(),
      ),
      investmentsControllerProvider.overrideWith(
        (ref) => InvestmentsController(investmentRepo),
      ),
    ],
    child: MaterialApp(
      theme: StillwaterTheme.daylight,
      darkTheme: StillwaterTheme.deepWater,
      home: child,
    ),
  );
}

void main() {
  group('Investments Stillwater Bloom Widget Tests', () {
    final now = DateTime(2026, 8, 15);

    final mfInvestment = Investment(
      id: 'inv_1',
      name: 'Parag Parikh Flexi Cap',
      assetType: AssetType.mutualFunds,
      quantityOrUnits: 100.0,
      purchasePrice: 1000.0,
      purchaseDate: DateTime(2025, 1, 1),
      currentValue: 125000.0,
      investedAmount: 100000.0,
      unrealizedProfitLoss: 25000.0,
      lastValuationDate: DateTime.now().subtract(
        const Duration(days: 5),
      ), // Fresh (< 30 days)
      createdAt: now,
      updatedAt: now,
    );

    final staleGoldInvestment = Investment(
      id: 'inv_2',
      name: 'Sovereign Gold Bond 2028',
      assetType: AssetType.gold,
      quantityOrUnits: 10.0,
      purchasePrice: 5000.0,
      purchaseDate: DateTime(2024, 6, 1),
      currentValue: 62000.0,
      investedAmount: 50000.0,
      unrealizedProfitLoss: 12000.0,
      lastValuationDate: DateTime(2026, 5, 1), // Stale (> 30 days ago)
      notes: 'Held in demat account',
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('InvestmentsScreen shows empty state when portfolio is empty', (
      tester,
    ) async {
      final repo = FakeInvestmentRepository();

      await tester.pumpWidget(
        _buildTestApp(child: const InvestmentsScreen(), investmentRepo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Investments'), findsOneWidget);
      expect(find.byType(FfHeroCard), findsOneWidget);
      expect(find.text('PORTFOLIO VALUE'), findsOneWidget);
      expect(find.byType(FfEmptyState), findsOneWidget);
      expect(find.text('No investments recorded'), findsOneWidget);
    });

    testWidgets(
      'InvestmentsScreen displays dusk hero, allocation band, and holdings',
      (tester) async {
        final repo = FakeInvestmentRepository([
          mfInvestment,
          staleGoldInvestment,
        ]);

        await tester.pumpWidget(
          _buildTestApp(child: const InvestmentsScreen(), investmentRepo: repo),
        );
        await tester.pumpAndSettle();

        // Dusk Hero Card verification
        expect(find.byType(FfHeroCard), findsOneWidget);
        expect(find.text('PORTFOLIO VALUE'), findsOneWidget);
        expect(find.text('Invested'), findsOneWidget);
        expect(find.text('Returns'), findsOneWidget);
        expect(
          find.text('Holdings'),
          findsNWidgets(2),
        ); // Hero figure + Section header
        expect(find.text('2 assets'), findsOneWidget);

        // Allocation Band verification
        expect(find.text('Asset Allocation'), findsOneWidget);
        expect(find.byType(FfAllocationBand), findsOneWidget);

        // Holdings verification
        expect(find.text('Parag Parikh Flexi Cap'), findsOneWidget);
        expect(find.text('Sovereign Gold Bond 2028'), findsOneWidget);

        // Stale valuation warning verification
        expect(find.textContaining('ago · Tap to update'), findsOneWidget);
      },
    );

    testWidgets(
      'InvestmentsScreen filters holdings when asset class pill is selected',
      (tester) async {
        final repo = FakeInvestmentRepository([
          mfInvestment,
          staleGoldInvestment,
        ]);

        await tester.pumpWidget(
          _buildTestApp(child: const InvestmentsScreen(), investmentRepo: repo),
        );
        await tester.pumpAndSettle();

        // Both holdings initially visible
        expect(find.text('Parag Parikh Flexi Cap'), findsOneWidget);
        expect(find.text('Sovereign Gold Bond 2028'), findsOneWidget);

        // Tap on the Gold filter chip
        await tester.tap(find.text('Gold & Precious Metals (1)'));
        await tester.pumpAndSettle();

        // Only Gold holding should remain visible
        expect(find.text('Parag Parikh Flexi Cap'), findsNothing);
        expect(find.text('Sovereign Gold Bond 2028'), findsOneWidget);

        // Tap "All" to restore
        await tester.tap(find.text('All (2)'));
        await tester.pumpAndSettle();

        expect(find.text('Parag Parikh Flexi Cap'), findsOneWidget);
        expect(find.text('Sovereign Gold Bond 2028'), findsOneWidget);
      },
    );

    testWidgets(
      'InvestmentDetailScreen displays valuation, facts, and manages holding',
      (tester) async {
        final repo = FakeInvestmentRepository([staleGoldInvestment]);
        final accRepo = FakeAccountRepository([
          Account(
            id: 'acc_demat',
            name: 'Zerodha Demat',
            type: AccountType.investment,
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        await tester.pumpWidget(
          _buildTestApp(
            child: InvestmentDetailScreen(investment: staleGoldInvestment),
            investmentRepo: repo,
            accountRepo: accRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Hero Card verification
        expect(find.text('Sovereign Gold Bond 2028'), findsOneWidget);
        expect(find.text('CURRENT VALUATION'), findsOneWidget);
        expect(find.text('Invested'), findsOneWidget);
        expect(find.text('Units'), findsOneWidget);
        expect(find.text('Avg Price'), findsOneWidget);

        // Holding Details facts
        expect(find.text('Holding Details'), findsOneWidget);
        expect(find.text('Asset Class'), findsOneWidget);
        expect(find.text('Gold & Precious Metals'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Held in demat account'), findsOneWidget);

        // Actions
        expect(find.text('Update Current Valuation'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Edit Details'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Edit Details'), findsOneWidget);
        expect(find.text('Delete Holding'), findsOneWidget);

        // Scroll back up and tap "Update Current Valuation"
        await tester.scrollUntilVisible(
          find.text('Update Current Valuation'),
          -100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Update Current Valuation'));
        await tester.pumpAndSettle();

        expect(find.text('Update Valuation'), findsOneWidget);
        expect(find.byType(FfConsequenceLine), findsOneWidget);
        expect(find.text('Update Value'), findsOneWidget);

        // Close valuation sheet
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'AddEditInvestmentSheet renders preview card and saves holding',
      (tester) async {
        final repo = FakeInvestmentRepository();

        await tester.pumpWidget(
          _buildTestApp(
            child: const Scaffold(body: AddEditInvestmentSheet()),
            investmentRepo: repo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add Investment'), findsOneWidget);
        expect(find.text('Asset Class'), findsOneWidget);
        expect(find.byType(FfConsequenceLine), findsOneWidget);

        // Enter holding name
        await tester.enterText(
          find.widgetWithText(FfTextField, 'Holding / Asset Name'),
          'Tata Steel Shares',
        );
        await tester.pumpAndSettle();

        // Live preview card updates with name
        expect(
          find.descendant(
            of: find.byType(FfCard),
            matching: find.text('Tata Steel Shares'),
          ),
          findsOneWidget,
        );

        // Enter price and current value
        await tester.enterText(
          find.widgetWithText(FfAmountField, 'Purchase / Unit Price'),
          '150',
        );
        await tester.enterText(
          find.widgetWithText(FfAmountField, 'Current Value'),
          '175',
        );
        await tester.pumpAndSettle();

        // Tap "Add Holding"
        await tester.tap(find.text('Add Holding'));
        await tester.pumpAndSettle();

        // Verify saved in repository
        final holdings = await repo.getAllInvestments();
        expect(holdings.length, 1);
        expect(holdings.first.name, 'Tata Steel Shares');
        expect(holdings.first.purchasePrice, 150.0);
        expect(holdings.first.currentValue, 175.0);
      },
    );
  });
}
