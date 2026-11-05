import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/transaction.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

enum FfAmountSize { hero, lg, md, sm }

/// A formatted amount in the money type roles (tabular figures).
///
/// Colour follows meaning: pass a transaction [type] (income, expense,
/// transfer…) or a [tone]. [FfTone.neutral] means plain text colour. Signs
/// (+/−) are shown for income and expense so the meaning never rests on
/// colour alone. The text scale is clamped so large amounts keep their
/// layout under big system font sizes.
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
  });

  final double amount;
  final TransactionType? type;

  /// Overrides the colour that [type] would choose.
  final FfTone? tone;
  final FfAmountSize size;
  final bool showSign;
  final bool isBlurred;
  final bool includeSymbol;

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

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: FfAmountTokens.maxTextScale,
      child: Semantics(
        label: formatted,
        excludeSemantics: true,
        child: Text(
          formatted,
          style: base.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
