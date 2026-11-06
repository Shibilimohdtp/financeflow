import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/transaction.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

enum FfAmountSize { hero, lg, md, sm }

/// How an amount is set.
enum FfAmountStyle {
  /// Big light number with a small currency symbol and small light paise
  /// (Stillwater Bloom). For heroes, summaries and stat tiles. Shrinks to
  /// fit instead of cutting digits off.
  split,

  /// One size, tabular, sign first. For list rows and tables.
  inline,
}

/// The size of the small parts of a split amount, relative to the number.
abstract final class FfAmountSplit {
  static const double unitScale = 0.45;
  static const double decimalScale = 0.5;

  /// Small parts never go below this, so signs stay readable on md amounts.
  static const double minPartSize = 12;

  /// Splits a formatted amount ("− ₹52,06,777.18") into the prefix (sign and
  /// symbol), the whole number and the decimals. Anything that doesn't look
  /// like a plain number stays whole.
  static ({String prefix, String number, String decimals, String suffix}) parts(
    String formatted,
  ) {
    final m = RegExp(r'^(\D*?)(\d[\d,]*)(\.\d+)?(\D*)$').firstMatch(formatted);
    if (m == null) {
      return (prefix: '', number: formatted, decimals: '', suffix: '');
    }
    return (
      prefix: m.group(1)!,
      number: m.group(2)!,
      decimals: m.group(3) ?? '',
      suffix: m.group(4)!,
    );
  }
}

/// A formatted amount in the money type roles (tabular figures).
///
/// Colour follows meaning: pass a transaction [type] (income, expense,
/// transfer…) or a [tone]. [FfTone.neutral] means plain text colour. Signs
/// (+/−) are shown for income and expense so the meaning never rests on
/// colour alone. The text scale is clamped so large amounts keep their
/// layout under big system font sizes.
///
/// [style] defaults to [FfAmountStyle.split] for [FfAmountSize.hero] and
/// [FfAmountSize.lg] and [FfAmountStyle.inline] otherwise.
class FfAmountText extends StatelessWidget {
  const FfAmountText({
    super.key,
    required this.amount,
    this.type,
    this.tone,
    this.size = FfAmountSize.md,
    this.showSign = true,
    this.isBlurred = false,
    this.includeSymbol = true,
    this.style,
  });

  final double amount;
  final TransactionType? type;

  /// Overrides the colour that [type] would choose.
  final FfTone? tone;
  final FfAmountSize size;
  final bool showSign;
  final bool isBlurred;
  final bool includeSymbol;
  final FfAmountStyle? style;

  FfAmountStyle get effectiveStyle =>
      style ??
      (size == FfAmountSize.hero || size == FfAmountSize.lg
          ? FfAmountStyle.split
          : FfAmountStyle.inline);

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final base = switch (size) {
      FfAmountSize.hero => ff.text.moneyHero,
      FfAmountSize.lg => ff.text.moneyLg,
      FfAmountSize.md => ff.text.moneyMd,
      FfAmountSize.sm => ff.text.moneySm,
    };

    if (isBlurred) {
      return Semantics(
        label: 'Amount hidden for privacy',
        excludeSemantics: true,
        child: Text(
          includeSymbol
              ? '${CurrencyFormatter.currencySymbol} ••••••'
              : '••••••',
          style: base.copyWith(color: c.textPrimary),
        ),
      );
    }

    final isIncome = type == TransactionType.income;
    final isExpense =
        type == TransactionType.expense ||
        type == TransactionType.loanEmi ||
        type == TransactionType.investment ||
        type == TransactionType.cash;

    final effectiveTone =
        tone ??
        (isIncome
            ? FfTone.income
            : isExpense
            ? FfTone.expense
            : type == TransactionType.transfer
            ? FfTone.transfer
            : FfTone.neutral);
    final color =
        effectiveTone == FfTone.neutral
            ? c.textPrimary
            : effectiveTone.foreground(c);

    final formatted = CurrencyFormatter.format(
      amount,
      showSign: showSign && type != TransactionType.transfer,
      isExpense: isExpense || (amount < 0 && type == null),
      isIncome: isIncome || (amount > 0 && type == null),
      includeSymbol: includeSymbol,
    );

    final textStyle = base.copyWith(color: color);
    final Widget text;
    if (effectiveStyle == FfAmountStyle.split) {
      final p = FfAmountSplit.parts(formatted);
      final fontSize = textStyle.fontSize!;
      final small = textStyle.copyWith(
        fontSize: math.max(
          fontSize * FfAmountSplit.unitScale,
          FfAmountSplit.minPartSize,
        ),
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: color.withValues(alpha: FfOpacity.high),
      );
      text = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(
            children: [
              if (p.prefix.isNotEmpty) TextSpan(text: p.prefix, style: small),
              TextSpan(text: p.number),
              if (p.decimals.isNotEmpty)
                TextSpan(
                  text: p.decimals,
                  style: small.copyWith(
                    fontSize: math.max(
                      fontSize * FfAmountSplit.decimalScale,
                      FfAmountSplit.minPartSize,
                    ),
                    fontWeight: textStyle.fontWeight,
                  ),
                ),
              if (p.suffix.isNotEmpty) TextSpan(text: p.suffix, style: small),
            ],
          ),
          style: textStyle,
          maxLines: 1,
          softWrap: false,
        ),
      );
    } else {
      text = Text(
        formatted,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: FfAmountTokens.maxTextScale,
      child: Semantics(label: formatted, excludeSemantics: true, child: text),
    );
  }
}
