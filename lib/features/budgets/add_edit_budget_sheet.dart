import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
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

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
      if (_nameController.text.trim().isEmpty ||
          (widget.initialBudget == null &&
              _nameController.text.endsWith(' Budget'))) {
        _nameController.text = '${category.name} Budget';
      }
    });
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
                  ? 'Budget updated.'
                  : 'Budget created.',
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
    final isEditing = widget.initialBudget != null;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories =
        (categoriesAsync.value ?? [])
            .where(
              (c) => !c.isArchived && c.typeCompatibility.contains('expense'),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (_selectedCategory == null &&
        widget.initialBudget != null &&
        categories.isNotEmpty) {
      _selectedCategory = categories.firstWhere(
        (c) => c.id == widget.initialBudget!.categoryId,
        orElse: () => categories.first,
      );
    }

    final parsedAmount = CurrencyFormatter.parse(_amountController.text) ?? 0.0;
    final alertRupeeValue = parsedAmount * _alertThreshold;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: isEditing ? 'Edit Budget' : 'New Budget Plan',
                subtitle: 'Set a conscious spending limit on this device',
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                  ),
                  shrinkWrap: true,
                  children: [
                    // ── 1. Amount Hero Field ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceMd,
                        vertical: StillwaterTokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusLg,
                        ),
                        border: Border.all(
                          color:
                              _amountError != null
                                  ? theme.colorScheme.error
                                  : theme.dividerColor,
                          width: StillwaterTokens.borderWidthDefault,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLANNED SPENDING LIMIT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹',
                                style: StillwaterTypography.numHero(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceSm),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  style: StillwaterTypography.numHero(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: StillwaterTypography.numHero(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.4),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_amountError != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _amountError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 2. Category Selector ──────────────────────────
                    Text(
                      'Category',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    if (categories.isEmpty)
                      const Text('No categories found.')
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              categories.map((cat) {
                                final isSelected =
                                    _selectedCategory?.id == cat.id;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: StillwaterTokens.spaceSm,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusMd,
                                    ),
                                    onTap: () => _onCategorySelected(cat),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: StillwaterTokens.spaceSm,
                                        vertical: StillwaterTokens.spaceXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? theme
                                                    .colorScheme
                                                    .primaryContainer
                                                : theme.cardColor,
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
                                                  ? StillwaterTokens
                                                      .borderWidthStrong
                                                  : StillwaterTokens
                                                      .borderWidthHairline,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FfCategoryTile(
                                            iconIdentifier: cat.iconIdentifier,
                                            colorTokenIdentifier:
                                                cat.colorTokenIdentifier,
                                            size: 28,
                                          ),
                                          const SizedBox(
                                            width: StillwaterTokens.spaceSm,
                                          ),
                                          Text(
                                            cat.name,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                  color:
                                                      isSelected
                                                          ? theme
                                                              .colorScheme
                                                              .onPrimaryContainer
                                                          : theme
                                                              .colorScheme
                                                              .onSurface,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    if (_categoryError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _categoryError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 3. Budget Name ────────────────────────────────
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Budget Name',
                        hintText: 'e.g. Dining Out, Groceries',
                        errorText: _nameError,
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 4. Period Selector ────────────────────────────
                    Text(
                      'Period Cycle',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    FfSegmentedPill<BudgetPeriod>(
                      options: const [
                        FfSegmentOption(
                          value: BudgetPeriod.monthly,
                          label: 'Monthly',
                        ),
                        FfSegmentOption(
                          value: BudgetPeriod.weekly,
                          label: 'Weekly',
                        ),
                        FfSegmentOption(
                          value: BudgetPeriod.yearly,
                          label: 'Yearly',
                        ),
                        FfSegmentOption(
                          value: BudgetPeriod.custom,
                          label: 'Custom',
                        ),
                      ],
                      selectedValue: _selectedPeriod,
                      onSelected: (period) async {
                        if (period == BudgetPeriod.custom) {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                            initialDateRange: DateTimeRange(
                              start: _startDate,
                              end:
                                  _endDate ??
                                  _startDate.add(const Duration(days: 30)),
                            ),
                          );
                          if (range != null) {
                            setState(() {
                              _selectedPeriod = period;
                              _startDate = range.start;
                              _endDate = range.end;
                            });
                          }
                        } else {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        }
                      },
                    ),

                    if (_selectedPeriod == BudgetPeriod.custom &&
                        _endDate != null) ...[
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Cycle: ${DateFormatter.formatShortDate(_startDate)} – ${DateFormatter.formatShortDate(_endDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 5. Alert Notification Threshold ───────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alert Threshold',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${(_alertThreshold * 100).toInt()}% (${CurrencyFormatter.formatINR(alertRupeeValue)})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                    Text(
                      'You will receive a gentle on-device alert when your spending crosses this threshold.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              FfSheetFooter(
                child: Row(
                  children: [
                    FfButton(
                      label: 'Cancel',
                      variant: FfButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    FfButton(
                      label: isEditing ? 'Update Budget' : 'Save Budget',
                      variant: FfButtonVariant.primary,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
