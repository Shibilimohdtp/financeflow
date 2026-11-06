import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/account.dart';
import '../../../../models/category.dart';
import '../../../../models/transaction.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/stillwater_colors.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionPurpose selectedPurpose;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Transaction> history;
  final void Function(
    TransactionPurpose purpose,
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  )
  onPurposeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedPurpose,
    required this.categories,
    required this.accounts,
    required this.history,
    required this.onPurposeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final incoming = <TransactionPurpose>{
      TransactionPurpose.income,
      TransactionPurpose.borrowing,
      TransactionPurpose.personalDebtRepaymentReceived,
      TransactionPurpose.loanDisbursement,
      TransactionPurpose.investmentRedemption,
    };
    final intent =
        selectedPurpose == TransactionPurpose.internalTransfer
            ? 'Move Money'
            : incoming.contains(selectedPurpose)
            ? 'Money In'
            : 'Money Out';

    final tabs = const [
      (label: 'Money Out', icon: Icons.arrow_outward_rounded),
      (label: 'Money In', icon: Icons.arrow_downward_rounded),
      (label: 'Move Money', icon: Icons.swap_horiz_rounded),
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.all(FfSpace.x3s),
      decoration: BoxDecoration(
        color:
            isDark
                ? StillwaterColors.darkSurfaceContainerLow
                : StillwaterColors.lightSurfaceContainerLow,
        borderRadius: BorderRadius.circular(FfRadius.lg),
        border: Border.all(
          color: context.ff.color.borderSubtle.withValues(
            alpha: FfTint.strong.alpha,
          ),
          width: FfBorderWidth.hairline,
        ),
      ),
      child: Row(
        children:
            tabs.map((tab) {
              final isSelected = intent == tab.label;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    final purpose = switch (tab.label) {
                      'Money In' => TransactionPurpose.income,
                      'Move Money' => TransactionPurpose.internalTransfer,
                      _ => TransactionPurpose.expense,
                    };
                    onPurposeChanged(purpose, categories, accounts, history);
                  },
                  borderRadius: BorderRadius.circular(FfRadius.md),
                  child: AnimatedContainer(
                    duration: FfMotion.fast,
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? (isDark
                                  ? context.ff.color.actionPrimaryContainer
                                      .withValues(alpha: FfTint.strong.alpha)
                                  : context.ff.color.actionPrimaryContainer
                                      .withValues(alpha: FfOpacity.muted))
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color:
                            isSelected
                                ? context.ff.color.actionPrimary.withValues(
                                  alpha: 0.8,
                                )
                                : Colors.transparent,
                        width: isSelected ? FfBorderWidth.focus : 0,
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FfSpace.x2s,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.icon,
                                size: 15,
                                color:
                                    isSelected
                                        ? context.ff.color.actionPrimary
                                        : context.ff.color.textSecondary,
                              ),
                              const SizedBox(width: FfSpace.x2s),
                              Text(
                                tab.label,
                                style: context.ff.text.label.copyWith(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? context.ff.color.actionPrimary
                                          : context.ff.color.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
