// DS-B20: every migrated sheet lays out at 360 dp with 2x text, in light
// and dark, all the way down, and follows the skeleton (no Cancel button).
import 'package:financeflow/features/investments/add_edit_investment_sheet.dart';
import 'package:financeflow/features/savings_goals/add_edit_savings_goal_sheet.dart';
import 'package:financeflow/features/savings_goals/add_goal_contribution_sheet.dart';
import 'package:financeflow/features/savings_goals/savings_goals_controller.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _goal = SavingsGoal(
  id: 'g1',
  name: 'Japan trip',
  targetAmount: 150000,
  targetDate: DateTime(2027, 5, 13),
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

/// The sheets under test, each with the provider overrides it needs to
/// render (no saving happens here).
final Map<String, (Widget, List<Override>)> sheets = {
  'savings goal': (
    const AddEditSavingsGoalSheet(),
    [allAccountsStreamProvider.overrideWith((ref) => Stream.value([]))],
  ),
  'goal contribution': (
    AddGoalContributionSheet(goal: _goal),
    [
      allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
      goalContributionsForGoalProvider(
        'g1',
      ).overrideWith((ref) => Stream.value([])),
    ],
  ),
  'investment': (
    const AddEditInvestmentSheet(),
    [allAccountsStreamProvider.overrideWith((ref) => Stream.value([]))],
  ),
};

Future<void> _open(
  WidgetTester tester,
  Widget sheet,
  List<Override> overrides,
  ThemeData theme,
) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showFfSheet<void>(context, builder: (_) => sheet),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final MapEntry(key: name, value: (sheet, overrides)) in sheets.entries) {
    for (final (mode, theme) in [
      ('light', FfTheme.light()),
      ('dark', FfTheme.dark()),
    ]) {
      testWidgets('$name: 360 dp, 2x text, $mode', (tester) async {
        await _open(tester, sheet, overrides, theme);
        expect(tester.takeException(), isNull);
        expect(find.text('Cancel'), findsNothing);
        final body =
            find
                .descendant(
                  of: find.byType(FfSheet),
                  matching: find.byType(Scrollable),
                )
                .first;
        for (var i = 0; i < 8; i++) {
          await tester.drag(body, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
