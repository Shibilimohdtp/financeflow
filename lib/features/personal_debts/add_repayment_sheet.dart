import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_record.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import 'money_records_controller.dart';
import '../accounts/accounts_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_amount_hero.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

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
    _amountController.text = FfAmountField.formatInput(amount);
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

  /// The inline amount error, with the messages the field validator used.
  String? _amountError;

  String? _validateAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return 'Amount is required';
    final parsed = FfAmountField.parse(text);
    if (parsed == null || parsed <= 0) return 'Enter a positive amount';
    if (parsed > (widget.remainingBalance + 0.001)) {
      return 'Cannot exceed ${CurrencyFormatter.format(widget.remainingBalance)}';
    }
    return null;
  }

  Future<void> _save() async {
    final amountError = _validateAmount();
    if (amountError != null) {
      setState(() => _amountError = amountError);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = FfAmountField.parse(_amountController.text) ?? 0.0;
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

    final entered = FfAmountField.parse(_amountController.text) ?? 0.0;
    final left = widget.remainingBalance - entered;
    final String consequence;
    if (entered <= 0) {
      consequence =
          '${CurrencyFormatter.format(widget.remainingBalance)} is still outstanding';
    } else if (left <= 0.001) {
      consequence = 'Clears the balance with ${widget.record.personName}';
    } else {
      consequence = 'Leaves ${CurrencyFormatter.format(left)} outstanding';
    }

    return Form(
      key: _formKey,
      child: FfSheet(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSheetHeader(
            title: 'Add repayment',
            subtitle:
                isLent
                    ? 'Money ${widget.record.personName} paid back'
                    : 'Money you paid back to ${widget.record.personName}',
          ),
          FfSheetBody(
            children: [
              // ── Amount first (archetype A) ───────────────────────────────
              FfSheetGroup(
                children: [
                  FfAmountHero(
                    controller: _amountController,
                    label: 'Amount repaid',
                    tone: isLent ? FfTone.income : FfTone.expense,
                    autofocus: true,
                    groupDigits: true,
                    errorText: _amountError,
                    consequence: consequence,
                    consequenceIcon: Icons.account_balance_wallet_outlined,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FfChip(
                      label:
                          'All of it (${CurrencyFormatter.format(widget.remainingBalance)})',
                      isSelected:
                          (entered - widget.remainingBalance).abs() < 0.001,
                      leading: const Icon(
                        Icons.done_all_rounded,
                        size: FfIconSize.sm,
                      ),
                      onSelected:
                          () => setState(() {
                            _setFullAmount();
                            _amountError = null;
                          }),
                    ),
                  ),
                ],
              ),

              // ── When and where ───────────────────────────────────────────
              FfSheetGroup(
                children: [
                  FfGroupedContainer(
                    children: [
                      FfRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date',
                        detail: DateFormatter.formatShortDate(_repaymentDate),
                        showChevron: true,
                        onTap: _pickDate,
                      ),
                      FfRow.toggle(
                        icon: Icons.sync_alt_rounded,
                        title: 'Record in my accounts',
                        subtitle:
                            isLent
                                ? 'Money received increases the account'
                                : 'Money paid decreases the account',
                        value: _recordInTransactions,
                        onChanged:
                            accounts.isEmpty
                                ? null
                                : (value) => setState(
                                  () => _recordInTransactions = value,
                                ),
                      ),
                    ],
                  ),
                  if (_recordInTransactions)
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
                ],
              ),

              // ── Note ─────────────────────────────────────────────────────
              FfSheetGroup(
                last: true,
                children: [
                  FfTextField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    maxLines: 2,
                    maxLength: 200,
                    hint: 'e.g. UPI transfer, part 1 of 2',
                  ),
                ],
              ),
            ],
          ),
          FfSheetFooter(
            primaryLabel: 'Add repayment',
            isPrimaryLoading: _isSaving,
            onPrimaryPressed: _save,
          ),
        ],
      ),
    );
  }
}
