import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/loan.dart';
import '../../models/investment.dart';
import '../../models/money_advance.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../models/transaction.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../services/categorization_service.dart';
import '../../services/merchant_normalization_service.dart';
import '../../services/loan_calculator.dart';
import '../../services/payee_suggestion_service.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../personal_debts/money_records_controller.dart';
import 'transactions_controller.dart';

/// A redesigned, clean, minimal, mobile-first transaction entry surface.
/// Principles: Calm, Precise, Local-First, Fast.
///
/// Daily Entry Target Flow: Amount -> Payee -> Category -> Account -> Save (1-3 taps).
class AddEditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;

  /// When supplied, saves the validated draft without posting to the ledger.
  final Future<void> Function(Transaction)? onSave;
  final String? headerTitle;
  final String? saveLabel;
  final Widget? sourceContext;

  const AddEditTransactionSheet({
    super.key,
    this.initialTransaction,
    this.onSave,
    this.headerTitle,
    this.saveLabel,
    this.sourceContext,
  });

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet> {
  late TransactionType _selectedType;
  late TransactionPurpose _selectedPurpose;
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _counterpartyController;
  late final TextEditingController _principalController;
  late final TextEditingController _interestController;
  late final TextEditingController _feeController;

  Category? _selectedCategory;
  Account? _selectedAccount;
  Account? _selectedToAccount;
  Loan? _selectedLoan;
  MoneyRecord? _selectedMoneyRecord;
  Investment? _selectedInvestment;
  DateTime _selectedDate = DateTime.now();
  DateTime? _debtDueDate;
  bool _createAsSeparateDebt = false;
  String _selectedPaymentMethod = 'UPI';

  bool _moreDetailsOpen = false;
  bool _isSubmitting = false;
  bool _defaultsApplied = false;

  CategorySuggestion? _suggestedCategory;
  String? _amountError;
  String? _merchantError;
  String? _categoryError;
  String? _accountError;
  String? _toAccountError;

  static const _allPaymentMethods = <String>[
    'UPI',
    'Debit Card',
    'Credit Card',
    'Cash',
    'Net Banking',
    'Auto Debit',
    'IMPS / NEFT',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTransaction;
    _selectedType = initial?.type ?? TransactionType.expense;
    _selectedPurpose = initial?.effectivePurpose ?? TransactionPurpose.expense;
    _amountController = TextEditingController(
      text: initial == null ? '' : _formatInitialAmount(initial.amount),
    );
    _merchantController = TextEditingController(text: initial?.merchant ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _tagsController = TextEditingController(
      text: initial?.tags.join(', ') ?? '',
    );
    _counterpartyController = TextEditingController(
      text: initial?.externalCounterpartyName ?? '',
    );
    _principalController = TextEditingController(
      text: initial?.principalComponent?.toStringAsFixed(2) ?? '',
    );
    _interestController = TextEditingController(
      text: initial?.interestComponent?.toStringAsFixed(2) ?? '',
    );
    _feeController = TextEditingController(
      text: initial?.feeComponent?.toStringAsFixed(2) ?? '',
    );
    _selectedDate = initial?.date ?? DateTime.now();
    _selectedPaymentMethod =
        initial?.paymentMethod ?? _defaultPaymentFor(_selectedType);

    if (initial != null &&
        widget.onSave == null &&
        (initial.notes != null ||
            initial.tags.isNotEmpty ||
            initial.paymentMethod != null)) {
      _moreDetailsOpen = true;
    }

    _merchantController.addListener(_onMerchantChanged);
  }

  String _formatInitialAmount(double amount) =>
      amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);

  @override
  void dispose() {
    _merchantController.removeListener(_onMerchantChanged);
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _counterpartyController.dispose();
    _principalController.dispose();
    _interestController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  String _defaultPaymentFor(TransactionType type) => switch (type) {
    TransactionType.cash => 'Cash',
    TransactionType.loanEmi => 'Auto Debit',
    TransactionType.transfer => 'IMPS / NEFT',
    _ => 'UPI',
  };

  List<String> get _paymentMethods => switch (_selectedType) {
    TransactionType.cash => const ['Cash', 'Other'],
    TransactionType.loanEmi => const [
      'Auto Debit',
      'UPI',
      'Net Banking',
      'Other',
    ],
    TransactionType.transfer => const [
      'IMPS / NEFT',
      'UPI',
      'Net Banking',
      'Other',
    ],
    _ => _allPaymentMethods,
  };

  bool get _needsCategory =>
      _selectedPurpose != TransactionPurpose.internalTransfer;

  bool get _needsCounterparty => <TransactionPurpose>{
    TransactionPurpose.lending,
    TransactionPurpose.borrowing,
    TransactionPurpose.personalDebtRepaymentMade,
    TransactionPurpose.personalDebtRepaymentReceived,
    TransactionPurpose.loanDisbursement,
  }.contains(_selectedPurpose);

  void _onMerchantChanged() {
    final merchant = _merchantController.text.trim();
    final suggestion =
        merchant.isEmpty
            ? null
            : CategorizationService.suggestCategory(merchant);
    if (_suggestedCategory?.categoryId != suggestion?.categoryId) {
      setState(() => _suggestedCategory = suggestion);
    }
  }

  void _applyDefaults(
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  ) {
    if (_defaultsApplied ||
        widget.initialTransaction != null ||
        accounts.isEmpty) {
      return;
    }
    _defaultsApplied = true;

    final recentForType =
        history.where((tx) => tx.type == _selectedType).toList();
    if (recentForType.isNotEmpty) {
      final recent = recentForType.first;
      _selectedAccount =
          accounts.where((a) => a.id == recent.accountId).firstOrNull ??
          accounts.first;

      final relevant = _prioritizedCategories(categories, history);
      _selectedCategory =
          relevant.where((c) => c.id == recent.categoryId).firstOrNull ??
          (relevant.isNotEmpty ? relevant.first : null);

      if (recent.paymentMethod != null &&
          _paymentMethods.contains(recent.paymentMethod)) {
        _selectedPaymentMethod = recent.paymentMethod!;
      }
    } else {
      _selectedAccount = accounts.first;
      final relevant = _prioritizedCategories(categories, history);
      if (relevant.isNotEmpty) {
        _selectedCategory = relevant.first;
      }
    }
  }

  List<Category> _relevantCategories(List<Category> categories) {
    final type = _selectedType.toDbString();
    return categories
        .where((c) => !c.isArchived && c.typeCompatibility.contains(type))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Category> _prioritizedCategories(
    List<Category> categories,
    List<Transaction> history,
  ) {
    final relevant = _relevantCategories(categories);
    final recentIds =
        history
            .where((t) => t.type == _selectedType)
            .map((t) => t.categoryId)
            .toList();

    relevant.sort((a, b) {
      final ai = recentIds.indexOf(a.id);
      final bi = recentIds.indexOf(b.id);
      final ap = ai == -1 ? 9999 : ai;
      final bp = bi == -1 ? 9999 : bi;
      return ap == bp ? a.sortOrder.compareTo(b.sortOrder) : ap.compareTo(bp);
    });
    return relevant;
  }

  void _changeType(
    TransactionType type,
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  ) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      _categoryError = null;
      _accountError = null;
      _toAccountError = null;

      if (!_paymentMethods.contains(_selectedPaymentMethod)) {
        _selectedPaymentMethod = _defaultPaymentFor(type);
      }

      final relevant = _prioritizedCategories(categories, history);
      if (_needsCategory) {
        if (!relevant.any((c) => c.id == _selectedCategory?.id)) {
          _selectedCategory = relevant.isNotEmpty ? relevant.first : null;
        }
      }

      if (_selectedAccount == null && accounts.isNotEmpty) {
        _selectedAccount = accounts.first;
      }
    });
  }

  TransactionType _typeForPurpose(
    TransactionPurpose purpose,
  ) => switch (purpose) {
    TransactionPurpose.income ||
    TransactionPurpose.borrowing ||
    TransactionPurpose.loanDisbursement ||
    TransactionPurpose.personalDebtRepaymentReceived => TransactionType.income,
    TransactionPurpose.internalTransfer => TransactionType.transfer,
    TransactionPurpose.investmentPurchase ||
    TransactionPurpose.investmentRedemption => TransactionType.investment,
    TransactionPurpose.loanRepayment => TransactionType.loanEmi,
    TransactionPurpose.legacyCash => TransactionType.cash,
    _ => TransactionType.expense,
  };

  void _changePurpose(
    TransactionPurpose purpose,
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  ) {
    if (_selectedPurpose == purpose) return;
    final type = _typeForPurpose(purpose);
    setState(() {
      _selectedPurpose = purpose;
      _selectedLoan = null;
      _selectedMoneyRecord = null;
      _selectedInvestment = null;
      _counterpartyController.clear();
      _principalController.clear();
      _interestController.clear();
      _feeController.clear();
      if (purpose != TransactionPurpose.internalTransfer) {
        _selectedToAccount = null;
      }
    });
    _changeType(type, categories, accounts, history);
  }

  Future<void> _selectLoan(Loan? loan) async {
    setState(() => _selectedLoan = loan);
    if (loan == null) {
      _principalController.clear();
      _interestController.clear();
      _feeController.clear();
      return;
    }
    final payments = await ref
        .read(loanRepositoryProvider)
        .getPaymentsForLoan(loan.id);
    if (!mounted) return;
    final unpaid =
        LoanCalculator.generateSchedule(
          loan,
          payments: payments,
        ).where((item) => !item.isPaid).toList();
    if (unpaid.isEmpty) return;
    final item = unpaid.first;
    setState(() {
      _amountController.text = item.emiAmount.toStringAsFixed(2);
      _principalController.text = item.principalPaid.toStringAsFixed(2);
      _interestController.text = item.interestPaid.toStringAsFixed(2);
      _feeController.text = '0.00';
      _merchantController.text = loan.name;
      _counterpartyController.text = loan.lender;
      _selectedAccount ??=
          (ref.read(rawAccountsStreamProvider).value ?? const <Account>[])
              .where((account) => account.id == loan.accountId)
              .firstOrNull;
    });
  }

  Future<void> _showCategoryPicker(List<Category> categories) async {
    final chosen = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CategoryPickerSheet(
            categories: categories,
            selected: _selectedCategory,
          ),
    );
    if (chosen != null && mounted) {
      setState(() {
        _selectedCategory = chosen;
        _categoryError = null;
      });
    }
  }

  Future<void> _showAccountPicker({
    required List<Account> accounts,
    required bool isDestination,
  }) async {
    final available =
        isDestination && _selectedAccount != null
            ? accounts.where((a) => a.id != _selectedAccount!.id).toList()
            : accounts;

    final chosen = await showModalBottomSheet<Account>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AccountPickerSheet(
            title:
                isDestination
                    ? 'Choose destination account'
                    : 'Choose source account',
            accounts: available,
            selected: isDestination ? _selectedToAccount : _selectedAccount,
          ),
    );

    if (chosen != null && mounted) {
      setState(() {
        if (isDestination) {
          _selectedToAccount = chosen;
          _toAccountError = null;
        } else {
          _selectedAccount = chosen;
          _accountError = null;
          if (_selectedToAccount?.id == chosen.id) {
            _selectedToAccount = null;
          }
        }
      });
    }
  }

  void _setDate(DateTime date) =>
      setState(() => _selectedDate = DateTime(date.year, date.month, date.day));

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusXl),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) _setDate(picked);
  }

  void _swapTransferAccounts() {
    if (_selectedAccount == null && _selectedToAccount == null) return;
    setState(() {
      final temp = _selectedAccount;
      _selectedAccount = _selectedToAccount;
      _selectedToAccount = temp;
      _accountError = null;
      _toAccountError = null;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _amountError = null;
      _merchantError = null;
      _categoryError = null;
      _accountError = null;
      _toAccountError = null;
    });

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(
        () => _amountError = 'Please enter an amount greater than zero.',
      );
      return;
    }

    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      setState(
        () =>
            _merchantError = switch (_selectedType) {
              TransactionType.transfer =>
                'Enter a transfer reference or recipient.',
              TransactionType.income => 'Enter a payer or source.',
              TransactionType.investment =>
                'Enter the investment name or platform.',
              TransactionType.loanEmi => 'Enter the lender or loan name.',
              _ => 'Payee / Merchant name is required.',
            },
      );
      return;
    }

    if (_selectedAccount == null) {
      setState(() => _accountError = 'Please select an account.');
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      if (_selectedToAccount == null) {
        setState(
          () => _toAccountError = 'Please select a destination account.',
        );
        return;
      }
      if (_selectedAccount!.id == _selectedToAccount!.id) {
        setState(
          () =>
              _toAccountError = 'Source and destination accounts must differ.',
        );
        return;
      }
    }

    if ((_selectedPurpose == TransactionPurpose.lending ||
            _selectedPurpose == TransactionPurpose.borrowing ||
            _selectedPurpose == TransactionPurpose.loanDisbursement) &&
        _counterpartyController.text.trim().isEmpty) {
      setState(() => _merchantError = 'Enter the external person or lender.');
      return;
    }
    if (<TransactionPurpose>{
          TransactionPurpose.personalDebtRepaymentMade,
          TransactionPurpose.personalDebtRepaymentReceived,
        }.contains(_selectedPurpose) &&
        _selectedMoneyRecord == null) {
      setState(() => _merchantError = 'Select the debt record being repaid.');
      return;
    }

    if (_needsCategory && _selectedCategory == null) {
      setState(() => _categoryError = 'Please select a category.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final txId = widget.initialTransaction?.id ?? const Uuid().v4();
      final createsDebt = <TransactionPurpose>{
        TransactionPurpose.lending,
        TransactionPurpose.borrowing,
      }.contains(_selectedPurpose);

      String? debtRecordId;
      MoneyRecord? debtDetails;
      if (createsDebt) {
        final counterparty = _counterpartyController.text.trim();
        final normalizedCounterparty = MoneyRecord.normalizePersonName(
          counterparty.isNotEmpty ? counterparty : merchant,
        );
        final debtType =
            _selectedPurpose == TransactionPurpose.lending
                ? MoneyRecordType.lent
                : MoneyRecordType.borrowed;
        final allDebts =
            ref.read(allMoneyRecordsStreamProvider).valueOrNull ??
            const <MoneyRecord>[];
        final matchingDebt =
            allDebts
                .where(
                  (d) =>
                      d.type == debtType &&
                      d.settledAt == null &&
                      !d.isCustomSeparateObligation &&
                      d.normalizedPersonName == normalizedCounterparty,
                )
                .firstOrNull;

        if (_createAsSeparateDebt) {
          debtRecordId =
              widget.initialTransaction?.linkedMoneyRecordId ?? 'debt_$txId';
          debtDetails = MoneyRecord(
            id: debtRecordId,
            type: debtType,
            personName: counterparty.isNotEmpty ? counterparty : merchant,
            originalAmount: amount,
            transactionDate: _selectedDate,
            dueDate:
                _debtDueDate ?? _selectedDate.add(const Duration(days: 30)),
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
            createdAt: now,
            updatedAt: now,
            isCustomSeparateObligation: true,
            originTransactionId: txId,
          );
        } else {
          debtRecordId =
              _selectedMoneyRecord?.id ??
              matchingDebt?.id ??
              widget.initialTransaction?.linkedMoneyRecordId;
          debtDetails = MoneyRecord(
            id: debtRecordId ?? 'debt_$txId',
            type: debtType,
            personName: counterparty.isNotEmpty ? counterparty : merchant,
            originalAmount: amount,
            transactionDate: _selectedDate,
            dueDate:
                _debtDueDate ?? _selectedDate.add(const Duration(days: 30)),
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
            createdAt: now,
            updatedAt: now,
            originTransactionId: txId,
          );
        }
      }

      final tx = Transaction(
        id: txId,
        amount: amount,
        type: _selectedType,
        purpose: _selectedPurpose,
        categoryId: _selectedCategory?.id ?? 'cat_transfer',
        categoryName: _selectedCategory?.name ?? 'Transfer',
        categoryIcon: _selectedCategory?.iconIdentifier ?? 'sync',
        categoryColor: _selectedCategory?.colorTokenIdentifier ?? 'slate',
        merchant: merchant,
        normalizedMerchant: MerchantNormalizationService.normalize(merchant),
        date: _selectedDate,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        source: widget.initialTransaction?.source ?? TransactionSource.manual,
        paymentMethod: _selectedPaymentMethod,
        accountId: _selectedAccount!.id,
        toAccountId:
            _selectedPurpose == TransactionPurpose.internalTransfer
                ? _selectedToAccount?.id
                : null,
        externalCounterpartyName:
            _counterpartyController.text.trim().isEmpty
                ? _selectedMoneyRecord?.personName
                : _counterpartyController.text.trim(),
        linkedLoanId:
            _selectedPurpose == TransactionPurpose.loanRepayment
                ? _selectedLoan?.id
                : null,
        linkedMoneyRecordId:
            createsDebt ? debtRecordId : _selectedMoneyRecord?.id,
        linkedInvestmentId:
            <TransactionPurpose>{
                  TransactionPurpose.investmentPurchase,
                  TransactionPurpose.investmentRedemption,
                }.contains(_selectedPurpose)
                ? _selectedInvestment?.id
                : null,
        principalComponent:
            _selectedLoan == null && _selectedInvestment == null
                ? null
                : CurrencyFormatter.parse(_principalController.text),
        interestComponent:
            _selectedLoan == null && _selectedInvestment == null
                ? null
                : CurrencyFormatter.parse(_interestController.text),
        feeComponent:
            _selectedLoan == null && _selectedInvestment == null
                ? null
                : CurrencyFormatter.parse(_feeController.text),
        tags:
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
        isReviewed: true,
        createdAt: widget.initialTransaction?.createdAt ?? now,
        updatedAt: now,
        originalMerchant: widget.initialTransaction?.originalMerchant,
        sourceName: widget.initialTransaction?.sourceName,
        sourceReference: widget.initialTransaction?.sourceReference,
        sourceMessageId: widget.initialTransaction?.sourceMessageId,
        fingerprint: widget.initialTransaction?.fingerprint,
        duplicateGroupId: widget.initialTransaction?.duplicateGroupId,
        mergedSources: widget.initialTransaction?.mergedSources ?? const [],
        importedAt: widget.initialTransaction?.importedAt,
        detectedAt: widget.initialTransaction?.detectedAt,
        reviewStatus: widget.initialTransaction?.reviewStatus ?? 'confirmed',
        categorizationConfidence:
            widget.initialTransaction?.categorizationConfidence,
      );

      tx.validate();
      if (widget.onSave != null) {
        await widget.onSave!(tx);
      } else {
        await ref
            .read(transactionsControllerProvider.notifier)
            .saveTransaction(tx, moneyRecordDetails: debtDetails);
      }

      if (_selectedCategory != null && _needsCategory) {
        CategorizationService.recordUserChoice(
          rawMerchant: merchant,
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.iconIdentifier,
          categoryColor: _selectedCategory!.colorTokenIdentifier,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(
          context,
          message:
              widget.onSave != null
                  ? 'Pending transaction updated on this device.'
                  : widget.initialTransaction == null
                  ? 'Saved on this device.'
                  : 'Transaction updated on this device.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        FfSnackbar.show(context, message: 'Could not save transaction: $e');
      }
    }
  }

  Color _typeColor(BuildContext context, TransactionType type) {
    final finColors = context.theme.extension<FfFinColors>();
    return switch (type) {
      TransactionType.expense =>
        finColors?.expense ?? StillwaterColors.lightExpense,
      TransactionType.income =>
        finColors?.income ?? StillwaterColors.lightIncome,
      TransactionType.transfer =>
        finColors?.transfer ?? StillwaterColors.lightTransfer,
      TransactionType.investment =>
        finColors?.investment ?? StillwaterColors.lightInvestment,
      TransactionType.loanEmi => finColors?.debt ?? StillwaterColors.lightDebt,
      TransactionType.cash =>
        finColors?.savings ?? StillwaterColors.lightSavings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts =
        ref
            .watch(rawAccountsStreamProvider)
            .value
            ?.where((a) => !a.isArchived)
            .toList() ??
        [];
    final history = ref.watch(allTransactionsStreamProvider).value ?? [];

    _applyDefaults(categories, accounts, history);

    if (widget.initialTransaction != null) {
      _selectedAccount ??=
          accounts
              .where((a) => a.id == widget.initialTransaction!.accountId)
              .firstOrNull;
      _selectedToAccount ??=
          accounts
              .where((a) => a.id == widget.initialTransaction!.toAccountId)
              .firstOrNull;
      _selectedCategory ??=
          categories
              .where((c) => c.id == widget.initialTransaction!.categoryId)
              .firstOrNull;
    }

    final categoriesForType = _prioritizedCategories(categories, history);
    final payeeSuggestions = PayeeSuggestionService.getSuggestions(
      transactions: history,
      type: _selectedType,
      categoryId: _selectedCategory?.id,
      query: _merchantController.text,
      limit: 6,
    );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final surfaceColor =
        isDark
            ? StillwaterColors.darkSurfaceDefault
            : StillwaterColors.lightSurfaceDefault;
    final activeTypeColor = _typeColor(context, _selectedType);

    final saveButtonText =
        widget.saveLabel ??
        (widget.initialTransaction == null
            ? 'Save ${_selectedPurpose.displayName}'
            : 'Update ${_selectedPurpose.displayName}');

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.50,
        maxChildSize: 0.98,
        expand: false,
        builder:
            (context, scrollController) => Material(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(StillwaterTokens.radius2Xl),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // 1. Drag handle & Header
                    _buildHeader(context),
                    const Divider(height: 1, thickness: 1),

                    // 2. Scrollable Body Form
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          StillwaterTokens.spaceLg,
                          StillwaterTokens.spaceSm,
                          StillwaterTokens.spaceLg,
                          StillwaterTokens.spaceXl,
                        ),
                        children: [
                          if (widget.sourceContext != null) ...[
                            widget.sourceContext!,
                            const SizedBox(height: StillwaterTokens.spaceMd),
                          ],
                          // Transaction Type Selector Bar
                          _buildTypeSelector(
                            categories: categories,
                            accounts: accounts,
                            history: history,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceLg),

                          // Hero Amount Input Card
                          _buildHeroAmountField(activeTypeColor),
                          const SizedBox(height: StillwaterTokens.spaceLg),

                          // Merchant / Payee Field
                          _buildMerchantField(
                            suggestions: payeeSuggestions,
                            categories: categories,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceLg),

                          _buildPurposeFields(),
                          if (_selectedPurpose != TransactionPurpose.expense &&
                              _selectedPurpose != TransactionPurpose.income &&
                              _selectedPurpose !=
                                  TransactionPurpose.internalTransfer)
                            const SizedBox(height: StillwaterTokens.spaceLg),

                          // Category Section (if applicable)
                          if (_needsCategory) ...[
                            _buildCategorySection(categoriesForType),
                            const SizedBox(height: StillwaterTokens.spaceLg),
                          ],

                          // Account Section (Single or Directional Transfer)
                          _buildAccountSection(accounts),
                          const SizedBox(height: StillwaterTokens.spaceLg),

                          // Quick Date Selector
                          _buildDateSection(),
                          const SizedBox(height: StillwaterTokens.spaceLg),

                          // Progressive Disclosure: Expandable More Details
                          _buildMoreDetailsSection(),

                          // Bottom spacing for keyboard / safe area
                          SizedBox(height: StillwaterTokens.spaceMd),
                        ],
                      ),
                    ),

                    // 3. Sticky Action Bar
                    _buildStickyActionBar(saveButtonText, bottomInset),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FfSheetHeader(
      title:
          widget.headerTitle ??
          (widget.initialTransaction == null
              ? 'Add Transaction'
              : 'Edit Transaction'),
      padding: const EdgeInsets.fromLTRB(
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceSm,
        StillwaterTokens.spaceSm,
        StillwaterTokens.spaceXs,
      ),
      onClose: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTypeSelector({
    required List<Category> categories,
    required List<Account> accounts,
    required List<Transaction> history,
  }) {
    final incoming = <TransactionPurpose>{
      TransactionPurpose.income,
      TransactionPurpose.borrowing,
      TransactionPurpose.personalDebtRepaymentReceived,
      TransactionPurpose.loanDisbursement,
      TransactionPurpose.investmentRedemption,
    };
    final intent =
        _selectedPurpose == TransactionPurpose.internalTransfer
            ? 'Move Money'
            : incoming.contains(_selectedPurpose)
            ? 'Money In'
            : 'Money Out';
    final purposes = switch (intent) {
      'Money In' => const [
        TransactionPurpose.income,
        TransactionPurpose.borrowing,
        TransactionPurpose.personalDebtRepaymentReceived,
        TransactionPurpose.loanDisbursement,
        TransactionPurpose.investmentRedemption,
      ],
      'Move Money' => const [TransactionPurpose.internalTransfer],
      _ => const [
        TransactionPurpose.expense,
        TransactionPurpose.lending,
        TransactionPurpose.personalDebtRepaymentMade,
        TransactionPurpose.loanRepayment,
        TransactionPurpose.investmentPurchase,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are you doing?', style: context.theme.textTheme.labelLarge),
        const SizedBox(height: StillwaterTokens.spaceXs),
        Wrap(
          spacing: StillwaterTokens.spaceXs,
          children:
              ['Money Out', 'Money In', 'Move Money'].map((label) {
                return ChoiceChip(
                  label: Text(label),
                  selected: intent == label,
                  onSelected: (_) {
                    final purpose = switch (label) {
                      'Money In' => TransactionPurpose.income,
                      'Move Money' => TransactionPurpose.internalTransfer,
                      _ => TransactionPurpose.expense,
                    };
                    _changePurpose(purpose, categories, accounts, history);
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: StillwaterTokens.spaceSm),
        DropdownButtonFormField<TransactionPurpose>(
          key: ValueKey(intent),
          value:
              purposes.contains(_selectedPurpose)
                  ? _selectedPurpose
                  : purposes.first,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Purpose'),
          items:
              purposes
                  .map(
                    (purpose) => DropdownMenuItem(
                      value: purpose,
                      child: Text(purpose.displayName),
                    ),
                  )
                  .toList(),
          onChanged: (purpose) {
            if (purpose != null) {
              _changePurpose(purpose, categories, accounts, history);
            }
          },
        ),
        if (_selectedPurpose == TransactionPurpose.internalTransfer) ...[
          const SizedBox(height: StillwaterTokens.spaceXs),
          Text(
            'Move money between accounts you own. This is not income or spending.',
            style: context.theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildHeroAmountField(Color activeTypeColor) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Amount', style: theme.textTheme.labelLarge),
            if (_amountController.text.isNotEmpty)
              InkWell(
                onTap: () => setState(() => _amountController.clear()),
                child: Text(
                  'Clear',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: StillwaterTokens.space2Xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceMd,
            vertical: StillwaterTokens.spaceSm,
          ),
          decoration: BoxDecoration(
            color:
                isDark
                    ? StillwaterColors.darkSurfaceContainerLow
                    : StillwaterColors.lightSurfaceContainerLow,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color:
                  _amountError != null
                      ? theme.colorScheme.error
                      : (isDark
                          ? StillwaterColors.darkBorderDefault
                          : StillwaterColors.lightBorderDefault),
              width:
                  _amountError != null
                      ? StillwaterTokens.borderWidthFocus
                      : StillwaterTokens.borderWidthDefault,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹ ',
                style: StillwaterTypography.numHero(
                  color: activeTypeColor,
                ).copyWith(fontSize: 32),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  autofocus: widget.initialTransaction == null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: StillwaterTypography.numHero(
                    color: theme.colorScheme.onSurface,
                  ).copyWith(fontSize: 32),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                ),
              ),
              if (_amountController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Clear amount',
                  icon: const Icon(Icons.backspace_outlined, size: 20),
                  onPressed: () {
                    final text = _amountController.text;
                    if (text.isNotEmpty) {
                      setState(() {
                        _amountController.text = text.substring(
                          0,
                          text.length - 1,
                        );
                        _amountController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                      });
                    }
                  },
                ),
            ],
          ),
        ),
        if (_amountError != null) ...[
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            _amountError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPurposeFields() {
    if (_selectedPurpose == TransactionPurpose.loanRepayment) {
      final loans =
          (ref.watch(allLoansStreamProvider).valueOrNull ?? const <Loan>[])
              .where((loan) => loan.status == LoanStatus.active)
              .toList();
      if (_selectedLoan == null &&
          widget.initialTransaction?.linkedLoanId != null) {
        _selectedLoan =
            loans
                .where(
                  (loan) => loan.id == widget.initialTransaction!.linkedLoanId,
                )
                .firstOrNull;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedLoan?.id ?? 'unlinked',
            decoration: const InputDecoration(labelText: 'Tracked loan'),
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
            onChanged:
                (id) => _selectLoan(
                  loans.where((loan) => loan.id == id).firstOrNull,
                ),
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Text(
            _selectedLoan == null
                ? 'This payment will affect the account, but will not update a loan schedule.'
                : 'Expected EMI ${CurrencyFormatter.formatINR(_selectedLoan!.emiAmount)} · Outstanding ${CurrencyFormatter.formatINR(_selectedLoan!.outstandingPrincipal)} · Due ${DateFormat.yMMMd().format(_selectedLoan!.nextDueDate)}',
            style: context.theme.textTheme.bodySmall,
          ),
          if (_selectedLoan != null) ...[
            const SizedBox(height: StillwaterTokens.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _componentField(_principalController, 'Principal'),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(
                  child: _componentField(_interestController, 'Interest'),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(child: _componentField(_feeController, 'Fees')),
              ],
            ),
          ],
        ],
      );
    }

    if (_selectedPurpose == TransactionPurpose.investmentPurchase ||
        _selectedPurpose == TransactionPurpose.investmentRedemption) {
      final investments =
          ref.watch(allInvestmentsStreamProvider).valueOrNull ??
          const <Investment>[];
      if (_selectedInvestment == null &&
          widget.initialTransaction?.linkedInvestmentId != null) {
        _selectedInvestment =
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
          DropdownButtonFormField<String>(
            value: _selectedInvestment?.id ?? 'unlinked',
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Investment asset'),
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
            onChanged:
                (id) => setState(() {
                  _selectedInvestment =
                      investments
                          .where((investment) => investment.id == id)
                          .firstOrNull;
                  if (_selectedInvestment != null) {
                    _merchantController.text = _selectedInvestment!.name;
                    final amount =
                        CurrencyFormatter.parse(_amountController.text) ?? 0;
                    _principalController.text = amount.toStringAsFixed(2);
                    _interestController.text = '0.00';
                    _feeController.text = '0.00';
                  }
                }),
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: _componentField(
                  _principalController,
                  _selectedPurpose == TransactionPurpose.investmentRedemption
                      ? 'Cost basis'
                      : 'Asset value',
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              if (_selectedPurpose ==
                  TransactionPurpose.investmentRedemption) ...[
                Expanded(
                  child: _componentField(_interestController, 'Realized gain'),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
              ],
              Expanded(child: _componentField(_feeController, 'Fees')),
            ],
          ),
        ],
      );
    }

    final isRepayment = <TransactionPurpose>{
      TransactionPurpose.personalDebtRepaymentMade,
      TransactionPurpose.personalDebtRepaymentReceived,
    }.contains(_selectedPurpose);
    if (isRepayment) {
      final records =
          ref.watch(allMoneyRecordsStreamProvider).valueOrNull ??
          const <MoneyRecord>[];
      final expectedType =
          _selectedPurpose == TransactionPurpose.personalDebtRepaymentReceived
              ? MoneyRecordType.lent
              : MoneyRecordType.borrowed;
      final eligible =
          records
              .where(
                (record) =>
                    record.type == expectedType && record.settledAt == null,
              )
              .toList();
      if (_selectedMoneyRecord == null &&
          widget.initialTransaction?.linkedMoneyRecordId != null) {
        _selectedMoneyRecord =
            eligible
                .where(
                  (record) =>
                      record.id ==
                      widget.initialTransaction!.linkedMoneyRecordId,
                )
                .firstOrNull;
      }
      return DropdownButtonFormField<String>(
        value: _selectedMoneyRecord?.id,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Debt record'),
        hint: const Text('Select person and balance'),
        items:
            eligible
                .map(
                  (record) => DropdownMenuItem(
                    value: record.id,
                    child: Text(
                      '${record.personName} · ${CurrencyFormatter.formatINR(record.originalAmount)}',
                    ),
                  ),
                )
                .toList(),
        onChanged:
            (id) => setState(() {
              _selectedMoneyRecord =
                  eligible.where((record) => record.id == id).firstOrNull;
              _counterpartyController.text =
                  _selectedMoneyRecord?.personName ?? '';
            }),
      );
    }

    if (_selectedPurpose == TransactionPurpose.lending ||
        _selectedPurpose == TransactionPurpose.borrowing) {
      final theme = Theme.of(context);
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
          _selectedPurpose == TransactionPurpose.lending
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

      final typedName = _counterpartyController.text.trim();
      final normalizedTyped = MoneyRecord.normalizePersonName(typedName);
      final matchingRecord =
          _selectedMoneyRecord ??
          eligible
              .where((r) => r.normalizedPersonName == normalizedTyped)
              .firstOrNull;

      final currentAmount =
          CurrencyFormatter.parse(_amountController.text) ?? 0.0;
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
            initialValue: TextEditingValue(text: _counterpartyController.text),
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
              _counterpartyController.text = selection;
              final found =
                  eligible
                      .where(
                        (r) =>
                            r.normalizedPersonName ==
                            MoneyRecord.normalizePersonName(selection),
                      )
                      .firstOrNull;
              setState(() {
                _selectedMoneyRecord = found;
              });
            },
            fieldViewBuilder: (
              context,
              textEditingController,
              focusNode,
              onFieldSubmitted,
            ) {
              if (_counterpartyController.text != textEditingController.text &&
                  textEditingController.text.isEmpty) {
                textEditingController.text = _counterpartyController.text;
              }
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Person / counterparty',
                  helperText:
                      'Repeated advances to the same person combine into one active balance.',
                  suffixIcon:
                      matchingRecord != null
                          ? const Icon(
                            Icons.check_circle_rounded,
                            color: StillwaterColors.lightIncome,
                            size: 20,
                          )
                          : null,
                ),
                onChanged: (val) {
                  _counterpartyController.text = val;
                  final found =
                      eligible
                          .where(
                            (r) =>
                                r.normalizedPersonName ==
                                MoneyRecord.normalizePersonName(val),
                          )
                          .firstOrNull;
                  if (found?.id != _selectedMoneyRecord?.id) {
                    setState(() {
                      _selectedMoneyRecord = found;
                    });
                  }
                },
              );
            },
          ),
          if (matchingRecord != null) ...[
            const SizedBox(height: StillwaterTokens.spaceSm),
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(
                  StillwaterTokens.radiusMd,
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: StillwaterColors.lightPrimary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Expanded(
                        child: Text(
                          _createAsSeparateDebt
                              ? 'Separate debt for ${matchingRecord.personName}'
                              : 'Adding to ${matchingRecord.personName}\'s active balance',
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: StillwaterColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _createAsSeparateDebt
                        ? 'This advance will be tracked as its own separate obligation card.'
                        : 'Current balance: ${CurrencyFormatter.formatINR(existingRemaining)} → New balance: ${CurrencyFormatter.formatINR(newTotal)}',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: StillwaterColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceXs),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _createAsSeparateDebt,
                          onChanged: (val) {
                            setState(() {
                              _createAsSeparateDebt = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _createAsSeparateDebt = !_createAsSeparateDebt;
                          });
                        },
                        child: Text(
                          'Create as separate debt record',
                          style: context.theme.textTheme.bodySmall?.copyWith(
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
          const SizedBox(height: StillwaterTokens.spaceSm),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _debtDueDate ??
                    _selectedDate.add(const Duration(days: 30)),
                firstDate: _selectedDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _debtDueDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Expected repayment date',
                suffixIcon: Icon(Icons.event_outlined),
              ),
              child: Text(
                DateFormat.yMMMd().format(
                  _debtDueDate ??
                      _selectedDate.add(const Duration(days: 30)),
                ),
                style: context.theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      );
    }

    if (_needsCounterparty) {
      return TextFormField(
        controller: _counterpartyController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Person / counterparty',
          helperText: 'A person is kept separate from accounts you own.',
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _componentField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(labelText: label, prefixText: '₹ '),
    );
  }

  Widget _buildMerchantField({
    required List<PayeeSuggestion> suggestions,
    required List<Category> categories,
  }) {
    final theme = context.theme;

    final label = switch (_selectedType) {
      TransactionType.income => 'Payer / Source',
      TransactionType.transfer => 'Transfer Reference / Recipient',
      TransactionType.investment => 'Asset / Platform',
      TransactionType.loanEmi => 'Lender / Loan Name',
      _ => 'Payee / Merchant',
    };

    final hint = switch (_selectedType) {
      TransactionType.income => 'e.g. Employer, Client, Refund',
      TransactionType.transfer => 'e.g. Move to savings, Shared bill',
      TransactionType.investment => 'e.g. Zerodha, Parag Parikh Flexi Cap',
      TransactionType.loanEmi => 'e.g. HDFC Home Loan, Car EMI',
      _ => 'e.g. Swiggy, Amazon, Groceries',
    };

    final prefixIcon = switch (_selectedType) {
      TransactionType.income => Icons.account_circle_outlined,
      TransactionType.transfer => Icons.swap_horiz_rounded,
      TransactionType.investment => Icons.trending_up_rounded,
      TransactionType.loanEmi => Icons.receipt_long_rounded,
      _ => Icons.storefront_outlined,
    };

    final typedText = _merchantController.text.trim().toLowerCase();
    final visibleSuggestions =
        typedText.isEmpty
            ? suggestions
            : suggestions
                .where((s) => s.displayName.toLowerCase() != typedText)
                .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _merchantController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: _merchantError,
            prefixIcon: Icon(prefixIcon),
            suffixIcon:
                _merchantController.text.isEmpty
                    ? null
                    : IconButton(
                      tooltip: 'Clear payee',
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _merchantController.clear();
                        setState(() => _merchantError = null);
                      },
                    ),
          ),
          onChanged: (text) {
            if (_merchantError != null) {
              setState(() => _merchantError = null);
            }
          },
        ),

        // Context-aware Payee suggestions chips
        if (visibleSuggestions.isNotEmpty) ...[
          const SizedBox(height: StillwaterTokens.spaceXs),
          Wrap(
            spacing: StillwaterTokens.spaceXs,
            runSpacing: StillwaterTokens.space2Xs,
            children:
                visibleSuggestions
                    .map(
                      (suggestion) => ActionChip(
                        avatar: const Icon(Icons.history_rounded, size: 14),
                        label: Text(
                          suggestion.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () {
                          _merchantController.text = suggestion.displayName;
                          _merchantController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: suggestion.displayName.length),
                          );
                          if (_needsCategory &&
                              _selectedCategory == null &&
                              suggestion.primaryCategoryId != null) {
                            final match =
                                categories
                                    .where(
                                      (c) =>
                                          c.id == suggestion.primaryCategoryId,
                                    )
                                    .firstOrNull;
                            if (match != null) {
                              setState(() {
                                _selectedCategory = match;
                                _categoryError = null;
                              });
                            }
                          }
                          if (_merchantError != null) {
                            setState(() => _merchantError = null);
                          }
                        },
                      ),
                    )
                    .toList(),
          ),
        ],

        // Offline Categorization Suggestion Banner / Pill
        if (_suggestedCategory != null && _needsCategory) ...[
          const SizedBox(height: StillwaterTokens.spaceXs),
          InkWell(
            onTap: () {
              final categories = ref.read(categoriesStreamProvider).value ?? [];
              final match =
                  categories
                      .where((c) => c.id == _suggestedCategory!.categoryId)
                      .firstOrNull;
              if (match != null) {
                setState(() {
                  _selectedCategory = match;
                  _categoryError = null;
                });
              }
            },
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: StillwaterTokens.borderWidthDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Expanded(
                    child: Text(
                      'Suggested: ${_suggestedCategory!.categoryName} • ${_suggestedCategory!.reason}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    'Apply',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategorySection(List<Category> categoriesForType) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: StillwaterTokens.spaceSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Category', style: theme.textTheme.labelLarge),
            TextButton.icon(
              onPressed: () => _showCategoryPicker(categoriesForType),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('All Categories'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: StillwaterTokens.space2Xs),

        // Horizontal Category Chip Bar
        if (categoriesForType.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categoriesForType.take(7).length,
              separatorBuilder:
                  (_, _) => const SizedBox(width: StillwaterTokens.spaceXs),
              itemBuilder: (context, index) {
                final cat = categoriesForType[index];
                final isSelected = cat.id == _selectedCategory?.id;

                return ChoiceChip(
                  avatar: FfCategoryTile(
                    iconIdentifier: cat.iconIdentifier,
                    colorTokenIdentifier: cat.colorTokenIdentifier,
                    size: 24,
                  ),
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _categoryError = null;
                    });
                  },
                );
              },
            ),
          ),

        if (_categoryError != null) ...[
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            _categoryError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSection(List<Account> accounts) {
    final theme = context.theme;

    if (_selectedType == TransactionType.transfer) {
      // Transfer Mode: Source -> Destination Account Selectors
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Accounts', style: theme.textTheme.labelLarge),
              IconButton(
                tooltip: 'Swap accounts',
                icon: const Icon(Icons.swap_vert_rounded, size: 20),
                onPressed: _swapTransferAccounts,
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text('From Account', style: theme.textTheme.labelSmall),
          const SizedBox(height: StillwaterTokens.space2Xs),
          _AccountTileButton(
            label: 'From Account',
            account: _selectedAccount,
            error: _accountError,
            icon: Icons.upload_rounded,
            onTap:
                () => _showAccountPicker(
                  accounts: accounts,
                  isDestination: false,
                ),
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Text('To Account', style: theme.textTheme.labelSmall),
          const SizedBox(height: StillwaterTokens.space2Xs),
          _AccountTileButton(
            label: 'To Account',
            account: _selectedToAccount,
            error: _toAccountError,
            icon: Icons.download_rounded,
            onTap:
                () =>
                    _showAccountPicker(accounts: accounts, isDestination: true),
          ),
        ],
      );
    }

    // Normal Mode: Single Account Selector
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: theme.textTheme.labelLarge),
        const SizedBox(height: StillwaterTokens.space2Xs),
        _AccountTileButton(
          label: 'Account',
          account: _selectedAccount,
          error: _accountError,
          icon: Icons.account_balance_wallet_outlined,
          onTap:
              () =>
                  _showAccountPicker(accounts: accounts, isDestination: false),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final theme = context.theme;
    final now = DateTime.now();
    final isToday = _sameDay(_selectedDate, now);
    final isYesterday = _sameDay(
      _selectedDate,
      now.subtract(const Duration(days: 1)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: theme.textTheme.labelLarge),
        const SizedBox(height: StillwaterTokens.space2Xs),
        Wrap(
          spacing: StillwaterTokens.spaceXs,
          runSpacing: StillwaterTokens.spaceXs,
          children: [
            ChoiceChip(
              label: const Text('Today'),
              selected: isToday,
              onSelected: (_) => _setDate(now),
            ),
            const SizedBox(width: StillwaterTokens.spaceXs),
            ChoiceChip(
              label: const Text('Yesterday'),
              selected: isYesterday,
              onSelected:
                  (_) => _setDate(now.subtract(const Duration(days: 1))),
            ),
            const SizedBox(width: StillwaterTokens.spaceXs),
            ActionChip(
              avatar: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(
                DateFormat('d MMM yyyy').format(_selectedDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: _pickCustomDate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreDetailsSection() {
    final theme = context.theme;
    final hasActiveDetails =
        _notesController.text.isNotEmpty || _tagsController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _moreDetailsOpen,
          onExpansionChanged: (open) => setState(() => _moreDetailsOpen = open),
          leading: Icon(
            Icons.tune_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'More details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            hasActiveDetails
                ? 'Payment method, notes & tags (Active)'
                : 'Payment method, note, tags',
            style: theme.textTheme.bodySmall,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceMd,
            0,
            StillwaterTokens.spaceMd,
            StillwaterTokens.spaceMd,
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: StillwaterTokens.spaceMd),

            // Payment Method Selector
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              items:
                  {..._paymentMethods, _selectedPaymentMethod}
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPaymentMethod = val);
                }
              },
            ),
            const SizedBox(height: StillwaterTokens.spaceMd),

            // Notes Input
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Invoice number, reimbursement notes, or context',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceMd),

            // Tags Input
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'e.g. trip, office, reimbursement (comma-separated)',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Future capabilities disclosure
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: StillwaterTokens.space2Xs),
                Expanded(
                  child: Text(
                    'Recurring schedules and split transactions will be saved when fully configured.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyActionBar(String label, double bottomInset) {
    return FfSheetFooter(
      primaryLabel: label,
      isPrimaryLoading: _isSubmitting,
      onPrimaryPressed: _isSubmitting ? null : _submit,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// A compact, rich tile button for selecting an Account.
class _AccountTileButton extends StatelessWidget {
  final String label;
  final Account? account;
  final String? error;
  final IconData icon;
  final VoidCallback onTap;

  const _AccountTileButton({
    required this.label,
    required this.account,
    required this.icon,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceMd,
              vertical: StillwaterTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
              border: Border.all(
                color:
                    error != null
                        ? theme.colorScheme.error
                        : (isDark
                            ? StillwaterColors.darkBorderDefault
                            : StillwaterColors.lightBorderDefault),
                width:
                    error != null
                        ? StillwaterTokens.borderWidthFocus
                        : StillwaterTokens.borderWidthDefault,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    account == null ? icon : _accountIcon(account!.type),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child:
                      account == null
                          ? Text(
                            'Select $label',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account!.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${account!.displaySubtitle} • ${CurrencyFormatter.formatINR(account!.currentBalance)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                ),
                const Icon(Icons.expand_more_rounded, size: 20),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  IconData _accountIcon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.upi => Icons.account_balance_wallet_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    _ => Icons.account_balance_outlined,
  };
}

/// Refined category selection bottom sheet with instant search.
class _CategoryPickerSheet extends StatefulWidget {
  final List<Category> categories;
  final Category? selected;

  const _CategoryPickerSheet({
    required this.categories,
    required this.selected,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final filtered =
        widget.categories
            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Material(
      color:
          isDark
              ? StillwaterColors.darkSurfaceDefault
              : StillwaterColors.lightSurfaceDefault,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(StillwaterTokens.radius2Xl),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: 'Choose Category',
                padding: EdgeInsets.zero,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: StillwaterTokens.spaceSm),
              TextField(
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search categories...',
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.45,
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Text(
                            'No matching category found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final category = filtered[index];
                            final isSelected =
                                category.id == widget.selected?.id;

                            return ListTile(
                              leading: FfCategoryTile(
                                iconIdentifier: category.iconIdentifier,
                                colorTokenIdentifier:
                                    category.colorTokenIdentifier,
                              ),
                              title: Text(
                                category.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check_circle_rounded,
                                        color: theme.colorScheme.primary,
                                      )
                                      : null,
                              onTap: () => Navigator.pop(context, category),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Refined account selection bottom sheet with balance display.
class _AccountPickerSheet extends StatelessWidget {
  final String title;
  final List<Account> accounts;
  final Account? selected;

  const _AccountPickerSheet({
    required this.title,
    required this.accounts,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color:
          isDark
              ? StillwaterColors.darkSurfaceDefault
              : StillwaterColors.lightSurfaceDefault,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(StillwaterTokens.radius2Xl),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: title,
                padding: EdgeInsets.zero,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: StillwaterTokens.spaceSm),
              if (accounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                  child: Text('No eligible account available.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isSelected = account.id == selected?.id;

                      return ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _icon(account.type),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          account.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${account.displaySubtitle} • ${CurrencyFormatter.formatINR(account.currentBalance)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                )
                                : null,
                        onTap: () => Navigator.pop(context, account),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.upi => Icons.account_balance_wallet_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    _ => Icons.account_balance_outlined,
  };
}
