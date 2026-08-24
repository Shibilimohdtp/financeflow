import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_record.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/ff_switch_row.dart';
import '../../theme/stillwater_tokens.dart';
import 'money_records_controller.dart';
import '../accounts/accounts_controller.dart';

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
  bool _recordInTransactions = true;
  String? _selectedAccountId;

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

    _transactionDate = init?.transactionDate ?? DateTime.now();
    _dueDate = init?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    _isReminderEnabled = init?.isReminderEnabled ?? true;
    _reminderDays = init?.reminderDaysBefore ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTransactionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _transactionDate = picked;
        // If due date is earlier than transaction date, move due date
        final txDay = DateTime(picked.year, picked.month, picked.day);
        final dueDay = DateTime(_dueDate.year, _dueDate.month, _dueDate.day);
        if (dueDay.isBefore(txDay)) {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dueDate.isBefore(_transactionDate) ? _transactionDate : _dueDate,
      firstDate: _transactionDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      FfSnackbar.show(context, message: "Please enter person's name.");
      return;
    }

    final amount =
        CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      FfSnackbar.show(
        context,
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
      FfSnackbar.show(
        context,
        message: 'Due date cannot be earlier than transaction date.',
      );
      return;
    }
    if (!isEditing && _recordInTransactions && _selectedAccountId == null) {
      FfSnackbar.show(context, message: 'Select the account for this entry.');
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
        FfSnackbar.show(
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
        FfSnackbar.show(context, message: 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts =
        ref
            .watch(accountsWithBalancesProvider)
            .valueOrNull
            ?.where((account) => !account.isArchived)
            .toList() ??
        const <Account>[];
    _selectedAccountId ??= accounts.firstOrNull?.id;
    if (accounts.isEmpty) _recordInTransactions = false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(StillwaterTokens.radiusXl),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FfSheetHeader(
                title:
                    isEditing
                        ? 'Edit Record'
                        : (_type == MoneyRecordType.lent
                            ? 'I Lent Money'
                            : 'I Borrowed Money'),
                subtitle:
                    isEditing
                        ? 'Update lending / borrowing details'
                        : 'Track money owed to you or money you owe',
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                    vertical: StillwaterTokens.spaceMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Record Type Segmented Pill ─────────────────────
                      FfSegmentedPill<MoneyRecordType>(
                        selectedValue: _type,
                        onSelected: (val) {
                          setState(() => _type = val);
                        },
                        options: const [
                          FfSegmentOption(
                            value: MoneyRecordType.lent,
                            label: 'I Lent Money',
                            icon: Icons.call_made_rounded,
                          ),
                          FfSegmentOption(
                            value: MoneyRecordType.borrowed,
                            label: 'I Borrowed Money',
                            icon: Icons.call_received_rounded,
                          ),
                        ],
                      ),

                      if (!isEditing) ...[
                        const SizedBox(height: StillwaterTokens.spaceMd),
                        FfSwitchRow(
                          title: 'Record in transactions and update balance',
                          subtitle:
                              _type == MoneyRecordType.lent
                                  ? 'Creates an account outflow and receivable.'
                                  : 'Creates an account inflow and liability.',
                          value: _recordInTransactions,
                          onChanged:
                              (value) =>
                                  setState(() => _recordInTransactions = value),
                        ),
                        if (_recordInTransactions)
                          DropdownButtonFormField<String>(
                            value: _selectedAccountId,
                            decoration: const InputDecoration(
                              labelText: 'Account',
                            ),
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
                                (value) =>
                                    setState(() => _selectedAccountId = value),
                          ),
                      ],

                      const SizedBox(height: StillwaterTokens.spaceLg),

                      // ── 2. Person's Name ──────────────────────────────────
                      Text(
                        _type == MoneyRecordType.lent
                            ? 'Lent to (Person Name)'
                            : 'Borrowed from (Person Name)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'e.g. Ahmed, Sarah, Uncle John',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Person's name is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: StillwaterTokens.spaceLg),

                      // ── 3. Original Amount ────────────────────────────────
                      Text(
                        'Amount',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceMd,
                            ),
                            child: Text(
                              CurrencyFormatter.currencySymbol,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    _type == MoneyRecordType.lent
                                        ? context.finColors.income
                                        : context.finColors.expense,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                          ),
                        ),
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

                      const SizedBox(height: StillwaterTokens.spaceLg),

                      // ── 4. Transaction Date & Due Date ────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: StillwaterTokens.spaceXs,
                                ),
                                InkWell(
                                  onTap: _pickTransactionDate,
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusMd,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: StillwaterTokens.spaceMd,
                                      vertical: StillwaterTokens.spaceMd,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        StillwaterTokens.radiusMd,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(
                                          width: StillwaterTokens.spaceSm,
                                        ),
                                        Expanded(
                                          child: Text(
                                            DateFormatter.formatShortDate(
                                              _transactionDate,
                                            ),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: StillwaterTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected Due Date',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: StillwaterTokens.spaceXs,
                                ),
                                InkWell(
                                  onTap: _pickDueDate,
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusMd,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: StillwaterTokens.spaceMd,
                                      vertical: StillwaterTokens.spaceMd,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        StillwaterTokens.radiusMd,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_available_outlined,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(
                                          width: StillwaterTokens.spaceSm,
                                        ),
                                        Expanded(
                                          child: Text(
                                            DateFormatter.formatShortDate(
                                              _dueDate,
                                            ),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: StillwaterTokens.spaceLg),

                      // ── 5. Notes ──────────────────────────────────────────
                      Text(
                        'Notes (Optional)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Emergency medical expense, will pay after salary',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: StillwaterTokens.spaceSm),

                      // ── 6. Reminder Settings ──────────────────────────────
                      FfSwitchRow(
                        title: 'Enable Reminder',
                        subtitle: 'Track upcoming repayment due date',
                        value: _isReminderEnabled,
                        onChanged: (val) {
                          setState(() => _isReminderEnabled = val);
                        },
                      ),

                      if (_isReminderEnabled) ...[
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceSm,
                            vertical: StillwaterTokens.space2Xs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: StillwaterTokens.spaceXs),
                              Expanded(
                                child: Text(
                                  'Remind me in',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 156,
                                child: FfSegmentedPill<int>(
                                  options: const [
                                    FfSegmentOption(value: 1, label: '1d'),
                                    FfSegmentOption(value: 3, label: '3d'),
                                    FfSegmentOption(value: 7, label: '7d'),
                                  ],
                                  selectedValue: _reminderDays,
                                  onSelected: (days) {
                                    setState(() => _reminderDays = days);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              FfSheetFooter(
                primaryLabel: isEditing ? 'Update Record' : 'Save Record',
                isPrimaryLoading: _isSaving,
                onPrimaryPressed: _save,
                secondaryLabel: 'Cancel',
                onSecondaryPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
