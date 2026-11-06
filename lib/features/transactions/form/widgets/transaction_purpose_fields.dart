import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/currency_formatter.dart';
import '../../../../models/account.dart';
import '../../../../models/investment.dart';
import '../../../../models/loan.dart';
import '../../../../models/money_advance.dart';
import '../../../../models/money_record.dart';
import '../../../../models/money_repayment.dart';
import '../../../../models/subscription.dart';
import '../../../../models/transaction.dart';
import '../../../../repositories/investment_repository.dart';
import '../../../../repositories/loan_repository.dart';
import '../../../../repositories/subscription_repository.dart';
import '../../../../shared/widgets/ff_pickers.dart';
import '../../../../shared/widgets/ff_select.dart';
import '../../../../shared/widgets/ff_text_field.dart';
import '../../../../theme/ff.dart';
import '../../../personal_debts/money_records_controller.dart';

class TransactionPurposeFields extends ConsumerStatefulWidget {
  final TransactionPurpose selectedPurpose;
  final Transaction? initialTransaction;
  final TextEditingController amountController;
  final TextEditingController merchantController;
  final TextEditingController counterpartyController;
  final TextEditingController principalController;
  final TextEditingController interestController;
  final TextEditingController feeController;
  final DateTime selectedDate;
  final DateTime? debtDueDate;
  final bool createAsSeparateDebt;
  final Loan? selectedLoan;
  final MoneyRecord? selectedMoneyRecord;
  final Investment? selectedInvestment;
  final Subscription? selectedSubscription;
  final Account? selectedAccount;
  final bool needsCounterparty;
  final void Function(Loan? loan) onSelectLoan;
  final void Function(MoneyRecord? record) onSelectMoneyRecord;
  final void Function(Investment? investment) onSelectInvestment;
  final void Function(Subscription? subscription) onSelectSubscription;
  final void Function(DateTime? date) onSelectDebtDueDate;
  final void Function(bool createAsSeparate) onToggleCreateAsSeparateDebt;

  const TransactionPurposeFields({
    super.key,
    required this.selectedPurpose,
    this.initialTransaction,
    required this.amountController,
    required this.merchantController,
    required this.counterpartyController,
    required this.principalController,
    required this.interestController,
    required this.feeController,
    required this.selectedDate,
    this.debtDueDate,
    required this.createAsSeparateDebt,
    this.selectedLoan,
    this.selectedMoneyRecord,
    this.selectedInvestment,
    this.selectedSubscription,
    this.selectedAccount,
    required this.needsCounterparty,
    required this.onSelectLoan,
    required this.onSelectMoneyRecord,
    required this.onSelectInvestment,
    required this.onSelectSubscription,
    required this.onSelectDebtDueDate,
    required this.onToggleCreateAsSeparateDebt,
  });

  @override
  ConsumerState<TransactionPurposeFields> createState() =>
      _TransactionPurposeFieldsState();
}

