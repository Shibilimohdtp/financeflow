import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
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
    final categories = categoriesAsync.value ?? [];

    if (_selectedCategory == null &&
        widget.initialBudget != null &&
        categories.isNotEmpty) {
      _selectedCategory = categories.firstWhere(
        (c) => c.id == widget.initialBudget!.categoryId,
        orElse: () => categories.first,
      );
    }

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
                          width: StillwaterTokens.borderWidthHairline,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.spaceXs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹',
                                style: StillwaterTypography.numLg(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceXs),
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
                                      color: theme.colorScheme.outline,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_amountError != null) ...[
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        _amountError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // ── 2. Budget Name ────────────────────────────────
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Budget Name',
                        hintText: 'e.g. Monthly Dining, Grocery Cap',
                        errorText: _nameError,
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 3. Period Selector ────────────────────────────
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
                      ],
                      selectedValue: _selectedPeriod,
                      onSelected: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 4. Category Selector ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SELECT CATEGORY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedCategory != null)
                          Text(
                            _selectedCategory!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    SizedBox(
                      height: 80,
                      child:
                          categories.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(
                                      width: StillwaterTokens.spaceSm,
                                    ),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final isSelected =
                                      _selectedCategory?.id == cat.id;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = cat;
                                        _categoryError = null;
                                        if (_nameController.text.isEmpty) {
                                          _nameController.text =
                                              '${cat.name} Budget';
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: StillwaterTokens.durationFast,
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
                                                    .withValues(alpha: 0.5)
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
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FfCategoryTile(
                                            iconIdentifier: cat.iconIdentifier,
                                            colorTokenIdentifier:
                                                cat.colorTokenIdentifier,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cat.name,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    if (_categoryError != null) ...[
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        _categoryError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // ── 5. Notification Threshold ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusLg,
                        ),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: StillwaterTokens.borderWidthHairline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alert Notification Threshold',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(_alertThreshold * 100).toInt()}%',
                                style: StillwaterTypography.numSm(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Receive a local reminder when spending reaches this level.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Slider(
                            value: _alertThreshold,
                            min: 0.5,
                            max: 1.0,
                            divisions: 10,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) {
                              setState(() {
                                _alertThreshold = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                  ],
                ),
              ),
              // ── Sticky Submit Footer ──────────────────────────────
              FfSheetFooter(
                primaryLabel: isEditing ? 'Save Changes' : 'Create Budget',
                isPrimaryLoading: _isSubmitting,
                onPrimaryPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
