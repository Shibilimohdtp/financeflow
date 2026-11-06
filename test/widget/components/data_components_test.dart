// DS-6: amounts, amount entry, progress, loading, badges, key-value rows,
// stat tiles and cards.
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/shared/widgets/ff_amount_field.dart';
import 'package:financeflow/shared/widgets/ff_amount_text.dart';
import 'package:financeflow/shared/widgets/ff_badge.dart';
import 'package:financeflow/shared/widgets/ff_card.dart';
import 'package:financeflow/shared/widgets/ff_key_value_row.dart';
import 'package:financeflow/shared/widgets/ff_progress.dart';
import 'package:financeflow/shared/widgets/ff_stat_tile.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_contrast.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_typography.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/tokens/ff_component_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  ThemeData theme,
  Widget child, {
  double textScale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

Color? _textColor(WidgetTester tester, Finder f) =>
    tester.widget<Text>(f).style?.color;

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final c = theme.extension<FfColors>()!;

    group('FfAmountText ($mode)', () {
      testWidgets('type picks colour and sign; tone overrides', (tester) async {
        await _pump(
          tester,
          theme,
          const Column(
            children: [
              FfAmountText(amount: 500, type: TransactionType.income),
              FfAmountText(amount: 200, type: TransactionType.expense),
              FfAmountText(amount: 300, tone: FfTone.debt),
              FfAmountText(amount: 900, tone: FfTone.neutral, showSign: false),
            ],
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts[0].data, startsWith('+'));
        expect(texts[0].style!.color, c.moneyIncome);
        expect(texts[1].data, anyOf(startsWith('−'), startsWith('-')));
        expect(texts[1].style!.color, c.moneyExpense);
        expect(texts[2].style!.color, c.moneyDebt);
        expect(texts[3].style!.color, c.textPrimary);
      });

      testWidgets('large system text is clamped for amounts', (tester) async {
        await _pump(
          tester,
          theme,
          const FfAmountText(amount: 1234567, size: FfAmountSize.hero),
          textScale: 2,
        );
        final scaler = MediaQuery.textScalerOf(
          tester.element(find.byType(Text)),
        );
        expect(
          scaler.scale(10),
          closeTo(10 * FfAmountTokens.maxTextScale, 0.01),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('hero and lg amounts are split, rows inline', (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          theme,
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FfAmountText(
                amount: 5206777.18,
                size: FfAmountSize.hero,
                tone: FfTone.neutral,
                showSign: false,
              ),
              FfAmountText(amount: 48210, size: FfAmountSize.sm),
            ],
          ),
        );
        final hero = tester.widget<Text>(find.byType(Text).first);
        final spans = (hero.textSpan! as TextSpan).children!.cast<TextSpan>();
        final number = spans.firstWhere((s) => s.style == null);
        final decimals = spans.last;
        expect(number.text, contains('52,06,777'));
        expect(decimals.text, '.18');
        expect(
          decimals.style!.fontSize,
          lessThan(theme.extension<FfText>()!.moneyHero.fontSize!),
        );
        // The row amount is one plain run of text.
        expect(tester.widget<Text>(find.byType(Text).last).data, isNotNull);
        // Screen readers hear the whole amount once.
        expect(find.bySemanticsLabel(RegExp('52,06,777.18')), findsOneWidget);
        handle.dispose();
      });

      testWidgets('split amounts shrink to fit instead of overflowing', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          const SizedBox(
            width: 140,
            child: FfAmountText(amount: 99999999.99, size: FfAmountSize.hero),
          ),
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(FittedBox)).width,
          lessThanOrEqualTo(140),
        );
      });

      test('split parts keep sign and symbol together', () {
        final p = FfAmountSplit.parts('− ₹1,08,480.50');
        expect(p.prefix, '− ₹');
        expect(p.number, '1,08,480');
        expect(p.decimals, '.50');
        expect(FfAmountSplit.parts('₹430').decimals, '');
        expect(FfAmountSplit.parts('n/a').number, 'n/a');
      });

      testWidgets('privacy blur hides the figure from everyone', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          theme,
          const FfAmountText(amount: 42, isBlurred: true),
        );
        expect(find.textContaining('42'), findsNothing);
        expect(
          find.bySemanticsLabel('Amount hidden for privacy'),
          findsOneWidget,
        );
        handle.dispose();
      });
    });

    group('FfAmountField ($mode)', () {
      testWidgets('accepts at most two decimals and validates', (tester) async {
        final controller = TextEditingController();
        final key = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Form(
                key: key,
                child: FfAmountField(
                  controller: controller,
                  label: 'Amount',
                  tone: FfTone.expense,
                  validator:
                      (v) => (v ?? '').isEmpty ? 'Enter an amount' : null,
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), '12.345');
        expect(controller.text, isNot('12.345'));
        await tester.enterText(find.byType(TextField), '12.34');
        expect(controller.text, '12.34');
        controller.clear();
        expect(key.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Enter an amount'), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration!.prefixStyle!.color, c.moneyExpense);
      });

      testWidgets('bare variant has no border', (tester) async {
        await _pump(
          tester,
          theme,
          FfAmountField.bare(controller: TextEditingController()),
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.decoration!.border, InputBorder.none);
      });
    });

    group('progress ($mode)', () {
      testWidgets('bar clamps, announces percent and shows pace', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          theme,
          const SizedBox(
            width: 200,
            child: FfProgressBar(
              value: 1.4,
              pace: 0.5,
              semanticLabel: 'Budget used',
            ),
          ),
        );
        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, 1.0);
        expect(bar.color, c.actionPrimary);
        expect(bar.backgroundColor, c.surfaceContainerHighest);
        expect(bar.semanticsValue, '100%');
        expect(find.byType(PositionedDirectional), findsOneWidget);
        handle.dispose();
      });

      testWidgets('loading spinner is labelled', (tester) async {
        await _pump(tester, theme, const FfLoading());
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(spinner.semanticsLabel, 'Loading');
      });
    });

    group('status and details ($mode)', () {
      testWidgets('badge uses the tone pair, which stays readable', (
        tester,
      ) async {
        await _pump(
          tester,
          theme,
          const FfBadge(
            label: 'Overdue',
            tone: FfTone.error,
            icon: Icons.schedule,
          ),
        );
        expect(_textColor(tester, find.text('Overdue')), c.statusError);
        expect(
          FfContrast.ratio(c.statusError, c.statusErrorContainer),
          greaterThanOrEqualTo(FfContrast.text),
        );
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('key-value row and stat tile', (tester) async {
        await _pump(
          tester,
          theme,
          const Column(
            children: [
              FfKeyValueRow(
                label: 'Overdue EMIs',
                value: '2',
                valueTone: FfTone.error,
              ),
              FfStatTile(
                label: 'Spent this month',
                value: FfAmountText(amount: 48210, tone: FfTone.neutral),
                caption: 'vs ₹52,000 last month',
              ),
            ],
          ),
        );
        expect(_textColor(tester, find.text('Overdue EMIs')), c.textSecondary);
        expect(_textColor(tester, find.text('2')), c.statusError);
        expect(find.text('vs ₹52,000 last month'), findsOneWidget);
      });

      testWidgets('card variants paint from the palette', (tester) async {
        await _pump(
          tester,
          theme,
          const Column(
            children: [
              FfCard(child: Text('standard')),
              FfCard(variant: FfCardVariant.warning, child: Text('warning')),
            ],
          ),
        );
        final boxes =
            tester
                .widgetList<Container>(find.byType(Container))
                .map((x) => x.decoration)
                .whereType<BoxDecoration>()
                .toList();
        expect(boxes.first.color, c.surfaceCard);
        expect(boxes.last.color, c.statusWarningContainer);
      });
    });
  }
}
