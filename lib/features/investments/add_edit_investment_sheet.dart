import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import 'investments_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../theme/ff.dart';

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
    final accountsAsync = ref.watch(allAccountsStreamProvider);

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
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset Type
                  _SectionLabel(label: 'Asset Class'),
                  const SizedBox(height: FfSpace.xs),
                  FfSelect<AssetType>(
                    value: _assetType,
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

                  const SizedBox(height: FfSpace.lg),

                  // Holding Name
                  _SectionLabel(label: 'Holding / Asset Name'),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    hint: 'e.g. Parag Parikh Flexi Cap, HDFC Bank Shares, SGB',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter holding name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Invested Amount & Current Valuation Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(label: 'Invested Cost'),
                            const SizedBox(height: FfSpace.xs),
                            FfTextField(
                              controller: _purchasePriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              hint: '50000',
                              prefixText:
                                  '${CurrencyFormatter.currencySymbol} ',
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
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(label: 'Current Value'),
                            const SizedBox(height: FfSpace.xs),
                            FfTextField(
                              controller: _currentValueController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              hint: '55000',
                              prefixText:
                                  '${CurrencyFormatter.currencySymbol} ',
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

                  const SizedBox(height: FfSpace.lg),

                  // Purchase Date
                  _SectionLabel(label: 'Purchase Date'),
                  const SizedBox(height: FfSpace.xs),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.md,
                          vertical: FfSpace.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FfRadius.md),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                      ),
                      child: Text(
                        DateFormatter.formatTransactionDate(_purchaseDate),
                        style: context.ff.text.body,
                      ),
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // More options
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
                            color: context.ff.color.secondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Text(
                            _showAdvanced
                                ? 'Hide units, account & notes'
                                : 'Units, Source Account & Notes (Optional)',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.actionPrimary,
                              fontWeight: FontWeight.w500,
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
                        return FfSelect<String>(
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
                  const SizedBox(height: FfSpace.md),
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
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
