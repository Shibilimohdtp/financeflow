import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/account_repository.dart';
import '../../services/loan_calculator.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_hero.dart';
import '../../shared/widgets/ff_disclosure_row.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import 'loans_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

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
      text: init != null ? FfAmountField.formatInput(init.principalAmount) : '',
    );
    _rateController = TextEditingController(
      text: init != null ? init.interestRate.toStringAsFixed(2) : '8.50',
    );
    _tenureController = TextEditingController(
      text: init != null ? init.tenureMonths.toString() : '24',
    );
    _emiController = TextEditingController(
      text: init != null ? FfAmountField.formatInput(init.emiAmount) : '',
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
    final p = FfAmountField.parse(_principalController.text) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;

    if (p > 0 && n > 0) {
      final calculated = LoanCalculator.calculateEmi(
        principal: p,
        annualRate: r,
        tenureMonths: n,
        interestType: _interestType,
      );
      _emiController.text = FfAmountField.formatInput(
        double.parse(calculated.toStringAsFixed(2)),
      );
      setState(() {});
    }
  }

  /// Returns a preview summary for the repayment block.
  /// Returns null if required fields are incomplete.
  ({double emi, double total, double interest, DateTime endDate})? _preview() {
    final p = FfAmountField.parse(_principalController.text) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = FfAmountField.parse(_emiController.text) ?? 0.0;
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
    final p = FfAmountField.parse(_principalController.text) ?? 0.0;
    final r = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    final emi = FfAmountField.parse(_emiController.text) ?? 0.0;
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
    final p = FfAmountField.parse(_principalController.text);
    final r = double.tryParse(_rateController.text.trim());
    final n = int.tryParse(_tenureController.text.trim());
    final emi = FfAmountField.parse(_emiController.text);

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

    final principal = FfAmountField.parse(_principalController.text)!;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = int.parse(_tenureController.text.trim());
    final emi = FfAmountField.parse(_emiController.text)!;
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
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];
    final pastInstallments = _getPastInstallmentsPreview();
    final previewData = _preview();
    final isEdit = widget.initialLoan != null;

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEdit ? 'Edit loan' : 'New loan',
          subtitle: 'Money you borrowed and pay back each month',
          onClose: () => Navigator.of(context).pop(),
        ),

        Flexible(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: FfSheetBody.standardPadding,
              children: [
                // ── 1. Principal hero ──────────────────────────────
                FfAmountHero(
                  controller: _principalController,
                  tone: FfTone.debt,
                  label: 'Amount borrowed',
                  errorText: _principalError,
                  consequence:
                      previewData == null
                          ? 'Enter the amount, rate and tenure to see the EMI.'
                          : 'About ${CurrencyFormatter.formatAmount(previewData.emi)} a month for $_tenureText months.',
                  consequenceIcon: Icons.event_repeat_rounded,
                  groupDigits: true,
                  onChanged: (_) {
                    setState(() => _principalError = null);
                    _recalculateEmi();
                  },
                ),

                const SizedBox(height: FfSheetTokens.groupGap),

                // ── 2. Who and what ────────────────────────────────
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
                const SizedBox(height: FfSheetTokens.itemGap),
                _inputField(
                  controller: _lenderController,
                  label: 'Lender',
                  hint: 'e.g. HDFC Bank, Bajaj Finserv',
                  capitalization: TextCapitalization.words,
                  icon: Icons.business_outlined,
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Lender name is required.'
                              : null,
                ),

                const SizedBox(height: FfSheetTokens.groupGap),

                // ── 3. Type as tappable chips ──────────────────────
                FfSheetGroup(
                  label: 'Type',
                  children: [
                    Wrap(
                      spacing: FfChipTokens.gap,
                      runSpacing: FfChipTokens.gap,
                      children: [
                        for (final t in LoanType.values)
                          FfChip(
                            label: t.displayName,
                            isSelected: _loanType == t,
                            leading: Icon(
                              _loanTypeIcon(t),
                              size: FfIconSize.sm,
                              color:
                                  _loanType == t
                                      ? context.ff.color.onActionPrimary
                                      : context.ff.color.textSecondary,
                            ),
                            onSelected: () => setState(() => _loanType = t),
                          ),
                      ],
                    ),
                  ],
                ),

                // ── 4. Terms ───────────────────────────────────────
                FfSheetGroup(
                  label: 'Terms',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _NumericInputField(
                            controller: _rateController,
                            label: 'Interest',
                            suffix: '% a year',
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
                        const SizedBox(width: FfSpace.md),
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
                    FfSegmentedPill<InterestType>(
                      options: [
                        FfSegmentOption(
                          value: InterestType.reducingBalance,
                          label: InterestType.reducingBalance.displayName,
                        ),
                        FfSegmentOption(
                          value: InterestType.flatRate,
                          label: InterestType.flatRate.displayName,
                        ),
                      ],
                      selectedValue: _interestType,
                      onSelected: (t) {
                        setState(() => _interestType = t);
                        _recalculateEmi();
                      },
                    ),
                    FfConsequenceLine(
                      text:
                          _interestType == InterestType.reducingBalance
                              ? 'Interest falls as you repay the principal.'
                              : 'Interest is charged on the original principal.',
                      icon: Icons.info_outline_rounded,
                    ),
                    FfAmountField(
                      controller: _emiController,
                      label: 'Monthly EMI',
                      size: FfAmountSize.md,
                      tone: FfTone.debt,
                      groupDigits: true,
                      helper:
                          'Calculated for you · edit if your lender differs',
                      errorText: _emiError,
                      onChanged: (_) => setState(() => _emiError = null),
                    ),

                    // ── 5. What it costs ───────────────────────────────
                    if (previewData != null)
                      _RepaymentPreview(data: previewData),
                  ],
                ),

                // ── 6. Schedule ────────────────────────────────────
                FfSheetGroup(
                  label: 'Schedule',
                  children: [
                    FfGroupedContainer(
                      children: [
                        FfRow(
                          title: 'Start date',
                          icon: Icons.event_outlined,
                          detail: DateFormatter.formatShortDate(_startDate),
                          showChevron: true,
                          onTap: _selectDate,
                        ),
                        FfRow(
                          title: 'Due day each month',
                          subtitle: 'Between 1 and 28',
                          icon: Icons.today_outlined,
                          trailing: SizedBox(
                            width: FfFieldTokens.compactWidth,
                            child: FfTextField(
                              controller: _paymentDayController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              hint: '5',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Past loan notice ───────────────────────────────
                    if (pastInstallments.isNotEmpty)
                      _PastLoanNotice(
                        installments: pastInstallments,
                        markPaid: _markPastPaid,
                        onChanged: (v) => setState(() => _markPastPaid = v),
                      ),
                  ],
                ),

                // ── 7. More details ────────────────────────────────
                FfDisclosureRow(
                  subtitle: 'Linked account and a note',
                  initiallyExpanded: _showMoreOptions,
                  onExpansionChanged: (v) => _showMoreOptions = v,
                  children: [
                    _AccountSelector(
                      accounts: accounts,
                      selected: _selectedAccountId,
                      onChanged: (v) => setState(() => _selectedAccountId = v),
                    ),
                    _inputField(
                      controller: _notesController,
                      label: 'Notes (optional)',
                      hint: 'Anything else about this loan',
                      icon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),

                const SizedBox(height: FfSheetTokens.groupGap),

                // ── Trust notice ───────────────────────────────────
                const FfConsequenceLine(
                  text:
                      'Entered by you and calculated on this device. FinanceFlow does not contact your lender.',
                  icon: Icons.lock_outline_rounded,
                  tone: FfTone.success,
                ),
              ],
            ),
          ),
        ),

        FfSheetFooter(
          primaryLabel: isEdit ? 'Save changes' : 'Create loan',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }

  String get _tenureText {
    final n = int.tryParse(_tenureController.text.trim()) ?? 0;
    return n > 0 ? '$n' : '—';
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
    return FfTextField(
      controller: controller,
      label: label,
      hint: hint,
      icon: icon,
      textCapitalization: capitalization,
      maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      validator: validator,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Private sub-widgets (Bloom)
// ──────────────────────────────────────────────────────────────────────────────

/// Numeric term field with a unit suffix or a currency prefix.
class _NumericInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _NumericInputField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FfTextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (keyboardType ==
            const TextInputType.numberWithOptions(decimal: true))
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      label: label,
      suffixText: suffix,
      errorText: errorText,
      onChanged: onChanged,
    );
  }
}

/// Repayment preview: three stat tiles and the estimated finish date.
class _RepaymentPreview extends StatelessWidget {
  final ({double emi, double total, double interest, DateTime endDate}) data;

  const _RepaymentPreview({required this.data});

  @override
  Widget build(BuildContext context) {
    return FfCard(
      density: FfDensity.compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FfStatTile(
                  label: 'Monthly',
                  value: FfAmountText(
                    amount: data.emi,
                    size: FfAmountSize.md,
                    showSign: false,
                  ),
                  tone: FfTone.debt,
                ),
              ),
              Expanded(
                child: FfStatTile(
                  label: 'Total repaid',
                  value: FfAmountText(
                    amount: data.total,
                    size: FfAmountSize.md,
                    showSign: false,
                  ),
                ),
              ),
              Expanded(
                child: FfStatTile(
                  label: 'Interest',
                  value: FfAmountText(
                    amount: data.interest,
                    size: FfAmountSize.md,
                    showSign: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          FfConsequenceLine(
            text: 'Finishes ${DateFormatter.formatMonthYear(data.endDate)}',
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }
}

/// Past-loan notice: a toggle row that explains the choice in plain words.
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
    final total = installments.fold<double>(0.0, (s, it) => s + it.emiAmount);
    final count = installments.length;

    return FfGroupedContainer(
      showDividers: false,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FfRow.toggle(
              title: 'This loan started earlier',
              subtitle:
                  '$count past installment${count > 1 ? 's' : ''} '
                  '(${DateFormatter.formatShortDate(installments.first.dueDate)} – '
                  '${DateFormatter.formatShortDate(installments.last.dueDate)}), '
                  'about ${CurrencyFormatter.formatAmount(total)}.',
              icon: Icons.history_rounded,
              value: markPaid,
              onChanged: onChanged,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FfRowTokens.textInsetAfterIcon,
                0,
                FfRowTokens.paddingH,
                FfSpace.md,
              ),
              child: FfConsequenceLine(
                text:
                    markPaid
                        ? 'Marked as paid. The next due date moves forward.'
                        : 'Kept as overdue until you mark each one paid.',
                icon:
                    markPaid
                        ? Icons.check_circle_outline_rounded
                        : Icons.schedule_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Linked account selector (kept on the shared select).
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
    return FfSelect<String?>(
      value: selected,
      label: 'Linked account (optional)',
      icon: Icons.account_balance_wallet_outlined,
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