class _TransactionPurposeFieldsState
    extends ConsumerState<TransactionPurposeFields> {
  Widget _componentField(TextEditingController controller, String label) {
    return FfTextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      label: label,
      prefixText: '${CurrencyFormatter.currencySymbol} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── 1. Subscription Payment ──────────────────────────────────────────────
    if (widget.selectedPurpose == TransactionPurpose.subscriptionPayment) {
      final allSubs = ref.watch(allSubscriptionsStreamProvider).value ?? [];
      final activeSubs =
          allSubs.where((s) => s.status == SubscriptionStatus.active).toList()
            ..sort((a, b) => a.merchant.compareTo(b.merchant));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeSubs.isEmpty)
            Container(
              padding: const EdgeInsets.all(FfSpace.md),
              decoration: BoxDecoration(
                color: context.ff.color.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(FfRadius.md),
                border: Border.all(
                  color: context.ff.color.borderSubtle.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 20,
                    color: context.ff.color.textSecondary,
                  ),
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: Text(
                      'No active subscriptions yet. Add subscriptions in the Subscriptions screen.',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FfSelect<String>(
              value: widget.selectedSubscription?.id ?? 'unlinked',
              label: 'Subscription',
              icon: Icons.subscriptions_outlined,
              helper:
                  widget.selectedSubscription == null
                      ? 'Choose a tracked subscription to link this payment.'
                      : null,
              items: [
                const DropdownMenuItem(
                  value: 'unlinked',
                  child: Text('Unlinked subscription payment'),
                ),
                ...activeSubs.map(
                  (sub) => DropdownMenuItem(
                    value: sub.id,
                    child: Text(
                      '${sub.merchant} · ${CurrencyFormatter.formatAmount(sub.amount)}/${sub.billingFrequency.shortLabel}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (id) {
                final chosen = activeSubs.where((s) => s.id == id).firstOrNull;
                widget.onSelectSubscription(chosen);
                if (chosen != null) {
                  widget.amountController.text = chosen.amount.toStringAsFixed(
                    2,
                  );
                  if (widget.merchantController.text.isEmpty) {
                    widget.merchantController.text = chosen.merchant;
                  }
                }
              },
            ),
          if (widget.selectedSubscription != null) ...[
            const SizedBox(height: FfSpace.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.sm,
                vertical: FfSpace.xs,
              ),
              decoration: BoxDecoration(
                color: context.ff.color.actionPrimaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(FfRadius.md),
                border: Border.all(
                  color: context.ff.color.actionPrimary.withValues(
                    alpha: FfTint.strong.alpha,
                  ),
                  width: FfBorderWidth.regular,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: context.ff.color.actionPrimary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      'Linked to ${widget.selectedSubscription!.merchant} · ${CurrencyFormatter.formatAmount(widget.selectedSubscription!.amount)} / ${widget.selectedSubscription!.billingFrequency.shortLabel}',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.onActionPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // ── 2. Loan Repayment ────────────────────────────────────────────────────
    if (widget.selectedPurpose == TransactionPurpose.loanRepayment) {
      final loans =
          (ref.watch(allLoansStreamProvider).valueOrNull ?? const <Loan>[])
              .where((loan) => loan.status == LoanStatus.active)
              .toList();
      var currentLoan = widget.selectedLoan;
      if (currentLoan == null &&
          widget.initialTransaction?.linkedLoanId != null) {
        currentLoan =
            loans
                .where(
                  (loan) => loan.id == widget.initialTransaction!.linkedLoanId,
                )
                .firstOrNull;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FfSelect<String>(
            value: currentLoan?.id ?? 'unlinked',
            label: 'Tracked loan',
            items: [
              const DropdownMenuItem(
                value: 'unlinked',
                child: Text('Unlinked loan payment'),
              ),
              ...loans.map(
                (loan) => DropdownMenuItem(
                  value: loan.id,
                  child: Text('${loan.name} · ${loan.lender}'),
                ),
              ),
            ],
            onChanged: (id) {
              final chosen = loans.where((loan) => loan.id == id).firstOrNull;
              widget.onSelectLoan(chosen);
            },
          ),
          const SizedBox(height: FfSpace.xs),
          Text(
            currentLoan == null
                ? 'This payment will affect the account, but will not update a loan schedule.'
                : 'Expected EMI ${CurrencyFormatter.formatAmount(currentLoan.emiAmount)} · Principal left ${CurrencyFormatter.formatAmount(currentLoan.outstandingPrincipal)} · Due ${DateFormat.yMMMd().format(currentLoan.nextDueDate)}',
            style: context.ff.text.bodySm,
          ),
          if (currentLoan != null) ...[
            const SizedBox(height: FfSpace.sm),
            Row(
              children: [
                Expanded(
                  child: _componentField(
                    widget.principalController,
                    'Principal',
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  child: _componentField(widget.interestController, 'Interest'),
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(child: _componentField(widget.feeController, 'Fees')),
              ],
            ),
          ],
        ],
      );
    }

    // ── 3. Investment ────────────────────────────────────────────────────────
    if (widget.selectedPurpose == TransactionPurpose.investmentPurchase ||
        widget.selectedPurpose == TransactionPurpose.investmentRedemption) {
      final investments =
          ref.watch(allInvestmentsStreamProvider).valueOrNull ??
          const <Investment>[];
      var currentInvestment = widget.selectedInvestment;
      if (currentInvestment == null &&
          widget.initialTransaction?.linkedInvestmentId != null) {
        currentInvestment =
            investments
                .where(
                  (investment) =>
                      investment.id ==
                      widget.initialTransaction!.linkedInvestmentId,
                )
                .firstOrNull;
      }
      return Column(
        children: [
          FfSelect<String>(
            value: currentInvestment?.id ?? 'unlinked',
            label: 'Investment asset',
            items: [
              const DropdownMenuItem(
                value: 'unlinked',
                child: Text('Unlinked investment movement'),
              ),
              ...investments.map(
                (investment) => DropdownMenuItem(
                  value: investment.id,
                  child: Text(investment.name),
                ),
              ),
            ],
            onChanged: (id) {
              final chosen =
                  investments
                      .where((investment) => investment.id == id)
                      .firstOrNull;
              widget.onSelectInvestment(chosen);
              if (chosen != null) {
                widget.merchantController.text = chosen.name;
                final amount =
                    CurrencyFormatter.parse(widget.amountController.text) ?? 0;
                widget.principalController.text = amount.toStringAsFixed(2);
                widget.interestController.text = '0.00';
                widget.feeController.text = '0.00';
              }
            },
          ),
          const SizedBox(height: FfSpace.sm),
          Row(
            children: [
              Expanded(
                child: _componentField(
                  widget.principalController,
                  widget.selectedPurpose ==
                          TransactionPurpose.investmentRedemption
                      ? 'Cost basis'
                      : 'Asset value',
                ),
              ),
              const SizedBox(width: FfSpace.xs),
              if (widget.selectedPurpose ==
                  TransactionPurpose.investmentRedemption) ...[
                Expanded(
                  child: _componentField(
                    widget.interestController,
                    'Realized gain',
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
              ],
              Expanded(child: _componentField(widget.feeController, 'Fees')),
            ],
          ),
        ],
      );
    }

    // ── 4. Debt Repayment ────────────────────────────────────────────────────
    final isRepayment = <TransactionPurpose>{
      TransactionPurpose.personalDebtRepaymentMade,
      TransactionPurpose.personalDebtRepaymentReceived,
    }.contains(widget.selectedPurpose);
    if (isRepayment) {
      final records =
          ref.watch(allMoneyRecordsStreamProvider).valueOrNull ??
          const <MoneyRecord>[];
      final expectedType =
          widget.selectedPurpose ==
                  TransactionPurpose.personalDebtRepaymentReceived
              ? MoneyRecordType.lent
              : MoneyRecordType.borrowed;
      final eligible =
          records
              .where(
                (record) =>
                    record.type == expectedType && record.settledAt == null,
              )
              .toList();
      var currentDebtRecord = widget.selectedMoneyRecord;
      if (currentDebtRecord == null &&
          widget.initialTransaction?.linkedMoneyRecordId != null) {
        currentDebtRecord =
            eligible
                .where(
                  (record) =>
                      record.id ==
                      widget.initialTransaction!.linkedMoneyRecordId,
                )
                .firstOrNull;
      }
      return FfSelect<String>(
        value: currentDebtRecord?.id,
        label: 'Debt record',
        hint: 'Select person and balance',
        items:
            eligible
                .map(
                  (record) => DropdownMenuItem(
                    value: record.id,
                    child: Text(
                      '${record.personName} · ${CurrencyFormatter.formatAmount(record.originalAmount)}',
                    ),
                  ),
                )
                .toList(),
        onChanged: (id) {
          final chosen =
              eligible.where((record) => record.id == id).firstOrNull;
          widget.onSelectMoneyRecord(chosen);
          widget.counterpartyController.text = chosen?.personName ?? '';
        },
      );
    }

    // ── 5. Lending / Borrowing ───────────────────────────────────────────────
    if (widget.selectedPurpose == TransactionPurpose.lending ||
        widget.selectedPurpose == TransactionPurpose.borrowing) {
      final records =
          ref.watch(allMoneyRecordsStreamProvider).valueOrNull ??
          const <MoneyRecord>[];
      final repayments =
          ref.watch(allMoneyRepaymentsStreamProvider).valueOrNull ??
          const <MoneyRepayment>[];
      final advances =
          ref.watch(allMoneyAdvancesStreamProvider).valueOrNull ??
          const <MoneyAdvance>[];

      final expectedType =
          widget.selectedPurpose == TransactionPurpose.lending
              ? MoneyRecordType.lent
              : MoneyRecordType.borrowed;

      final eligible =
          records
              .where(
                (record) =>
                    record.type == expectedType &&
                    record.settledAt == null &&
                    !record.isCustomSeparateObligation,
              )
              .toList();

      final typedName = widget.counterpartyController.text.trim();
      final normalizedTyped = MoneyRecord.normalizePersonName(typedName);
      final matchingRecord =
          widget.selectedMoneyRecord ??
          eligible
              .where((r) => r.normalizedPersonName == normalizedTyped)
              .firstOrNull;

      final currentAmount =
          CurrencyFormatter.parse(widget.amountController.text) ?? 0.0;
      final existingRemaining =
          matchingRecord?.calculateRemainingAmount(
            repayments,
            advances: advances,
          ) ??
          0.0;
      final newTotal = existingRemaining + currentAmount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            initialValue: TextEditingValue(
              text: widget.counterpartyController.text,
            ),
            optionsBuilder: (TextEditingValue value) {
              if (value.text.trim().isEmpty) {
                return eligible.map((r) => r.personName);
              }
              final query = MoneyRecord.normalizePersonName(value.text);
              return eligible
                  .where((r) => r.normalizedPersonName.contains(query))
                  .map((r) => r.personName);
            },
            onSelected: (String selection) {
              widget.counterpartyController.text = selection;
              final found =
                  eligible
                      .where(
                        (r) =>
                            r.normalizedPersonName ==
                            MoneyRecord.normalizePersonName(selection),
                      )
                      .firstOrNull;
              widget.onSelectMoneyRecord(found);
            },
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              if (widget.counterpartyController.text !=
                      textEditingController.text &&
                  textEditingController.text.isEmpty) {
                textEditingController.text = widget.counterpartyController.text;
              }
              return FfTextField(
                controller: textEditingController,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.words,
                label: 'Person / counterparty',
                helper:
                    'Repeated advances to the same person combine into one active balance.',
                suffix:
                    matchingRecord != null
                        ? Icon(
                          Icons.check_circle_rounded,
                          color: context.ff.color.statusSuccess,
                          size: 20,
                        )
                        : null,
                onChanged: (val) {
                  widget.counterpartyController.text = val;
                  final found =
                      eligible
                          .where(
                            (r) =>
                                r.normalizedPersonName ==
                                MoneyRecord.normalizePersonName(val),
                          )
                          .firstOrNull;
                  if (found?.id != widget.selectedMoneyRecord?.id) {
                    widget.onSelectMoneyRecord(found);
                  }
                },
              );
            },
          ),
          if (matchingRecord != null) ...[
            const SizedBox(height: FfSpace.sm),
            Container(
              padding: const EdgeInsets.all(FfSpace.sm),
              decoration: BoxDecoration(
                color: context.ff.color.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(FfRadius.md),
                border: Border.all(
                  color: context.ff.color.actionPrimary.withValues(
                    alpha: FfTint.medium.alpha,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: context.ff.color.actionPrimary,
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Expanded(
                        child: Text(
                          widget.createAsSeparateDebt
                              ? 'Separate debt for ${matchingRecord.personName}'
                              : 'Adding to ${matchingRecord.personName}\'s active balance',
                          style: context.ff.text.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.ff.color.actionPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.x2s),
                  Text(
                    widget.createAsSeparateDebt
                        ? 'This advance will be tracked as its own separate obligation card.'
                        : 'Current balance: ${CurrencyFormatter.formatAmount(existingRemaining)} → New balance: ${CurrencyFormatter.formatAmount(newTotal)}',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.textSecondary,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: widget.createAsSeparateDebt,
                          onChanged: (val) {
                            widget.onToggleCreateAsSeparateDebt(val ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: FfSpace.xs),
                      GestureDetector(
                        onTap: () {
                          widget.onToggleCreateAsSeparateDebt(
                            !widget.createAsSeparateDebt,
                          );
                        },
                        child: Text(
                          'Create as separate debt record',
                          style: context.ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: FfSpace.sm),
          InkWell(
            onTap: () async {
              final picked = await pickFfDate(
                context,
                initialDate:
                    widget.debtDueDate ??
                    widget.selectedDate.add(const Duration(days: 30)),
                firstDate: widget.selectedDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                widget.onSelectDebtDueDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(FfRadius.md),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Expected repayment date',
                suffixIcon: Icon(Icons.event_outlined),
              ),
              child: Text(
                DateFormat.yMMMd().format(
                  widget.debtDueDate ??
                      widget.selectedDate.add(const Duration(days: 30)),
                ),
                style: context.ff.text.body,
              ),
            ),
          ),
        ],
      );
    }

    if (widget.needsCounterparty) {
      return FfTextField(
        controller: widget.counterpartyController,
        textCapitalization: TextCapitalization.words,
        label: 'Person / counterparty',
        helper: 'A person is kept separate from accounts you own.',
      );
    }

    return const SizedBox.shrink();
  }
}
