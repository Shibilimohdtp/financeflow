import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import 'investments_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';

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
  }

  @override
  void dispose() {
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
    final theme = context.theme;
    final accountsAsync = ref.watch(allAccountsStreamProvider);

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
                title: isEditing ? 'Edit Holding' : 'Add Investment',
                subtitle: 'Manual on-device portfolio valuation',
              ),
              const Divider(height: 1, thickness: 1),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Asset Type
                        _SectionLabel(label: 'Asset Class'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        DropdownButtonFormField<AssetType>(
                          value: _assetType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceMd,
                              vertical: StillwaterTokens.spaceSm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusMd,
                              ),
                            ),
                          ),
                          items:
                              AssetType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _assetType = val);
                            }
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Holding Name
                        _SectionLabel(label: 'Holding / Asset Name'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Parag Parikh Flexi Cap, HDFC Bank Shares, SGB',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter holding name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Invested Amount & Current Valuation Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionLabel(label: 'Invested Cost'),
                                  const SizedBox(
                                    height: StillwaterTokens.spaceXs,
                                  ),
                                  TextFormField(
                                    controller: _purchasePriceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: '50000',
                                      prefixText:
                                          '${CurrencyFormatter.currencySymbol} ',
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: StillwaterTokens.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionLabel(label: 'Current Value'),
                                  const SizedBox(
                                    height: StillwaterTokens.spaceXs,
                                  ),
                                  TextFormField(
                                    controller: _currentValueController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: '55000',
                                      prefixText:
                                          '${CurrencyFormatter.currencySymbol} ',
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Purchase Date
                        _SectionLabel(label: 'Purchase Date'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceMd,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusMd,
                                ),
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                            ),
                            child: Text(
                              DateFormatter.formatTransactionDate(
                                _purchaseDate,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // More options
                        InkWell(
                          onTap:
                              () => setState(
                                () => _showAdvanced = !_showAdvanced,
                              ),
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: StillwaterTokens.spaceXs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showAdvanced
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: StillwaterTokens.spaceXs),
                                Text(
                                  _showAdvanced
                                      ? 'Hide units, account & notes'
                                      : 'Units, Source Account & Notes (Optional)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showAdvanced) ...[
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          // Quantity / Units
                          TextFormField(
                            controller: _unitsController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Units / Quantity',
                              hintText: '1.0',
                            ),
                          ),

                          const SizedBox(height: StillwaterTokens.spaceMd),

                          // Linked Account
                          accountsAsync.when(
                            data: (accounts) {
                              final activeAccounts =
                                  accounts.where((a) => !a.isArchived).toList();
                              return DropdownButtonFormField<String>(
                                value: _selectedAccountId,
                                decoration: InputDecoration(
                                  labelText: 'Purchased From Account',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: StillwaterTokens.spaceMd,
                                    vertical: StillwaterTokens.spaceSm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusMd,
                                    ),
                                  ),
                                ),
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
                                    (val) => setState(
                                      () => _selectedAccountId = val,
                                    ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),

                          const SizedBox(height: StillwaterTokens.spaceMd),

                          // Notes
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText:
                                  'e.g. SIP started in 2024, Long term horizon',
                            ),
                          ),
                        ],
                        const SizedBox(height: StillwaterTokens.spaceMd),
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
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
