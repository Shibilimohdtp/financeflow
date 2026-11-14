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
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_disclosure_row.dart';
import '../../shared/widgets/ff_entity_preview_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
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
      text: init != null ? FfAmountField.formatInput(init.purchasePrice) : '',
    );
    _currentValueController = TextEditingController(
      text: init != null ? FfAmountField.formatInput(init.currentValue) : '',
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
      consequence =
          'Enter what you paid and what it is worth to see the return.';
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

    final displayName =
        _nameController.text.trim().isEmpty
            ? 'New holding'
            : _nameController.text.trim();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit holding' : 'New holding',
          subtitle: "Something you've invested in, valued by you",
        ),
        Flexible(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: FfSheetBody.standardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Live preview (archetype B) ───────────────────────────
                  FfEntityPreviewCard(
                    leading: FfEntityPreviewCard.disc(
                      context,
                      FfHeroTone.dusk,
                      FfAssetTypeTiles.iconFor(_assetType),
                    ),
                    title: displayName,
                    subtitle: _assetType.displayName,
                    figureCaption: 'Value',
                    figure: FfAmountText(
                      amount: currentVal,
                      size: FfAmountSize.lg,
                      style: FfAmountStyle.split,
                      tone: FfTone.neutral,
                      showSign: false,
                    ),
                    status:
                        hasAmounts
                            ? FfBadge(
                              label:
                                  '$returnSign${pctReturn.toStringAsFixed(1)}%',
                              tone: isGain ? FfTone.income : FfTone.error,
                              icon:
                                  isGain
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                            )
                            : null,
                    semanticLabel:
                        'Preview: $displayName, ${_assetType.displayName}, '
                        'value ${CurrencyFormatter.formatAmount(currentVal)}'
                        '${hasAmounts ? ', return $returnSign${pctReturn.toStringAsFixed(1)} percent' : ''}',
                  ),
                  const SizedBox(height: FfSheetTokens.groupGap),

                  // ── Asset class ──────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Asset class',
                    children: [
                      FfAssetTypeTiles(
                        selectedType: _assetType,
                        onChanged: (type) => setState(() => _assetType = type),
                      ),
                    ],
                  ),

                  // ── Name and amounts ─────────────────────────────────────
                  FfSheetGroup(
                    children: [
                      FfTextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        label: 'Holding name',
                        hint: 'e.g. Parag Parikh Flexi Cap, SGB 2024',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter holding name';
                          }
                          return null;
                        },
                      ),
                      FfAmountField(
                        controller: _purchasePriceController,
                        label: 'Purchase price (per unit)',
                        size: FfAmountSize.md,
                        tone: FfTone.neutral,
                        groupDigits: true,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      FfAmountField(
                        controller: _currentValueController,
                        label: 'Current value',
                        size: FfAmountSize.md,
                        tone: FfTone.investment,
                        groupDigits: true,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
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
                    ],
                  ),

                  // ── Purchase date ────────────────────────────────────────
                  FfSheetGroup(
                    children: [
                      FfGroupedContainer(
                        children: [
                          FfRow(
                            icon: Icons.calendar_today_outlined,
                            title: 'Purchase date',
                            detail: DateFormatter.formatShortDate(
                              _purchaseDate,
                            ),
                            showChevron: true,
                            onTap: _selectDate,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ── More details ─────────────────────────────────────────
                  FfDisclosureRow(
                    subtitle: 'Units, account and a note',
                    initiallyExpanded: _showAdvanced,
                    onExpansionChanged: (v) => _showAdvanced = v,
                    children: [
                      FfTextField(
                        controller: _unitsController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        label: 'Units',
                        hint: '1',
                      ),
                      accountsAsync.when(
                        data: (accounts) {
                          final activeAccounts =
                              accounts.where((a) => !a.isArchived).toList();
                          return FfSelect<String?>(
                            value: _selectedAccountId,
                            label: 'Paid from account (optional)',
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
                                (val) =>
                                    setState(() => _selectedAccountId = val),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      FfTextField(
                        controller: _notesController,
                        maxLines: 2,
                        label: 'Notes (optional)',
                        hint: 'e.g. SIP started in 2024',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: isEditing ? 'Save changes' : 'Add holding',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
