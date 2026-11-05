// DS-5c: FfTextField (+ search), FfSelect, FfMenuButton.
import 'package:financeflow/shared/widgets/ff_menu.dart';
import 'package:financeflow/shared/widgets/ff_select.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, ThemeData theme, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final c = theme.extension<FfColors>()!;

    group('FfTextField ($mode)', () {
      testWidgets('label, hint, prefix and icon slots render', (tester) async {
        await _pump(
          tester,
          theme,
          const FfTextField(
            label: 'Goal name',
            hint: 'e.g. Emergency fund',
            icon: Icons.flag_outlined,
            prefixText: '₹ ',
          ),
        );
        expect(find.text('Goal name'), findsOneWidget);
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration!.hintText, 'e.g. Emergency fund');
        expect(field.decoration!.prefixText, '₹ ');
        // Borders and fill come from the theme, not the call site.
        expect(field.decoration!.border, theme.inputDecorationTheme.border);
        expect(
          field.decoration!.fillColor,
          theme.inputDecorationTheme.fillColor,
        );
      });

      testWidgets('validator errors show under the field', (tester) async {
        final key = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Form(
                key: key,
                child: FfTextField(
                  label: 'Amount',
                  validator:
                      (v) => (v ?? '').isEmpty ? 'Enter an amount' : null,
                ),
              ),
            ),
          ),
        );
        expect(key.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Enter an amount'), findsOneWidget);
      });

      testWidgets('search clears with one tap', (tester) async {
        final controller = TextEditingController();
        final changes = <String>[];
        await _pump(
          tester,
          theme,
          FfTextField.search(
            controller: controller,
            hint: 'Search categories...',
            onChanged: changes.add,
          ),
        );
        expect(find.byTooltip('Clear search'), findsNothing);
        await tester.enterText(find.byType(TextField), 'food');
        await tester.pump();
        expect(find.byTooltip('Clear search'), findsOneWidget);
        await tester.tap(find.byTooltip('Clear search'));
        await tester.pump();
        expect(controller.text, isEmpty);
        expect(changes.last, '');
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration!.fillColor, c.surfaceContainerLow);
      });
    });

    group('FfSelect ($mode)', () {
      testWidgets('opens on the raised surface and returns the choice', (
        tester,
      ) async {
        String? picked;
        await _pump(
          tester,
          theme,
          FfSelect<String>(
            label: 'Account',
            icon: Icons.account_balance_wallet_outlined,
            value: 'cash',
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash wallet')),
              DropdownMenuItem(value: 'hdfc', child: Text('HDFC Savings')),
            ],
            onChanged: (v) => picked = v,
          ),
        );
        expect(find.text('Account'), findsOneWidget);
        await tester.tap(find.text('Cash wallet'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('HDFC Savings').last);
        await tester.pumpAndSettle();
        expect(picked, 'hdfc');
      });
    });

    group('FfMenuButton ($mode)', () {
      testWidgets('lists actions and marks destructive ones', (tester) async {
        String? chosen;
        await _pump(
          tester,
          theme,
          Align(
            alignment: Alignment.topRight,
            child: FfMenuButton<String>(
              items: const [
                FfMenuItem(value: 'edit', label: 'Edit details'),
                FfMenuItem(
                  value: 'delete',
                  label: 'Delete account',
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                ),
              ],
              onSelected: (v) => chosen = v,
            ),
          ),
        );
        await tester.tap(find.byTooltip('More options'));
        await tester.pumpAndSettle();
        final delete = tester.widget<Text>(find.text('Delete account'));
        expect(delete.style!.color, c.statusError);
        await tester.tap(find.text('Edit details'));
        await tester.pumpAndSettle();
        expect(chosen, 'edit');
      });
    });
  }
}
