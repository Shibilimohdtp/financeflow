// DS-B20: one sheet skeleton (header, body, footer) and the shared pieces
// every sheet body is built from.
import 'package:financeflow/core/formatting/app_currency.dart';
import 'package:financeflow/core/formatting/currency_formatter.dart';
import 'package:financeflow/shared/widgets/ff_amount_field.dart';
import 'package:financeflow/shared/widgets/ff_amount_hero.dart';
import 'package:financeflow/shared/widgets/ff_amount_text.dart';
import 'package:financeflow/shared/widgets/ff_choice_tiles.dart';
import 'package:financeflow/shared/widgets/ff_disclosure_row.dart';
import 'package:financeflow/shared/widgets/ff_entity_preview_card.dart';
import 'package:financeflow/shared/widgets/ff_field_label.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/shared/widgets/ff_sheet_footer.dart';
import 'package:financeflow/shared/widgets/ff_sheet_header.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _screen = Size(360, 720);

Future<void> _pump(
  WidgetTester tester,
  ThemeData theme,
  Widget child, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(
          size: _screen,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Color? _bottomBorder(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(FfSheetHeader),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return ((box.decoration as BoxDecoration).border as Border).bottom.color;
}

Color? _topBorder(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(FfSheetFooter),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return ((box.decoration as BoxDecoration).border as Border).top.color;
}

Widget _sheet(int rows) => FfSheet(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const FfSheetHeader(
      title: 'New loan',
      subtitle: 'Money you borrowed and pay back',
    ),
    FfSheetBody(children: [for (var i = 0; i < rows; i++) Text('Line $i')]),
    FfSheetFooter(primaryLabel: 'Create loan', onPrimaryPressed: () {}),
  ],
);

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final c = theme.extension<FfColors>()!;

    group('Sheet skeleton ($mode)', () {
      testWidgets('hairlines appear only while content scrolls', (
        tester,
      ) async {
        await _pump(tester, theme, _sheet(80));
        expect(_bottomBorder(tester), Colors.transparent);
        expect(_topBorder(tester), c.borderSubtle);

        await tester.drag(find.text('Line 3'), const Offset(0, -200));
        await tester.pumpAndSettle();
        expect(_bottomBorder(tester), c.borderSubtle);
      });

      testWidgets('short sheets draw no hairlines', (tester) async {
        await _pump(tester, theme, _sheet(2));
        expect(_bottomBorder(tester), Colors.transparent);
        expect(_topBorder(tester), Colors.transparent);
      });

      testWidgets('header title is not bold and subtitle is secondary', (
        tester,
      ) async {
        await _pump(tester, theme, _sheet(2));
        final title = tester.widget<Text>(find.text('New loan'));
        expect(title.style!.fontWeight, isNot(FontWeight.w700));
        final subtitle = tester.widget<Text>(
          find.text('Money you borrowed and pay back'),
        );
        expect(subtitle.style!.color, c.textSecondary);
        expect(find.byTooltip('Close'), findsOneWidget);
        expect(
          tester.getSize(find.byTooltip('Close')).height,
          greaterThanOrEqualTo(FfTouch.minTarget),
        );
      });

      testWidgets('footer has one full-width primary and no Cancel', (
        tester,
      ) async {
        await _pump(tester, theme, _sheet(2));
        expect(find.text('Cancel'), findsNothing);
        final button = tester.getSize(find.text('Create loan'));
        expect(button.width, greaterThan(0));
        expect(tester.getSize(find.byType(FfSheetFooter)).width, _screen.width);
      });

      testWidgets('a secondary action is a text button above the primary', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          FfSheetFooter(
            primaryLabel: 'Show results',
            onPrimaryPressed: () {},
            secondaryLabel: 'Reset',
            onSecondaryPressed: () {},
          ),
        );
        expect(
          tester.getTopLeft(find.text('Reset')).dy,
          lessThan(tester.getTopLeft(find.text('Show results')).dy),
        );
      });

      testWidgets('no overflow at 2x text and 360 dp', (tester) async {
        await _pump(tester, theme, _sheet(10), textScale: 2);
        expect(tester.takeException(), isNull);
      });
    });

    group('Fields ($mode)', () {
      testWidgets('text field label sits above the box', (tester) async {
        await _pump(
          tester,
          theme,
          const Padding(
            padding: EdgeInsets.all(16),
            child: FfTextField(label: 'Loan name', hint: 'e.g. Car loan'),
          ),
        );
        expect(find.byType(FfFieldLabel), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration!.labelText, isNull);
        expect(
          tester.getBottomLeft(find.text('Loan name')).dy,
          lessThanOrEqualTo(tester.getTopLeft(find.byType(TextField)).dy),
        );
      });

      testWidgets('currency stays visible while empty and unfocused', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          Padding(
            padding: const EdgeInsets.all(16),
            child: FfAmountField(
              controller: TextEditingController(),
              label: 'Target amount',
            ),
          ),
        );
        expect(find.text(CurrencyFormatter.currencySymbol), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('amount hero no longer draws a tinted border', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          FfAmountHero(
            controller: TextEditingController(),
            tone: FfTone.debt,
            label: 'Amount borrowed',
          ),
        );
        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(FfAmountHero),
                matching: find.byType(Container),
              )
              .first,
        );
        final border = (box.decoration! as BoxDecoration).border! as Border;
        expect(border.top.color, c.borderSubtle);
      });
    });

    group('Choice tiles ($mode)', () {
      testWidgets('selected tile is ink with a check, labels never cut', (
        tester,
      ) async {
        String selected = 'cloud';
        await _pump(
          tester,
          theme,
          StatefulBuilder(
            builder:
                (context, setState) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: FfChoiceTiles<String>(
                    selected: selected,
                    onChanged: (v) => setState(() => selected = v),
                    options: const [
                      FfChoiceTile(
                        value: 'stream',
                        icon: Icons.movie_outlined,
                        label: 'Streaming',
                      ),
                      FfChoiceTile(
                        value: 'cloud',
                        icon: Icons.cloud_outlined,
                        label: 'Cloud & apps',
                      ),
                      FfChoiceTile(
                        value: 'news',
                        icon: Icons.newspaper_outlined,
                        label: 'News & magazines',
                      ),
                      FfChoiceTile(
                        value: 'game',
                        icon: Icons.sports_esports_outlined,
                        label: 'Gaming',
                      ),
                    ],
                  ),
                ),
          ),
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        final cloud = tester.widget<Text>(find.text('Cloud & apps'));
        expect(cloud.overflow, isNot(TextOverflow.ellipsis));
        expect(
          tester.getSemantics(find.bySemanticsLabel('Cloud & apps')),
          matchesSemantics(
            label: 'Cloud & apps',
            isButton: true,
            isSelected: true,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
          ),
        );
        await tester.tap(find.text('Gaming'));
        await tester.pump();
        expect(selected, 'game');
      });
    });

    group('Entity preview and disclosure ($mode)', () {
      testWidgets('preview card reads as one sentence', (tester) async {
        await _pump(
          tester,
          theme,
          Builder(
            builder:
                (context) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: FfEntityPreviewCard(
                    leading: FfEntityPreviewCard.disc(
                      context,
                      FfHeroTone.tide,
                      Icons.flag_rounded,
                    ),
                    title: 'Japan trip',
                    subtitle: 'By 13 May 2027',
                    figureCaption: 'Target',
                    figure: const FfAmountText(
                      amount: 100000,
                      size: FfAmountSize.lg,
                    ),
                    semanticLabel: 'Japan trip, target ₹1,00,000',
                  ),
                ),
          ),
        );
        expect(
          find.bySemanticsLabel('Japan trip, target ₹1,00,000'),
          findsOneWidget,
        );
      });

      testWidgets('disclosure row opens and closes', (tester) async {
        await _pump(
          tester,
          theme,
          const Padding(
            padding: EdgeInsets.all(16),
            child: FfDisclosureRow(
              subtitle: 'Account and notes',
              children: [Text('Notes field')],
            ),
          ),
        );
        expect(find.text('Notes field'), findsNothing);
        await tester.tap(find.text('More details'));
        await tester.pumpAndSettle();
        expect(find.text('Notes field'), findsOneWidget);
      });
    });
  }

  group('FfAmountInputFormatter', () {
    TextEditingValue type(String text) =>
        FfAmountInputFormatter().formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );

    tearDown(() => CurrencyFormatter.current = AppCurrency.inr);

    test('groups in the Indian convention', () {
      expect(type('100000').text, '1,00,000');
      expect(type('12345678.5').text, '1,23,45,678.5');
      expect(type('999').text, '999');
      expect(type('1,00,0000').text, '10,00,000');
    });

    test('groups in thousands for other currencies', () {
      CurrencyFormatter.current = AppCurrency.usd;
      expect(type('1234567.25').text, '1,234,567.25');
    });

    test('rejects a third decimal and letters', () {
      final old = const TextEditingValue(text: '12.34');
      final r = FfAmountInputFormatter().formatEditUpdate(
        old,
        const TextEditingValue(
          text: '12.345',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(r.text, '12.34');
      expect(type('12a').text, '');
    });

    test('keeps the cursor after the same digit', () {
      final r = FfAmountInputFormatter().formatEditUpdate(
        const TextEditingValue(text: '1,000'),
        const TextEditingValue(
          text: '1,0000',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(r.text, '10,000');
      expect(r.selection.baseOffset, 6);
    });

    test('parse and formatInput round-trip', () {
      expect(FfAmountField.parse('1,00,000.50'), 100000.5);
      expect(FfAmountField.formatInput(3246.32), '3,246.32');
      expect(FfAmountField.formatInput(5000), '5,000');
    });
  });
}
