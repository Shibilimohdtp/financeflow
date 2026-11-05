import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/transaction.dart';
import '../../theme/stillwater_typography.dart';

enum FfAmountSize { hero, lg, md, sm }

class FfAmountText extends StatelessWidget {
  final double amount;
  final TransactionType? type;
  final FfAmountSize size;
  final bool showSign;
  final bool isBlurred;
  final Color? colorOverride;
  final bool includeSymbol;

  const FfAmountText({
    super.key,
    required this.amount,
    this.type,
    this.size = FfAmountSize.md,
    this.showSign = true,
    this.isBlurred = false,
    this.colorOverride,
    this.includeSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlurred) {
      final style = _getTextStyle(context, context.textTheme.bodyMedium?.color);
      return Text(includeSymbol ? '${CurrencyFormatter.currencySymbol} ••••••' : '••••••', style: style);
    }

    final isIncome = type == TransactionType.income;
    final isExpense =
        type == TransactionType.expense ||
        type == TransactionType.loanEmi ||
        type == TransactionType.investment ||
        type == TransactionType.cash;

    Color? textColor = colorOverride;
    if (textColor == null) {
      if (isIncome) {
        textColor = context.finColors.income;
      } else if (isExpense) {
        textColor = context.finColors.expense;
      } else if (type == TransactionType.transfer) {
        textColor = context.finColors.transfer;
      } else {
        textColor = context.theme.colorScheme.onSurface;
      }
    }

    final formatted = CurrencyFormatter.format(
      amount,
      showSign: showSign && type != TransactionType.transfer,
      isExpense: isExpense || (amount < 0 && type == null),
      isIncome: isIncome || (amount > 0 && type == null),
      includeSymbol: includeSymbol,
    );

    final style = _getTextStyle(context, textColor);

    return Semantics(
      label: isBlurred ? 'Amount hidden for privacy' : formatted,
      child: Text(
        formatted,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context, Color? color) {
    switch (size) {
      case FfAmountSize.hero:
        return StillwaterTypography.numHero(color: color);
      case FfAmountSize.lg:
        return StillwaterTypography.numLg(color: color);
      case FfAmountSize.md:
        return StillwaterTypography.numMd(color: color);
      case FfAmountSize.sm:
        return StillwaterTypography.numSm(color: color);
    }
  }
}
