import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_record.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_typography.dart';
import 'money_records_controller.dart';
import '../accounts/accounts_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../theme/ff.dart';

class AddRepaymentSheet extends ConsumerStatefulWidget {
  final MoneyRecord record;
  final double remainingBalance;

  const AddRepaymentSheet({
    super.key,
    required this.record,
    required this.remainingBalance,
  });

  @override
  ConsumerState<AddRepaymentSheet> createState() => _AddRepaymentSheetState();
}

class _AddRepaymentSheetState extends ConsumerState<AddRepaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late DateTime _repaymentDate;
  bool _isSaving = false;
  bool _recordInTransactions = true;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _repaymentDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setFullAmount() {
    final amount = widget.remainingBalance;
    _amountController.text =
        amount.truncateToDouble() == amount
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _repaymentDate,
      firstDate: widget.record.transactionDate.subtract(
        const Duration(days: 30),
      ),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _repaymentDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid amount.',
      );
      return;
    }

    if (amount > (widget.remainingBalance + 0.001)) {
      FfToast.show(
        context,
        message:
            'Repayment cannot exceed remaining balance of ${CurrencyFormatter.format(widget.remainingBalance)}',
      );
      return;
    }
    if (_recordInTransactions && _selectedAccountId == null) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Select the account for this payment.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(moneyRecordsControllerProvider.notifier);

    try {
      await controller.addRepayment(
        moneyRecordId: widget.record.id,
        amount: amount,
        repaymentDate: _repaymentDate,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        accountId: _selectedAccountId,
        recordInTransactions: _recordInTransactions,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        FfToast.show(context, message: 'Repayment recorded successfully.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Failed to record repayment: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLent = widget.record.type == MoneyRecordType.lent;
    final accounts =
        ref
            .watch(accountsWithBalancesProvider)
            .valueOrNull
            ?.where((account) => !account.isArchived)
            .toList() ??
        const <Account>[];
    _selectedAccountId ??= accounts.firstOrNull?.id;
    if (accounts.isEmpty) _recordInTransactions = false;

    return Form(
      key: _formKey,
      child: FfSheet(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSheetHeader(
            title: 'Record Repayment',
            subtitle:
                isLent
                    ? 'Payment from ${widget.record.personName}'
                    : 'Payment to ${widget.record.personName}',
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.lg,
                vertical: FfSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outstanding balance banner
                  Container(
                    padding: const EdgeInsets.all(FfSpace.md),
                    decoration: BoxDecoration(
                      color: context.ff.color.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color: context.ff.color.borderSubtle.withValues(
                          alpha: FfTint.strong.alpha,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OUTSTANDING BALANCE',
                              style: context.ff.text.labelSm.copyWith(
                                color: context.ff.color.secondary,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: FfSpace.x2s),
                            Text(
                              CurrencyFormatter.format(widget.remainingBalance),
                              style: context.ff.text.title.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFeatures:
                                    StillwaterTypography.tabularFeatures,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _setFullAmount,
                          icon: const Icon(Icons.flash_on_rounded, size: 16),
                          label: const Text('Pay Full'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.sm,
                              vertical: FfSpace.xs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  FfRow.toggle(
                    title: 'Record in transactions and update balance',
                    subtitle:
                        isLent
                            ? 'Money received increases the selected account.'
                            : 'Money paid decreases the selected account.',
                    value: _recordInTransactions,
                    onChanged:
                        (value) =>
                            setState(() => _recordInTransactions = value),
                  ),
                  if (_recordInTransactions) ...[
                    FfSelect<String>(
                      value: _selectedAccountId,
                      label: 'Account',
                      items:
                          accounts
                              .map(
                                (account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(account.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedAccountId = value),
                    ),
                    const SizedBox(height: FfSpace.lg),
                  ],

                  // Repayment Amount Input
                  Text(
                    'Repayment Amount',
                    style: context.ff.text.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfAmountField(
                    controller: _amountController,
                    hint: '0.00',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = CurrencyFormatter.parse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a positive amount';
                      }
                      if (parsed > (widget.remainingBalance + 0.001)) {
                        return 'Cannot exceed ${CurrencyFormatter.format(widget.remainingBalance)}';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Repayment Date
                  Text(
                    'Payment Date',
                    style: context.ff.text.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.md,
                        vertical: FfSpace.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.ff.color.borderSubtle,
                        ),
                        borderRadius: BorderRadius.circular(FfRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: context.ff.color.actionPrimary,
                          ),
                          const SizedBox(width: FfSpace.sm),
                          Text(
                            DateFormatter.formatShortDate(_repaymentDate),
                            style: context.ff.text.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Change',
                            style: context.ff.text.labelSm.copyWith(
                              color: context.ff.color.actionPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Optional Notes
                  Text(
                    'Notes (Optional)',
                    style: context.ff.text.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _notesController,
                    maxLines: 2,
                    maxLength: 200,
                    hint: 'e.g. UPI transfer, Part 1 of 2',
                  ),
                ],
              ),
            ),
          ),

          FfSheetFooter(
            primaryLabel: 'Save Repayment',
            isPrimaryLoading: _isSaving,
            secondaryLabel: 'Cancel',
            onSecondaryPressed: () => Navigator.of(context).pop(),
            onPrimaryPressed: _save,
          ),
        ],
      ),
    );
  }
}
