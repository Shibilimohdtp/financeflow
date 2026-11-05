import 'package:flutter/painting.dart';

import 'ff_colors.dart';

/// The small set of meanings a component can be coloured by. Components take
/// a tone instead of a raw colour, so every palette controls the result.
enum FfTone {
  neutral,
  primary,
  accent,
  income,
  expense,
  transfer,
  savings,
  debt,
  investment,
  success,
  warning,
  info,
  error;

  /// The tone's strong colour: icons, text and amounts.
  Color foreground(FfColors c) => switch (this) {
    FfTone.neutral => c.textSecondary,
    FfTone.primary => c.actionPrimary,
    FfTone.accent => c.accent,
    FfTone.income => c.moneyIncome,
    FfTone.expense => c.moneyExpense,
    FfTone.transfer => c.moneyTransfer,
    FfTone.savings => c.moneySavings,
    FfTone.debt => c.moneyDebt,
    FfTone.investment => c.moneyInvestment,
    FfTone.success => c.statusSuccess,
    FfTone.warning => c.statusWarning,
    FfTone.info => c.statusInfo,
    FfTone.error => c.statusError,
  };

  /// The tone's soft fill: badges and banners.
  Color container(FfColors c) => switch (this) {
    FfTone.neutral => c.surfaceContainer,
    FfTone.primary => c.actionPrimaryContainer,
    FfTone.accent => c.accentContainer,
    FfTone.income => c.moneyIncomeContainer,
    FfTone.expense => c.moneyExpenseContainer,
    FfTone.transfer => c.moneyTransferContainer,
    FfTone.savings => c.moneySavingsContainer,
    FfTone.debt => c.moneyDebtContainer,
    FfTone.investment => c.moneyInvestmentContainer,
    FfTone.success => c.statusSuccessContainer,
    FfTone.warning => c.statusWarningContainer,
    FfTone.info => c.statusInfoContainer,
    FfTone.error => c.statusErrorContainer,
  };
}
