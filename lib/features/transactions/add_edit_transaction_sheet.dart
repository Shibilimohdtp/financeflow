import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../services/categorization_service.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'transactions_controller.dart';

/// A mobile-first, local-only entry surface.  Defaults are calculated from the
/// user's on-device history and are never persisted separately or sent away.
class AddEditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;

  const AddEditTransactionSheet({super.key, this.initialTransaction});

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet> {
  late TransactionType _selectedType;
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  Category? _selectedCategory;
  Account? _selectedAccount;
  Account? _selectedToAccount;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'UPI';
  bool _moreDetailsOpen = false;
  bool _isSubmitting = false;
  bool _defaultsApplied = false;
  CategorySuggestion? _suggestedCategory;
  String? _amountError;
  String? _merchantError;
  String? _categoryError;
  String? _accountError;

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
    _amountController = TextEditingController(
      text: initial == null ? '' : _amountText(initial.amount),
    );
    _merchantController = TextEditingController(text: initial?.merchant ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _tagsController = TextEditingController(
      text: initial?.tags.join(', ') ?? '',
    );
    _selectedDate = initial?.date ?? DateTime.now();
    _selectedPaymentMethod =
        initial?.paymentMethod ?? _defaultPaymentFor(_selectedType);
    _merchantController.addListener(_onMerchantChanged);
  }

  String _amountText(double amount) =>
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
      'UPI',
      'IMPS / NEFT',
      'Net Banking',
      'Other',
    ],
    _ => _allPaymentMethods,
  };

  bool get _needsCategory => _selectedType != TransactionType.transfer;

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
      _selectedCategory =
          categories.where((c) => c.id == recent.categoryId).firstOrNull;
      if (recent.paymentMethod != null &&
          _paymentMethods.contains(recent.paymentMethod)) {
        _selectedPaymentMethod = recent.paymentMethod!;
      }
    } else {
      _selectedAccount = accounts.first;
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
    setState(() {
      _selectedType = type;
      _categoryError = null;
      _accountError = null;
      if (!_paymentMethods.contains(_selectedPaymentMethod)) {
        _selectedPaymentMethod = _defaultPaymentFor(type);
      }
      final relevant = _prioritizedCategories(categories, history);
      if (_needsCategory &&
          !relevant.any((c) => c.id == _selectedCategory?.id)) {
        _selectedCategory = relevant.isEmpty ? null : relevant.first;
      }
      if (_selectedAccount == null && accounts.isNotEmpty) {
        _selectedAccount = accounts.first;
      }
    });
  }

  Future<void> _showCategoryPicker(List<Category> categories) async {
    final chosen = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _CategoryPicker(
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
    required bool destination,
  }) async {
    final available =
        destination && _selectedAccount != null
            ? accounts.where((a) => a.id != _selectedAccount!.id).toList()
            : accounts;
    final chosen = await showModalBottomSheet<Account>(
      context: context,
      builder:
          (context) => _AccountPicker(
            accounts: available,
            selected: destination ? _selectedToAccount : _selectedAccount,
          ),
    );
    if (chosen != null && mounted) {
      setState(() {
        if (destination) {
          _selectedToAccount = chosen;
        } else {
          _selectedAccount = chosen;
          if (_selectedToAccount?.id == chosen.id) _selectedToAccount = null;
        }
        _accountError = null;
      });
    }
  }

  void _setDate(DateTime date) =>
      setState(() => _selectedDate = DateTime(date.year, date.month, date.day));

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) _setDate(date);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _amountError = null;
      _merchantError = null;
      _categoryError = null;
      _accountError = null;
    });
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter an amount greater than zero.');
      return;
    }
    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      setState(
        () =>
            _merchantError =
                _selectedType == TransactionType.transfer
                    ? 'Enter a transfer reference or recipient.'
                    : 'Enter a payee or source.',
      );
      return;
    }
    if (_selectedAccount == null) {
      setState(() => _accountError = 'Select an account.');
      return;
    }
    if (_selectedType == TransactionType.transfer &&
        _selectedToAccount == null) {
      setState(() => _accountError = 'Select a destination account.');
      return;
    }
    if (_selectedType == TransactionType.transfer &&
        _selectedAccount!.id == _selectedToAccount!.id) {
      setState(
        () => _accountError = 'Source and destination must be different.',
      );
      return;
    }
    if (_needsCategory && _selectedCategory == null) {
      setState(() => _categoryError = 'Select a category.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final now = DateTime.now();
      final tx = Transaction(
        id: widget.initialTransaction?.id ?? const Uuid().v4(),
        amount: amount,
        type: _selectedType,
        categoryId: _selectedCategory?.id ?? 'cat_transfer',
        categoryName: _selectedCategory?.name ?? 'Transfer',
        categoryIcon: _selectedCategory?.iconIdentifier ?? 'sync',
        categoryColor: _selectedCategory?.colorTokenIdentifier ?? 'slate',
        merchant: merchant,
        date: _selectedDate,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        source: widget.initialTransaction?.source ?? TransactionSource.manual,
        paymentMethod: _selectedPaymentMethod,
        accountId: _selectedAccount!.id,
        toAccountId: _selectedToAccount?.id,
        tags:
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
        isReviewed: true,
        createdAt: widget.initialTransaction?.createdAt ?? now,
        updatedAt: now,
      );
      if (_selectedCategory != null && _needsCategory) {
        CategorizationService.recordUserChoice(
          rawMerchant: merchant,
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.iconIdentifier,
          categoryColor: _selectedCategory!.colorTokenIdentifier,
        );
      }
      await ref
          .read(transactionsControllerProvider.notifier)
          .saveTransaction(tx);
      if (mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(
          context,
          message:
              widget.initialTransaction == null
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
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
    final recentPayees =
        history
            .map((t) => t.merchant)
            .where((m) => m.isNotEmpty)
            .toSet()
            .take(4)
            .toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return DraggableScrollableSheet(
      initialChildSize: .9,
      minChildSize: .55,
      maxChildSize: .96,
      expand: false,
      builder:
          (context, scrollController) => Material(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(StillwaterTokens.radius2Xl),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      StillwaterTokens.spaceLg,
                      StillwaterTokens.spaceSm,
                      StillwaterTokens.spaceXs,
                      StillwaterTokens.spaceSm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.initialTransaction == null
                                ? 'Add transaction'
                                : 'Edit transaction',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                      children: [
                        Wrap(
                          spacing: StillwaterTokens.spaceXs,
                          runSpacing: StillwaterTokens.spaceXs,
                          children:
                              TransactionType.values
                                  .map(
                                    (type) => ChoiceChip(
                                      avatar: Icon(_typeIcon(type), size: 18),
                                      label: Text(
                                        type == TransactionType.loanEmi
                                            ? 'EMI'
                                            : type.displayName,
                                      ),
                                      selected: _selectedType == type,
                                      onSelected:
                                          (_) => _changeType(
                                            type,
                                            categories,
                                            accounts,
                                            history,
                                          ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: StillwaterTokens.spaceXl),
                        FfAmountField(
                          controller: _amountController,
                          autoFocus: true,
                          labelText: 'Amount',
                          errorText: _amountError,
                          onChanged: (_) {
                            if (_amountError != null) {
                              setState(() => _amountError = null);
                            }
                          },
                        ),
                        const SizedBox(height: StillwaterTokens.spaceLg),
                        TextField(
                          controller: _merchantController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText:
                                _selectedType == TransactionType.income
                                    ? 'Payer / source'
                                    : _selectedType == TransactionType.transfer
                                    ? 'Transfer note / recipient'
                                    : 'Payee / merchant',
                            hintText:
                                _selectedType == TransactionType.transfer
                                    ? 'e.g. Move to savings'
                                    : 'Start typing a name',
                            errorText: _merchantError,
                            prefixIcon: Icon(
                              _selectedType == TransactionType.income
                                  ? Icons.account_circle_outlined
                                  : Icons.storefront_outlined,
                            ),
                            suffixIcon:
                                _merchantController.text.isEmpty
                                    ? null
                                    : IconButton(
                                      tooltip: 'Clear payee',
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: _merchantController.clear,
                                    ),
                          ),
                          onChanged: (_) {
                            if (_merchantError != null) {
                              setState(() => _merchantError = null);
                            }
                          },
                        ),
                        if (recentPayees.isNotEmpty &&
                            _merchantController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: StillwaterTokens.spaceXs,
                            ),
                            child: Wrap(
                              spacing: StillwaterTokens.spaceXs,
                              children:
                                  recentPayees
                                      .map(
                                        (payee) => ActionChip(
                                          label: Text(
                                            payee,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onPressed:
                                              () =>
                                                  _merchantController.text =
                                                      payee,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        if (_suggestedCategory != null && _needsCategory)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: StillwaterTokens.spaceXs,
                            ),
                            child: TextButton.icon(
                              onPressed: () {
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
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                              ),
                              label: Text(
                                'Use suggested ${_suggestedCategory!.categoryName}',
                              ),
                            ),
                          ),
                        if (_needsCategory) ...[
                          const SizedBox(height: StillwaterTokens.spaceLg),
                          _FieldButton(
                            label: 'Category',
                            error: _categoryError,
                            value:
                                _selectedCategory == null
                                    ? 'Choose category'
                                    : _selectedCategory!.name,
                            icon:
                                _selectedCategory == null
                                    ? Icons.category_outlined
                                    : null,
                            leading:
                                _selectedCategory == null
                                    ? null
                                    : FfCategoryTile(
                                      iconIdentifier:
                                          _selectedCategory!.iconIdentifier,
                                      colorTokenIdentifier:
                                          _selectedCategory!
                                              .colorTokenIdentifier,
                                    ),
                            onTap: () => _showCategoryPicker(categoriesForType),
                          ),
                          if (categoriesForType.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: StillwaterTokens.spaceXs,
                              ),
                              child: SizedBox(
                                height: 42,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoriesForType.take(6).length,
                                  separatorBuilder:
                                      (_, _) => const SizedBox(
                                        width: StillwaterTokens.spaceXs,
                                      ),
                                  itemBuilder: (_, index) {
                                    final category = categoriesForType[index];
                                    return ChoiceChip(
                                      avatar: FfCategoryTile(
                                        iconIdentifier: category.iconIdentifier,
                                        colorTokenIdentifier:
                                            category.colorTokenIdentifier,
                                        size: 24,
                                      ),
                                      label: Text(category.name),
                                      selected:
                                          category.id == _selectedCategory?.id,
                                      onSelected:
                                          (_) => setState(() {
                                            _selectedCategory = category;
                                            _categoryError = null;
                                          }),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: StillwaterTokens.spaceLg),
                        _FieldButton(
                          label:
                              _selectedType == TransactionType.transfer
                                  ? 'From account'
                                  : 'Account',
                          error: _accountError,
                          value:
                              _selectedAccount == null
                                  ? 'Choose account'
                                  : _accountTitle(_selectedAccount!),
                          icon: Icons.account_balance_wallet_outlined,
                          onTap:
                              () => _showAccountPicker(
                                accounts: accounts,
                                destination: false,
                              ),
                        ),
                        if (_selectedType == TransactionType.transfer) ...[
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          _FieldButton(
                            label: 'To account',
                            error: _accountError,
                            value:
                                _selectedToAccount == null
                                    ? 'Choose destination'
                                    : _accountTitle(_selectedToAccount!),
                            icon: Icons.south_east_rounded,
                            onTap:
                                () => _showAccountPicker(
                                  accounts: accounts,
                                  destination: true,
                                ),
                          ),
                        ],
                        const SizedBox(height: StillwaterTokens.spaceLg),
                        Text('Date', style: theme.textTheme.labelLarge),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        Wrap(
                          spacing: StillwaterTokens.spaceXs,
                          runSpacing: StillwaterTokens.spaceXs,
                          children: [
                            _DateChip(
                              label: 'Today',
                              date: DateTime.now(),
                              selected: _sameDay(_selectedDate, DateTime.now()),
                              onTap: _setDate,
                            ),
                            _DateChip(
                              label: 'Yesterday',
                              date: DateTime.now().subtract(
                                const Duration(days: 1),
                              ),
                              selected: _sameDay(
                                _selectedDate,
                                DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                              ),
                              onTap: _setDate,
                            ),
                            ActionChip(
                              avatar: const Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                              ),
                              label: Text(
                                DateFormat('d MMM yyyy').format(_selectedDate),
                              ),
                              onPressed: _pickDate,
                            ),
                          ],
                        ),
                        const SizedBox(height: StillwaterTokens.spaceMd),
                        ExpansionTile(
                          leading: const Icon(Icons.tune_rounded),
                          title: const Text('More details'),
                          subtitle: const Text('Payment method, note and tags'),
                          initiallyExpanded: _moreDetailsOpen,
                          onExpansionChanged:
                              (open) => setState(() => _moreDetailsOpen = open),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: StillwaterTokens.spaceMd,
                              ),
                              child: DropdownButtonFormField<String>(
                                value:
                                    _paymentMethods.contains(
                                          _selectedPaymentMethod,
                                        )
                                        ? _selectedPaymentMethod
                                        : _defaultPaymentFor(_selectedType),
                                decoration: const InputDecoration(
                                  labelText: 'Payment method',
                                  prefixIcon: Icon(Icons.payment_outlined),
                                ),
                                items:
                                    _paymentMethods
                                        .map(
                                          (method) => DropdownMenuItem(
                                            value: method,
                                            child: Text(method),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _selectedPaymentMethod = value,
                                    );
                                  }
                                },
                              ),
                            ),
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                                hintText: 'Invoice number or context',
                                prefixIcon: Icon(Icons.notes_rounded),
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceMd),
                            TextField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                labelText: 'Tags',
                                hintText: 'trip, work, reimbursement',
                                prefixIcon: Icon(Icons.tag_rounded),
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceSm),
                            Text(
                              'Split, recurring, attachments and location need model support before they can be saved safely.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: StillwaterTokens.spaceLg + bottomInset,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      StillwaterTokens.spaceLg,
                      StillwaterTokens.spaceSm,
                      StillwaterTokens.spaceLg,
                      StillwaterTokens.spaceSm + bottomInset,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: FfButton(
                      width: double.infinity,
                      size: FfButtonSize.lg,
                      isLoading: _isSubmitting,
                      label:
                          '${widget.initialTransaction == null ? 'Save' : 'Update'} ${_selectedType.displayName}',
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _accountTitle(Account account) =>
      '${account.name} · ${account.displaySubtitle}';
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static IconData _typeIcon(TransactionType type) => switch (type) {
    TransactionType.expense => Icons.arrow_upward_rounded,
    TransactionType.income => Icons.arrow_downward_rounded,
    TransactionType.transfer => Icons.swap_horiz_rounded,
    TransactionType.investment => Icons.trending_up_rounded,
    TransactionType.loanEmi => Icons.receipt_long_rounded,
    TransactionType.cash => Icons.payments_outlined,
  };
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool selected;
  final ValueChanged<DateTime> onTap;
  const _DateChip({
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(date),
  );
}

class _FieldButton extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? leading;
  final String? error;
  final VoidCallback onTap;
  const _FieldButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.leading,
    this.error,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label: $value',
    child: InkWell(
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          prefixIcon:
              leading == null
                  ? (icon == null ? null : Icon(icon))
                  : Padding(padding: const EdgeInsets.all(10), child: leading),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ),
  );
}

class _CategoryPicker extends StatefulWidget {
  final List<Category> categories;
  final Category? selected;
  const _CategoryPicker({required this.categories, required this.selected});
  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final shown =
        widget.categories
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: StillwaterTokens.spaceMd),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search categories',
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .48,
              child: ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, index) {
                  final category = shown[index];
                  return ListTile(
                    leading: FfCategoryTile(
                      iconIdentifier: category.iconIdentifier,
                      colorTokenIdentifier: category.colorTokenIdentifier,
                    ),
                    title: Text(category.name),
                    trailing:
                        category.id == widget.selected?.id
                            ? const Icon(Icons.check_rounded)
                            : null,
                    onTap: () => Navigator.pop(context, category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPicker extends StatelessWidget {
  final List<Account> accounts;
  final Account? selected;
  const _AccountPicker({required this.accounts, required this.selected});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Choose account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: StillwaterTokens.spaceSm),
          if (accounts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(StillwaterTokens.spaceLg),
              child: Text('No eligible account available.'),
            ),
          ...accounts.map(
            (account) => ListTile(
              leading: Icon(_icon(account.type)),
              title: Text(account.name),
              subtitle: Text(
                '${account.displaySubtitle} · ${CurrencyFormatter.formatINR(account.currentBalance)}',
              ),
              trailing:
                  account.id == selected?.id
                      ? const Icon(Icons.check_rounded)
                      : null,
              onTap: () => Navigator.pop(context, account),
            ),
          ),
        ],
      ),
    ),
  );
  IconData _icon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.upi => Icons.account_balance_wallet_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    _ => Icons.account_balance_outlined,
  };
}
