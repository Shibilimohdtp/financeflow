import 'package:flutter/material.dart';

import '../../../../core/formatting/currency_formatter.dart';
import '../../../../models/account.dart';
import '../../../../models/category.dart';
import '../../../../models/loan.dart';
import '../../../../models/money_record.dart';
import '../../../../models/transaction.dart';
import '../../../../shared/widgets/ff_amount_hero.dart';
import '../../../../shared/widgets/ff_select.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/ff_tone.dart';
import '../../transaction_form.dart';

class TransactionPurposeAmountRow extends StatelessWidget {
  final TransactionType selectedType;
  final TransactionPurpose selectedPurpose;
  final TextEditingController amountController;
  final String? amountError;
  final bool autofocus;
  final Account? selectedAccount;
  final Account? selectedToAccount;
  final Loan? selectedLoan;
  final MoneyRecord? selectedMoneyRecord;
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
    required this.selectedType,
    required this.selectedPurpose,
    required this.amountController,
    this.amountError,
    this.autofocus = false,
    this.selectedAccount,
    this.selectedToAccount,
    this.selectedLoan,
    this.selectedMoneyRecord,
    required this.categories,
    required this.accounts,
    required this.history,
    required this.onPurposeChanged,
    this.onAmountChanged,
    required this.onClearAmount,
  });

  FfTone _typeTone(TransactionType type) => switch (type) {
    TransactionType.income => FfTone.income,
    TransactionType.transfer => FfTone.transfer,
    TransactionType.investment => FfTone.investment,
    TransactionType.loanEmi => FfTone.debt,
    _ => FfTone.expense,
  };

  String _amountLabel(TransactionType type) => switch (type) {
    TransactionType.income => 'Amount received',
    TransactionType.transfer => 'Amount to transfer',
    TransactionType.investment => 'Investment amount',
    TransactionType.loanEmi => 'EMI payment amount',
    _ => 'Amount spent',
  };

  @override
  Widget build(BuildContext context) {
    final amountVal = CurrencyFormatter.parse(amountController.text) ?? 0.0;

    final consequence = TransactionFormValues.calculateConsequenceLine(
      type: selectedType,
      purpose: selectedPurpose,
      account: selectedAccount,
      toAccount: selectedToAccount,
      amount: amountVal,
      loan: selectedLoan,
      moneyRecord: selectedMoneyRecord,
    );

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
        // ── 1. The Bloom Amount Hero Card ────────────────────────────────────
        FfAmountHero(
          controller: amountController,
          tone: _typeTone(selectedType),
          label: _amountLabel(selectedType),
          consequence: consequence?.text,
          consequenceIcon:
              selectedType == TransactionType.transfer
                  ? Icons.swap_horiz_rounded
                  : (selectedPurpose == TransactionPurpose.loanRepayment
                      ? Icons.receipt_long_rounded
                      : Icons.account_balance_wallet_outlined),
          errorText: amountError,
          autofocus: autofocus,
          onChanged: onAmountChanged,
          onClear: onClearAmount,
        ),

        // ── 2. Purpose Selector (when intent offers multiple purposes) ────────
        if (purposes.length > 1) ...[
          const SizedBox(height: FfSpace.xs),
          FfSelect<TransactionPurpose>(
            value:
                purposes.contains(selectedPurpose)
                    ? selectedPurpose
                    : purposes.first,
            label: 'Purpose',
            items:
                purposes
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      ),
                    )
                    .toList(),
            onChanged: (p) {
              if (p != null) {
                onPurposeChanged(p, categories, accounts, history);
              }
            },
          ),
        ],
      ],
    );
  }
}
