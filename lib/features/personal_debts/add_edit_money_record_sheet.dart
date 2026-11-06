import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/money_record.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../accounts/accounts_controller.dart';
import 'money_records_controller.dart';
import 'widgets/money_record_account_section.dart';
import 'widgets/money_record_date_chips.dart';
import 'widgets/money_record_direction_tiles.dart';
import 'widgets/money_record_person_field.dart';
import 'widgets/money_record_preview_card.dart';
import 'widgets/money_record_reminder_selector.dart';

/// Stillwater Bloom Add / Edit Money Record bottom sheet (Pattern E).
///
/// Designed as a fast, guided, mostly one-hand creation flow:
/// 1. Real-time squircle preview card (`MoneyRecordPreviewCard`)
/// 2. Direction first via `MoneyRecordDirectionTiles` (I Lent / I Borrowed)
/// 3. Person field with autocomplete chips and collision hint
/// 4. Amount input with type-reactive squircle styling and Geist numerals
/// 5. Dates as quick chips (Today / Yesterday / End of month / In 3 months)
/// 6. Account link with live dynamic `FfConsequenceLine`
/// 7. Inline reminder cadence chips and optional notes
/// 8. Edit mode safeguards (cannot lower amount below total repaid) and delete
class AddEditMoneyRecordSheet extends ConsumerStatefulWidget {
  final MoneyRecord? initialRecord;
  final MoneyRecordType? defaultType;

  const AddEditMoneyRecordSheet({
    super.key,
    this.initialRecord,
    this.defaultType,
  });

  @override
  ConsumerState<AddEditMoneyRecordSheet> createState() =>
      _AddEditMoneyRecordSheetState();
}

