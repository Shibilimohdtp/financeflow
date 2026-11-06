import 'package:financeflow/shared/widgets/ff_schedule_row.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  required Widget child,
  ThemeData? theme,
  double width = 360,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: theme ?? StillwaterTheme.daylight,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: SizedBox(width: width, child: child)),
    ),
  );
}

FfScheduleRow _row({
  FfScheduleRowState state = FfScheduleRowState.upcoming,
  VoidCallback? onAction,
  bool isBlurred = false,
  DateTime? paidOn,
  int number = 7,
}) {
  return FfScheduleRow(
    number: number,
    dueDate: DateTime(2026, 9, 3),
    emiAmount: 9047.92,
    principal: 7166.67,
    interest: 1881.25,
    balance: 150000,
    state: state,
    paidOn: paidOn,
    onAction: onAction,
    isBlurred: isBlurred,
  );
}

void main() {
  group('FfScheduleRow', () {
    for (final (mode, theme) in [
      ('light', StillwaterTheme.daylight),
      ('dark', StillwaterTheme.deepWater),
    ]) {
      for (final state in FfScheduleRowState.values) {
        testWidgets('renders $state in $mode without overflow', (tester) async {
          await tester.pumpWidget(
            _host(
              theme: theme,
              child: _row(
                state: state,
                onAction: () {},
                paidOn: DateTime(2026, 9, 3),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(FfScheduleRow), findsOneWidget);
        });
      }
    }

    testWidgets('paid row shows the paid badge and an Undo action', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          child: _row(
            state: FfScheduleRowState.paid,
            paidOn: DateTime(2026, 9, 3),
            onAction: () => taps++,
          ),
        ),
      );

      expect(find.text('Paid 3 Sep 2026'), findsOneWidget);
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      expect(taps, 1);
    });

    testWidgets('next row offers Mark paid and no status for a future row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(child: _row(state: FfScheduleRowState.next, onAction: () {})),
      );
      expect(find.text('Mark paid'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('upcoming row with no action shows no button', (tester) async {
      await tester.pumpWidget(
        _host(child: _row(state: FfScheduleRowState.upcoming)),
      );
      expect(find.text('Mark paid'), findsNothing);
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('overdue row says Overdue in words, not colour alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: FfScheduleRow(
            number: 4,
            dueDate: DateTime.now().subtract(const Duration(days: 5)),
            emiAmount: 9047.92,
            principal: 7166.67,
            interest: 1881.25,
            balance: 150000,
            state: FfScheduleRowState.overdue,
            onAction: () {},
          ),
        ),
      );
      expect(find.textContaining('Overdue'), findsOneWidget);
    });

    testWidgets('semantics name the installment, state and figures', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: _row(state: FfScheduleRowState.upcoming)),
      );

      expect(
        find.bySemanticsLabel(RegExp(r'^Installment 7, .*upcoming, EMI ')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('hidden amounts leave no figures in text or semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: _row(state: FfScheduleRowState.upcoming, isBlurred: true)),
      );

      expect(find.textContaining('Principal'), findsNothing);
      expect(find.textContaining('Interest'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp(r'^Installment 7, .*upcoming$')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('survives 2x text on a narrow 320 px screen', (tester) async {
      await tester.pumpWidget(
        _host(
          width: 320,
          textScale: 2.0,
          child: _row(state: FfScheduleRowState.overdue, onAction: () {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
