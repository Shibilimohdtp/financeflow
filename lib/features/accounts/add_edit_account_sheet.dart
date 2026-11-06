import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_account_preview_card.dart';
import '../../shared/widgets/ff_account_type_tiles.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../settings/settings_controller.dart';
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

/// Common Indian banking institutions, wallets, and brokers for fast autofill.
const List<String> _kSuggestedInstitutions = [
  'HDFC',
  'SBI',
  'ICICI',
  'Axis',
  'Kotak',
  'Zerodha',
  'Groww',
  'PhonePe',
];

/// Stillwater Bloom Add / Edit Financial Account bottom sheet.
class AddEditAccountSheet extends ConsumerStatefulWidget {
  final Account? account;

  const AddEditAccountSheet({super.key, this.account});

  @override
  ConsumerState<AddEditAccountSheet> createState() =>
      _AddEditAccountSheetState();
}

class _AddEditAccountSheetState extends ConsumerState<AddEditAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _balanceFocusNode = FocusNode();

  late final TextEditingController _nameController;
  late final TextEditingController _institutionController;
  late final TextEditingController _maskedController;
  late final TextEditingController _openingBalanceController;
  late AccountType _selectedType;

  bool _isSaving = false;
  bool _showDetails = false;

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

    if (acc != null) {
      final balanceVal =
          acc.type == AccountType.creditCard
              ? acc.openingBalance.abs()
              : acc.openingBalance;
      _openingBalanceController = TextEditingController(
        text:
            balanceVal.truncateToDouble() == balanceVal
                ? balanceVal.toInt().toString()
                : balanceVal.toString(),
      );
    } else {
      _openingBalanceController = TextEditingController(text: '0');
    }

    _selectedType = acc?.type ?? AccountType.bank;

    // Expand details disclosure if editing an account with details
    _showDetails =
        isEditing &&
        ((acc?.institutionName != null && acc!.institutionName!.isNotEmpty) ||
            (acc?.maskedIdentifier != null &&
                acc!.maskedIdentifier!.isNotEmpty));
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _balanceFocusNode.dispose();
    _nameController.dispose();
    _institutionController.dispose();
    _maskedController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  String _nameHintForType(AccountType type) => switch (type) {
    AccountType.bank => 'e.g. HDFC Salary, SBI Savings',
    AccountType.cash => 'e.g. Wallet, Pocket Cash',
    AccountType.upi => 'e.g. PhonePe UPI, Google Pay',
    AccountType.creditCard => 'e.g. ICICI Amazon Card',
    AccountType.investment => 'e.g. Zerodha, Groww',
    AccountType.business => 'e.g. Shop Account, Current Acc',
  };

  String _balanceLabelForType(AccountType type) => switch (type) {
    AccountType.creditCard => 'Current balance owed',
    AccountType.investment => 'Opening portfolio value',
    _ => 'Opening Balance',
  };

  String _balanceHelperForType(AccountType type) => switch (type) {
    AccountType.creditCard => 'Outstanding debt you currently owe to the bank',
    AccountType.investment => 'Current value of holdings in this account',
    _ => 'Starting balance when setting up this account',
  };

  void _onInstitutionChipSelected(String inst) {
    setState(() {
      _institutionController.text = inst;
      if (_nameController.text.trim().isEmpty) {
        final suffix = switch (_selectedType) {
          AccountType.creditCard => 'Card',
          AccountType.investment => 'Invest',
          AccountType.upi => 'UPI',
          AccountType.business => 'Business',
          _ => 'Savings',
        };
        _nameController.text = '$inst $suffix';
      }
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _nameFocusNode.requestFocus();
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    var opening =
        CurrencyFormatter.parse(_openingBalanceController.text) ?? 0.0;
    if (_selectedType == AccountType.creditCard && opening > 0) {
      opening = -opening;
    }

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
      Navigator.of(context).pop(updatedAccount.id);
      FfToast.show(
        context,
        message:
            isEditing
                ? 'Account updated on this device.'
                : 'Account created on this device.',
      );
    }
  }

  Future<void> _archiveOrRestore() async {
    final acc = widget.account;
    if (acc == null) return;
    final newArchived = !acc.isArchived;
    await ref
        .read(accountsControllerProvider.notifier)
        .archiveAccount(acc.id, newArchived);
    if (mounted) {
      Navigator.of(context).pop();
      FfToast.show(
        context,
        message:
            newArchived
                ? 'Account archived.'
                : 'Account restored to active.',
      );
    }
  }

  Future<void> _delete() async {
    final acc = widget.account;
    if (acc == null) return;
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Account?',
      message:
          'Are you sure you want to permanently delete "${acc.name}" from this device?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed == true && mounted) {
      await ref.read(accountsControllerProvider.notifier).deleteAccount(acc.id);
      if (mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Account deleted.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final isPrivacyBlur =
        ref.watch(settingsStreamProvider).value?.isPrivacyBlurEnabled ?? false;
    final accountsList =
        ref.watch(accountsWithBalancesProvider).valueOrNull ?? const [];

    final rawBalance =
        CurrencyFormatter.parse(_openingBalanceController.text) ?? 0.0;
    final double previewBalance;
    final String? balanceLabel;
    if (isEditing) {
      previewBalance = widget.account!.currentBalance;
      balanceLabel = 'Current balance';
    } else {
      previewBalance =
          _selectedType == AccountType.creditCard ? -rawBalance : rawBalance;
      balanceLabel = null;
    }

    final trimmedName = _nameController.text.trim();
    final hasDuplicateName =
        trimmedName.isNotEmpty &&
        accountsList.any(
          (a) =>
              a.id != widget.account?.id &&
              !a.isArchived &&
              a.name.trim().toLowerCase() == trimmedName.toLowerCase(),
        );

    final maskedText = _maskedController.text.trim();
    final showMaskedLengthWarning =
        _selectedType != AccountType.upi &&
        !maskedText.contains('@') &&
        maskedText.length > 4;

    // Dynamic CTA label
    String primaryLabel;
    if (trimmedName.isEmpty) {
      primaryLabel = 'Enter account name';
    } else if (isEditing) {
      primaryLabel = 'Save Changes';
    } else {
      primaryLabel = 'Add Account';
    }

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Account' : 'Add Financial Account',
          subtitle: 'Stored 100% locally on device',
        ),
        Flexible(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.sm,
              FfSpace.lg,
              FfSpace.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Live Account Preview Card ─────────────────────────────
                  FfAccountPreviewCard(
                    accountType: _selectedType,
                    name: _nameController.text,
                    institutionName: _institutionController.text,
                    maskedIdentifier: _maskedController.text,
                    balance: previewBalance,
                    balanceLabel: balanceLabel,
                    isPrivacyBlur: isPrivacyBlur,
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 2. Account Type Selector Grid ────────────────────────────
                  Text(
                    'Account type',
                    style: ff.text.label.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.sm),
                  FfAccountTypeTiles(
                    selectedType: _selectedType,
                    onChanged: (newType) {
                      setState(() {
                        _selectedType = newType;
                      });
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 3. Account Name ──────────────────────────────────────────
                  FfTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    label: 'Account Name',
                    hint: _nameHintForType(_selectedType),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an account name.';
                      }
                      return null;
                    },
                  ),

                  // Duplicate name soft warning
                  if (hasDuplicateName) ...[
                    const SizedBox(height: FfSpace.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: c.statusWarning,
                        ),
                        const SizedBox(width: FfSpace.xs),
                        Expanded(
                          child: Text(
                            'An active account with this name already exists',
                            style: ff.text.labelSm.copyWith(
                              color: c.statusWarning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: FfSpace.lg),

                  // ── 4. Balance Entry (FfAmountField) ─────────────────────────
                  FfAmountField(
                    controller: _openingBalanceController,
                    focusNode: _balanceFocusNode,
                    label: _balanceLabelForType(_selectedType),
                    hint: '0',
                    size: FfAmountSize.lg,
                    onChanged: (_) => setState(() {}),
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
                  const SizedBox(height: FfSpace.xs),
                  Text(
                    _balanceHelperForType(_selectedType),
                    style: ff.text.labelSm.copyWith(color: c.textTertiary),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 5. Optional Details Disclosure ───────────────────────────
                  InkWell(
                    onTap: () {
                      setState(() => _showDetails = !_showDetails);
                    },
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: FfSpace.sm),
                      child: Row(
                        children: [
                          Icon(
                            _showDetails
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 20,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.sm),
                          Expanded(
                            child: Text(
                              'Bank and identifier details (optional)',
                              style: ff.text.titleSm.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showDetails) ...[
                    const SizedBox(height: FfSpace.sm),

                    // Institution suggestion chips
                    Text(
                      'Common institutions',
                      style: ff.text.labelSm.copyWith(color: c.textTertiary),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Wrap(
                      spacing: FfSpace.xs,
                      runSpacing: FfSpace.xs,
                      children: [
                        for (final inst in _kSuggestedInstitutions)
                          FfChip(
                            label: inst,
                            isSelected:
                                _institutionController.text
                                    .trim()
                                    .toLowerCase() ==
                                inst.toLowerCase(),
                            onSelected: () => _onInstitutionChipSelected(inst),
                          ),
                      ],
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Institution field
                    FfTextField(
                      controller: _institutionController,
                      label: 'Institution Name (Optional)',
                      hint: 'e.g. HDFC Bank, SBI, Zerodha',
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Masked identifier field
                    FfTextField(
                      controller: _maskedController,
                      label: 'Masked Number / UPI ID (Optional)',
                      hint:
                          _selectedType == AccountType.upi
                              ? 'e.g. user@okhdfcbank'
                              : 'e.g. •••• 4235',
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: FfSpace.xs),
                    Text(
                      'Last 4 digits only, never enter the full card or account number.',
                      style: ff.text.labelSm.copyWith(color: c.textTertiary),
                    ),

                    if (showMaskedLengthWarning) ...[
                      const SizedBox(height: FfSpace.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Expanded(
                            child: Text(
                              'Only 4 digits are needed for privacy.',
                              style: ff.text.labelSm.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // ── 6. Edit-Mode Actions & Baseline History Note ─────────────
                  if (isEditing) ...[
                    const SizedBox(height: FfSpace.lg),
                    Container(
                      padding: const EdgeInsets.all(FfSpace.md),
                      decoration: ShapeDecoration(
                        color: c.surfaceCard,
                        shape: FfShape.of(
                          FfRadius.md,
                          side: BorderSide(color: c.borderSubtle, width: 1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.sm),
                          Expanded(
                            child: Text(
                              'Editing the opening balance shifts your baseline balance without changing past transaction records.',
                              style: ff.text.bodySm.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FfSpace.lg),
                    Row(
                      children: [
                        Expanded(
                          child: FfButton(
                            label:
                                widget.account!.isArchived
                                    ? 'Restore account'
                                    : 'Archive account',
                            leadingIcon: Icon(
                              widget.account!.isArchived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              size: 18,
                            ),
                            variant: FfButtonVariant.secondary,
                            onPressed: _archiveOrRestore,
                          ),
                        ),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          child: FfButton(
                            label: 'Delete account',
                            leadingIcon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            variant: FfButtonVariant.destructive,
                            onPressed: _delete,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: FfSpace.md),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: primaryLabel,
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _save,
        ),
      ],
    );
  }
}
