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
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;

  Category? _selectedCategory;
  CategorySuggestion? _suggestedCategory;
  bool _hasUserManuallySelectedCategory = false;
  Account? _selectedAccount;
  Account? _selectedToAccount; // For transfers
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'UPI';

  String? _amountError;
  String? _merchantError;
  String? _categoryError;
  String? _accountError;
  bool _isSubmitting = false;

  final List<String> _paymentMethods = [
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
      text:
          initial != null
              ? initial.amount.toStringAsFixed(
                initial.amount.truncateToDouble() == initial.amount ? 0 : 2,
              )
              : '',
    );
    _merchantController = TextEditingController(text: initial?.merchant ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _tagsController = TextEditingController(
      text: initial?.tags.join(', ') ?? '',
    );
    _selectedDate = initial?.date ?? DateTime.now();
    _selectedPaymentMethod = initial?.paymentMethod ?? 'UPI';

    if (initial != null) {
      _hasUserManuallySelectedCategory = true;
    }

    _merchantController.addListener(_onMerchantChanged);
  }

  @override
  void dispose() {
    _merchantController.removeListener(_onMerchantChanged);
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onMerchantChanged() {
    final text = _merchantController.text.trim();
    if (text.isEmpty) {
      if (_suggestedCategory != null) {
        setState(() {
          _suggestedCategory = null;
        });
      }
      return;
    }

    final suggestion = CategorizationService.suggestCategory(text);
    if (suggestion != null) {
      setState(() {
        _suggestedCategory = suggestion;
      });

      // If user hasn't explicitly tapped a category, auto-apply suggestion
      if (!_hasUserManuallySelectedCategory) {
        final categories = ref.read(categoriesStreamProvider).value ?? [];
        final matchingCat =
            categories.where((c) => c.id == suggestion.categoryId).firstOrNull;
        if (matchingCat != null && _selectedCategory?.id != matchingCat.id) {
          setState(() {
            _selectedCategory = matchingCat;
            _categoryError = null;
          });
        }
      }
    } else {
      if (_suggestedCategory != null) {
        setState(() {
          _suggestedCategory = null;
        });
      }
    }
  }

  void _acceptSuggestion(
    CategorySuggestion suggestion,
    List<Category> categories,
  ) {
    final matchingCat =
        categories.where((c) => c.id == suggestion.categoryId).firstOrNull;
    if (matchingCat != null) {
      setState(() {
        _selectedCategory = matchingCat;
        _categoryError = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _amountError = null;
      _merchantError = null;
      _categoryError = null;
      _accountError = null;
    });

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter an amount greater than zero.';
      });
      return;
    }

    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      setState(() {
        _merchantError = 'Merchant or payee name is required.';
      });
      return;
    }

    if (_selectedAccount == null) {
      setState(() {
        _accountError = 'Please select an account.';
      });
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      if (_selectedToAccount == null) {
        setState(() {
          _accountError = 'Please select a destination account.';
        });
        return;
      }
      if (_selectedToAccount!.id == _selectedAccount!.id) {
        setState(() {
          _accountError = 'Source and destination accounts must be different.';
        });
        return;
      }
    } else {
      if (_selectedCategory == null) {
        setState(() {
          _categoryError = 'Please select a category.';
        });
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final tags =
          _tagsController.text
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();

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
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        source: widget.initialTransaction?.source ?? TransactionSource.manual,
        paymentMethod: _selectedPaymentMethod,
        accountId: _selectedAccount!.id,
        toAccountId: _selectedToAccount?.id,
        tags: tags,
        isReviewed: true,
        createdAt: widget.initialTransaction?.createdAt ?? now,
        updatedAt: now,
      );

      // Record user choice for future deterministic suggestions
      if (_selectedCategory != null &&
          _selectedType != TransactionType.transfer) {
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
              widget.initialTransaction != null
                  ? 'Transaction updated on this device.'
                  : 'Saved on this device.',
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save transaction: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    // Ensure selected account is set
    if (_selectedAccount == null && accounts.isNotEmpty) {
      if (widget.initialTransaction != null) {
        _selectedAccount =
            accounts
                .where((a) => a.id == widget.initialTransaction!.accountId)
                .firstOrNull;
      }
      _selectedAccount ??= accounts.first;
    }

    // Ensure selected category is set
    if (_selectedCategory == null && categories.isNotEmpty) {
      if (widget.initialTransaction != null) {
        _selectedCategory =
            categories
                .where((c) => c.id == widget.initialTransaction!.categoryId)
                .firstOrNull;
      }
      _selectedCategory ??= categories.first;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialTransaction != null
                          ? 'Edit Transaction'
                          : 'Add Transaction',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                  children: [
                    // 1. Type Selector Segmented Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text('Expense'),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text('Income'),
                          ),
                          ButtonSegment(
                            value: TransactionType.transfer,
                            label: Text('Transfer'),
                          ),
                          ButtonSegment(
                            value: TransactionType.investment,
                            label: Text('Invest'),
                          ),
                          ButtonSegment(
                            value: TransactionType.loanEmi,
                            label: Text('EMI'),
                          ),
                          ButtonSegment(
                            value: TransactionType.cash,
                            label: Text('Cash'),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 2. Hero Amount Input Field
                    FfAmountField(
                      controller: _amountController,
                      errorText: _amountError,
                      onChanged: (val) {
                        if (_amountError != null) {
                          setState(() {
                            _amountError = null;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // 3. Merchant / Payee Text Field
                    TextField(
                      controller: _merchantController,
                      decoration: InputDecoration(
                        labelText:
                            _selectedType == TransactionType.income
                                ? 'Payer / Source'
                                : 'Payee / Merchant',
                        hintText:
                            _selectedType == TransactionType.income
                                ? 'e.g. Acme Corp, Client, Interest'
                                : 'e.g. Swiggy, Uber, Electricity Board',
                        errorText: _merchantError,
                        prefixIcon: const Icon(Icons.storefront_outlined),
                      ),
                      onChanged: (val) {
                        if (_merchantError != null) {
                          setState(() {
                            _merchantError = null;
                          });
                        }
                      },
                    ),

                    // Smart Categorization Suggestion Banner
                    if (_suggestedCategory != null &&
                        _selectedType != TransactionType.transfer) ...[
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceMd,
                          vertical: StillwaterTokens.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          color: context.aiColors.surface,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          border: Border.all(
                            color: context.aiColors.accent.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: context.aiColors.accent,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Suggested: ${_suggestedCategory!.categoryName} (${(_suggestedCategory!.confidence * 100).toInt()}% match)',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.aiColors.accent,
                                        ),
                                  ),
                                  Text(
                                    _suggestedCategory!.reason,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedCategory?.id !=
                                _suggestedCategory!.categoryId)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: StillwaterTokens.spaceSm,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed:
                                    () => _acceptSuggestion(
                                      _suggestedCategory!,
                                      categories,
                                    ),
                                child: const Text('Apply'),
                              ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // 4. Category Selector (if not Transfer)
                    if (_selectedType != TransactionType.transfer) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Category', style: theme.textTheme.labelLarge),
                          if (_selectedCategory != null)
                            Text(
                              _selectedCategory!.name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(
                                width: StillwaterTokens.spaceXs,
                              ),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = _selectedCategory?.id == cat.id;

                            return ChoiceChip(
                              label: Text(cat.name),
                              avatar: FfCategoryTile(
                                iconIdentifier: cat.iconIdentifier,
                                colorTokenIdentifier: cat.colorTokenIdentifier,
                                size: 24,
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _hasUserManuallySelectedCategory = true;
                                    _categoryError = null;
                                  });
                                }
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
                          ),
                        ),
                      ],
                      const SizedBox(height: StillwaterTokens.spaceLg),
                    ],

                    // 5. Account Selector
                    DropdownButtonFormField<Account>(
                      value: _selectedAccount,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText:
                            _selectedType == TransactionType.transfer
                                ? 'From Account'
                                : 'Account',
                        errorText: _accountError,
                      ),
                      items:
                          accounts.map((acc) {
                            return DropdownMenuItem<Account>(
                              value: acc,
                              child: Text(
                                '${acc.name} (${acc.type.displayName})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (acc) {
                        setState(() {
                          _selectedAccount = acc;
                          _accountError = null;
                        });
                      },
                    ),

                    // 6. Destination Account (for Transfer only)
                    if (_selectedType == TransactionType.transfer) ...[
                      const SizedBox(height: StillwaterTokens.spaceLg),
                      DropdownButtonFormField<Account>(
                        value: _selectedToAccount,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'To Account (Destination)',
                          errorText: _accountError,
                        ),
                        items:
                            accounts.map((acc) {
                              return DropdownMenuItem<Account>(
                                value: acc,
                                child: Text(
                                  '${acc.name} (${acc.type.displayName})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (acc) {
                          setState(() {
                            _selectedToAccount = acc;
                            _accountError = null;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // 7. Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // 8. Payment Method
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: Icon(Icons.payment_outlined),
                      ),
                      items:
                          _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPaymentMethod = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // 9. Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add context, invoice number, or description',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // 10. Tags
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (Optional)',
                        hintText:
                            'e.g. trip, office, reimbursement (comma-separated)',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // Submit Button
                    FfButton(
                      label: 'Save Transaction',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
