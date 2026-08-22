import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'investments_controller.dart';

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

  @override
  void initState() {
    super.initState();
    final init = widget.initialInvestment;
    _nameController = TextEditingController(text: init?.name ?? '');
    _unitsController = TextEditingController(
      text: init != null ? init.quantityOrUnits.toString() : '1.0',
    );
    _purchasePriceController = TextEditingController(
      text: init != null ? init.purchasePrice.toStringAsFixed(2) : '',
    );
    _currentValueController = TextEditingController(
      text: init != null ? init.currentValue.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _assetType = init?.assetType ?? AssetType.mutualFunds;
    _purchaseDate = init?.purchaseDate ?? DateTime.now();
    _selectedAccountId = init?.accountId;
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
    final picked = await showDatePicker(
      context: context,
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
    final price = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
    final currentVal =
        double.tryParse(_currentValueController.text.trim()) ?? (price * units);

    if (name.isEmpty || price < 0 || currentVal < 0) {
      FfSnackbar.show(
        context,
        message: 'Please enter valid investment information.',
      );
      return;
    }

    final controller = ref.read(investmentsControllerProvider.notifier);

    if (widget.initialInvestment != null) {
      final updated = widget.initialInvestment!.copyWith(
        name: name,
        assetType: _assetType,
        accountId: _selectedAccountId,
        quantityOrUnits: units,
        purchasePrice: price,
        purchaseDate: _purchaseDate,
        currentValue: currentVal,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
      await controller.updateInvestment(updated);
    } else {
      await controller.addInvestment(
        name: name,
        assetType: _assetType,
        accountId: _selectedAccountId,
        quantityOrUnits: units,
        purchasePrice: price,
        purchaseDate: _purchaseDate,
        currentValue: currentVal,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      FfSnackbar.show(
        context,
        message:
            widget.initialInvestment != null
                ? 'Investment updated.'
                : 'Investment added.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: StillwaterTokens.spaceLg,
        right: StillwaterTokens.spaceLg,
        top: StillwaterTokens.spaceLg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialInvestment != null
                        ? 'Edit Investment'
                        : 'Add Investment',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),

              // Asset Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset / Fund Name',
                  hintText:
                      'e.g. Parag Parikh Flexi Cap, HDFC Bank, Sovereign Gold',
                  prefixIcon: Icon(Icons.show_chart_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Asset Type Selector
              DropdownButtonFormField<AssetType>(
                value: _assetType,
                decoration: const InputDecoration(
                  labelText: 'Asset Category',
                  prefixIcon: Icon(Icons.pie_chart_outline_rounded),
                ),
                items:
                    AssetType.values.map((at) {
                      return DropdownMenuItem(
                        value: at,
                        child: Text(at.displayName),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _assetType = val);
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Quantity / Units & Purchase Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Units / Qty',
                        hintText: 'e.g. 100',
                      ),
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: FfAmountField(
                      controller: _purchasePriceController,
                      labelText: 'Purchase Price (₹)',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Current Value (User entered)
              FfAmountField(
                controller: _currentValueController,
                labelText: 'Current Market Value (₹)',
                hintText: 'As entered by you',
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Purchase Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.event_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Purchase Date'),
                subtitle: Text(DateFormatter.formatFullDate(_purchaseDate)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _selectDate,
              ),

              const Divider(),

              // Linked Account
              DropdownButtonFormField<String?>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Broker / Investment Account (Optional)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None / Unlinked'),
                  ),
                  ...accounts.map(
                    (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Honest Pricing Disclosure
              FfCard(
                variant: FfCardVariant.tinted,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'Values stay as entered by you. FinanceFlow does not fetch live market prices.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              FfButton(
                label:
                    widget.initialInvestment != null
                        ? 'Save Investment'
                        : 'Add Investment',
                onPressed: _save,
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
