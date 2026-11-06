import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/extensions/context_extensions.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/investment.dart';
import '../../models/loan.dart';
import '../../models/money_record.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/categorization_service.dart';
import '../../services/default_account_service.dart';
import '../../services/loan_calculator.dart';
import '../../services/payee_suggestion_service.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/stillwater_colors.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../personal_debts/money_records_controller.dart';
import 'form/widgets/transaction_account_section.dart';
import 'form/widgets/transaction_action_bar.dart';
import 'form/widgets/transaction_category_section.dart';
import 'form/widgets/transaction_date_section.dart';
import 'form/widgets/transaction_merchant_section.dart';
import 'form/widgets/transaction_more_details_section.dart';
import 'form/widgets/transaction_purpose_amount_row.dart';
import 'form/widgets/transaction_purpose_fields.dart';
import 'form/widgets/transaction_type_selector.dart';
import 'transaction_form.dart';
import 'transactions_controller.dart';
import 'widgets/transaction_pickers.dart';

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

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTransaction;
    _selectedType = initial?.type ?? TransactionType.expense;
    _selectedPurpose = initial?.effectivePurpose ?? TransactionPurpose.expense;
    _initialType = _selectedType;
    _initialPurpose = _selectedPurpose;

    _initialAmount =
        initial == null
            ? ''
            : TransactionFormValues.formatInitialAmount(initial.amount);
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
        initial?.paymentMethod ??
        TransactionFormValues.defaultPaymentFor(_selectedType);

    _merchantFocusNode = FocusNode();
    _merchantFocusNode.addListener(_onMerchantFocusChanged);

    // Restore subscription link when editing an existing transaction.
    if (initial?.purpose == TransactionPurpose.subscriptionPayment &&
        initial?.linkedSubscriptionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final subs = ref.read(allSubscriptionsStreamProvider).value ?? const [];
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
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      destructive: true,
    );
    return confirmed ?? false;
  }

  void _onMerchantFocusChanged() {
    if (_merchantFocusNode.hasFocus) {
      setState(() {
        _showMerchantSuggestions = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(FfMotion.fast, () {
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
        duration: FfMotion.base,
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<String> get _paymentMethods =>
      TransactionFormValues.paymentMethodsFor(_selectedType);

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
        _selectedPaymentMethod = TransactionFormValues.defaultPaymentFor(type);
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

  void _changePurpose(
    TransactionPurpose purpose,
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  ) {
    if (_selectedPurpose == purpose) return;
    final type = TransactionFormValues.typeForPurpose(purpose);
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
    final chosen = await showFfSheet<Category>(
      context,
      enableDrag: false,
      builder:
          (context) => CategoryPickerSheet(
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

    final chosen = await showFfSheet<Account>(
      context,
      enableDrag: false,
      builder:
          (context) => AccountPickerSheet(
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
    final picked = await pickFfDate(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  TransactionFormValues get _formValues => TransactionFormValues(
    amountText: _amountController.text,
    payeeText: _merchantController.text,
    notesText: _notesController.text,
    tagsText: _tagsController.text,
    counterpartyText: _counterpartyController.text,
    principalText: _principalController.text,
    interestText: _interestController.text,
    feeText: _feeController.text,
    type: _selectedType,
    purpose: _selectedPurpose,
    category: _selectedCategory,
    account: _selectedAccount,
    toAccount: _selectedToAccount,
    loan: _selectedLoan,
    moneyRecord: _selectedMoneyRecord,
    investment: _selectedInvestment,
    subscription: _selectedSubscription,
    date: _selectedDate,
    debtDueDate: _debtDueDate,
    createAsSeparateDebt: _createAsSeparateDebt,
    paymentMethod: _selectedPaymentMethod,
  );

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final values = _formValues;
    final errors = validateTransactionForm(values);
    setState(() {
      _amountError = errors.amount;
      _merchantError = errors.payee;
      _categoryError = errors.category;
      _accountError = errors.account;
      _toAccountError = errors.toAccount;
    });
    if (!errors.isValid) return;

    setState(() => _isSubmitting = true);

    try {
      final built = buildTransactionFromForm(
        values,
        id: widget.initialTransaction?.id ?? const Uuid().v4(),
        now: DateTime.now(),
        initial: widget.initialTransaction,
        existingDebts:
            ref.read(allMoneyRecordsStreamProvider).valueOrNull ??
            const <MoneyRecord>[],
      );
      final tx = built.transaction;

      tx.validate();
      if (widget.onSave != null) {
        await widget.onSave!(tx);
      } else {
        await ref
            .read(transactionsControllerProvider.notifier)
            .saveTransaction(tx, moneyRecordDetails: built.debt);
      }

      final typedPayee = _merchantController.text.trim();
      if (_selectedCategory != null &&
          values.needsCategory &&
          typedPayee.isNotEmpty) {
        CategorizationService.recordUserChoice(
          rawMerchant: typedPayee,
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.iconIdentifier,
          categoryColor: _selectedCategory!.colorTokenIdentifier,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        FfToast.show(
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
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not save transaction: $e',
        );
      }
    }
  }

  Color _typeColor(BuildContext context, TransactionType type) {
    final finColors = context.ff.color;
    return switch (type) {
      TransactionType.expense => finColors.moneyExpense,
      TransactionType.income => finColors.moneyIncome,
      TransactionType.transfer => finColors.moneyTransfer,
      TransactionType.investment => finColors.moneyInvestment,
      TransactionType.loanEmi => finColors.moneyDebt,
      TransactionType.cash => finColors.moneySavings,
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
        final isMisc =
            initCatId == 'cat_miscellaneous' ||
            widget.initialTransaction!.categoryName.toLowerCase() ==
                'miscellaneous';
        if (isMisc && widget.initialTransaction!.merchant.isNotEmpty) {
          final histCat = CategorizationService.suggestCategory(
            widget.initialTransaction!.merchant,
            history: history,
          );
          if (histCat != null && histCat.categoryId != 'cat_miscellaneous') {
            _selectedCategory =
                categories.where((c) => c.id == histCat.categoryId).firstOrNull;
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
        appBar: FfAppBar(
          title: titleText,
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
                        FfSpace.lg,
                        FfSpace.sm,
                        FfSpace.lg,
                        FfSpace.xl,
                      ),
                      children: [
                        if (widget.sourceContext != null) ...[
                          widget.sourceContext!,
                          const SizedBox(height: FfSpace.md),
                        ],
                        // 1. Transaction Type Selector Bar
                        TransactionTypeSelector(
                          selectedPurpose: _selectedPurpose,
                          categories: categories,
                          accounts: accounts,
                          history: history,
                          onPurposeChanged: _changePurpose,
                        ),
                        const SizedBox(height: FfSpace.sm),

                        // 2. Purpose & Amount in a Single Unified Row
                        TransactionPurposeAmountRow(
                          selectedPurpose: _selectedPurpose,
                          activeTypeColor: activeTypeColor,
                          amountController: _amountController,
                          amountError: _amountError,
                          autofocus: widget.initialTransaction == null,
                          categories: categories,
                          accounts: accounts,
                          history: history,
                          onPurposeChanged: _changePurpose,
                          onAmountChanged: (val) {
                            if (_amountError != null) {
                              setState(() => _amountError = null);
                            }
                          },
                          onClearAmount:
                              () => setState(() => _amountController.clear()),
                        ),
                        const SizedBox(height: FfSpace.md),

                        // 3. Payee / Merchant Field with dynamic focused suggestions
                        TransactionMerchantSection(
                          merchantFieldKey: _merchantFieldKey,
                          merchantController: _merchantController,
                          merchantFocusNode: _merchantFocusNode,
                          selectedType: _selectedType,
                          selectedCategory: _selectedCategory,
                          needsCategory: _needsCategory,
                          merchantError: _merchantError,
                          showMerchantSuggestions: _showMerchantSuggestions,
                          suggestions: payeeSuggestions,
                          suggestedCategory: _suggestedCategory,
                          categories: categories,
                          history: history,
                          onSelectSuggestion: (suggestion) {
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
                          onApplySuggestedCategory: () {
                            if (_suggestedCategory == null) return;
                            final match =
                                categories
                                    .where(
                                      (c) =>
                                          c.id ==
                                          _suggestedCategory!.categoryId,
                                    )
                                    .firstOrNull;
                            if (match != null) {
                              setState(() {
                                _selectedCategory = match;
                                _categoryError = null;
                              });
                            }
                          },
                          onCloseSuggestions: () {
                            setState(() {
                              _showMerchantSuggestions = false;
                            });
                            _merchantFocusNode.unfocus();
                          },
                          onChanged: (text) {
                            if (_merchantError != null) {
                              setState(() => _merchantError = null);
                            }
                          },
                          onClearPayee: () {
                            _merchantController.clear();
                            setState(() => _merchantError = null);
                          },
                        ),
                        const SizedBox(height: FfSpace.md),

                        // 4. Purpose-Specific Detailed Fields (Loans, Debts, Investments)
                        TransactionPurposeFields(
                          selectedPurpose: _selectedPurpose,
                          initialTransaction: widget.initialTransaction,
                          amountController: _amountController,
                          merchantController: _merchantController,
                          counterpartyController: _counterpartyController,
                          principalController: _principalController,
                          interestController: _interestController,
                          feeController: _feeController,
                          selectedDate: _selectedDate,
                          debtDueDate: _debtDueDate,
                          createAsSeparateDebt: _createAsSeparateDebt,
                          selectedLoan: _selectedLoan,
                          selectedMoneyRecord: _selectedMoneyRecord,
                          selectedInvestment: _selectedInvestment,
                          selectedSubscription: _selectedSubscription,
                          selectedAccount: _selectedAccount,
                          needsCounterparty: _needsCounterparty,
                          onSelectLoan: _selectLoan,
                          onSelectMoneyRecord:
                              (r) => setState(() => _selectedMoneyRecord = r),
                          onSelectInvestment:
                              (i) => setState(() => _selectedInvestment = i),
                          onSelectSubscription:
                              (s) => setState(() => _selectedSubscription = s),
                          onSelectDebtDueDate:
                              (d) => setState(() => _debtDueDate = d),
                          onToggleCreateAsSeparateDebt:
                              (val) =>
                                  setState(() => _createAsSeparateDebt = val),
                        ),
                        if (_selectedPurpose != TransactionPurpose.expense &&
                            _selectedPurpose != TransactionPurpose.income &&
                            _selectedPurpose !=
                                TransactionPurpose.internalTransfer)
                          const SizedBox(height: FfSpace.md),

                        // 5. Category Section (Top 3 quick + All Categories button)
                        if (_needsCategory) ...[
                          TransactionCategorySection(
                            categoriesForType: categoriesForType,
                            selectedCategory: _selectedCategory,
                            categoryError: _categoryError,
                            onSelectCategory: (cat) {
                              setState(() {
                                _selectedCategory = cat;
                                _categoryError = null;
                              });
                            },
                            onOpenCategoryPicker:
                                () => _showCategoryPicker(categoriesForType),
                          ),
                          const SizedBox(height: FfSpace.md),
                        ],

                        // 6. Account Section (Single or Directional Transfer)
                        TransactionAccountSection(
                          selectedType: _selectedType,
                          accounts: accounts,
                          selectedAccount: _selectedAccount,
                          selectedToAccount: _selectedToAccount,
                          accountError: _accountError,
                          toAccountError: _toAccountError,
                          onSwapAccounts: _swapTransferAccounts,
                          onPickSourceAccount:
                              () => _showAccountPicker(
                                accounts: accounts,
                                isDestination: false,
                              ),
                          onPickDestinationAccount:
                              () => _showAccountPicker(
                                accounts: accounts,
                                isDestination: true,
                              ),
                        ),
                        const SizedBox(height: FfSpace.md),

                        // 7. Single-Row Quick Date Selector
                        TransactionDateSection(
                          selectedDate: _selectedDate,
                          onSelectDate: _setDate,
                          onPickCustomDate: _pickCustomDate,
                        ),
                        const SizedBox(height: FfSpace.lg),

                        // 8. Progressive Disclosure: Expandable More Details
                        TransactionMoreDetailsSection(
                          initiallyExpanded: _moreDetailsOpen,
                          onExpansionChanged:
                              (open) => setState(() => _moreDetailsOpen = open),
                          selectedPaymentMethod: _selectedPaymentMethod,
                          paymentMethods: _paymentMethods,
                          onPaymentMethodChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPaymentMethod = val);
                            }
                          },
                          notesController: _notesController,
                          tagsController: _tagsController,
                        ),

                        const SizedBox(height: FfSpace.xl),
                      ],
                    ),
                  ),
                ),
              ),

              // 9. Sticky Action Bar pinned at bottom
              TransactionActionBar(
                label: saveButtonText,
                isSubmitting: _isSubmitting,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
