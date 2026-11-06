import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../models/account.dart';
import '../../../../models/category.dart';
import '../../../../models/transaction.dart';
import '../../../../shared/widgets/ff_amount_field.dart';
import '../../../../shared/widgets/ff_amount_text.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/stillwater_colors.dart';
import '../../../../theme/stillwater_typography.dart';

class TransactionPurposeAmountRow extends StatelessWidget {
  final TransactionPurpose selectedPurpose;
  final Color activeTypeColor;
  final TextEditingController amountController;
  final String? amountError;
  final bool autofocus;
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
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback onClearAmount;

  const TransactionPurposeAmountRow({
    super.key,
    required this.selectedPurpose,
    required this.activeTypeColor,
    required this.amountController,
    this.amountError,
    this.autofocus = false,
    required this.categories,
    required this.accounts,
    required this.history,
    required this.onPurposeChanged,
    this.onAmountChanged,
    required this.onClearAmount,
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
    final purposes = switch (intent) {
      'Money In' => const [
        TransactionPurpose.income,
        TransactionPurpose.borrowing,
        TransactionPurpose.personalDebtRepaymentReceived,
        TransactionPurpose.loanDisbursement,
        TransactionPurpose.investmentRedemption,
      ],
      'Move Money' => const [TransactionPurpose.internalTransfer],
      _ => const [
        TransactionPurpose.expense,
        TransactionPurpose.lending,
        TransactionPurpose.personalDebtRepaymentMade,
        TransactionPurpose.loanRepayment,
        TransactionPurpose.investmentPurchase,
        TransactionPurpose.subscriptionPayment,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Purpose Field (Left Column, ~42% width)
            Expanded(
              flex: 4,
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(
                  FfSpace.sm,
                  FfSpace.x2s,
                  FfSpace.xs,
                  FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(FfRadius.lg),
                  border: Border.all(
                    color: context.ff.color.borderSubtle.withValues(
                      alpha: 0.35,
                    ),
                    width: FfBorderWidth.hairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Purpose',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TransactionPurpose>(
                          key: ValueKey(intent),
                          value:
                              purposes.contains(selectedPurpose)
                                  ? selectedPurpose
                                  : purposes.first,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: context.ff.color.textSecondary,
                          ),
                          style: context.ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.ff.color.textPrimary,
                          ),
                          items:
                              purposes.map((purpose) {
                                return DropdownMenuItem(
                                  value: purpose,
                                  child: Text(
                                    purpose.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (purpose) {
                            if (purpose != null) {
                              onPurposeChanged(
                                purpose,
                                categories,
                                accounts,
                                history,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: FfSpace.sm),

            // 2. Hero Amount Field (Right Column, ~58% width)
            Expanded(
              flex: 5,
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(
                  FfSpace.sm,
                  FfSpace.x2s,
                  FfSpace.sm,
                  FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(FfRadius.lg),
                  border: Border.all(
                    color:
                        amountError != null
                            ? context.ff.color.statusError
                            : context.ff.color.borderSubtle.withValues(
                              alpha: 0.35,
                            ),
                    width:
                        amountError != null
                            ? FfBorderWidth.focus
                            : FfBorderWidth.hairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (amountController.text.isNotEmpty)
                          InkWell(
                            onTap: onClearAmount,
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: context.ff.color.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${CurrencyFormatter.currencySymbol} ',
                            style: StillwaterTypography.numHero(
                              color: activeTypeColor,
                            ).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: FfAmountField.bare(
                              controller: amountController,
                              size: FfAmountSize.md,
                              autofocus: autofocus,
                              onChanged: onAmountChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (amountError != null) ...[
          const SizedBox(height: FfSpace.x2s),
          Text(
            amountError!,
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.statusError,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (selectedPurpose == TransactionPurpose.internalTransfer) ...[
          const SizedBox(height: FfSpace.xs),
          Text(
            'Move money between accounts you own. This is not income or spending.',
            style: context.ff.text.bodySm,
          ),
        ],
      ],
    );
  }
}
