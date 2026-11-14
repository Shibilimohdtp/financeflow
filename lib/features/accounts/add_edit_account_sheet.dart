import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_account_preview_card.dart';
import '../../shared/widgets/ff_account_type_tiles.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_field_label.dart';
import '../../shared/widgets/ff_disclosure_row.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
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
        text: FfAmountField.formatInput(balanceVal),
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
    _ => 'Opening balance',
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
            newArchived ? 'Account archived.' : 'Account restored to active.',
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

    // Dynamic CTA label: says what is missing while the CTA cannot work.
    String primaryLabel;
    if (trimmedName.isEmpty) {
      primaryLabel = 'Enter account name';
    } else if (isEditing) {
      primaryLabel = 'Save changes';
    } else {
      primaryLabel = 'Add account';
    }

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit account' : 'New account',
          subtitle: 'Where your money is kept',
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
                  // ── Live preview (archetype B; the account keeps its
                  //    gradient as a miniature of the Home account hero) ──
                  FfAccountPreviewCard(
                    accountType: _selectedType,
                    name: _nameController.text,
                    institutionName: _institutionController.text,
                    maskedIdentifier: _maskedController.text,
                    balance: previewBalance,
                    balanceLabel: balanceLabel,
                    isPrivacyBlur: isPrivacyBlur,
                  ),
                  const SizedBox(height: FfSheetTokens.groupGap),

                  // ── Type ─────────────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Account type',
                    children: [
                      FfAccountTypeTiles(
                        selectedType: _selectedType,
                        onChanged:
                            (newType) =>
                                setState(() => _selectedType = newType),
                      ),
                    ],
                  ),

                  // ── Name and balance ─────────────────────────────────────
                  FfSheetGroup(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FfTextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            label: 'Account name',
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
                          if (hasDuplicateName) ...[
                            const SizedBox(height: FfSpace.xs),
                            FfConsequenceLine(
                              text:
                                  'An active account with this name already exists',
                              icon: Icons.warning_amber_rounded,
                              tone: FfTone.warning,
                            ),
                          ],
                        ],
                      ),
                      FfAmountField(
                        controller: _openingBalanceController,
                        focusNode: _balanceFocusNode,
                        label: _balanceLabelForType(_selectedType),
                        helper: _balanceHelperForType(_selectedType),
                        size: FfAmountSize.lg,
                        groupDigits: true,
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter opening balance.';
                          }
                          if (FfAmountField.parse(val) == null) {
                            return 'Please enter a valid amount.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  // ── More details ─────────────────────────────────────────
                  FfDisclosureRow(
                    title: 'Bank and identifier details (optional)',
                    subtitle: 'Bank name and the last 4 digits',
                    initiallyExpanded: _showDetails,
                    onExpansionChanged: (v) => _showDetails = v,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FfFieldLabel('Common institutions'),
                          const SizedBox(height: FfSheetTokens.labelGap),
                          Wrap(
                            spacing: FfChipTokens.gap,
                            runSpacing: FfChipTokens.gap,
                            children: [
                              for (final inst in _kSuggestedInstitutions)
                                FfChip(
                                  label: inst,
                                  isSelected:
                                      _institutionController.text
                                          .trim()
                                          .toLowerCase() ==
                                      inst.toLowerCase(),
                                  onSelected:
                                      () => _onInstitutionChipSelected(inst),
                                ),
                            ],
                          ),
                        ],
                      ),
                      FfTextField(
                        controller: _institutionController,
                        label: 'Institution name (optional)',
                        hint: 'e.g. HDFC Bank, SBI, Zerodha',
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      FfTextField(
                        controller: _maskedController,
                        label: 'Last 4 digits or UPI ID (optional)',
                        hint:
                            _selectedType == AccountType.upi
                                ? 'e.g. user@okhdfcbank'
                                : 'e.g. •••• 4235',
                        helper:
                            showMaskedLengthWarning
                                ? 'Only 4 digits are needed for privacy.'
                                : 'Last 4 digits only, never enter the full card or account number.',
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),

                  // ── Edit-mode note and actions (end of the body) ─────────
                  if (isEditing) ...[
                    const SizedBox(height: FfSheetTokens.groupGap),
                    const FfConsequenceLine(
                      text:
                          'Editing the opening balance shifts your baseline balance without changing past transaction records.',
                      icon: Icons.info_outline_rounded,
                      tone: FfTone.neutral,
                    ),
                    const SizedBox(height: FfSheetTokens.itemGap),
                    FfGroupedContainer(
                      children: [
                        FfRow(
                          title:
                              widget.account!.isArchived
                                  ? 'Restore account'
                                  : 'Archive account',
                          icon:
                              widget.account!.isArchived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                          onTap: _archiveOrRestore,
                        ),
                        FfRow(
                          title: 'Delete account',
                          icon: Icons.delete_outline_rounded,
                          destructive: true,
                          onTap: _delete,
                        ),
                      ],
                    ),
                  ],
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
