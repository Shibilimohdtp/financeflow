import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/money_record.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import 'money_records_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_row.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(_amountController.text) ?? 0.0;
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
    final theme = Theme.of(context);
    final isLent = widget.record.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.finColors.income : context.finColors.expense;
    final accounts =
        ref.watch(rawAccountsStreamProvider).valueOrNull ?? const <Account>[];
    final activeAccounts = accounts.where((a) => !a.isArchived).toList();

    if (_selectedAccount == null && activeAccounts.isNotEmpty) {
      _selectedAccount = activeAccounts.first;
    }

    return Form(
      key: _formKey,
      child: FfSheet(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSheetHeader(
            title: isLent ? 'Lend More Money' : 'Borrow More Money',
            subtitle: 'Adding advance for ${widget.record.personName}',
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                StillwaterTokens.spaceLg,
                0,
                StillwaterTokens.spaceLg,
                StillwaterTokens.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    autofocus: true,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: typeColor,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Advance Amount',
                      prefixText: '${CurrencyFormatter.currencySymbol} ',
                      prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: typeColor,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final parsed = CurrencyFormatter.parse(val);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a positive amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: StillwaterTokens.spaceMd),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
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
                                  _dueDate = _advanceDate.add(
                                    const Duration(days: 30),
                                  );
                                }
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Advance Date',
                              suffixIcon: Icon(Icons.event_outlined, size: 20),
                            ),
                            child: Text(
                              DateFormat.yMMMd().format(_advanceDate),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await pickFfDate(
                              context,
                              initialDate: _dueDate,
                              firstDate: _advanceDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _dueDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              suffixIcon: Icon(Icons.event_available, size: 20),
                            ),
                            child: Text(
                              DateFormat.yMMMd().format(_dueDate),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: StillwaterTokens.spaceMd),

                  // Transaction linking toggle
                  FfCard(
                    variant: FfCardVariant.standard,
                    padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                    child: Column(
                      children: [
                        FfRow.toggle(
                          title: 'Record as Transaction',
                          subtitle:
                              _recordInTransactions
                                  ? (isLent
                                      ? 'Deducts money from selected account'
                                      : 'Adds money to selected account')
                                  : 'Update debt balance only (no account change)',
                          value: _recordInTransactions,
                          onChanged: (val) {
                            setState(() => _recordInTransactions = val);
                          },
                        ),
                        if (_recordInTransactions &&
                            activeAccounts.isNotEmpty) ...[
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          DropdownButtonFormField<String>(
                            value: _selectedAccount?.id,
                            decoration: InputDecoration(
                              labelText: isLent ? 'Paid From' : 'Deposited To',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceMd,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                            ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: StillwaterTokens.spaceMd),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g. For dinner, taxi ride, groceries...',
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: StillwaterTokens.spaceLg),

                  // Action button
                  FfButton(
                    label: 'Save Advance',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
