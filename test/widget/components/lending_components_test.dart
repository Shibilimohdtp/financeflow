import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/ff_due_chip.dart';
import 'package:financeflow/shared/widgets/ff_balance_band.dart';
import 'package:financeflow/shared/widgets/ff_ledger_entry_row.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  final refDate = DateTime(2026, 11, 6);

  group('FfDueChip boundary rules', () {
    test('formats boundary dates accurately', () {
      // Settled
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 10),
          isSettled: true,
          asOfDate: refDate,
        ),
        equals('Settled'),
      );
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 10),
          settledAt: DateTime(2026, 11, 5),
          asOfDate: refDate,
        ),
        equals('Settled 5 Nov'),
      );

      // Overdue
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 5), // 1 day ago
          asOfDate: refDate,
        ),
        equals('Overdue 1 day'),
      );
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 10, 25), // 12 days ago
          asOfDate: refDate,
        ),
        equals('Overdue 12 days'),
      );
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 10, 25),
          asOfDate: refDate,
          compact: true,
        ),
        equals('Overdue 12d'),
      );

      // Today
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 6),
          asOfDate: refDate,
        ),
        equals('Due today'),
      );

      // Tomorrow
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 7),
          asOfDate: refDate,
        ),
        equals('Due tomorrow'),
      );

      // 2–7 days
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 9), // 3 days
          asOfDate: refDate,
        ),
        equals('Due in 3 days'),
      );
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 13), // 7 days
          asOfDate: refDate,
        ),
        equals('Due in 7 days'),
      );

      // > 7 days
      expect(
        FfDueChip.formatLabel(
          dueDate: DateTime(2026, 11, 20),
          asOfDate: refDate,
        ),
        equals('Due 20 Nov'),
      );
    });

    test('resolves semantic tones and icons correctly', () {
      expect(
        FfDueChip.resolveTone(
          dueDate: DateTime(2026, 11, 1),
          asOfDate: refDate,
        ),
        equals(FfTone.expense),
      );
      expect(
        FfDueChip.resolveTone(
          dueDate: DateTime(2026, 11, 6),
          asOfDate: refDate,
        ),
        equals(FfTone.warning),
      );
      expect(
        FfDueChip.resolveTone(
          dueDate: DateTime(2026, 11, 10),
          asOfDate: refDate,
        ),
        equals(FfTone.debt),
      );
      expect(
        FfDueChip.resolveTone(
          dueDate: DateTime(2026, 11, 25),
          asOfDate: refDate,
        ),
        equals(FfTone.neutral),
      );
      expect(
        FfDueChip.resolveTone(
          dueDate: DateTime(2026, 11, 25),
          isSettled: true,
          asOfDate: refDate,
        ),
        equals(FfTone.income),
      );
    });

    testWidgets('renders properly in light and dark mode', (tester) async {
      for (final theme in [
        StillwaterTheme.daylight,
        StillwaterTheme.deepWater,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: FfDueChip(
                  dueDate: DateTime(2026, 10, 25),
                  asOfDate: refDate,
                ),
              ),
            ),
          ),
        );
        expect(find.text('Overdue 12 days'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      }
    });
  });

  group('FfBalanceBand', () {
    testWidgets('renders proportional segments and legend', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: Center(
              child: FfBalanceBand(
                leftLabel: 'Owed to you',
                leftAmount: 7000,
                rightLabel: 'You owe',
                rightAmount: 5000,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Owed to you: '), findsOneWidget);
      expect(find.text('You owe: '), findsOneWidget);
      expect(find.text('₹7,000'), findsOneWidget);
      expect(find.text('₹5,000'), findsOneWidget);
    });
  });

  group('FfLedgerEntryRow', () {
    testWidgets('renders event details and handles tap/delete', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: Center(
              child: FfLedgerEntryRow(
                title: 'Money lent',
                date: DateTime(2026, 10, 1),
                amount: 7500,
                runningBalance: 7500,
                isInflow: false,
                accountName: 'HDFC Salary',
                allocationBadge: 'Partly paid',
                allocationTone: FfTone.debt,
                notes: 'Emergency car repair',
                onDelete: () => deleted = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Money lent'), findsOneWidget);
      expect(find.text('Partly paid'), findsOneWidget);
      expect(find.text('1 Oct 2026 · HDFC Salary'), findsOneWidget);
      expect(find.text('Emergency car repair'), findsOneWidget);
      expect(find.text('Bal: ₹7,500'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(deleted, isTrue);
    });
  });
}
