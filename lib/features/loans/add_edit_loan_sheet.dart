import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/account_repository.dart';
import '../../services/loan_calculator.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'loans_controller.dart';

class AddEditLoanSheet extends ConsumerStatefulWidget {
  final Loan? initialLoan;

  const AddEditLoanSheet({super.key, this.initialLoan});

  @override
  ConsumerState<AddEditLoanSheet> createState() => _AddEditLoanSheetState();
}

class _AddEditLoanSheetState extends ConsumerState<AddEditLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lenderController;
  late final TextEditingController _principalController;
  late final TextEditingController _rateController;
  late final TextEditingController _tenureController;
  late final TextEditingController _emiController;
  late final TextEditingController _paymentDayController;
  late final TextEditingController _notesController;

  late LoanType _loanType;
  late InterestType _interestType;
  late DateTime _startDate;
  String? _selectedAccountId;
  bool _markPastPaid = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialLoan;
    _nameController = TextEditingController(text: init?.name ?? '');
    _lenderController = TextEditingController(text: init?.lender ?? '');
    _principalController = TextEditingController(
      text: init != null ? init.principalAmount.toStringAsFixed(0) : '',
    );
    _rateController = TextEditingController(
      text: init != null ? init.interestRate.toStringAsFixed(2) : '8.50',
    );
    _tenureController = TextEditingController(
      text: init != null ? init.tenureMonths.toString() : '24',
    );
    _emiController = TextEditingController(
      text: init != null ? init.emiAmount.toStringAsFixed(2) : '',
    );
    _paymentDayController = TextEditingController(
      text: init != null ? init.paymentDay.toString() : '5',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _loanType = init?.loanType ?? LoanType.personalLoan;
    _interestType = init?.interestType ?? InterestType.reducingBalance;
    _startDate = init?.startDate ?? DateTime.now();
    _selectedAccountId = init?.accountId;

    if (init == null) {
      _recalculateEmi();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lenderController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _emiController.dispose();
    _paymentDayController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculateEmi() {
    final p = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;

    if (p > 0 && n > 0) {
      final calculated = LoanCalculator.calculateEmi(
        principal: p,
        annualRate: r,
        tenureMonths: n,
        interestType: _interestType,
      );
      _emiController.text = calculated.toStringAsFixed(2);
      setState(() {});
    }
  }

  List<AmortizationScheduleItem> _getPastInstallmentsPreview() {
    if (widget.initialLoan != null) return const [];
    final p = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = double.tryParse(_emiController.text.trim()) ?? 0.0;
    final day = (int.tryParse(_paymentDayController.text.trim()) ?? 5).clamp(1, 28);

    if (p <= 0 || n <= 0 || emi <= 0) return const [];

    final now = DateTime.now();
    final tempLoan = Loan(
      id: 'preview',
      name: 'Preview',
      lender: 'Preview',
      principalAmount: p,
      interestRate: r,
      interestType: _interestType,
      tenureMonths: n,
      startDate: _startDate,
      expectedEndDate: DateTime(_startDate.year, _startDate.month + n, _startDate.day),
      emiAmount: emi,
      paymentDay: day,
      outstandingPrincipal: p,
      nextDueDate: DateTime(_startDate.year, _startDate.month + 1, day),
      createdAt: now,
      updatedAt: now,
    );

    return LoanCalculator.getMissedInstallments(tempLoan, asOfDate: now);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = double.tryParse(_emiController.text.trim()) ?? 0.0;
    final paymentDay = (int.tryParse(_paymentDayController.text.trim()) ?? 5)
        .clamp(1, 28);

    if (principal <= 0 || tenure <= 0 || emi <= 0) {
      FfSnackbar.show(context, message: 'Please enter valid loan details.');
      return;
    }

    final controller = ref.read(loansControllerProvider.notifier);

    if (widget.initialLoan != null) {
      final updated = widget.initialLoan!.copyWith(
        name: _nameController.text.trim(),
        lender: _lenderController.text.trim(),
        loanType: _loanType,
        accountId: _selectedAccountId,
        principalAmount: principal,
        interestRate: rate,
        interestType: _interestType,
        tenureMonths: tenure,
        startDate: _startDate,
        emiAmount: emi,
        paymentDay: paymentDay,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
      await controller.updateLoan(updated);
    } else {
      await controller.addLoan(
        name: _nameController.text.trim(),
        lender: _lenderController.text.trim(),
        loanType: _loanType,
        accountId: _selectedAccountId,
        principalAmount: principal,
        interestRate: rate,
        interestType: _interestType,
        tenureMonths: tenure,
        startDate: _startDate,
        emiAmount: emi,
        paymentDay: paymentDay,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        markPastInstallmentsPaid: _markPastPaid,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      FfSnackbar.show(
        context,
        message:
            widget.initialLoan != null
                ? 'Loan updated.'
                : 'Loan added to tracker.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];
    final pastInstallments = _getPastInstallmentsPreview();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: StillwaterTokens.spaceLg,
        right: StillwaterTokens.spaceLg,
        top: StillwaterTokens.spaceLg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialLoan != null ? 'Edit Loan' : 'Add Loan / EMI',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),

              // Loan Name & Lender
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Loan Name',
                  hintText: 'e.g. HDFC Home Loan, Macbook EMI',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              TextFormField(
                controller: _lenderController,
                decoration: const InputDecoration(
                  labelText: 'Lender / Institution',
                  hintText: 'e.g. HDFC Bank, Bajaj Finserv',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Loan Type Dropdown
              DropdownButtonFormField<LoanType>(
                value: _loanType,
                decoration: const InputDecoration(
                  labelText: 'Loan Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items:
                    LoanType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _loanType = val);
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Principal Amount
              FfAmountField(
                controller: _principalController,
                labelText: 'Principal Amount (₹)',
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Interest Rate & Tenure Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (% p.a.)',
                        suffixText: '%',
                      ),
                      onChanged: (_) => _recalculateEmi(),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: TextFormField(
                      controller: _tenureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Months)',
                        suffixText: 'mo',
                      ),
                      onChanged: (_) => _recalculateEmi(),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Interest Type Selector
              DropdownButtonFormField<InterestType>(
                value: _interestType,
                decoration: const InputDecoration(labelText: 'Interest Type'),
                items:
                    InterestType.values.map((it) {
                      return DropdownMenuItem(
                        value: it,
                        child: Text(it.displayName),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _interestType = val);
                    _recalculateEmi();
                  }
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // EMI Amount (auto-calculated / editable)
              FfAmountField(
                controller: _emiController,
                labelText: 'Monthly EMI (₹)',
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Start Date & Payment Day
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(DateFormatter.formatFullDate(_startDate)),
                      trailing: const Icon(Icons.event_outlined),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: TextFormField(
                      controller: _paymentDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Due Day of Month',
                        hintText: '1 - 28',
                      ),
                    ),
                  ),
                ],
              ),

              // Past loan notification and confirmation toggle
              if (pastInstallments.isNotEmpty) ...[
                const SizedBox(height: StillwaterTokens.spaceMd),
                Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceSm),
                          Expanded(
                            child: Text(
                              'Past Loan Detected',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        'Found ${pastInstallments.length} past installments (${DateFormatter.formatTransactionDate(pastInstallments.first.dueDate)} – ${DateFormatter.formatTransactionDate(pastInstallments.last.dueDate)}) totaling ${CurrencyFormatter.formatINR(pastInstallments.fold(0.0, (s, it) => s + it.emiAmount))}.',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _markPastPaid,
                        title: Text(
                          'Mark past ${pastInstallments.length} EMIs as already paid',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _markPastPaid
                              ? 'Past installments will be recorded as paid. Next due date will advance to next upcoming EMI.'
                              : 'Keep past installments as overdue until manually paid.',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                        onChanged: (val) {
                          setState(() => _markPastPaid = val ?? false);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(),

              // Account Selector
              DropdownButtonFormField<String?>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Linked Account (Optional)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None / Manual'),
                  ),
                  ...accounts.map(
                    (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // Trust notice
              FfCard(
                variant: FfCardVariant.tinted,
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: context.secColors.verified,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'Entered by you · Calculated locally · FinanceFlow does not access lender servers.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              FfButton(
                label: widget.initialLoan != null ? 'Save Loan' : 'Add Loan',
                onPressed: _save,
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
