import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../dashboard/widgets/home_accounts_carousel.dart';
import 'accounts_controller.dart';

/// Opens the Add / Edit Financial Account bottom sheet.
Future<T?> showAddEditAccountSheet<T>(
  BuildContext context, {
  Account? account,
}) {
  return showFfSheet<T>(
    context,
    builder: (ctx) => AddEditAccountSheet(account: account),
  );
}

/// Bottom sheet for creating or updating a financial account.
class AddEditAccountSheet extends ConsumerStatefulWidget {
  final Account? account;

  const AddEditAccountSheet({super.key, this.account});

  @override
  ConsumerState<AddEditAccountSheet> createState() =>
      _AddEditAccountSheetState();
}

class _AddEditAccountSheetState extends ConsumerState<AddEditAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _institutionController;
  late final TextEditingController _maskedController;
  late final TextEditingController _openingBalanceController;
  late AccountType _selectedType;
  bool _isSaving = false;

  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _nameController = TextEditingController(text: acc?.name ?? '');
    _institutionController = TextEditingController(
      text: acc?.institutionName ?? '',
    );
    _maskedController = TextEditingController(
      text: acc?.maskedIdentifier ?? '',
    );
    _openingBalanceController = TextEditingController(
      text:
          acc != null
              ? (acc.openingBalance.truncateToDouble() == acc.openingBalance
                  ? acc.openingBalance.toInt().toString()
                  : acc.openingBalance.toString())
              : '0',
    );
    _selectedType = acc?.type ?? AccountType.bank;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _maskedController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final opening =
        CurrencyFormatter.parse(_openingBalanceController.text) ?? 0.0;
    final now = DateTime.now();

    final updatedAccount = Account(
      id: widget.account?.id ?? const Uuid().v4(),
      name: name,
      type: _selectedType,
      institutionName:
          _institutionController.text.trim().isNotEmpty
              ? _institutionController.text.trim()
              : null,
      maskedIdentifier:
          _maskedController.text.trim().isNotEmpty
              ? _maskedController.text.trim()
              : null,
      openingBalance: opening,
      currentBalance: widget.account?.currentBalance ?? opening,
      currency: 'INR',
      isArchived: widget.account?.isArchived ?? false,
      createdAt: widget.account?.createdAt ?? now,
      updatedAt: now,
    );

    await ref
        .read(accountsControllerProvider.notifier)
        .saveAccount(updatedAccount);

    if (mounted) {
      Navigator.of(context).pop();
      FfToast.show(
        context,
        message:
            isEditing
                ? 'Account updated on this device.'
                : 'Account created on this device.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Account' : 'Add Financial Account',
          subtitle: 'Stored 100% locally on device',
        ),
        const FfDivider(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.md,
              FfSpace.lg,
              FfSpace.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Type selector
                  Text(
                    'ACCOUNT TYPE',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.secondary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfSelect<AccountType>(
                    value: _selectedType,
                    items:
                        AccountType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  HomeAccountsCarousel.iconFor(type),
                                  size: 18,
                                  color: context.ff.color.secondary,
                                ),
                                const SizedBox(width: FfSpace.sm),
                                Text(type.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Account Name field
                  FfTextField(
                    controller: _nameController,
                    label: 'Account Name',
                    hint: 'e.g. HDFC Salary, Cash in Hand',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an account name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Opening Balance field
                  FfTextField(
                    controller: _openingBalanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    label: 'Opening Balance',
                    prefixText: '${CurrencyFormatter.currencySymbol} ',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter opening balance.';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Please enter a valid amount.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Optional Details (Institution & Masked ID)
                  FfTextField(
                    controller: _institutionController,
                    label: 'Institution Name (Optional)',
                    hint: 'e.g. HDFC Bank, SBI, ICICI, Zerodha',
                  ),

                  const SizedBox(height: FfSpace.lg),

                  FfTextField(
                    controller: _maskedController,
                    label: 'Masked Number / UPI ID (Optional)',
                    hint: 'e.g. •••• 4235, user@okhdfcbank',
                  ),

                  const SizedBox(height: FfSpace.md),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: isEditing ? 'Save Changes' : 'Add Account',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _save,
        ),
      ],
    );
  }
}
