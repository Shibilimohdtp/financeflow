// DS-5a: FfAppBar (standard, two-line, search, selection) and FfDivider.
import 'package:financeflow/shared/widgets/ff_app_bar.dart';
import 'package:financeflow/shared/widgets/ff_divider.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/tokens/ff_component_tokens.dart';
import 'package:financeflow/theme/tokens/ff_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(ThemeData theme, PreferredSizeWidget bar, {Widget? body}) =>
    MaterialApp(theme: theme, home: Scaffold(appBar: bar, body: body));

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final colors = theme.extension<FfColors>()!;

    group('FfAppBar ($mode)', () {
      testWidgets('a tab title lines up with the page margin', (tester) async {
        await tester.pumpWidget(_app(theme, const FfAppBar(title: 'Loans')));
        expect(tester.getTopLeft(find.text('Loans')).dx, FfSpace.pageMargin);
      });

      testWidgets('long titles stay on one line', (tester) async {
        await tester.pumpWidget(
          _app(
            theme,
            const FfAppBar(
              title:
                  'A very long savings goal name that will not fit in the bar',
            ),
          ),
        );
        final text = tester.widget<Text>(find.textContaining('A very long'));
        expect(text.maxLines, 1);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(tester.takeException(), isNull);
      });

      testWidgets('subtitle shows as a second, smaller line', (tester) async {
        await tester.pumpWidget(
          _app(
            theme,
            const FfAppBar(title: 'Home loan', subtitle: 'HDFC Bank'),
          ),
        );
        expect(find.text('Home loan'), findsOneWidget);
        expect(find.text('HDFC Bank'), findsOneWidget);
        final sub = tester.widget<Text>(find.text('HDFC Bank'));
        final main = tester.widget<Text>(find.text('Home loan'));
        expect(sub.style!.fontSize, lessThan(main.style!.fontSize!));
      });

      testWidgets('search mode edits, clears and closes', (tester) async {
        final controller = TextEditingController();
        final changes = <String>[];
        var closed = false;
        await tester.pumpWidget(
          _app(
            theme,
            FfAppBar.search(
              controller: controller,
              hint: 'Search payee',
              onChanged: changes.add,
              onClose: () => closed = true,
            ),
          ),
        );
        expect(find.text('Search payee'), findsOneWidget);
        expect(find.byTooltip('Clear search text'), findsNothing);

        await tester.enterText(find.byType(TextField), 'swiggy');
        await tester.pump();
        expect(changes.last, 'swiggy');
        expect(find.byTooltip('Clear search text'), findsOneWidget);

        await tester.tap(find.byTooltip('Clear search text'));
        await tester.pump();
        expect(controller.text, isEmpty);
        expect(changes.last, '');

        await tester.tap(find.byTooltip('Close search'));
        expect(closed, isTrue);
      });

      testWidgets('selection mode shows the count and cancels', (tester) async {
        var cancelled = false;
        await tester.pumpWidget(
          _app(
            theme,
            FfAppBar.selection(
              count: 3,
              onCancel: () => cancelled = true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete selected',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
        expect(find.text('3 selected'), findsOneWidget);
        expect(find.byTooltip('Delete selected'), findsOneWidget);
        await tester.tap(find.byTooltip('Cancel selection'));
        expect(cancelled, isTrue);
      });
    });

    group('FfDivider ($mode)', () {
      testWidgets('variants share colour and thickness', (tester) async {
        await tester.pumpWidget(
          _app(
            theme,
            const FfAppBar(title: 'x'),
            body: const Column(
              children: [FfDivider(), FfDivider.inset(), FfDivider.spaced()],
            ),
          ),
        );
        final dividers = tester.widgetList<Divider>(find.byType(Divider));
        expect(dividers.map((d) => d.color).toSet(), {colors.borderSubtle});
        expect(dividers.map((d) => d.thickness).toSet(), {
          FfDividerTokens.thickness,
        });
        expect(dividers.map((d) => d.indent).toList(), [
          0,
          FfDividerTokens.rowInset,
          0,
        ]);
        expect(dividers.map((d) => d.height).toList(), [
          FfDividerTokens.space,
          FfDividerTokens.space,
          FfDividerTokens.spacedHeight,
        ]);
      });
    });
  }
}
