import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../categories/categories_controller.dart';
import 'budgets_controller.dart';

class AddEditBudgetSheet extends ConsumerStatefulWidget {
  final Budget? initialBudget;

  const AddEditBudgetSheet({super.key, this.initialBudget});

  @override
  ConsumerState<AddEditBudgetSheet> createState() => _AddEditBudgetSheetState();
}

class _AddEditBudgetSheetState extends ConsumerState<AddEditBudgetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  Category? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  double _alertThreshold = 0.8; // 80%

  String? _nameError;
  String? _amountError;
  String? _categoryError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBudget;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text:
          initial != null
              ? initial.amountLimit.toStringAsFixed(
                initial.amountLimit.truncateToDouble() == initial.amountLimit
                    ? 0
                    : 2,
              )
              : '',
    );
    _selectedPeriod = initial?.period ?? BudgetPeriod.monthly;
    _startDate =
        initial?.startDate ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    _endDate = initial?.endDate;
    _alertThreshold = initial?.alertThreshold ?? 0.8;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = null;
      _amountError = null;
      _categoryError = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Budget name is required.';
      });
      return;
    }

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter an amount limit greater than zero.';
      });
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Please select a category for this budget.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();
      final budget = Budget(
        id: widget.initialBudget?.id ?? const Uuid().v4(),
        name: name,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.iconIdentifier,
        categoryColor: _selectedCategory!.colorTokenIdentifier,
        amountLimit: amount,
        period: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
        alertThreshold: _alertThreshold,
        isArchived: widget.initialBudget?.isArchived ?? false,
        createdAt: widget.initialBudget?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(budgetsControllerProvider.notifier).saveBudget(budget);

      if (mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(
          context,
          message:
              widget.initialBudget != null
                  ? 'Budget updated on this device.'
                  : 'Budget created on this device.',
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save budget: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final categories = ref.watch(categoriesStreamProvider).value ?? [];

    // Pre-populate category
    if (_selectedCategory == null && categories.isNotEmpty) {
      if (widget.initialBudget != null) {
        _selectedCategory =
            categories
                .where((c) => c.id == widget.initialBudget!.categoryId)
                .firstOrNull;
      }
      _selectedCategory ??= categories.first;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                      widget.initialBudget != null
                          ? 'Edit Budget'
                          : 'New Budget',
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
                    // Amount Field
                    FfAmountField(
                      controller: _amountController,
                      errorText: _amountError,
                      autoFocus: widget.initialBudget == null,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Budget Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Budget Name *',
                        hintText: 'e.g. Monthly Dining, Grocery Limit',
                        errorText: _nameError,
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Category Selector
                    Text('Category *', style: theme.textTheme.titleMedium),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    if (_categoryError != null) ...[
                      Text(
                        _categoryError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceMd,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusMd,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Category>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items:
                              categories.map((cat) {
                                return DropdownMenuItem<Category>(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      FfCategoryTile(
                                        iconIdentifier: cat.iconIdentifier,
                                        colorTokenIdentifier:
                                            cat.colorTokenIdentifier,
                                        size: 32,
                                      ),
                                      const SizedBox(
                                        width: StillwaterTokens.spaceSm,
                                      ),
                                      Text(cat.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (cat) {
                            if (cat != null) {
                              setState(() {
                                _selectedCategory = cat;
                                if (_nameController.text.isEmpty) {
                                  _nameController.text = '${cat.name} Budget';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Budget Period
                    Text('Period', style: theme.textTheme.titleMedium),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    SegmentedButton<BudgetPeriod>(
                      segments: const [
                        ButtonSegment(
                          value: BudgetPeriod.monthly,
                          label: Text('Monthly'),
                        ),
                        ButtonSegment(
                          value: BudgetPeriod.weekly,
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: BudgetPeriod.yearly,
                          label: Text('Yearly'),
                        ),
                        ButtonSegment(
                          value: BudgetPeriod.custom,
                          label: Text('Custom'),
                        ),
                      ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (set) {
                        setState(() {
                          _selectedPeriod = set.first;
                        });
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Start Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Start Date'),
                      subtitle: Text(
                        DateFormat('dd MMMM yyyy').format(_startDate),
                      ),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // Alert Threshold Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alert Threshold',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${(_alertThreshold * 100).toInt()}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.space3Xs),
                    Text(
                      'Quietly notify when spending reaches this percentage of the budget.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    Slider(
                      value: _alertThreshold,
                      min: 0.5,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_alertThreshold * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() {
                          _alertThreshold = val;
                        });
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // Save Button
                    FfButton(
                      label:
                          widget.initialBudget != null
                              ? 'Save Changes'
                              : 'Create Budget',
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
