import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_asset_type_tiles.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'investments_controller.dart';

/// The Stillwater Bloom Add / Edit Investment sheet (Pattern E).
class AddEditInvestmentSheet extends ConsumerStatefulWidget {
  final Investment? initialInvestment;

  const AddEditInvestmentSheet({super.key, this.initialInvestment});

  @override
  ConsumerState<AddEditInvestmentSheet> createState() =>
      _AddEditInvestmentSheetState();
}

class _AddEditInvestmentSheetState
    extends ConsumerState<AddEditInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _unitsController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _currentValueController;
  late final TextEditingController _notesController;

  late AssetType _assetType;
  late DateTime _purchaseDate;
  String? _selectedAccountId;
  bool _showAdvanced = false;
  bool _isSaving = false;

  bool get isEditing => widget.initialInvestment != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialInvestment;
    _nameController = TextEditingController(text: init?.name ?? '');
    _unitsController = TextEditingController(
      text:
          init != null
              ? (init.quantityOrUnits.truncateToDouble() == init.quantityOrUnits
                  ? init.quantityOrUnits.toInt().toString()
                  : init.quantityOrUnits.toString())
              : '1',
    );
    _purchasePriceController = TextEditingController(
      text:
          init != null
              ? (init.purchasePrice.truncateToDouble() == init.purchasePrice
                  ? init.purchasePrice.toInt().toString()
                  : init.purchasePrice.toString())
              : '',
    );
    _currentValueController = TextEditingController(
      text:
          init != null
              ? (init.currentValue.truncateToDouble() == init.currentValue
                  ? init.currentValue.toInt().toString()
                  : init.currentValue.toString())
              : '',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _assetType = init?.assetType ?? AssetType.mutualFunds;
    _purchaseDate = init?.purchaseDate ?? DateTime.now();
    _selectedAccountId = init?.accountId;
    _showAdvanced =
        init != null &&
        ((init.notes?.isNotEmpty ?? false) ||
            init.accountId != null ||
            init.quantityOrUnits != 1.0);

    _nameController.addListener(_rebuild);
    _unitsController.addListener(_rebuild);
    _purchasePriceController.addListener(_rebuild);
    _currentValueController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_rebuild);
    _unitsController.removeListener(_rebuild);
    _purchasePriceController.removeListener(_rebuild);
    _currentValueController.removeListener(_rebuild);
    _nameController.dispose();
    _unitsController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _purchaseDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final units = double.tryParse(_unitsController.text.trim()) ?? 1.0;
    final price = CurrencyFormatter.parse(_purchasePriceController.text) ?? 0.0;
    final currentVal =
        CurrencyFormatter.parse(_currentValueController.text) ??
        (price * units);

    if (name.isEmpty) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter the investment name.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(investmentsControllerProvider.notifier);

    if (widget.initialInvestment != null) {
      final updated = widget.initialInvestment!.copyWith(
        name: name,
        assetType: _assetType,
        quantityOrUnits: units,
        purchasePrice: price,
        currentValue: currentVal,
        purchaseDate: _purchaseDate,
        accountId: _selectedAccountId,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
      );
      await controller.updateInvestment(updated);
    } else {
      await controller.addInvestment(
        name: name,
        assetType: _assetType,
        quantityOrUnits: units,
        purchasePrice: price,
        currentValue: currentVal,
        purchaseDate: _purchaseDate,
        accountId: _selectedAccountId,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      FfToast.show(
        context,
        message:
            isEditing
                ? 'Investment updated.'
                : 'Investment added to portfolio.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsStreamProvider);

    final units = double.tryParse(_unitsController.text.trim()) ?? 1.0;
    final price = CurrencyFormatter.parse(_purchasePriceController.text) ?? 0.0;
    final totalInvested = price * units;
    final currentVal =
        CurrencyFormatter.parse(_currentValueController.text) ?? totalInvested;

    final hasAmounts = price > 0 || currentVal > 0;
    final delta = currentVal - totalInvested;
    final isGain = delta >= 0;
    final pctReturn = totalInvested > 0 ? (delta / totalInvested) * 100.0 : 0.0;
    final returnSign = isGain ? '+' : '';

    String consequence;
    FfTone consequenceTone;
    if (!hasAmounts) {
      consequence = 'Enter purchase price and valuation to track gains';
      consequenceTone = FfTone.neutral;
    } else if (units > 1.0) {
      consequence =
          '$units units @ ${CurrencyFormatter.formatAmount(price)} = ${CurrencyFormatter.formatAmount(totalInvested)} cost · Return: $returnSign${CurrencyFormatter.formatAmount(delta)} ($returnSign${pctReturn.toStringAsFixed(1)}%)';
      consequenceTone = isGain ? FfTone.income : FfTone.error;
    } else {
      consequence =
          'Invested ${CurrencyFormatter.formatAmount(totalInvested)} · Return: $returnSign${CurrencyFormatter.formatAmount(delta)} ($returnSign${pctReturn.toStringAsFixed(1)}%)';
      consequenceTone = isGain ? FfTone.income : FfTone.error;
    }

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Holding' : 'Add Investment',
          subtitle: 'Manual on-device portfolio valuation',
        ),
        const FfDivider(),

        // Form Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: FfSpace.sm),

                  // ── Live Squircle Preview Card ────────────────────────────
                  _buildPreviewCard(
                    context,
                    name:
                        _nameController.text.trim().isEmpty
                            ? 'Holding Name'
                            : _nameController.text.trim(),
                    assetType: _assetType,
                    currentValue: currentVal,
                    invested: totalInvested,
                    delta: delta,
                    pctReturn: pctReturn,
                    isGain: isGain,
                    hasAmounts: hasAmounts,
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 1. Asset Class Visual Selector ────────────────────────
                  Text(
                    'Asset Class',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfAssetTypeTiles(
                    selectedType: _assetType,
                    onChanged: (type) => setState(() => _assetType = type),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 2. Holding Name ───────────────────────────────────────
                  FfTextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    label: 'Holding / Asset Name',
                    hint: 'e.g. Parag Parikh Flexi Cap, HDFC Bank Shares, SGB',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter holding name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 3. Amounts Row ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FfAmountField(
                          controller: _purchasePriceController,
                          label: 'Purchase / Unit Price',
                          tone: FfTone.neutral,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: FfAmountField(
                          controller: _currentValueController,
                          label: 'Current Value',
                          tone: FfTone.investment,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FfSpace.sm),

                  // ── 4. Live Consequence Feedback ──────────────────────────
                  FfConsequenceLine(
                    text: consequence,
                    tone: consequenceTone,
                    icon:
                        hasAmounts
                            ? (isGain
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded)
                            : Icons.info_outline_rounded,
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 5. Purchase Date ──────────────────────────────────────
                  FfRow(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: 'Purchase Date',
                    detail: DateFormatter.formatShortDate(_purchaseDate),
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 6. Advanced Toggle ────────────────────────────────────
                  InkWell(
                    onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvanced
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: context.ff.color.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Text(
                            _showAdvanced
                                ? 'Hide units, source account & notes'
                                : 'Units, Source Account & Notes (Optional)',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.actionPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAdvanced) ...[
                    const SizedBox(height: FfSpace.sm),
                    // Quantity / Units
                    FfTextField(
                      controller: _unitsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: 'Units / Quantity',
                      hint: '1.0',
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Linked Account
                    accountsAsync.when(
                      data: (accounts) {
                        final activeAccounts =
                            accounts.where((a) => !a.isArchived).toList();
                        return FfSelect<String?>(
                          value: _selectedAccountId,
                          label: 'Purchased From Account',
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Not specified'),
                            ),
                            ...activeAccounts.map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            ),
                          ],
                          onChanged:
                              (val) => setState(() => _selectedAccountId = val),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Notes
                    FfTextField(
                      controller: _notesController,
                      maxLines: 2,
                      label: 'Notes',
                      hint: 'e.g. SIP started in 2024, Long term horizon',
                    ),
                  ],

                  const SizedBox(height: FfSpace.lg),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          secondaryLabel: 'Cancel',
          primaryLabel: isEditing ? 'Save Changes' : 'Add Holding',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required String name,
    required AssetType assetType,
    required double currentValue,
    required double invested,
    required double delta,
    required double pctReturn,
    required bool isGain,
    required bool hasAmounts,
  }) {
    final ff = context.ff;
    final c = ff.color;
    final returnSign = isGain ? '+' : '';

    return FfCard(
      variant: FfCardVariant.elevated,
      density: FfDensity.compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FfIconTile(
                icon: FfAssetTypeTiles.iconFor(assetType),
                tone: FfTone.investment,
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: ff.text.title.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      assetType.displayName,
                      style: ff.text.labelSm.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              if (hasAmounts)
                FfBadge(
                  label:
                      '$returnSign${CurrencyFormatter.formatAmount(delta)} ($returnSign${pctReturn.toStringAsFixed(1)}%)',
                  tone: isGain ? FfTone.income : FfTone.error,
                  icon:
                      isGain
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valuation',
                style: ff.text.labelSm.copyWith(color: c.textSecondary),
              ),
              FfAmountText(
                amount: currentValue,
                size: FfAmountSize.md,
                style: FfAmountStyle.inline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
