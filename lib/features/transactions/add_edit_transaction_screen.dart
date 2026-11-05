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
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/categorization_service.dart';
import '../../services/default_account_service.dart';
import '../../services/merchant_normalization_service.dart';
import '../../services/loan_calculator.dart';
import '../../services/payee_suggestion_service.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../personal_debts/money_records_controller.dart';
import 'transactions_controller.dart';

/// A first-class, dedicated full-screen page for creating and editing transactions.
/// Principles: Calm, Precise, Local-First, Fast.
///
/// Standard Entry Flow: Amount -> Payee -> Category -> Account -> Date -> Save.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;

  /// When supplied, saves the validated draft without posting to the ledger directly.
  final Future<void> Function(Transaction)? onSave;
  final String? headerTitle;
  final String? saveLabel;
  final Widget? sourceContext;

  const AddEditTransactionScreen({
    super.key,
    this.initialTransaction,
    this.onSave,
    this.headerTitle,
    this.saveLabel,
    this.sourceContext,
  });

  /// Pushes the full-screen [AddEditTransactionScreen] onto the navigation stack.
  static Future<T?> push<T>(
    BuildContext context, {
    Transaction? initialTransaction,
    Future<void> Function(Transaction)? onSave,
    String? headerTitle,
    String? saveLabel,
    Widget? sourceContext,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder:
            (ctx) => AddEditTransactionScreen(
              initialTransaction: initialTransaction,
              onSave: onSave,
              headerTitle: headerTitle,
              saveLabel: saveLabel,
              sourceContext: sourceContext,
            ),
      ),
    );
  }

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
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

  late final FocusNode _merchantFocusNode;
  final GlobalKey _merchantFieldKey = GlobalKey();

  Category? _selectedCategory;
  Account? _selectedAccount;
  Account? _selectedToAccount;
  Loan? _selectedLoan;
  MoneyRecord? _selectedMoneyRecord;
  Investment? _selectedInvestment;
  Subscription? _selectedSubscription;
  DateTime _selectedDate = DateTime.now();
  DateTime? _debtDueDate;
  bool _createAsSeparateDebt = false;
  String _selectedPaymentMethod = 'UPI';

  bool _moreDetailsOpen = false;
  bool _isSubmitting = false;
  bool _defaultsApplied = false;
  bool _showMerchantSuggestions = false;

  CategorySuggestion? _suggestedCategory;
  String? _amountError;
  String? _merchantError;
  String? _categoryError;
  String? _accountError;
  String? _toAccountError;

  // Track initial snapshot for dirty state checking
  late final String _initialAmount;
  late final String _initialMerchant;
  late final String _initialNotes;
  late final String _initialTags;
  late final TransactionType _initialType;
  late final TransactionPurpose _initialPurpose;

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
    _initialType = _selectedType;
    _initialPurpose = _selectedPurpose;

    _initialAmount =
        initial == null ? '' : _formatInitialAmount(initial.amount);
    _amountController = TextEditingController(text: _initialAmount);

    _initialMerchant = initial?.merchant ?? '';
    _merchantController = TextEditingController(text: _initialMerchant);

    _initialNotes = initial?.notes ?? '';
    _notesController = TextEditingController(text: _initialNotes);

    _initialTags = initial?.tags.join(', ') ?? '';
    _tagsController = TextEditingController(text: _initialTags);

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

    _merchantFocusNode = FocusNode();
    _merchantFocusNode.addListener(_onMerchantFocusChanged);

    // Restore subscription link when editing an existing transaction.
    if (initial?.purpose == TransactionPurpose.subscriptionPayment &&
        initial?.linkedSubscriptionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final subs =
            ref.read(allSubscriptionsStreamProvider).value ?? const [];
        final found =
            subs
                .where((s) => s.id == initial!.linkedSubscriptionId)
                .firstOrNull;
        if (found != null && mounted) {
          setState(() => _selectedSubscription = found);
        }
      });
    }

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
    _merchantFocusNode.removeListener(_onMerchantFocusChanged);
    _merchantFocusNode.dispose();
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

  bool get _isDirty {
    if (_amountController.text.trim() != _initialAmount) return true;
    if (_merchantController.text.trim() != _initialMerchant) return true;
    if (_notesController.text.trim() != _initialNotes) return true;
    if (_tagsController.text.trim() != _initialTags) return true;
    if (_selectedType != _initialType) return true;
    if (_selectedPurpose != _initialPurpose) return true;
    if (_counterpartyController.text.trim().isNotEmpty) return true;
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      isDestructive: true,
    );
    return confirmed ?? false;
  }

  void _onMerchantFocusChanged() {
    if (_merchantFocusNode.hasFocus) {
      setState(() {
        _showMerchantSuggestions = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && _merchantFocusNode.hasFocus) {
            _scrollToMerchantField();
          }
        });
      });
    } else {
      setState(() {
        _showMerchantSuggestions = false;
      });
    }
  }

  void _scrollToMerchantField() {
    final targetContext = _merchantFieldKey.currentContext;
    if (targetContext != null && mounted) {
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.02,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
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
    final history = ref.read(allTransactionsStreamProvider).value ?? const [];
    final suggestion =
        merchant.isEmpty
            ? null
            : CategorizationService.suggestCategory(merchant, history: history);
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

    // The newest account is the user's intentional default. Keep category
    // and payment-method suggestions based on transaction history, but do not
    // let an older transaction force the account back to Cash Wallet.
    _selectedAccount = defaultTransactionAccount(accounts);

    final recentForType =
        history.where((tx) => tx.type == _selectedType).toList();
    if (recentForType.isNotEmpty) {
      final recent = recentForType.first;

      final relevant = _prioritizedCategories(categories, history);
      _selectedCategory =
          relevant.where((c) => c.id == recent.categoryId).firstOrNull ??
          (relevant.isNotEmpty ? relevant.first : null);

      if (recent.paymentMethod != null &&
          _paymentMethods.contains(recent.paymentMethod)) {
        _selectedPaymentMethod = recent.paymentMethod!;
      }
    } else {
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
      _selectedSubscription = null;
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
      enableDrag: false,
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
      enableDrag: false,
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
        linkedSubscriptionId:
            _selectedPurpose == TransactionPurpose.subscriptionPayment
                ? _selectedSubscription?.id
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
    final finColors = context.finColors;
    return switch (type) {
      TransactionType.expense => finColors.expense,
      TransactionType.income => finColors.income,
      TransactionType.transfer => finColors.transfer,
      TransactionType.investment => finColors.investment,
      TransactionType.loanEmi => finColors.debt,
      TransactionType.cash => finColors.savings,
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
      if (_selectedCategory == null) {
        final initCatId = widget.initialTransaction!.categoryId;
        final isMisc = initCatId == 'cat_miscellaneous' ||
            widget.initialTransaction!.categoryName.toLowerCase() == 'miscellaneous';
        if (isMisc && widget.initialTransaction!.merchant.isNotEmpty) {
          final histCat = CategorizationService.suggestCategory(
            widget.initialTransaction!.merchant,
            history: history,
          );
          if (histCat != null && histCat.categoryId != 'cat_miscellaneous') {
            _selectedCategory = categories
                .where((c) => c.id == histCat.categoryId)
                .firstOrNull;
          }
        }
        _selectedCategory ??=
            categories
                .where((c) => c.id == widget.initialTransaction!.categoryId)
                .firstOrNull;
      }
    }

    final categoriesForType = _prioritizedCategories(categories, history);
    final payeeSuggestions = PayeeSuggestionService.getSuggestions(
      transactions: history,
      type: _selectedType,
      categoryId: _selectedCategory?.id,
      query: _merchantController.text,
      limit: 6,
    );

    final activeTypeColor = _typeColor(context, _selectedType);
    final saveButtonText =
        widget.saveLabel ??
        (widget.initialTransaction == null
            ? 'Save ${_selectedPurpose.displayName}'
            : 'Update ${_selectedPurpose.displayName}');

    final titleText =
        widget.headerTitle ??
        (widget.initialTransaction == null
            ? 'Add Transaction'
            : 'Edit Transaction');

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark
                ? StillwaterColors.darkSurfaceDefault
                : StillwaterColors.lightSurfaceDefault,
        appBar: AppBar(
          title: Text(
            titleText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
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
                        // 1. Transaction Type Selector Bar
                        _buildTypeSelector(
                          categories: categories,
                          accounts: accounts,
                          history: history,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceSm),

                        // 2. Purpose & Amount in a Single Unified Row
                        _buildPurposeAndAmountRow(
                          activeTypeColor: activeTypeColor,
                          categories: categories,
                          accounts: accounts,
                          history: history,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceMd),

                        // 3. Payee / Merchant Field with dynamic focused suggestions
                        _buildMerchantField(
                          suggestions: payeeSuggestions,
                          categories: categories,
                          history: history,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceMd),

                        // 4. Purpose-Specific Detailed Fields (Loans, Debts, Investments)
                        _buildPurposeFields(),
                        if (_selectedPurpose != TransactionPurpose.expense &&
                            _selectedPurpose != TransactionPurpose.income &&
                            _selectedPurpose !=
                                TransactionPurpose.internalTransfer)
                          const SizedBox(height: StillwaterTokens.spaceMd),

                        // 5. Category Section (Top 3 quick + All Categories button)
                        if (_needsCategory) ...[
                          _buildCategorySection(categoriesForType),
                          const SizedBox(height: StillwaterTokens.spaceMd),
                        ],

                        // 6. Account Section (Single or Directional Transfer)
                        _buildAccountSection(accounts),
                        const SizedBox(height: StillwaterTokens.spaceMd),

                        // 7. Single-Row Quick Date Selector
                        _buildDateSection(),
                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // 8. Progressive Disclosure: Expandable More Details
                        _buildMoreDetailsSection(),

                        const SizedBox(height: StillwaterTokens.spaceXl),
                      ],
                    ),
                  ),
                ),
              ),

              // 9. Sticky Action Bar pinned at bottom
              _buildStickyActionBar(saveButtonText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector({
    required List<Category> categories,
    required List<Account> accounts,
    required List<Transaction> history,
  }) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

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

    final tabs = const [
      (label: 'Money Out', icon: Icons.arrow_outward_rounded),
      (label: 'Money In', icon: Icons.arrow_downward_rounded),
      (label: 'Move Money', icon: Icons.swap_horiz_rounded),
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:
            isDark
                ? StillwaterColors.darkSurfaceContainerLow
                : StillwaterColors.lightSurfaceContainerLow,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        children:
            tabs.map((tab) {
              final isSelected = intent == tab.label;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    final purpose = switch (tab.label) {
                      'Money In' => TransactionPurpose.income,
                      'Move Money' => TransactionPurpose.internalTransfer,
                      _ => TransactionPurpose.expense,
                    };
                    _changePurpose(purpose, categories, accounts, history);
                  },
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusMd,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? (isDark
                                  ? theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.45)
                                  : theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.6))
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusMd,
                      ),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.8,
                                )
                                : Colors.transparent,
                        width:
                            isSelected ? StillwaterTokens.borderWidthFocus : 0,
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.icon,
                                size: 15,
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tab.label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPurposeAndAmountRow({
    required Color activeTypeColor,
    required List<Category> categories,
    required List<Account> accounts,
    required List<Transaction> history,
  }) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

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
        TransactionPurpose.subscriptionPayment,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Purpose Field (Left Column, ~42% width)
            Expanded(
              flex: 4,
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(
                  StillwaterTokens.spaceSm,
                  6,
                  StillwaterTokens.spaceXs,
                  6,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusLg,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                    width: StillwaterTokens.borderWidthHairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Purpose',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TransactionPurpose>(
                          key: ValueKey(intent),
                          value:
                              purposes.contains(_selectedPurpose)
                                  ? _selectedPurpose
                                  : purposes.first,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                          ),
                          items:
                              purposes.map((purpose) {
                                return DropdownMenuItem(
                                  value: purpose,
                                  child: Text(
                                    purpose.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (purpose) {
                            if (purpose != null) {
                              _changePurpose(
                                purpose,
                                categories,
                                accounts,
                                history,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: StillwaterTokens.spaceSm),

            // 2. Hero Amount Field (Right Column, ~58% width)
            Expanded(
              flex: 5,
              child: Container(
                height: 58,
                padding: const EdgeInsets.fromLTRB(
                  StillwaterTokens.spaceSm,
                  6,
                  StillwaterTokens.spaceSm,
                  6,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusLg,
                  ),
                  border: Border.all(
                    color:
                        _amountError != null
                            ? theme.colorScheme.error
                            : theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.35,
                            ),
                    width:
                        _amountError != null
                            ? StillwaterTokens.borderWidthFocus
                            : StillwaterTokens.borderWidthHairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_amountController.text.isNotEmpty)
                          InkWell(
                            onTap:
                                () => setState(() => _amountController.clear()),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${CurrencyFormatter.currencySymbol} ',
                            style: StillwaterTypography.numHero(
                              color: activeTypeColor,
                            ).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              autofocus: widget.initialTransaction == null,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              style: StillwaterTypography.numHero(
                                color: theme.colorScheme.onSurface,
                              ).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: StillwaterTypography.numHero(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.45),
                                ).copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildMerchantField({
    required List<PayeeSuggestion> suggestions,
    required List<Category> categories,
    required List<Transaction> history,
  }) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

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

    final isFocused = _merchantFocusNode.hasFocus || _showMerchantSuggestions;
    final typedText = _merchantController.text.trim();
    final typedTextLower = typedText.toLowerCase();

    final visibleSuggestions =
        typedText.isEmpty
            ? suggestions
            : suggestions
                .where((s) => s.displayName.toLowerCase() != typedTextLower)
                .toList();

    return Column(
      key: _merchantFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _merchantController,
          focusNode: _merchantFocusNode,
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

        // Context-aware dynamic Payee suggestions surface
        if (isFocused &&
            (visibleSuggestions.isNotEmpty || typedText.isNotEmpty)) ...[
          const SizedBox(height: StillwaterTokens.spaceXs),
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? StillwaterColors.darkSurfaceContainerLow
                      : StillwaterColors.lightSurfaceContainerLow,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: StillwaterTokens.borderWidthDefault,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(
                    alpha: isDark ? 0.35 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceSm,
              vertical: StillwaterTokens.spaceXs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory != null &&
                              visibleSuggestions.any((s) => s.isCategoryMatch)
                          ? 'Suggested for ${_selectedCategory!.name}'
                          : (typedText.isEmpty
                              ? 'Recent payees'
                              : 'Matching payees'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Close suggestions',
                      onPressed: () {
                        setState(() {
                          _showMerchantSuggestions = false;
                        });
                        _merchantFocusNode.unfocus();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.space2Xs),
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return true;
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Rank best matching payees at the top of the dropdown
                        ...visibleSuggestions.map((suggestion) {
                          return InkWell(
                            onTap: () {
                              _merchantController.text = suggestion.displayName;
                              _merchantController
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: suggestion.displayName.length,
                                ),
                              );
                              if (_needsCategory) {
                                final targetCatId =
                                    suggestion.primaryCategoryId ??
                                    CategorizationService.suggestCategory(
                                      suggestion.displayName,
                                      history: history,
                                    )?.categoryId;
                                if (targetCatId != null) {
                                  final match =
                                      categories
                                          .where((c) => c.id == targetCatId)
                                          .firstOrNull;
                                  if (match != null) {
                                    setState(() {
                                      _selectedCategory = match;
                                      _categoryError = null;
                                    });
                                  }
                                }
                              }
                              if (_merchantError != null) {
                                setState(() => _merchantError = null);
                              }
                              setState(() {
                                _showMerchantSuggestions = false;
                              });
                              _merchantFocusNode.unfocus();
                            },
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceXs,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    suggestion.isCategoryMatch
                                        ? Icons.auto_awesome_rounded
                                        : Icons.history_rounded,
                                    size: 18,
                                    color:
                                        suggestion.isCategoryMatch
                                            ? theme.colorScheme.primary
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceSm,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          suggestion.displayName,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (suggestion.reasonLabel != null)
                                          Text(
                                            suggestion.reasonLabel!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                  fontSize: 11,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (suggestion.primaryCategoryName != null &&
                                      _needsCategory &&
                                      _selectedCategory?.id !=
                                          suggestion.primaryCategoryId)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: StillwaterTokens.spaceXs,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          StillwaterTokens.radiusSm,
                                        ),
                                      ),
                                      child: Text(
                                        suggestion.primaryCategoryName!,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (typedText.isNotEmpty &&
                            !visibleSuggestions.any(
                              (s) =>
                                  s.displayName.toLowerCase() == typedTextLower,
                            )) ...[
                          if (visibleSuggestions.isNotEmpty)
                            const Divider(height: StillwaterTokens.spaceSm),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showMerchantSuggestions = false;
                              });
                              _merchantFocusNode.unfocus();
                            },
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusMd,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceXs,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceSm,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Use "$typedText"',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    'Enter',
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
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildPurposeFields() {
    if (_selectedPurpose == TransactionPurpose.subscriptionPayment) {
      final theme = context.theme;
      final isDark = theme.brightness == Brightness.dark;
      final allSubs = ref.watch(allSubscriptionsStreamProvider).value ?? [];
      final activeSubs =
          allSubs.where((s) => s.status == SubscriptionStatus.active).toList()
            ..sort((a, b) => a.merchant.compareTo(b.merchant));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subscription selector ──────────────────────────────────────────
          if (activeSubs.isEmpty)
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'No active subscriptions yet. Add subscriptions in the Subscriptions screen.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedSubscription?.id ?? 'unlinked',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Subscription',
                prefixIcon: const Icon(Icons.subscriptions_outlined),
                helperText:
                    _selectedSubscription == null
                        ? 'Choose a tracked subscription to link this payment.'
                        : null,
              ),
              items: [
                const DropdownMenuItem(
                  value: 'unlinked',
                  child: Text('Unlinked subscription payment'),
                ),
                ...activeSubs.map(
                  (sub) => DropdownMenuItem(
                    value: sub.id,
                    child: Text(
                      '${sub.merchant} · ${CurrencyFormatter.formatAmount(sub.amount)}/${sub.billingFrequency.shortLabel}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (id) {
                final chosen =
                    activeSubs.where((s) => s.id == id).firstOrNull;
                setState(() {
                  _selectedSubscription = chosen;
                  if (chosen != null) {
                    // Pre-fill amount and merchant from the subscription.
                    _amountController.text =
                        chosen.amount.toStringAsFixed(2);
                    if (_merchantController.text.isEmpty) {
                      _merchantController.text = chosen.merchant;
                    }
                  }
                });
              },
            ),
          // ── Info chip when subscription is linked ──────────────────────────
          if (_selectedSubscription != null) ...[
            const SizedBox(height: StillwaterTokens.spaceXs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.space2Xs + 2,
              ),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                        : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.45,
                        ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  width: StillwaterTokens.borderWidthDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Expanded(
                    child: Text(
                      'This payment will appear in ${_selectedSubscription!.merchant}\'s payment history.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

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
                : 'Expected EMI ${CurrencyFormatter.formatAmount(_selectedLoan!.emiAmount)} · Principal left ${CurrencyFormatter.formatAmount(_selectedLoan!.outstandingPrincipal)} · Due ${DateFormat.yMMMd().format(_selectedLoan!.nextDueDate)}',
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
                      '${record.personName} · ${CurrencyFormatter.formatAmount(record.originalAmount)}',
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
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: context.secColors.verified,
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
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Expanded(
                        child: Text(
                          _createAsSeparateDebt
                              ? 'Separate debt for ${matchingRecord.personName}'
                              : 'Adding to ${matchingRecord.personName}\'s active balance',
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _createAsSeparateDebt
                        ? 'This advance will be tracked as its own separate obligation card.'
                        : 'Current balance: ${CurrencyFormatter.formatAmount(existingRemaining)} → New balance: ${CurrencyFormatter.formatAmount(newTotal)}',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
                    _debtDueDate ?? _selectedDate.add(const Duration(days: 30)),
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
                  _debtDueDate ?? _selectedDate.add(const Duration(days: 30)),
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
      decoration: InputDecoration(labelText: label, prefixText: '${CurrencyFormatter.currencySymbol} '),
    );
  }

  Widget _buildCategorySection(List<Category> categoriesForType) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Show top 3 prioritized categories.
    // If active selection is outside top 3, display it in place of 3rd slot.
    final top3 = categoriesForType.take(3).toList();
    final List<Category> displayedQuickCategories;
    if (_selectedCategory != null &&
        !top3.any((c) => c.id == _selectedCategory!.id)) {
      if (top3.length >= 3) {
        displayedQuickCategories = [top3[0], top3[1], _selectedCategory!];
      } else {
        displayedQuickCategories = [...top3, _selectedCategory!];
      }
    } else {
      displayedQuickCategories = top3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: theme.textTheme.labelLarge),
        const SizedBox(height: StillwaterTokens.space2Xs),

        // 4-Column Balanced Grid/Row: 3 Top Categories + 1 "All Categories" Tile
        Row(
          children: [
            ...displayedQuickCategories.map((cat) {
              final isSelected = cat.id == _selectedCategory?.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: StillwaterTokens.space2Xs,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        _categoryError = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? (isDark
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.35)
                                    : theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.45))
                                : (isDark
                                    ? StillwaterColors.darkSurfaceContainerLow
                                    : StillwaterColors
                                        .lightSurfaceContainerLow),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusMd,
                        ),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                          width:
                              isSelected
                                  ? StillwaterTokens.borderWidthFocus
                                  : StillwaterTokens.borderWidthDefault,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FfCategoryTile(
                            iconIdentifier: cat.iconIdentifier,
                            colorTokenIdentifier: cat.colorTokenIdentifier,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.name,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // 4th Tile: All Categories Launcher
            Expanded(
              child: InkWell(
                onTap: () => _showCategoryPicker(categoriesForType),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: StillwaterTokens.space2Xs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? StillwaterColors.darkSurfaceContainerLow
                            : StillwaterColors.lightSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                      width: StillwaterTokens.borderWidthDefault,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All Categories',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    final isCustom = !isToday && !isYesterday;
    final formattedDate = DateFormat('d MMM yyyy').format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: theme.textTheme.labelLarge),
        const SizedBox(height: StillwaterTokens.space2Xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final isVeryNarrow = constraints.maxWidth < 280;

            if (isVeryNarrow) {
              return Wrap(
                spacing: StillwaterTokens.spaceXs,
                runSpacing: StillwaterTokens.spaceXs,
                children: [
                  ChoiceChip(
                    label: const Text('Today'),
                    selected: isToday,
                    onSelected: (_) => _setDate(now),
                  ),
                  ChoiceChip(
                    label: const Text('Yesterday'),
                    selected: isYesterday,
                    onSelected:
                        (_) => _setDate(now.subtract(const Duration(days: 1))),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: _pickCustomDate,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ChoiceChip(
                    label: const Center(child: Text('Today')),
                    selected: isToday,
                    showCheckmark: false,
                    onSelected: (_) => _setDate(now),
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(
                  flex: 4,
                  child: ChoiceChip(
                    label: const Center(child: Text('Yesterday')),
                    selected: isYesterday,
                    showCheckmark: false,
                    onSelected:
                        (_) => _setDate(now.subtract(const Duration(days: 1))),
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(
                  flex: 5,
                  child: ChoiceChip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 14),
                    label: Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    selected: isCustom,
                    showCheckmark: false,
                    onSelected: (_) => _pickCustomDate(),
                  ),
                ),
              ],
            );
          },
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

  Widget _buildStickyActionBar(String label) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceSm,
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color:
            isDark
                ? StillwaterColors.darkSurfaceDefault
                : StillwaterColors.lightSurfaceDefault,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SizedBox(
            width: double.infinity,
            child: FfButton(
              label: label,
              isLoading: _isSubmitting,
              variant: FfButtonVariant.primary,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ),
        ),
      ),
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
                                '${account!.displaySubtitle} • ${CurrencyFormatter.formatAmount(account!.currentBalance)}',
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

/// Category selection modal bottom sheet with instant search and multi-column visual grid.
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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          padding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceSm,
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceLg,
          ),
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
                controller: _searchController,
                autofocus: false,
                onChanged: (val) => setState(() => _query = val.trim()),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon:
                      _query.isEmpty
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  hintText: 'Search categories...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceMd,
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: StillwaterTokens.borderWidthFocus,
                    ),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.50,
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: StillwaterTokens.spaceXs),
                              Text(
                                'No matching category found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                        : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount =
                                width < 340 ? 2 : (width < 600 ? 3 : 4);

                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filtered.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: StillwaterTokens.spaceSm,
                                    mainAxisSpacing: StillwaterTokens.spaceSm,
                                    childAspectRatio: 1.3,
                                  ),
                              itemBuilder: (context, index) {
                                final category = filtered[index];
                                final isSelected =
                                    category.id == widget.selected?.id;

                                return _CategoryGridTile(
                                  category: category,
                                  isSelected: isSelected,
                                  onTap: () => Navigator.pop(context, category),
                                );
                              },
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

/// Visual grid tile for selecting a category in the full picker sheet.
class _CategoryGridTile extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg =
        isDark
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.45);
    final unselectedBg =
        isDark
            ? StillwaterColors.darkSurfaceContainerLow.withValues(alpha: 0.6)
            : StillwaterColors.lightSurfaceContainerLow.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
              width:
                  isSelected
                      ? StillwaterTokens.borderWidthFocus
                      : StillwaterTokens.borderWidthHairline,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceXs,
            vertical: StillwaterTokens.spaceSm,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FfCategoryTile(
                      iconIdentifier: category.iconIdentifier,
                      colorTokenIdentifier: category.colorTokenIdentifier,
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account selection bottom sheet with balance display.
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
                          '${account.displaySubtitle} • ${CurrencyFormatter.formatAmount(account.currentBalance)}',
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
