import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../settings/settings_controller.dart';
import 'accounts_controller.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  void _showAddEditAccountSheet(BuildContext context, [Account? account]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEditAccountSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accountsAsync = ref.watch(accountsWithBalancesProvider);
    final settings = ref.watch(settingsStreamProvider).value;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Accounts'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'accounts_fab',
        tooltip: 'Add account',
        onPressed: () => _showAddEditAccountSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add account'),
      ),
      body: accountsAsync.when(
        data: (allAccounts) {
          final activeAccounts =
              allAccounts.where((a) => !a.isArchived).toList();
          final archivedAccounts =
              allAccounts.where((a) => a.isArchived).toList();
          final displayAccounts =
              _showArchived ? archivedAccounts : activeAccounts;
          final visibleBalance = activeAccounts.fold<double>(
            0,
            (total, account) => total + account.currentBalance,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              StillwaterTokens.spaceLg,
              StillwaterTokens.spaceMd,
              StillwaterTokens.spaceLg,
              104,
            ),
            children: [
              // ── 1. Total Net Balance Hero ────────────────────────────────
              if (!_showArchived) ...[
                FfCard(
                  variant: FfCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NET FINANCIAL BALANCE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPrivacyBlur
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: theme.colorScheme.secondary,
                            ),
                            tooltip:
                                isPrivacyBlur ? 'Show balance' : 'Hide balance',
                            onPressed: () {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .setPrivacyBlurEnabled(!isPrivacyBlur);
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      if (isPrivacyBlur)
                        Text(
                          '₹ ••••••',
                          style: StillwaterTypography.numHero(
                            color: theme.colorScheme.onSurface,
                          ),
                        )
                      else
                        Text(
                          CurrencyFormatter.formatINR(visibleBalance),
                          style: StillwaterTypography.numHero(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Text(
                        'Across ${activeAccounts.length} active on-device ${activeAccounts.length == 1 ? 'account' : 'accounts'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
              ],

              // ── 2. Segmented Pill Tab Bar ────────────────────────────────
              FfSegmentedPill<bool>(
                options: [
                  FfSegmentOption(
                    value: false,
                    label: 'Active (${activeAccounts.length})',
                  ),
                  FfSegmentOption(
                    value: true,
                    label: 'Archived (${archivedAccounts.length})',
                  ),
                ],
                selectedValue: _showArchived,
                onSelected: (val) {
                  setState(() {
                    _showArchived = val;
                  });
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 3. Accounts List Section ─────────────────────────────────
              FfSectionHeader(
                title: _showArchived ? 'Archived Accounts' : 'Active Accounts',
              ),

              if (displayAccounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.space2Xl,
                  ),
                  child: FfEmptyState(
                    icon:
                        _showArchived
                            ? Icons.archive_outlined
                            : Icons.account_balance_wallet_outlined,
                    title:
                        _showArchived
                            ? 'No archived accounts'
                            : 'No active accounts',
                    description:
                        _showArchived
                            ? 'Accounts you archive will be stored here safely without affecting active balances.'
                            : 'Create a local bank account, cash wallet, or card to track balances on-device.',
                    actionLabel: _showArchived ? null : 'Add Account',
                    onAction:
                        _showArchived
                            ? null
                            : () => _showAddEditAccountSheet(context),
                  ),
                )
              else
                FfGroupedContainer(
                  children:
                      displayAccounts.map((acc) {
                        final typeLabel = acc.type.displayName;
                        final institution = acc.institutionName;
                        final masked = acc.maskedIdentifier;

                        final subtitleParts = <String>[];
                        if (institution != null && institution.isNotEmpty) {
                          subtitleParts.add(institution);
                        } else {
                          subtitleParts.add(typeLabel);
                        }
                        if (masked != null && masked.isNotEmpty) {
                          subtitleParts.add(masked);
                        }
                        if (_showArchived) {
                          subtitleParts.add('Archived');
                        }

                        return FfListRow(
                          leading: Container(
                            width: StillwaterTokens.iconTileSize,
                            height: StillwaterTokens.iconTileSize,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusSm,
                              ),
                            ),
                            child: Icon(
                              _getAccountTypeIcon(acc.type),
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: acc.name,
                          subtitle: subtitleParts.join(' · '),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (acc.isArchived)
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: StillwaterTokens.spaceSm,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: StillwaterTokens.spaceSm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    'Archived',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              FfAmountText(
                                amount: acc.currentBalance,
                                size: FfAmountSize.md,
                                showSign: false,
                                isBlurred: isPrivacyBlur,
                              ),
                              const SizedBox(width: StillwaterTokens.spaceXs),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                onSelected: (val) async {
                                  if (val == 'edit') {
                                    _showAddEditAccountSheet(context, acc);
                                  } else if (val == 'archive') {
                                    await ref
                                        .read(
                                          accountsControllerProvider.notifier,
                                        )
                                        .archiveAccount(
                                          acc.id,
                                          !acc.isArchived,
                                        );
                                    if (context.mounted) {
                                      FfSnackbar.show(
                                        context,
                                        message:
                                            acc.isArchived
                                                ? 'Account restored to active.'
                                                : 'Account archived.',
                                      );
                                    }
                                  } else if (val == 'delete') {
                                    final confirmed = await FfConfirmDialog.show(
                                      context,
                                      title: 'Delete Account?',
                                      message:
                                          'Are you sure you want to permanently delete "${acc.name}" from this device?',
                                      confirmLabel: 'Delete',
                                      isDestructive: true,
                                    );
                                    if (confirmed == true && context.mounted) {
                                      await ref
                                          .read(
                                            accountsControllerProvider.notifier,
                                          )
                                          .deleteAccount(acc.id);
                                      if (context.mounted) {
                                        FfSnackbar.show(
                                          context,
                                          message: 'Account deleted.',
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder:
                                    (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Details'),
                                      ),
                                      PopupMenuItem(
                                        value: 'archive',
                                        child: Text(
                                          acc.isArchived
                                              ? 'Restore Account'
                                              : 'Archive Account',
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Delete Account',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          onTap: () => _showAddEditAccountSheet(context, acc),
                          showChevron: false,
                        );
                      }).toList(),
                ),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: CircularProgressIndicator(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.creditCard:
        return Icons.credit_card_outlined;
      case AccountType.upi:
        return Icons.qr_code_rounded;
      case AccountType.investment:
        return Icons.show_chart_rounded;
      case AccountType.business:
        return Icons.storefront_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Account Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddEditAccountSheet extends ConsumerStatefulWidget {
  final Account? account;
  const _AddEditAccountSheet({this.account});

  @override
  ConsumerState<_AddEditAccountSheet> createState() =>
      _AddEditAccountSheetState();
}

class _AddEditAccountSheetState extends ConsumerState<_AddEditAccountSheet> {
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
      FfSnackbar.show(
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
    final theme = context.theme;

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
                title: isEditing ? 'Edit Account' : 'Add Financial Account',
                subtitle: 'Stored 100% locally on device',
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Type selector
                        Text(
                          'ACCOUNT TYPE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        DropdownButtonFormField<AccountType>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceMd,
                              vertical: StillwaterTokens.spaceSm,
                            ),
                          ),
                          items:
                              AccountType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _AccountsScreenState._getAccountTypeIcon(
                                          type,
                                        ),
                                        size: 18,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(
                                        width: StillwaterTokens.spaceSm,
                                      ),
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

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Account Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Account Name',
                            hintText: 'e.g. HDFC Salary, Cash in Hand',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter an account name.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Opening Balance field
                        TextFormField(
                          controller: _openingBalanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Opening Balance (₹)',
                            prefixText: '₹ ',
                          ),
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

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Optional Details (Institution & Masked ID)
                        TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            labelText: 'Institution Name (Optional)',
                            hintText: 'e.g. HDFC Bank, SBI, ICICI, Zerodha',
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        TextFormField(
                          controller: _maskedController,
                          decoration: const InputDecoration(
                            labelText: 'Masked Number / UPI ID (Optional)',
                            hintText: 'e.g. •••• 4235, user@okhdfcbank',
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceMd),
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
          ),
        ),
      ),
    );
  }
}
