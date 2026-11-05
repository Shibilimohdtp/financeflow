// DS-5b: FfRow (plain, tile, detail, chevron, selected, toggle, checkbox,
// radio, destructive), FfIconTile and FfGroupedContainer dividers.
import 'package:financeflow/shared/widgets/ff_divider.dart';
import 'package:financeflow/shared/widgets/ff_grouped_container.dart';
import 'package:financeflow/shared/widgets/ff_icon_tile.dart';
import 'package:financeflow/shared/widgets/ff_row.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_contrast.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/tokens/ff_component_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, ThemeData theme, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: ListView(children: [child])),
      ),
    );

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final c = theme.extension<FfColors>()!;

    group('FfRow ($mode)', () {
      testWidgets('tappable rows show a chevron and meet the touch target', (
        tester,
      ) async {
        var taps = 0;
        await _pump(
          tester,
          theme,
          FfRow(
            icon: Icons.account_balance_outlined,
            title: 'Loans & EMI Tracker',
            onTap: () => taps++,
          ),
        );
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
        expect(
          tester.getSize(find.byType(FfRow)).height,
          greaterThanOrEqualTo(FfRowTokens.minHeight),
        );
        await tester.tap(find.text('Loans & EMI Tracker'));
        expect(taps, 1);
      });

      testWidgets('read-only rows have no chevron', (tester) async {
        await _pump(
          tester,
          theme,
          const FfRow(title: 'Version', detail: '1.0.0'),
        );
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
        expect(find.text('1.0.0'), findsOneWidget);
      });

      testWidgets('plain icons and tone tiles', (tester) async {
        await _pump(
          tester,
          theme,
          const Column(
            children: [
              FfRow(icon: Icons.palette_outlined, title: 'Appearance'),
              FfRow(
                icon: Icons.savings_outlined,
                iconTone: FfTone.savings,
                title: 'Emergency fund',
              ),
            ],
          ),
        );
        final plain = tester.widget<Icon>(find.byIcon(Icons.palette_outlined));
        expect(plain.color, c.textSecondary);
        expect(plain.size, FfRowTokens.iconSize);
        expect(find.byType(FfIconTile), findsOneWidget);
        final tiled = tester.widget<Icon>(find.byIcon(Icons.savings_outlined));
        expect(tiled.color, c.moneySavings);
      });

      testWidgets('toggle: tapping anywhere flips the switch', (tester) async {
        var value = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder:
                    (context, setState) => FfRow.toggle(
                      title: 'Privacy blur',
                      subtitle: 'Mask balances by default',
                      value: value,
                      onChanged: (v) => setState(() => value = v),
                    ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Mask balances by default'));
        await tester.pump();
        expect(value, isTrue);
        expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      });

      testWidgets('toggle announces its state once', (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          theme,
          FfRow.toggle(title: 'Daily reminder', value: true, onChanged: (_) {}),
        );
        expect(
          tester.getSemantics(find.byType(FfRow)),
          matchesSemantics(
            label: 'Daily reminder',
            hasToggledState: true,
            isToggled: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
          ),
        );
        handle.dispose();
      });

      testWidgets('disabled toggle ignores taps', (tester) async {
        var changed = false;
        await _pump(
          tester,
          theme,
          FfRow.toggle(
            title: 'Biometric lock',
            value: false,
            enabled: false,
            onChanged: (_) => changed = true,
          ),
        );
        await tester.tap(find.text('Biometric lock'));
        expect(changed, isFalse);
        final title = tester.widget<Text>(find.text('Biometric lock'));
        expect(title.style!.color, c.textDisabled);
      });

      testWidgets('checkbox and radio rows', (tester) async {
        var checked = false;
        var picked = 'merge';
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder:
                    (context, setState) => Column(
                      children: [
                        FfRow.checkbox(
                          title: 'Google Pay',
                          checked: checked,
                          onChanged: (v) => setState(() => checked = v),
                        ),
                        for (final mode in ['merge', 'replace'])
                          FfRow.radio(
                            title: mode,
                            selected: picked == mode,
                            onTap: () => setState(() => picked = mode),
                          ),
                      ],
                    ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Google Pay'));
        await tester.pump();
        expect(checked, isTrue);

        expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
        await tester.tap(find.text('replace'));
        await tester.pump();
        expect(picked, 'replace');
        final marks = tester.widgetList<Icon>(
          find.byIcon(Icons.radio_button_checked),
        );
        expect(marks.single.color, c.actionPrimary);
      });

      testWidgets('selected rows show a check, others nothing', (tester) async {
        await _pump(
          tester,
          theme,
          Column(
            children: [
              FfRow(title: 'INR', selected: true, onTap: () {}),
              FfRow(title: 'USD', selected: false, onTap: () {}),
            ],
          ),
        );
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      });

      testWidgets('destructive rows use the error colour', (tester) async {
        await _pump(
          tester,
          theme,
          FfRow(
            icon: Icons.delete_outline_rounded,
            title: 'Delete transaction',
            destructive: true,
            onTap: () {},
          ),
        );
        final title = tester.widget<Text>(find.text('Delete transaction'));
        expect(title.style!.color, c.statusError);
        final icon = tester.widget<Icon>(
          find.byIcon(Icons.delete_outline_rounded),
        );
        expect(icon.color, c.statusError);
        expect(
          FfContrast.ratio(c.statusError, c.surfaceCard),
          greaterThanOrEqualTo(FfContrast.text),
        );
      });

      testWidgets('long text never overflows', (tester) async {
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _pump(
          tester,
          theme,
          FfRow(
            icon: Icons.account_balance_outlined,
            title: 'A very long account name that keeps going and going',
            subtitle:
                'And a subtitle that is also far too long to fit on one line of a narrow phone screen',
            detail: '₹1,23,45,678.90',
            onTap: () {},
          ),
        );
        expect(tester.takeException(), isNull);
      });
    });

    group('FfGroupedContainer ($mode)', () {
      testWidgets('draws dividers between rows, inset to the text', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          const FfGroupedContainer(
            dividerInset: FfRowLeading.icon,
            children: [
              FfRow(icon: Icons.lock_outline, title: 'PIN'),
              FfRow(icon: Icons.fingerprint, title: 'Biometrics'),
              FfRow(icon: Icons.blur_on, title: 'Blur'),
            ],
          ),
        );
        final dividers = tester.widgetList<Divider>(find.byType(Divider));
        expect(dividers, hasLength(2));
        expect(dividers.first.indent, FfRowTokens.textInsetAfterIcon);
        // The divider starts where the row text starts.
        final textLeft = tester.getTopLeft(find.text('PIN')).dx;
        final containerLeft =
            tester.getTopLeft(find.byType(FfGroupedContainer)).dx;
        expect(
          textLeft - containerLeft,
          closeTo(FfRowTokens.textInsetAfterIcon + FfCardTokens.borderWidth, 1),
        );
      });
    });
  }
}
