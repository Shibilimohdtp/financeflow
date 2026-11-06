import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/category_icons.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../categories/categories_controller.dart';
import 'budget_format.dart';
import 'budgets_controller.dart';
import 'plan_providers.dart';

/// Add or edit a budget (Stillwater Bloom recipe E), opened with
/// `openBudgetSheet`.
///
/// The limit comes first, large, with a live preview of what it means per
/// day ("₹6,500 a month · about ₹217 a day"). Choosing a category offers
/// what it usually costs ("Usually ₹5,840 · use ₹6,000"). Then the category
/// chips, how often it repeats, when to be nudged, and an optional name
/// (the category's name otherwise). Group and rollover arrive with the
/// persistence slice.
class AddEditBudgetSheet extends ConsumerStatefulWidget {
  final Budget? initialBudget;

  const AddEditBudgetSheet({super.key, this.initialBudget});

  @override
  ConsumerState<AddEditBudgetSheet> createState() => _AddEditBudgetSheetState();
}

class _AddEditBudgetSheetState extends ConsumerState<AddEditBudgetSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _name;
  String? _categoryId;
  late BudgetPeriod _period;
  DateTime? _customStart;
  DateTime? _customEnd;
  late double _threshold;

  String? _amountError;
  String? _categoryError;
  String? _datesError;
  bool _saving = false;

  /// Alert choices; an older budget's own value (say 85%) is kept as a
  /// fifth choice so editing never silently changes it.
  static const _thresholds = [0.75, 0.8, 0.9, 1.0];

  bool get _isEditing => widget.initialBudget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.initialBudget;
    _amount = TextEditingController(
      text:
          b == null
              ? ''
              : b.amountLimit.toStringAsFixed(
                b.amountLimit == b.amountLimit.truncateToDouble() ? 0 : 2,
              ),
    );
    _name = TextEditingController(
      text: b == null || b.name == b.categoryName ? '' : b.name,
    );
    _categoryId = b?.categoryId;
    _period = b?.period ?? BudgetPeriod.monthly;
    if (b?.period == BudgetPeriod.custom) {
      _customStart = b!.startDate;
      _customEnd = b.endDate;
    }
    _threshold = b?.alertThreshold ?? 0.8;
    _amount.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_amountError != null) _amountError = null;
    setState(() {});
  }

  @override
  void dispose() {
    _amount.removeListener(_onAmountChanged);
    _amount.dispose();
    _name.dispose();
    super.dispose();
  }

  int? get _amountMinor {
    final v = CurrencyFormatter.parse(_amount.text);
    return v == null ? null : MoneyMath.toMinor(v);
  }

  /// The period this budget would cover if it started today, for the
  /// preview and the start date.
  Period _previewPeriod(DateTime now) => switch (_period) {
    BudgetPeriod.weekly => Period.containing(PeriodUnit.week, now),
    BudgetPeriod.yearly => Period.containing(PeriodUnit.year, now),
    BudgetPeriod.monthly => Period.containing(PeriodUnit.month, now),
    BudgetPeriod.custom =>
      _customStart != null && _customEnd != null
          ? Period.custom(_customStart!, _customEnd!)
          : Period.containing(PeriodUnit.month, now),
  };

  Future<void> _pickDates() async {
    final now = ref.read(planNowProvider);
    final picked = await pickFfDateRange(
      context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3, 12, 31),
      initialDateRange:
          _customStart != null && _customEnd != null
              ? DateTimeRange(start: _customStart!, end: _customEnd!)
              : null,
      helpText: 'Budget dates',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customStart = picked.start;
      _customEnd = picked.end;
      _datesError = null;
    });
  }

  Future<void> _submit(List<Category> categories) async {
    final minor = _amountMinor;
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    setState(() {
      _amountError =
          minor == null || minor <= 0 ? 'Enter a limit above zero.' : null;
      _categoryError = category == null ? 'Choose a category.' : null;
      _datesError =
          _period == BudgetPeriod.custom &&
                  (_customStart == null || _customEnd == null)
              ? 'Choose the dates this budget covers.'
              : null;
    });
    if (_amountError != null || _categoryError != null || _datesError != null) {
      return;
    }

    setState(() => _saving = true);
    // The plan's day decides the period; the record's timestamps are real.
    final now = ref.read(planNowProvider);
    final stamp = DateTime.now();
    final initial = widget.initialBudget;
    final keepsDates =
        initial != null &&
        initial.period == _period &&
        _period != BudgetPeriod.custom;
    final name = _name.text.trim().isEmpty ? category!.name : _name.text.trim();
    final budget = Budget(
      id: initial?.id ?? const Uuid().v4(),
      name: name,
      categoryId: category!.id,
      categoryName: category.name,
      categoryIcon: category.iconIdentifier,
      categoryColor: category.colorTokenIdentifier,
      amountLimit: MoneyMath.fromMinor(minor!),
      period: _period,
      // A new budget starts with the current period, so spending earlier in
      // it counts (limits are not pro-rated).
      startDate:
          _period == BudgetPeriod.custom
              ? _customStart!
              : keepsDates
              ? initial.startDate
              : _previewPeriod(now).start,
      endDate: _period == BudgetPeriod.custom ? _customEnd : null,
      alertThreshold: _threshold,
      isArchived: initial?.isArchived ?? false,
      createdAt: initial?.createdAt ?? stamp,
      updatedAt: stamp,
    );

    try {
      await ref.read(budgetsControllerProvider.notifier).saveBudget(budget);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.of(context).pop();
      if (messenger != null && messenger.mounted) {
        FfToast.show(
          messenger.context,
          message: _isEditing ? '$name updated.' : '$name budget created.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      FfToast.show(
        context,
        message: 'Could not save the budget. Nothing changed.',
        tone: FfToastTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final all = ref.watch(categoriesStreamProvider).valueOrNull ?? const [];
    final categories = [
      for (final c in all)
        if ((!c.isArchived && c.typeCompatibility.contains('expense')) ||
            c.id == _categoryId)
          c,
    ];
    final usual =
        _categoryId == null
            ? null
            : ref.watch(categoryUsualProvider(_categoryId!));

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: _isEditing ? 'Edit budget' : 'New budget',
          subtitle:
              _isEditing
                  ? 'Changes apply from this period on'
                  : 'A spending limit for one category',
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.xs,
              FfSpace.pageMargin,
              FfSpace.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LimitBlock(
                  controller: _amount,
                  autofocus: !_isEditing,
                  preview: _preview(),
                  error: _amountError,
                  usual: usual,
                  onUseSuggestion:
                      usual == null
                          ? null
                          : () =>
                              _amount.text = MoneyMath.fromMinor(
                                usual.suggestedMinor,
                              ).toStringAsFixed(0),
                ),
                const SizedBox(height: FfSpace.xl),
                _Label('Category', error: _categoryError),
                const SizedBox(height: FfSpace.xs),
                if (categories.isEmpty)
                  Text(
                    'Add a spending category first, in Settings.',
                    style: ff.text.bodySm,
                  )
                else
                  Wrap(
                    spacing: FfSpace.xs,
                    runSpacing: FfSpace.xs,
                    children: [
                      for (final c in categories)
                        FfChip(
                          key: ValueKey('budget-category-${c.id}'),
                          label: c.name,
                          isSelected: c.id == _categoryId,
                          leading: Icon(
                            CategoryIcons.getIcon(c.iconIdentifier),
                            size: FfIconSize.sm,
                          ),
                          onSelected:
                              () => setState(() {
                                _categoryId = c.id;
                                _categoryError = null;
                              }),
                        ),
                    ],
                  ),
                const SizedBox(height: FfSpace.xl),
                const _Label('Repeats'),
                const SizedBox(height: FfSpace.xs),
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
                    FfSegmentOption(value: BudgetPeriod.custom, label: 'Once'),
                  ],
                  selectedValue: _period,
                  onSelected: (p) => setState(() => _period = p),
                ),
                if (_period == BudgetPeriod.custom) ...[
                  const SizedBox(height: FfSpace.sm),
                  FfGroupedContainer(
                    children: [
                      FfRow(
                        key: const ValueKey('budget-dates'),
                        icon: Icons.date_range_rounded,
                        title:
                            _customStart == null || _customEnd == null
                                ? 'Choose dates'
                                : '${BudgetFormat.shortDate(_customStart!)} – '
                                    '${BudgetFormat.shortDate(_customEnd!)} '
                                    '${_customEnd!.year}',
                        subtitle: 'One period, start and end days included',
                        onTap: _pickDates,
                      ),
                    ],
                  ),
                  if (_datesError != null) ...[
                    const SizedBox(height: FfSpace.x2s),
                    _ErrorLine(_datesError!),
                  ],
                ],
                const SizedBox(height: FfSpace.xl),
                const _Label('Alert me at'),
                const SizedBox(height: FfSpace.xs),
                FfSegmentedPill<double>(
                  options: [
                    for (final t
                        in {..._thresholds, _threshold}.toList()..sort())
                      FfSegmentOption(
                        value: t,
                        label: '${(t * 100).round()}%',
                      ),
                  ],
                  selectedValue: _threshold,
                  onSelected: (t) => setState(() => _threshold = t),
                ),
                const SizedBox(height: FfSpace.x2s),
                Text(_alertLine(), style: ff.text.label),
                const SizedBox(height: FfSpace.xl),
                FfTextField(
                  controller: _name,
                  label: 'Name (optional)',
                  hint:
                      categories
                          .where((c) => c.id == _categoryId)
                          .firstOrNull
                          ?.name ??
                      'Same as the category',
                  helper: 'Shown on the Plan tab',
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                ),
                if (!_isEditing && _period != BudgetPeriod.custom) ...[
                  const SizedBox(height: FfSpace.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: FfIconSize.sm,
                        color: ff.color.textSecondary,
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Expanded(
                        child: Text(
                          'It starts with this '
                          '${BudgetFormat.periodNoun(_period)}, and spending '
                          'from earlier in it counts too.',
                          style: ff.text.label,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: _isEditing ? 'Save changes' : 'Create budget',
          isPrimaryLoading: _saving,
          onPrimaryPressed: _saving ? null : () => _submit(categories),
          secondaryLabel: 'Cancel',
          onSecondaryPressed:
              _saving ? null : () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  /// "₹6,500 a month · about ₹217 a day".
  String _preview() {
    final minor = _amountMinor;
    if (minor == null || minor <= 0) {
      return switch (_period) {
        BudgetPeriod.weekly => 'How much for a week?',
        BudgetPeriod.yearly => 'How much for a year?',
        BudgetPeriod.custom => 'How much for these dates?',
        BudgetPeriod.monthly => 'How much for a month?',
      };
    }
    final p = _previewPeriod(ref.read(planNowProvider));
    final per =
        _period == BudgetPeriod.yearly
            ? 'about ${BudgetFormat.estimate(minor ~/ 12)} a month'
            : 'about ${BudgetFormat.estimate(minor ~/ p.dayCount)} a day';
    final span = switch (_period) {
      BudgetPeriod.weekly => 'a week',
      BudgetPeriod.yearly => 'a year',
      BudgetPeriod.custom => 'over ${p.dayCount} days',
      BudgetPeriod.monthly => 'a month',
    };
    return '${BudgetFormat.money(minor)} $span · $per';
  }

  String _alertLine() {
    final minor = _amountMinor;
    final at =
        minor == null || minor <= 0
            ? ''
            : ' (${BudgetFormat.estimate((minor * _threshold).round())})';
    return _threshold >= 1.0
        ? 'A nudge only when the limit is reached.'
        : 'A gentle nudge on this device at ${(_threshold * 100).round()}% '
            'of the limit$at.';
  }
}

/// The sheet's lead: the limit as a large light amount on a soft card, the
/// live preview under it, and the category's usual spending as a one-tap
/// suggestion.
class _LimitBlock extends StatelessWidget {
  const _LimitBlock({
    required this.controller,
    required this.autofocus,
    required this.preview,
    required this.error,
    required this.usual,
    required this.onUseSuggestion,
  });

  final TextEditingController controller;
  final bool autofocus;
  final String preview;
  final String? error;
  final ({int medianMinor, int suggestedMinor})? usual;
  final VoidCallback? onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final u = usual;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.lg,
        FfSpace.md,
        FfSpace.lg,
        FfSpace.md,
      ),
      decoration: ShapeDecoration(
        color: ff.color.surfaceCard,
        shape: FfShape.of(FfRadius.xl),
        shadows: FfElevation.card(
          ff.color.shadow,
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Limit', style: ff.text.label),
          const SizedBox(height: FfSpace.x2s),
          FfAmountField.bare(
            key: const ValueKey('budget-limit'),
            controller: controller,
            autofocus: autofocus,
          ),
          const SizedBox(height: FfSpace.xs),
          Text(
            preview,
            key: const ValueKey('budget-preview'),
            style: ff.text.label.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: FfSpace.x2s),
            _ErrorLine(error!),
          ],
          if (u != null) ...[
            const SizedBox(height: FfSpace.sm),
            FfChip(
              key: const ValueKey('budget-use-usual'),
              label:
                  'Usually ${BudgetFormat.money(u.medianMinor)} · '
                  'use ${BudgetFormat.money(u.suggestedMinor)}',
              isSelected: false,
              leading: const Icon(
                Icons.auto_graph_rounded,
                size: FfIconSize.sm,
              ),
              onSelected: () => onUseSuggestion?.call(),
            ),
          ],
        ],
      ),
    );
  }
}

/// A sentence-case field label, with its error underneath.
class _Label extends StatelessWidget {
  const _Label(this.text, {this.error});

  final String text;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: ff.text.titleSm),
        if (error != null) ...[
          const SizedBox(height: FfSpace.x3s),
          _ErrorLine(error!),
        ],
      ],
    );
  }
}

/// An error in words with an icon, never colour alone.
class _ErrorLine extends StatelessWidget {
  const _ErrorLine(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: FfIconSize.sm,
            color: ff.color.statusError,
          ),
          const SizedBox(width: FfSpace.x2s),
          Expanded(
            child: Text(
              message,
              style: ff.text.label.copyWith(color: ff.color.statusError),
            ),
          ),
        ],
      ),
    );
  }
}
