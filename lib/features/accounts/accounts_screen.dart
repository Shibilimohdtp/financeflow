import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../settings/settings_controller.dart';
import 'accounts_controller.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  void _showAddEditAccountDialog(
    BuildContext context, [
    Account? account,
  ]) {
    final isEditing = account != null;
    final nameController = TextEditingController(text: account?.name ?? '');
    final institutionController = TextEditingController(
      text: account?.institutionName ?? '',
    );
    final maskedController = TextEditingController(
      text: account?.maskedIdentifier ?? '',
    );
    final openingBalanceController = TextEditingController(
      text:
          account != null
              ? (account.openingBalance.truncateToDouble() ==
                      account.openingBalance
                  ? account.openingBalance.toInt().toString()
                  : account.openingBalance.toString())
              : '0',
    );
    AccountType selectedType = account?.type ?? AccountType.bank;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: StillwaterTokens.spaceLg,
                right: StillwaterTokens.spaceLg,
                top: StillwaterTokens.spaceLg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    StillwaterTokens.spaceLg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Account' : 'Add Financial Account',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceLg),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                        hintText: 'e.g. HDFC Salary, SBI Savings, Main Cash',
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    DropdownButtonFormField<AccountType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                      ),
                      items:
                          AccountType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    TextField(
                      controller: institutionController,
                      decoration: const InputDecoration(
                        labelText: 'Institution / Provider Name (Optional)',
                        hintText: 'e.g. HDFC Bank, Google Pay, Paytm',
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    TextField(
                      controller: maskedController,
                      decoration: const InputDecoration(
                        labelText: 'Masked Identifier (Optional)',
                        hintText: 'e.g. ••4321',
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    TextField(
                      controller: openingBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Opening Balance (₹)',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xl),
                    Row(
                      children: [
                        Expanded(
                          child: FfButton(
                            label: 'Cancel',
                            variant: FfButtonVariant.outlined,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceMd),
                        Expanded(
                          child: FfButton(
                            label: isEditing ? 'Update' : 'Add Account',
                            onPressed: () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                FfSnackbar.show(
                                  context,
                                  message: 'Please enter account name.',
                                );
                                return;
                              }

                              final opening =
                                  CurrencyFormatter.parse(
                                    openingBalanceController.text,
                                  ) ??
                                  0.0;

                              final now = DateTime.now();
                              final newAccount = Account(
                                id: account?.id ?? const Uuid().v4(),
                                name: name,
                                type: selectedType,
                                institutionName:
                                    institutionController.text.trim().isNotEmpty
                                        ? institutionController.text.trim()
                                        : null,
                                maskedIdentifier:
                                    maskedController.text.trim().isNotEmpty
                                        ? maskedController.text.trim()
                                        : null,
                                openingBalance: opening,
                                currentBalance:
                                    account?.currentBalance ?? opening,
                                currency: 'INR',
                                isArchived: account?.isArchived ?? false,
                                createdAt: account?.createdAt ?? now,
                                updatedAt: now,
                              );

                              await ref
                                  .read(accountsControllerProvider.notifier)
                                  .saveAccount(newAccount);

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                FfSnackbar.show(
                                  context,
                                  message:
                                      isEditing
                                          ? 'Account updated on this device.'
                                          : 'Account created on this device.',
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Account',
            onPressed: () => _showAddEditAccountDialog(context),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (allAccounts) {
          final activeAccounts =
              allAccounts.where((a) => !a.isArchived).toList();
          final archivedAccounts =
              allAccounts.where((a) => a.isArchived).toList();
          final displayAccounts =
              _showArchived ? archivedAccounts : activeAccounts;

          return Column(
            children: [
              // Segmented Active / Archived Tab
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceSm,
                ),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text('Active (${activeAccounts.length})'),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Archived (${archivedAccounts.length})'),
                    ),
                  ],
                  selected: {_showArchived},
                  onSelectionChanged: (set) {
                    setState(() {
                      _showArchived = set.first;
                    });
                  },
                ),
              ),
              Expanded(
                child:
                    displayAccounts.isEmpty
                        ? FfEmptyState(
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
                                  ? 'Accounts you archive will be stored here safely.'
                                  : 'Create a local bank account or cash wallet to begin.',
                          actionLabel: _showArchived ? null : 'Add Account',
                          onAction:
                              _showArchived
                                  ? null
                                  : () => _showAddEditAccountDialog(context),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.all(
                            StillwaterTokens.spaceLg,
                          ),
                          itemCount: displayAccounts.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(
                                height: StillwaterTokens.spaceSm,
                              ),
                          itemBuilder: (context, index) {
                            final account = displayAccounts[index];
                            return FfCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getAccountIcon(account.type),
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(
                                            width: StillwaterTokens.spaceXs,
                                          ),
                                          Text(
                                            account.name,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          if (account.isArchived) ...[
                                            const SizedBox(
                                              width: StillwaterTokens.space2Xs,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.outline
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Archived',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                          size: 20,
                                        ),
                                        onSelected: (action) async {
                                          if (action == 'edit') {
                                            _showAddEditAccountDialog(
                                              context,
                                              account,
                                            );
                                          } else if (action == 'archive') {
                                            await ref
                                                .read(
                                                  accountsControllerProvider
                                                      .notifier,
                                                )
                                                .archiveAccount(
                                                  account.id,
                                                  !account.isArchived,
                                                );
                                            if (context.mounted) {
                                              FfSnackbar.show(
                                                context,
                                                message:
                                                    account.isArchived
                                                        ? 'Account unarchived.'
                                                        : 'Account archived.',
                                              );
                                            }
                                          } else if (action == 'delete') {
                                            final confirmed =
                                                await FfConfirmDialog.show(
                                                  context,
                                                  title: 'Delete Account?',
                                                  message:
                                                      'Are you sure you want to delete ${account.name}? This will remove the account from this device.',
                                                  confirmLabel: 'Delete',
                                                  isDestructive: true,
                                                );
                                            if (confirmed == true &&
                                                context.mounted) {
                                              await ref
                                                  .read(
                                                    accountsControllerProvider
                                                        .notifier,
                                                  )
                                                  .deleteAccount(account.id);
                                              if (context.mounted) {
                                                FfSnackbar.show(
                                                  context,
                                                  message:
                                                      'Account deleted from this device.',
                                                );
                                              }
                                            }
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit Account'),
                                              ),
                                              PopupMenuItem(
                                                value: 'archive',
                                                child: Text(
                                                  account.isArchived
                                                      ? 'Unarchive Account'
                                                      : 'Archive Account',
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color:
                                                        theme.colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    account.displaySubtitle,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(
                                    height: StillwaterTokens.spaceMd,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Opening: ${CurrencyFormatter.format(account.openingBalance)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                            ),
                                      ),
                                      FfAmountText(
                                        amount: account.currentBalance,
                                        size: FfAmountSize.md,
                                        isBlurred: isPrivacyBlur,
                                        showSign: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.cash:
        return Icons.wallet_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.upi:
        return Icons.phone_android_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.business:
        return Icons.store_rounded;
    }
  }
}
