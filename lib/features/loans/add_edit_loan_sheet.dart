import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/account_repository.dart';
import '../../services/loan_calculator.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import 'loans_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Icon map for each loan type
// ─────────────────────────────────────────────────────────────────────────────
IconData _loanTypeIcon(LoanType t) {
  switch (t) {
    case LoanType.homeLoan:
      return Icons.home_outlined;
    case LoanType.personalLoan:
      return Icons.person_outline_rounded;
    case LoanType.educationLoan:
      return Icons.school_outlined;
    case LoanType.vehicleLoan:
      return Icons.directions_car_outlined;
    case LoanType.creditCardEmi:
      return Icons.credit_card_outlined;
    case LoanType.bnpl:
      return Icons.shopping_bag_outlined;
    case LoanType.other:
      return Icons.more_horiz_rounded;
  }
}

class AddEditLoanSheet extends ConsumerStatefulWidget {
  final Loan? initialLoan;

  const AddEditLoanSheet({super.key, this.initialLoan});

  @override
  ConsumerState<AddEditLoanSheet> createState() => _AddEditLoanSheetState();
}

class _AddEditLoanSheetState extends ConsumerState<AddEditLoanSheet> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers — each field keeps its own controller
  late final TextEditingController _nameController;
  late final TextEditingController _lenderController;
  late final TextEditingController _principalController;
  late final TextEditingController _rateController;
  late final TextEditingController _tenureController;
  late final TextEditingController _emiController;
  late final TextEditingController _paymentDayController;
  late final TextEditingController _notesController;

  // Non-text state
  late LoanType _loanType;
  late InterestType _interestType;
  late DateTime _startDate;
  String? _selectedAccountId;
  bool _markPastPaid = false;
  bool _showMoreOptions = false;
  bool _isSaving = false;

  // Inline field error state (kept separate so errors don't shift layout heavily)
  String? _principalError;
  String? _rateError;
  String? _tenureError;
  String? _emiError;

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

    // Auto-calculate EMI for new loans
    if (init == null) _recalculateEmi();
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

  // ── Calculation helpers ────────────────────────────────────────────────────

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

  /// Returns a preview summary for the repayment block.
  /// Returns null if required fields are incomplete.
  ({double emi, double total, double interest, DateTime endDate})? _preview() {
    final p = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = double.tryParse(_emiController.text.trim()) ?? 0.0;
    if (p <= 0 || n <= 0 || emi <= 0) return null;

    final tempLoan = Loan(
      id: 'preview',
      name: 'Preview',
      lender: '',
      principalAmount: p,
      interestRate: r,
      interestType: _interestType,
      tenureMonths: n,
      startDate: _startDate,
      expectedEndDate: DateTime(
        _startDate.year,
        _startDate.month + n,
        _startDate.day,
      ),
      emiAmount: emi,
      outstandingPrincipal: p,
      nextDueDate: DateTime(
        _startDate.year,
        _startDate.month + 1,
        (_paymentDayInt()).clamp(1, 28),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return (
      emi: emi,
      total: LoanCalculator.calculateTotalRepayment(tempLoan),
      interest: LoanCalculator.calculateTotalEstimatedInterest(tempLoan),
      endDate: tempLoan.expectedEndDate,
    );
  }

  List<AmortizationScheduleItem> _getPastInstallmentsPreview() {
    if (widget.initialLoan != null) return const [];
    final p = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = double.tryParse(_emiController.text.trim()) ?? 0.0;
    final day = _paymentDayInt();
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
      expectedEndDate: DateTime(
        _startDate.year,
        _startDate.month + n,
        _startDate.day,
      ),
      emiAmount: emi,
      paymentDay: day,
      outstandingPrincipal: p,
      nextDueDate: DateTime(_startDate.year, _startDate.month + 1, day),
      createdAt: now,
      updatedAt: now,
    );
    return LoanCalculator.getMissedInstallments(tempLoan, asOfDate: now);
  }

  int _paymentDayInt() =>
      (int.tryParse(_paymentDayController.text.trim()) ?? 5).clamp(1, 28);

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _selectDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  bool _validateNumericFields() {
    final p = double.tryParse(_principalController.text.trim());
    final r = double.tryParse(_rateController.text.trim());
    final n = int.tryParse(_tenureController.text.trim());
    final emi = double.tryParse(_emiController.text.trim());

    String? pErr, rErr, nErr, eErr;
    if (p == null || p <= 0) pErr = 'Enter a valid principal amount.';
    if (r == null || r < 0) rErr = 'Enter a valid annual interest rate.';
    if (n == null || n <= 0) nErr = 'Enter a valid tenure in months.';
    if (emi == null || emi <= 0) eErr = 'Enter a valid monthly EMI.';

    setState(() {
      _principalError = pErr;
      _rateError = rErr;
      _tenureError = nErr;
      _emiError = eErr;
    });
    return pErr == null && rErr == null && nErr == null && eErr == null;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final formValid = _formKey.currentState!.validate();
    final numValid = _validateNumericFields();
    if (!formValid || !numValid) return;

    setState(() => _isSaving = true);

    final principal = double.parse(_principalController.text.trim());
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = int.parse(_tenureController.text.trim());
    final emi = double.parse(_emiController.text.trim());
    final paymentDay = _paymentDayInt();

    try {
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
        FfToast.show(
          context,
          message:
              widget.initialLoan != null
                  ? 'Loan updated.'
                  : 'Loan added to tracker.',
        );
      }
    } catch (_) {
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Failed to save. Please try again.',
        );
        setState(() => _isSaving = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];
    final pastInstallments = _getPastInstallmentsPreview();
    final previewData = _preview();
    final isEdit = widget.initialLoan != null;

    return FfSheet(
      children: [
        // ── Drag handle + header ─────────────────────────────────
        FfSheetHeader(
          title: isEdit ? 'Edit Loan' : 'Add Loan / EMI',
          subtitle:
              isEdit
                  ? 'Update loan details and repayment terms.'
                  : 'Track repayments and outstanding balance.',
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, thickness: 1),

        // ── Scrollable form body ─────────────────────────────────
        Flexible(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
              ),
              children: [
                const SizedBox(height: StillwaterTokens.spaceXs),

                // ── 1. Loan type selector ──────────────────────────
                _LoanTypeSelector(
                  selected: _loanType,
                  onChanged: (t) => setState(() => _loanType = t),
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── 2. Loan details ────────────────────────────────
                _SectionLabel(label: 'Loan Details'),
                const SizedBox(height: StillwaterTokens.spaceXs),

                _inputField(
                  controller: _nameController,
                  label: 'Loan name',
                  hint: 'e.g. HDFC Home Loan, Macbook EMI',
                  capitalization: TextCapitalization.words,
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Loan name is required.'
                              : null,
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                _inputField(
                  controller: _lenderController,
                  label: 'Lender / Institution',
                  hint: 'e.g. HDFC Bank, Bajaj Finserv',
                  capitalization: TextCapitalization.words,
                  icon: Icons.business_outlined,
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Lender name is required.'
                              : null,
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── 3. Amount and repayment ────────────────────────
                _SectionLabel(label: 'Amount & Repayment'),
                const SizedBox(height: StillwaterTokens.spaceXs),

                // Principal
                _NumericInputField(
                  controller: _principalController,
                  label: 'Principal Amount',
                  suffix: CurrencyFormatter.currencySymbol,
                  prefixSymbol: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _principalError,
                  onChanged: (_) {
                    setState(() => _principalError = null);
                    _recalculateEmi();
                  },
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Rate + Tenure row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _NumericInputField(
                        controller: _rateController,
                        label: 'Interest rate',
                        suffix: '% p.a.',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: _rateError,
                        onChanged: (_) {
                          setState(() => _rateError = null);
                          _recalculateEmi();
                        },
                      ),
                    ),
                    const SizedBox(width: StillwaterTokens.spaceMd),
                    Expanded(
                      child: _NumericInputField(
                        controller: _tenureController,
                        label: 'Tenure',
                        suffix: 'months',
                        keyboardType: TextInputType.number,
                        errorText: _tenureError,
                        onChanged: (_) {
                          setState(() => _tenureError = null);
                          _recalculateEmi();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // ── 4. Interest type ───────────────────────────────
                _InterestTypeSelector(
                  selected: _interestType,
                  onChanged: (t) {
                    setState(() => _interestType = t);
                    _recalculateEmi();
                  },
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Monthly EMI
                _NumericInputField(
                  controller: _emiController,
                  label: 'Monthly EMI',
                  suffix: CurrencyFormatter.currencySymbol,
                  prefixSymbol: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _emiError,
                  helperText: 'Auto-calculated · edit to override',
                  onChanged: (_) => setState(() => _emiError = null),
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── 5. Repayment preview ───────────────────────────
                if (previewData != null) ...[
                  _RepaymentPreview(data: previewData),
                  const SizedBox(height: StillwaterTokens.spaceLg),
                ],

                // ── 6. Schedule ────────────────────────────────────
                _SectionLabel(label: 'Schedule'),
                const SizedBox(height: StillwaterTokens.spaceXs),

                _DateAndPaymentDayRow(
                  startDate: _startDate,
                  paymentDayController: _paymentDayController,
                  onSelectDate: _selectDate,
                  onDayChanged: (_) => setState(() {}),
                ),

                // ── Past loan notice ───────────────────────────────
                if (pastInstallments.isNotEmpty) ...[
                  const SizedBox(height: StillwaterTokens.spaceMd),
                  _PastLoanNotice(
                    installments: pastInstallments,
                    markPaid: _markPastPaid,
                    onChanged: (v) => setState(() => _markPastPaid = v),
                  ),
                ],

                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── 7. More options ────────────────────────────────
                _MoreOptionsToggle(
                  isExpanded: _showMoreOptions,
                  onToggle:
                      () =>
                          setState(() => _showMoreOptions = !_showMoreOptions),
                ),

                if (_showMoreOptions) ...[
                  const SizedBox(height: StillwaterTokens.spaceMd),

                  // Linked account
                  _AccountSelector(
                    accounts: accounts,
                    selected: _selectedAccountId,
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                  ),

                  const SizedBox(height: StillwaterTokens.spaceMd),

                  // Notes
                  _inputField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    hint: 'Any additional details about this loan',
                    icon: Icons.notes_outlined,
                    maxLines: 2,
                  ),
                ],

                const SizedBox(height: StillwaterTokens.spaceLg),

                // ── Trust notice ───────────────────────────────────
                FfCard(
                  variant: FfCardVariant.tinted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceMd,
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: context.secColors.verified,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Expanded(
                        child: Text(
                          'Entered by you · Calculated locally · FinanceFlow does not access lender servers.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),
              ],
            ),
          ),
        ),

        // ── Sticky primary action ───────────────────────────────────
        FfSheetFooter(
          primaryLabel: isEdit ? 'Save Changes' : 'Create Loan',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }

  // ── Convenience field builder ──────────────────────────────────────────────

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = context.theme;
    return TextFormField(
      controller: controller,
      textCapitalization: capitalization,
      maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
      ),
      validator: validator,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ──────────────────────────────────────────────────────────────────────────────
// ── Convenience field builder ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Responsive loan-type selector: wraps chips in a Wrap layout.
class _LoanTypeSelector extends StatelessWidget {
  final LoanType selected;
  final ValueChanged<LoanType> onChanged;

  const _LoanTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Loan Type'),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Wrap(
          spacing: StillwaterTokens.spaceXs,
          runSpacing: StillwaterTokens.spaceXs,
          children:
              LoanType.values.map((t) {
                return FfChip(
                  label: t.displayName,
                  isSelected: selected == t,
                  leading: Icon(
                    _loanTypeIcon(t),
                    size: 15,
                    color:
                        selected == t
                            ? context.theme.colorScheme.onPrimaryContainer
                            : context.theme.colorScheme.secondary,
                  ),
                  onSelected: () => onChanged(t),
                );
              }).toList(),
        ),
      ],
    );
  }
}

/// Numeric input styled inline (no box unless focused) — lighter than FfAmountField.
class _NumericInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool prefixSymbol;
  final TextInputType keyboardType;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;

  const _NumericInputField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.keyboardType,
    this.prefixSymbol = false,
    this.errorText,
    this.helperText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (keyboardType ==
            const TextInputType.numberWithOptions(decimal: true))
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
        prefixText:
            prefixSymbol ? '${CurrencyFormatter.currencySymbol}  ' : null,
        prefixStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        suffixText: prefixSymbol ? null : suffix,
        suffixStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
        errorText: errorText,
        helperText: helperText,
        helperStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontSize: 10,
        ),
        errorStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.error,
          fontSize: 10,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// Two-option interest type selector with explanatory sub-text.
class _InterestTypeSelector extends StatelessWidget {
  final InterestType selected;
  final ValueChanged<InterestType> onChanged;

  const _InterestTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
          child: Text(
            'Interest Type',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Row(
          children:
              InterestType.values.map((t) {
                final isSelected = selected == t;
                final description =
                    t == InterestType.reducingBalance
                        ? 'Reduces as principal decreases'
                        : 'Fixed on original principal';
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right:
                          t == InterestType.reducingBalance
                              ? StillwaterTokens.spaceXs
                              : 0,
                      left:
                          t == InterestType.flatRate
                              ? StillwaterTokens.spaceXs
                              : 0,
                    ),
                    child: InkWell(
                      onTap: () => onChanged(t),
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusMd,
                      ),
                      child: AnimatedContainer(
                        duration: StillwaterTokens.durationFast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceMd,
                          vertical: StillwaterTokens.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          border: Border.all(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                            width:
                                isSelected
                                    ? StillwaterTokens.borderWidthDefault
                                    : StillwaterTokens.borderWidthHairline,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.displayName,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.75)
                                        : theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

/// Compact repayment preview — same language as the loan detail balance card.
class _RepaymentPreview extends StatelessWidget {
  final ({double emi, double total, double interest, DateTime endDate}) data;

  const _RepaymentPreview({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                size: 14,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: StillwaterTokens.space2Xs),
              Text(
                'Repayment Preview',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          // Three stat columns
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _PreviewStat(
                    label: 'Monthly EMI',
                    value: CurrencyFormatter.formatAmount(data.emi),
                    isPrimary: true,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: StillwaterTokens.borderWidthHairline,
                  indent: 4,
                  endIndent: 4,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _PreviewStat(
                    label: 'Total Repayment',
                    value: CurrencyFormatter.formatAmount(data.total),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: StillwaterTokens.borderWidthHairline,
                  indent: 4,
                  endIndent: 4,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _PreviewStat(
                    label: 'Est. Interest',
                    value: CurrencyFormatter.formatAmount(data.interest),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Row(
            children: [
              Text(
                'Est. completion',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.formatMonthYear(data.endDate),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _PreviewStat({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isPrimary ? theme.colorScheme.primary : null,
              fontSize: isPrimary ? 13 : 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Start date + payment day row.
class _DateAndPaymentDayRow extends StatelessWidget {
  final DateTime startDate;
  final TextEditingController paymentDayController;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onDayChanged;

  const _DateAndPaymentDayRow({
    required this.startDate,
    required this.paymentDayController,
    required this.onSelectDate,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start date — tappable tile
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: onSelectDate,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Start date',
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                suffixIcon: const Icon(Icons.event_outlined, size: 18),
              ),
              child: Text(
                DateFormatter.formatShortDate(startDate),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),

        const SizedBox(width: StillwaterTokens.spaceMd),

        // Due day of month
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: paymentDayController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              labelText: 'Due day',
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              hintText: '1–28',
              suffixText: 'of month',
              suffixStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontSize: 10,
              ),
            ),
            onChanged: onDayChanged,
          ),
        ),
      ],
    );
  }
}

/// Calm past-loan notice card with toggle.
class _PastLoanNotice extends StatelessWidget {
  final List<AmortizationScheduleItem> installments;
  final bool markPaid;
  final ValueChanged<bool> onChanged;

  const _PastLoanNotice({
    required this.installments,
    required this.markPaid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final total = installments.fold<double>(0.0, (s, it) => s + it.emiAmount);

    return FfCard(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              Expanded(
                child: Text(
                  'Past Loan Detected',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Text(
            '${installments.length} past installment${installments.length > 1 ? "s" : ""} found '
            '(${DateFormatter.formatShortDate(installments.first.dueDate)} – '
            '${DateFormatter.formatShortDate(installments.last.dueDate)}) '
            'totaling ${CurrencyFormatter.formatAmount(total)}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  markPaid
                      ? 'Mark past ${installments.length} EMIs as already paid — next due date will advance.'
                      : 'Keep past installments as overdue until manually paid.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
              Switch(value: markPaid, onChanged: onChanged),
            ],
          ),
        ],
      ),
    );
  }
}

/// "More options" expandable toggle row.
class _MoreOptionsToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MoreOptionsToggle({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: StillwaterTokens.spaceXs),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: StillwaterTokens.spaceXs),
            Text(
              isExpanded ? 'Fewer options' : 'More options',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              isExpanded ? '' : 'Linked account, notes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linked account selector (DropdownButton inside a styled field).
class _AccountSelector extends StatelessWidget {
  final List<dynamic> accounts;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _AccountSelector({
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selected,
      decoration: InputDecoration(
        labelText: 'Linked account (optional)',
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
        labelStyle: context.textTheme.bodySmall?.copyWith(
          color: context.theme.colorScheme.secondary,
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('None / Manual'),
        ),
        ...accounts.map(
          (a) => DropdownMenuItem<String?>(
            value: a.id as String,
            child: Text(a.name as String, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
