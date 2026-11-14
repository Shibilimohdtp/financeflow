import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/money_record.dart';
import '../accounts/accounts_controller.dart';
import 'money_records_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_amount_hero.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../theme/ff_tone.dart';

class AddAdvanceSheet extends ConsumerStatefulWidget {
  final MoneyRecord record;

  const AddAdvanceSheet({super.key, required this.record});

  @override
  ConsumerState<AddAdvanceSheet> createState() => _AddAdvanceSheetState();
}

class _AddAdvanceSheetState extends ConsumerState<AddAdvanceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _advanceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _recordInTransactions = true;
  Account? _selectedAccount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Inline amount error, with the messages the field validator used.
  String? _amountError;

  Future<void> _submit() async {
    final text = _amountController.text.trim();
    final parsedAmount = FfAmountField.parse(text);
    final amountError =
        text.isEmpty
            ? 'Please enter an amount'
            : (parsedAmount == null || parsedAmount <= 0)
            ? 'Enter a positive amount'
            : null;
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
        message: 'Please enter a valid amount greater than zero.',
      );
      return;
    }

    if (_recordInTransactions && _selectedAccount == null) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please select an account for the transaction.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(moneyRecordsControllerProvider.notifier)
          .addAdvance(
            moneyRecordId: widget.record.id,
            amount: amount,
            date: _advanceDate,
            dueDate: _dueDate,
            notes:
                _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
            accountId: _recordInTransactions ? _selectedAccount?.id : null,
            recordInTransactions: _recordInTransactions,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        FfToast.show(
          context,
          message: 'Advance recorded for ${widget.record.personName}.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not add advance: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLent = widget.record.type == MoneyRecordType.lent;
    final accounts =
        ref.watch(rawAccountsStreamProvider).valueOrNull ?? const <Account>[];
    final activeAccounts = accounts.where((a) => !a.isArchived).toList();

    if (_selectedAccount == null && activeAccounts.isNotEmpty) {
      _selectedAccount = activeAccounts.first;
    }

    Future<void> pickAdvanceDate() async {
      final picked = await pickFfDate(
        context,
        initialDate: _advanceDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _advanceDate = picked;
          if (_dueDate.isBefore(_advanceDate)) {
            _dueDate = _advanceDate.add(const Duration(days: 30));
          }
        });
      }
    }

    Future<void> pickDueDate() async {
      final picked = await pickFfDate(
        context,
        initialDate: _dueDate,
        firstDate: _advanceDate,
        lastDate: DateTime(2100),
      );
      if (picked != null) setState(() => _dueDate = picked);
    }

    final entered = FfAmountField.parse(_amountController.text) ?? 0.0;
    final name = widget.record.personName;

    return Form(
      key: _formKey,
      child: FfSheet(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSheetHeader(
            title: isLent ? 'Lend more' : 'Borrow more',
            subtitle:
                isLent
                    ? 'More money you gave $name'
                    : 'More money $name gave you',
          ),
          FfSheetBody(
            children: [
              // ── Amount first (archetype A) ───────────────────────────────
              FfSheetGroup(
                children: [
                  FfAmountHero(
                    controller: _amountController,
                    label: 'Amount',
                    tone: isLent ? FfTone.income : FfTone.expense,
                    autofocus: true,
                    groupDigits: true,
                    errorText: _amountError,
                    consequenceIcon: Icons.add_circle_outline_rounded,
                    consequence:
                        entered > 0
                            ? (isLent
                                ? '$name will owe you ${CurrencyFormatter.format(entered)} more'
                                : 'You will owe $name ${CurrencyFormatter.format(entered)} more')
                            : 'Added on top of what is already open',
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                ],
              ),

              // ── Dates and account ────────────────────────────────────────
              FfSheetGroup(
                children: [
                  FfGroupedContainer(
                    children: [
                      FfRow(
                        icon: Icons.event_outlined,
                        title: isLent ? 'Lent on' : 'Borrowed on',
                        detail: DateFormatter.formatShortDate(_advanceDate),
                        showChevron: true,
                        onTap: pickAdvanceDate,
                      ),
                      FfRow(
                        icon: Icons.event_available_outlined,
                        title: 'Due back by',
                        detail: DateFormatter.formatShortDate(_dueDate),
                        showChevron: true,
                        onTap: pickDueDate,
                      ),
                      FfRow.toggle(
                        icon: Icons.sync_alt_rounded,
                        title: 'Record in my accounts',
                        subtitle:
                            _recordInTransactions
                                ? (isLent
                                    ? 'Takes the money from the account'
                                    : 'Adds the money to the account')
                                : 'Updates the balance with $name only',
                        value: _recordInTransactions,
                        onChanged:
                            (val) =>
                                setState(() => _recordInTransactions = val),
                      ),
                    ],
                  ),
                  if (_recordInTransactions && activeAccounts.isNotEmpty)
                    FfSelect<String>(
                      value: _selectedAccount?.id,
                      label: isLent ? 'Paid from' : 'Received in',
                      items:
                          activeAccounts.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.name} (${CurrencyFormatter.format(a.currentBalance)})',
                              ),
                            );
                          }).toList(),
                      onChanged: (id) {
                        setState(() {
                          _selectedAccount =
                              activeAccounts
                                  .where((a) => a.id == id)
                                  .firstOrNull;
                        });
                      },
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
                    hint: 'e.g. For dinner, taxi ride, groceries',
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
          FfSheetFooter(
            primaryLabel: 'Add advance',
            isPrimaryLoading: _isSubmitting,
            onPrimaryPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