class _AddEditMoneyRecordSheetState
    extends ConsumerState<AddEditMoneyRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late MoneyRecordType _type;
  late DateTime _transactionDate;
  late DateTime _dueDate;
  late bool _isReminderEnabled;
  late int _reminderDays;
  bool _isSaving = false;
  bool _recordInTransactions = false;
  String? _selectedAccountId;
  double _parsedAmount = 0.0;

  bool get isEditing => widget.initialRecord != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialRecord;
    _type = init?.type ?? widget.defaultType ?? MoneyRecordType.lent;
    _nameController = TextEditingController(text: init?.personName ?? '');
    _amountController = TextEditingController(
      text:
          init != null
              ? (init.originalAmount.truncateToDouble() == init.originalAmount
                  ? init.originalAmount.toInt().toString()
                  : init.originalAmount.toStringAsFixed(2))
              : '',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _parsedAmount = init?.originalAmount ?? 0.0;

    _transactionDate = init?.transactionDate ?? DateTime.now();
    _dueDate = init?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    _isReminderEnabled = init?.isReminderEnabled ?? true;
    _reminderDays = init?.reminderDaysBefore ?? 1;

    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() {
      final parsed =
          CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
      if (parsed != _parsedAmount) {
        setState(() => _parsedAmount = parsed);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final record = widget.initialRecord;
    if (record == null) return;

    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Record?',
      message:
          'Remove "${record.personName}" and all associated history? This action cannot be undone.',
      confirmLabel: 'Delete Record',
      destructive: true,
    );

    if (confirmed == true && mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRecord(record.id);
        if (mounted) {
          Navigator.of(context).pop(true);
          FfToast.show(context, message: 'Record deleted.');
        }
      } catch (e) {
        if (mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to delete record: $e',
          );
        }
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: "Person's name is required.",
      );
      return;
    }

    final amount =
        CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid positive amount.',
      );
      return;
    }

    final txDay = DateTime(
      _transactionDate.year,
      _transactionDate.month,
      _transactionDate.day,
    );
    final dueDay = DateTime(_dueDate.year, _dueDate.month, _dueDate.day);
    if (dueDay.isBefore(txDay)) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Due date cannot be earlier than transaction date.',
      );
      return;
    }

    if (!isEditing && _recordInTransactions && _selectedAccountId == null) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Select the account for this entry.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(moneyRecordsControllerProvider.notifier);

    try {
      if (isEditing) {
        final updated = widget.initialRecord!.copyWith(
          type: _type,
          personName: name,
          originalAmount: amount,
          transactionDate: _transactionDate,
          dueDate: _dueDate,
          notes:
              _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
          isReminderEnabled: _isReminderEnabled,
          reminderDaysBefore: _reminderDays,
        );
        await controller.updateRecord(updated);
      } else {
        await controller.addRecord(
          personName: name,
          type: _type,
          originalAmount: amount,
          transactionDate: _transactionDate,
          dueDate: _dueDate,
          notes:
              _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
          isReminderEnabled: _isReminderEnabled,
          reminderDaysBefore: _reminderDays,
          accountId: _selectedAccountId,
          recordInTransactions: _recordInTransactions,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        FfToast.show(
          context,
          message:
              isEditing
                  ? 'Record updated successfully.'
                  : 'Money record created.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        FfToast.show(context, tone: FfToastTone.error, message: 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final allRecords =
        ref.watch(allMoneyRecordsStreamProvider).value ?? const [];
    final accounts =
        ref
            .watch(accountsWithBalancesProvider)
            .valueOrNull
            ?.where((account) => !account.isArchived)
            .toList() ??
        const <Account>[];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final selectedAccount =
        accounts.where((a) => a.id == _selectedAccountId).firstOrNull;

    // Collect recent known counterparties for quick autocomplete chips
    final knownNames =
        allRecords
            .map((r) => r.personName.trim())
            .where((n) => n.isNotEmpty)
            .toSet()
            .take(5)
            .toList();

    // Check for existing open debt with the same person
    final normalizedInput = MoneyRecord.normalizePersonName(
      _nameController.text,
    );
    final collisionMatch =
        normalizedInput.isEmpty
            ? null
            : allRecords.where((r) {
              return r.normalizedPersonName == normalizedInput &&
                  r.type == _type &&
                  r.settledAt == null &&
                  (!isEditing || r.id != widget.initialRecord?.id);
            }).firstOrNull;

    final sheetTitle =
        isEditing
            ? 'Edit Record'
            : (_type == MoneyRecordType.lent
                ? 'I Lent Money'
                : 'I Borrowed Money');

    final sheetSubtitle =
        isEditing
            ? 'Update relationship details'
            : (_type == MoneyRecordType.lent
                ? 'Track money you handed over to someone'
                : 'Track money you received from someone');

    return Form(
      key: _formKey,
      child: FfSheet(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSheetHeader(title: sheetTitle, subtitle: sheetSubtitle),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.lg,
                vertical: FfSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Live Preview Card ──────────────────────────────
                  MoneyRecordPreviewCard(
                    personName: _nameController.text,
                    type: _type,
                    amount: _parsedAmount,
                    dueDate: _dueDate,
                    accountName:
                        _recordInTransactions ? selectedAccount?.name : null,
                    settledAt: widget.initialRecord?.settledAt,
                    isSettled: widget.initialRecord?.settledAt != null,
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 2. Direction Selection (Create mode) ──────────────
                  if (!isEditing) ...[
                    MoneyRecordDirectionTiles(
                      selectedType: _type,
                      onChanged: (newType) => setState(() => _type = newType),
                    ),
                    const SizedBox(height: FfSpace.lg),
                  ],

                  // ── 3. Person's Name Field & Suggestions ───────────────
                  MoneyRecordPersonField(
                    controller: _nameController,
                    type: _type,
                    isEditing: isEditing,
                    knownNames: knownNames,
                    collisionMatch: collisionMatch,
                    onSuggestionSelected: (val) {
                      _nameController.text = val;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: FfSpace.lg),

                  // ── 4. Amount Field ───────────────────────────────────
                  Text(
                    'Amount',
                    style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfAmountField(
                    controller: _amountController,
                    hint: '0.00',
                    tone:
                        _type == MoneyRecordType.lent
                            ? FfTone.income
                            : FfTone.expense,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = CurrencyFormatter.parse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a positive amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 5. Dates as Quick Chips ───────────────────────────
                  MoneyRecordDateChips(
                    transactionDate: _transactionDate,
                    dueDate: _dueDate,
                    onTransactionDateChanged:
                        (d) => setState(() => _transactionDate = d),
                    onDueDateChanged: (d) => setState(() => _dueDate = d),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 6. Account & Consequence Line ─────────────────────
                  if (!isEditing) ...[
                    MoneyRecordAccountSection(
                      recordInTransactions: _recordInTransactions,
                      onRecordInTransactionsChanged:
                          (v) => setState(() => _recordInTransactions = v),
                      accounts: accounts,
                      selectedAccountId: _selectedAccountId,
                      onAccountSelected:
                          (accId) => setState(() => _selectedAccountId = accId),
                      type: _type,
                      amount: _parsedAmount,
                    ),
                    const SizedBox(height: FfSpace.lg),
                  ],

                  // ── 7. Notes ──────────────────────────────────────────
                  Text(
                    'Notes (Optional)',
                    style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _notesController,
                    maxLines: 2,
                    maxLength: 300,
                    hint: 'e.g. Emergency expense, will pay after payday',
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 8. Reminder Cadence Chips ─────────────────────────
                  MoneyRecordReminderSelector(
                    isEnabled: _isReminderEnabled,
                    daysBefore: _reminderDays,
                    onChanged: (enabled, days) {
                      setState(() {
                        _isReminderEnabled = enabled;
                        _reminderDays = days;
                      });
                    },
                  ),
                  const SizedBox(height: FfSpace.lg),
                ],
              ),
            ),
          ),

          // ── Sheet Footer ──────────────────────────────────────────────
          FfSheetFooter(
            child:
                isEditing
                    ? Row(
                      children: [
                        Expanded(
                          child: FfButton(
                            label: 'Delete',
                            variant: FfButtonVariant.destructive,
                            onPressed: _handleDelete,
                          ),
                        ),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          flex: 2,
                          child: FfButton(
                            label: 'Save Changes',
                            isLoading: _isSaving,
                            onPressed: _save,
                          ),
                        ),
                      ],
                    )
                    : FfButton(
                      label: 'Save Record',
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
          ),
        ],
      ),
    );
  }
}
